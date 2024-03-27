package com.pinterest.secor.uploader;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Base64;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.oracle.bmc.ConfigFileReader;
import com.oracle.bmc.Region;
import com.oracle.bmc.auth.AuthenticationDetailsProvider;
import com.oracle.bmc.auth.ConfigFileAuthenticationDetailsProvider;
import com.oracle.bmc.auth.SimpleAuthenticationDetailsProvider;
import com.oracle.bmc.objectstorage.ObjectStorageClient;
import com.oracle.bmc.objectstorage.requests.PutObjectRequest;
import com.pinterest.secor.common.LogFilePath;
import com.pinterest.secor.common.SecorConfig;

public class OciUploadManager extends UploadManager {
    private static final Logger LOG = LoggerFactory.getLogger(OciUploadManager.class);

    private static final ExecutorService executor = Executors.newFixedThreadPool(256);

    private final ObjectStorageClient mClient;
    private final String mNamespace;
    private final String mBucket;
    private final String mPath;

    public OciUploadManager(SecorConfig config) {
        super(config);
        mNamespace = mConfig.getString("secor.oci.namespace");
        mBucket = mConfig.getString("secor.oci.bucket");
        mPath = mConfig.getString("secor.oci.path");
        Region region = Region.fromRegionCodeOrId(mConfig.getString("secor.oci.region", "us-ashburn-1"));
        AuthenticationDetailsProvider provider;
        try {
            LOG.info("use local auth config file");
            String configurationFilePath = "~/.oci/config";
            String profile = "DEFAULT";
            final ConfigFileReader.ConfigFile configFile = ConfigFileReader.parse(configurationFilePath, profile);
            provider = new ConfigFileAuthenticationDetailsProvider(configFile);
        } catch (IOException ex) {
            LOG.warn("use auth properties");
            byte[] key = Base64.getDecoder().decode(mConfig.getString("secor.oci.key"));
            provider = SimpleAuthenticationDetailsProvider.builder()
                    .region(region)
                    .tenantId(mConfig.getString("secor.oci.tenantId"))
                    .userId(mConfig.getString("secor.oci.userId"))
                    .fingerprint(mConfig.getString("secor.oci.fingerprint"))
                    .passphraseCharacters(mConfig.getString("secor.oci.passphrase", "").toCharArray())
                    .privateKeySupplier(() -> new ByteArrayInputStream(key))
                    .build();
        }
        mClient = ObjectStorageClient.builder()
                .region(region)
                .build(provider);
    }

    @Override
    public Handle<?> upload(LogFilePath localPath) throws Exception {
        final String key = localPath.withPrefix(mPath).getLogFilePath();
        final File localFile = new File(localPath.getLogFilePath());

        LOG.info("uploading file {} to oci://{}/{}", localFile, mBucket, key);

        final Future<?> f = executor.submit(new Runnable() {
            @Override
            public void run() {
                try {
                    final FileInputStream fileInputStream = new FileInputStream(localFile);
                    PutObjectRequest request = PutObjectRequest.builder()
                            .namespaceName(mNamespace)
                            .bucketName(mBucket)
                            .contentLength(localFile.length())
                            .objectName(key)
                            .putObjectBody(fileInputStream)
                            .build();
                    mClient.putObject(request);
                } catch (FileNotFoundException e) {
                    throw new RuntimeException(e);
                }
            }
        });

        return new FutureHandle(f);
    }
}
