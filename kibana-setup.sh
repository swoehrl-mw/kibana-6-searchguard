#!/bin/bash

KIBANA_YAML=$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/config/kibana.yml

cat <<EOF > $KIBANA_YAML
elasticsearch.url: $ELASTICSEARCH_URL
server.host: 0.0.0.0
server.port: 5601
EOF

echo -e "\n$KIBANA_EXTRA_CONFIG\n" >> $KIBANA_YAML

if [ "$XPACK_ENABLED" = true ]; then
	cat <<EOF >> $KIBANA_YAML
xpack.security.encryptionKey: $MESOS_FRAMEWORK_ID
xpack.reporting.encryptionKey: $MESOS_FRAMEWORK_ID
elasticsearch.username: $KIBANA_USER
elasticsearch.password: $KIBANA_PASSWORD
EOF
fi
if [ "$SEARCHGUARD_ENABLED" = true ]; then
	cat <<EOF >> $KIBANA_YAML
searchguard.basicauth.enabled: true
elasticsearch.username: $KIBANA_USER
elasticsearch.password: $KIBANA_PASSWORD
EOF
fi

if [ "$KIBANA_ELASTICSEARCH_TLS" = true ]; then
	echo -e "\nelasticsearch.ssl.certificateAuthorities: $MESOS_SANDBOX/.ssl/ca-bundle.crt\n" >> $KIBANA_YAML
fi
$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana-plugin install file://$MESOS_SANDBOX/search-guard-kibana-plugin-${ELASTIC_VERSION}-${SEARCHGUARD_KIBANA_VERSION}.zip
$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana
