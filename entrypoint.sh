#!/bin/sh

CONFLUENCE_INSTALL=/opt/confluence
CONFLUENCE_HOME=/var/atlassian/application-data/confluence

. /opt/confluence-scripts/common.sh

# FROM https://github.com/teamatldocker/jira/blob/master/bin/docker-entrypoint.sh

add_prop() {
  KEY=$1
  VALUE=$2
  xmlstarlet ed -L -s //properties -t elem -n property -v "$VALUE" \
    -s "//properties/property[not(@name)]" \
    -t attr -n name -v "$KEY" $CONFLUENCE_HOME/confluence.cfg.xml
}

if [ -n "${CONFLUENCE_PROXY_NAME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${CONFLUENCE_PROXY_NAME}" ${CONFLUENCE_INSTALL}/conf/server.xml
fi

if [ -n "${CONFLUENCE_PROXY_PORT}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${CONFLUENCE_PROXY_PORT}" ${CONFLUENCE_INSTALL}/conf/server.xml
fi

if [ -n "${CONFLUENCE_PROXY_SCHEME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${CONFLUENCE_PROXY_SCHEME}" ${CONFLUENCE_INSTALL}/conf/server.xml
fi

if [ ! -f $CONFLUENCE_HOME/.container-config-ok ]; then
  if [ -n "$CONFLUENCE_ATLASSIAN_LICENSE_MESSAGE" ]; then
    add_prop "atlassian.license.message" "$CONFLUENCE_ATLASSIAN_LICENSE_MESSAGE"
  fi
  
  if [ -n "$CONFLUENCE_SERVER_ID" ]; then
    add_prop "confluence.setup.server.id" "$CONFLUENCE_SERVER_ID"
  fi
  
  if [ -n "$CONFLUENCE_DB_URL" ]; then
    add_prop "hibernate.connection.url" "$CONFLUENCE_DB_URL"
  fi
  
  if [ -n "$CONFLUENCE_DB_USERNAME" ]; then
    add_prop "hibernate.connection.username" "$CONFLUENCE_DB_USERNAME"
  fi
  
  if [ -n "$CONFLUENCE_DB_PASSWORD" ]; then
    add_prop "hibernate.connection.password" "$CONFLUENCE_DB_PASSWORD"
  fi
  
  if [ -n "$CONFLUENCE_DB_DRIVER_CLASS" ]; then
    add_prop "hibernate.connection.driver_class" "$CONFLUENCE_DB_DRIVER_CLASS"
  fi
  
  if [ -n "$CONFLUENCE_DB_DIALECT" ]; then
    add_prop "hibernate.dialect" "$CONFLUENCE_DB_DIALECT"
  fi

  if [ -n "$CONFLUENCE_DATABASE_URL" ]; then
  extract_database_url "$CONFLUENCE_DATABASE_URL" CONFLUENCE_DB ${CONFLUENCE_INSTALL}/lib
  CONFLUENCE_DB_JDBC_URL="$(xmlstarlet esc "$CONFLUENCE_DB_JDBC_URL")"
  CONFLUENCE_DB_PASSWORD="$(xmlstarlet esc "$CONFLUENCE_DB_PASSWORD")"
  SCHEMA=''
  if [ "$CONFLUENCE_DB_TYPE" != "mysql" ]; then
    SCHEMA='<schema-name>public</schema-name>'
  fi
  if [ "$CONFLUENCE_DB_TYPE" == "mssql" ]; then
    SCHEMA='<schema-name>dbo</schema-name>'
  fi

  cat <<END > ${CONFLUENCE_HOME}/dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<confluence-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>$CONFLUENCE_DB_TYPE</database-type>
  $SCHEMA
  <jdbc-datasource>
    <url>$CONFLUENCE_DB_JDBC_URL</url>
    <driver-class>$CONFLUENCE_DB_JDBC_DRIVER</driver-class>
    <username>$CONFLUENCE_DB_USER</username>
    <password>$CONFLUENCE_DB_PASSWORD</password>
    <pool-min-size>20</pool-min-size>
    <pool-max-size>20</pool-max-size>
    <pool-max-wait>30000</pool-max-wait>
    <pool-max-idle>20</pool-max-idle>
    <pool-remove-abandoned>true</pool-remove-abandoned>
    <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
    <validation-query>$CONFLUENCE_DB_VALIDATION_QUERY</validation-query>
    <validation-query-timeout>3</validation-query-timeout>
    <min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
    <time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
    <pool-test-on-borrow>false</pool-test-on-borrow>
    <pool-test-while-idle>true</pool-test-while-idle>
  </jdbc-datasource>
</confluence-database-config>
END
  fi

  touch $CONFLUENCE_HOME/.container-config-ok;
fi

echo "Launching Confluence..."

/opt/confluence-scripts/launch.sh $CONFLUENCE_INSTALL $CONFLUENCE_HOME
