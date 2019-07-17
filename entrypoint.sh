#!/bin/sh

CONFLUENCE_INSTALL=/opt/confluence
CONFLUENCE_HOME=/var/atlassian/application-data/confluence

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

  touch $CONFLUENCE_HOME/.container-config-ok;
fi

echo "Launching Confluence..."

/opt/confluence-scripts/launch.sh $CONFLUENCE_INSTALL $CONFLUENCE_HOME
