#!/bin/bash

# Based on https://github.com/teamatldocker/jira/blob/master/bin/launch.sh
. /opt/confluence-scripts/common.sh

CONFLUENCE_INSTALL=$1
CONFLUENCE_HOME=$2

echo "CONFLUENCE_HOME=$CONFLUENCE_HOME"
echo "CONFLUENCE_INSTALL=$CONFLUENCE_HOME"

rm -f $CONFLUENCE_HOME/.confluence-home.lock

if [ "$CONFLUENCE_CONTEXT_PATH" == "ROOT" -o -z "$CONFLUENCE_CONTEXT_PATH" ]; then
  CONTEXT_PATH=
else
  CONTEXT_PATH="/$CONFLUENCE_CONTEXT_PATH"
fi

xmlstarlet ed -P -S -L -u '//Context/@path' -v "$CONTEXT_PATH" ${CONFLUENCE_INSTALL}/conf/server.xml

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

$CONFLUENCE_INSTALL/bin/start-confluence.sh -fg
