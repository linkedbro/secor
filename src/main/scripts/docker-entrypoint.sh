#!/bin/sh
set -e


SECOR_CONFIG=''

if [ -z "$ZOOKEEPER_QUORUM" ]; then
    echo "ZOOKEEPER_QUORUM variable not set, launch with -e ZOOKEEPER_QUORUM=zookeeper:2181"
else
    SECOR_CONFIG="$SECOR_CONFIG -Dzookeeper.quorum=$ZOOKEEPER_QUORUM"
    echo "zookeeper.quorum=$ZOOKEEPER_QUORUM"
fi

if [ -z "$ZOOKEEPER_PATH" ]; then
    echo "ZOOKEEPER_PATH variable not set, launch with -e ZOOKEEPER_PATH=/"
else
    SECOR_CONFIG="$SECOR_CONFIG -Dkafka.zookeeper.path=$ZOOKEEPER_PATH"
    echo "kafka.zookeeper.path=$ZOOKEEPER_PATH"
fi

if [ ! -z "$KAFKA_SEED_BROKER_HOST" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dkafka.seed.broker.host=$KAFKA_SEED_BROKER_HOST"
    echo "kafka.seed.broker.host=$KAFKA_SEED_BROKER_HOST"
fi
if [ ! -z "$KAFKA_SEED_BROKER_PORT" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dkafka.seed.broker.port=$KAFKA_SEED_BROKER_PORT"
    echo "kafka.seed.broker.port=$KAFKA_SEED_BROKER_PORT"
fi
if [ ! -z "$KAFKA_SECURITY_PROTOCOL" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dkafka.new.consumer.security.protocol=$KAFKA_SECURITY_PROTOCOL"
    echo "kafka.new.consumer.security.protocol=$KAFKA_SECURITY_PROTOCOL"
fi
if [ ! -z "$KAFKA_SASL_MECHANISM" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dkafka.new.consumer.sasl.mechanism=$KAFKA_SASL_MECHANISM"
    echo "kafka.new.consumer.sasl.mechanism=$KAFKA_SASL_MECHANISM"
fi
if [ ! -z "$KAFKA_SASL_JAAS_CONFIG" ]; then
    sed -i s/^kafka.new.consumer.sasl.jaas.config=.*/#/
    echo "kafka.new.consumer.sasl.jaas.config=$KAFKA_SASL_JAAS_CONFIG" >> secor.common.properties
    echo "kafka.new.consumer.sasl.jaas.config=KAFKA_SASL_JAAS_CONFIG"
fi

if [ ! -z "$SECOR_GROUP" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.kafka.group=$SECOR_GROUP"
    echo "secor.kafka.group=$SECOR_GROUP"
fi

if [ ! -z "$OCI_TENANT_ID" ]; then
    sed -i s/^secor.oci.tenantId=.*/secor.oci.tenantId=$OCI_TENANT_ID/ secor.common.properties
    echo "secor.oci.tenantId=$OCI_TENANT_ID"
fi
if [ ! -z "$OCI_USER_ID" ]; then
    sed -i s/^secor.oci.userId=.*/secor.oci.userId=$OCI_USER_ID/ secor.common.properties
    echo "secor.oci.userId=$OCI_USER_ID"
fi
if [ ! -z "$OCI_FINGERPRINT" ]; then
    sed -i s/^secor.oci.fingerprint=.*/secor.oci.fingerprint=$OCI_FINGERPRINT/ secor.common.properties
    echo "secor.oci.fingerprint=$OCI_FINGERPRINT"
fi
if [ ! -z "$OCI_PASSPHRASE" ]; then
    sed -i s/^secor.oci.passphrase=.*/secor.oci.passphrase=$OCI_PASSPHRASE/ secor.common.properties
    echo "secor.oci.passphrase=$OCI_PASSPHRASE"
fi
if [ ! -z "$OCI_KEY" ]; then
    sed -i s/^secor.oci.key=.*/secor.oci.key=$OCI_KEY/ secor.common.properties
    echo "secor.oci.key=OCI_KEY"
fi
if [ ! -z "$OCI_REGION" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.oci.region=$OCI_REGION"
    echo "secor.oci.region=$OCI_REGION"
fi
if [ ! -z "$OCI_NAMESPACE" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.oci.namespace=$OCI_NAMESPACE"
    echo "secor.oci.namespace=$OCI_NAMESPACE"
fi
if [ ! -z "$OCI_BUCKET" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.oci.bucket=$OCI_BUCKET"
    echo "secor.oci.bucket=$OCI_BUCKET"
fi
if [ ! -z "$OCI_PATH" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.oci.path=$OCI_PATH"
    echo "secor.oci.path=$OCI_PATH"
fi

if [ ! -z "$AWS_REGION" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Daws.region=$AWS_REGION"
    echo "aws.region=$AWS_REGION"
fi
if [ ! -z "$AWS_ENDPOINT" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Daws.endpoint=$AWS_ENDPOINT"
    echo "aws.endpoint=$AWS_ENDPOINT"
fi
if [ ! -z "$AWS_PATH_STYLE_ACCESS" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Daws.client.pathstyleaccess=$AWS_PATH_STYLE_ACCESS"
    echo "aws.client.pathstyleaccess=$AWS_PATH_STYLE_ACCESS"
fi
if [ ! -z "$AWS_ACCESS_KEY" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Daws.access.key=$AWS_ACCESS_KEY"
fi
if [ ! -z "$AWS_SECRET_KEY" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Daws.secret.key=$AWS_SECRET_KEY"
fi
if [ ! -z "$AWS_SESSION_TOKEN" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Daws.session.token=$AWS_SESSION_TOKEN"
fi
if [ ! -z "$SECOR_S3_BUCKET" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.s3.bucket=$SECOR_S3_BUCKET"
    echo "secor.s3.bucket=$SECOR_S3_BUCKET"
fi
if [ ! -z "$S3_PATH" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.s3.path=$S3_PATH"
    echo "secor.s3.path=$S3_PATH"
fi
if [ ! -z "$SECOR_SCHEMA_REGISTRY" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dschema.registry.url=$SECOR_SCHEMA_REGISTRY"
    echo "schema.registry.url=$SECOR_SCHEMA_REGISTRY"
fi

if [ ! -z "$MESSAGE_TIMESTAMP_NAME" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dmessage.timestamp.name=$MESSAGE_TIMESTAMP_NAME"
    echo "message.timestamp.name=$MESSAGE_TIMESTAMP_NAME"
fi
if [ ! -z "$MESSAGE_TIMESTAMP_NAME_SEPARATOR" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dmessage.timestamp.name.separator=$MESSAGE_TIMESTAMP_NAME_SEPARATOR"
    echo "message.timestamp.name.separator=$MESSAGE_TIMESTAMP_NAME_SEPARATOR"
fi
if [ ! -z "$SECOR_PARSER_TIMEZONE" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.parser.timezone=$SECOR_PARSER_TIMEZONE"
    echo "secor.parser.timezone=$SECOR_PARSER_TIMEZONE"
fi

if [ ! -z "$CLOUD_SERVICE" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dcloud.service=$CLOUD_SERVICE"
    echo "cloud.service=$CLOUD_SERVICE"
fi
if [ ! -z "$SECOR_UPLOAD_MANAGER_CLASS" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.upload.manager.class=$SECOR_UPLOAD_MANAGER_CLASS"
    echo "secor.upload.manager.class=$SECOR_UPLOAD_MANAGER_CLASS"
fi
if [ ! -z "$SECOR_GS_BUCKET" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.gs.bucket=$SECOR_GS_BUCKET"
    echo "secor.gs.bucket=$SECOR_GS_BUCKET"
fi
if [ ! -z "$SECOR_GS_PATH" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.gs.path=$SECOR_GS_PATH"
    echo "secor.gs.path=$SECOR_GS_PATH"
fi

if [ ! -z "$SECOR_MAX_FILE_BYTES" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.max.file.size.bytes=$SECOR_MAX_FILE_BYTES"
    echo "secor.max.file.size.bytes=$SECOR_MAX_FILE_BYTES"
fi
if [ ! -z "$SECOR_MAX_FILE_SECONDS" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.max.file.age.seconds=$SECOR_MAX_FILE_SECONDS"
    echo "secor.max.file.age.seconds=$SECOR_MAX_FILE_SECONDS"
fi


if [ ! -z "$SECOR_KAFKA_TOPIC_FILTER" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.kafka.topic_filter=$SECOR_KAFKA_TOPIC_FILTER"
    echo "secor.kafka.topic_filter=$SECOR_KAFKA_TOPIC_FILTER"
fi
if [ ! -z "$SECOR_WRITER_FACTORY" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.file.reader.writer.factory=$SECOR_WRITER_FACTORY"
    echo "secor.file.reader.writer.factory=$SECOR_WRITER_FACTORY"
fi
if [ ! -z "$SECOR_MESSAGE_PARSER" ]; then
    SECOR_CONFIG="$SECOR_CONFIG -Dsecor.message.parser.class=$SECOR_MESSAGE_PARSER"
    echo "secor.message.parser.class=$SECOR_MESSAGE_PARSER"
fi
SECOR_CONFIG="$SECOR_CONFIG $SECOR_EXTRA_OPTS"

DEFAULT_CLASSPATH="*:lib/*"
CLASSPATH=${CLASSPATH:-$DEFAULT_CLASSPATH}

java -Xmx${JVM_MEMORY:-512m} $JAVA_OPTS -ea -Dsecor_group=${SECOR_GROUP:-partition} -Dlog4j.configuration=file:${LOG4J_CONFIGURATION:-log4j.docker.properties} \
        -Dconfig=${CONFIG_FILE:-secor.prod.partition.properties} ${SECOR_CONFIG} \
        -cp $CLASSPATH ${SECOR_MAIN_CLASS:-com.pinterest.secor.main.ConsumerMain}
