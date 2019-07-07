#!/bin/sh

CONFLUENCE_INSTALL=/opt/confluence
CONFLUENCE_HOME=/var/atlassian/application-data/confluence

# FROM https://github.com/teamatldocker/jira/blob/master/bin/docker-entrypoint.sh

if [ -n "${CONFLUENCE_PROXY_NAME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${CONFLUENCE_PROXY_NAME}" ${CONFLUENCE_INSTALL}/conf/server.xml
fi

if [ -n "${CONFLUENCE_PROXY_PORT}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${CONFLUENCE_PROXY_PORT}" ${CONFLUENCE_INSTALL}/conf/server.xml
fi

if [ -n "${CONFLUENCE_PROXY_SCHEME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${CONFLUENCE_PROXY_SCHEME}" ${CONFLUENCE_INSTALL}/conf/server.xml
fi

echo "Launching Confluence..."
/opt/confluence-scripts/launch.sh $CONFLUENCE_INSTALL $CONFLUENCE_HOME
