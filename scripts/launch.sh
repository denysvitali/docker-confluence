#!/bin/bash

# Based on https://github.com/teamatldocker/jira/blob/master/bin/launch.sh
. /opt/confluence-scripts/common.sh

CONFLUENCE_INSTALL=$1
CONFLUENCE_HOME=$2

echo "CONFLUENCE_HOME=$CONFLUENCE_HOME"
echo "CONFLUENCE_INSTALL=$CONFLUENCE_INSTALL"

$CONFLUENCE_INSTALL/bin/start-confluence.sh -fg
