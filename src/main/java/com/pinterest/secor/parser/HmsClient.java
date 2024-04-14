package com.pinterest.secor.parser;

import org.apache.commons.lang3.StringUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hive.metastore.HiveMetaStoreClient;
import org.apache.hadoop.hive.metastore.api.MetaException;
import org.apache.thrift.TException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pinterest.secor.common.SecorConfig;

public class HmsClient {
    private static final Logger LOG = LoggerFactory.getLogger(HmsClient.class);
    private HiveMetaStoreClient mHiveMetaStoreClient;
    private final String mDbName;

    public HmsClient(SecorConfig config) {
        mDbName = config.getString("secor.hive.dbname");
        String uri = config.getString("secor.hive.uris");
        LOG.info("HMS config: db={}, uri={}", mDbName, uri);
        if (StringUtils.isNotEmpty(uri) && StringUtils.isNotEmpty(mDbName)) {
            Configuration conf = new Configuration();
            conf.set("hive.metastore.uris", uri);
            try {
                mHiveMetaStoreClient = new HiveMetaStoreClient(conf);
            } catch (MetaException exception) {
                LOG.error("Failed to create HMS client", exception);
            }
        }
    }

    public void addPartition(String table, String partition) throws TException {
        LOG.info("Add partition {} to table {}", partition, table);
        if (mHiveMetaStoreClient != null) {
            mHiveMetaStoreClient.appendPartition(mDbName, table, partition);
        }
    }
}
