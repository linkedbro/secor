package com.pinterest.secor.parser;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hive.metastore.HiveMetaStoreClient;
import org.apache.hadoop.hive.metastore.api.MetaException;
import org.apache.hadoop.hive.metastore.api.Partition;
import org.apache.thrift.TException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pinterest.secor.common.SecorConfig;

public class HmsClient {
    private static final Logger LOG = LoggerFactory.getLogger(HmsClient.class);
    private HiveMetaStoreClient mHiveMetaStoreClient;
    private final String mDbName;
    private Exception mLastException;

    public HmsClient(SecorConfig config) {
        mDbName = config.getString("secor.hive.dbname");
        String catalog = config.getString("secor.hive.catalog");
        String uri = config.getString("secor.hive.uris");
        LOG.info("HMS config: db={}, uri={}", mDbName, uri);
        if (StringUtils.isNotEmpty(uri) && StringUtils.isNotEmpty(mDbName)) {
            Configuration conf = new Configuration();
            conf.set("metastore.catalog.default", catalog);
            conf.set("hive.metastore.uris", uri);
            try {
                mHiveMetaStoreClient = new HiveMetaStoreClient(conf);
            } catch (MetaException exception) {
                mLastException = exception;
                LOG.error("Failed to create HMS client", exception);
            }
        } else {
            mLastException = new RuntimeException(
                    String.format("Bad HMS config: catalog=%s, db=%s, uri=%s", catalog, mDbName, uri));
            LOG.error("Skip to create HMS client", mLastException);
        }
    }

    public void addPartition(String table, String[] partition) throws TException {
        LOG.info("Add partition {} to table {}", partition, table);
        if (mHiveMetaStoreClient != null) {
            List<String> partitions = new ArrayList<>();
            for (String part : partition) {
                String[] p = part.split("=");
                partitions.add(p[1]); // HMS needs value only
            }
            Partition added = mHiveMetaStoreClient.appendPartition(mDbName, table, partitions);
            LOG.info("Added partition {}", added);
        } else {
            LOG.error("Skip to add partition due to empty client", mLastException);
        }
    }
}
