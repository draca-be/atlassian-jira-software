#!/bin/bash

SERVERXML="${JIRA_INSTALL}/conf/server.xml"
SETENV="${JIRA_INSTALL}/bin/setenv.sh"

if [ -f ${SERVERXML}.orig ]; then
    # Copy back the original server.xml for clean editing
    cp ${SERVERXML}.orig ${SERVERXML}
else
    # Make a backup of server.xml
    cp ${SERVERXML} ${SERVERXML}.orig
fi


if [ -n "${JIRA_PROXY_NAME}" ]; then
    sed -i "s/port=\"8080\"/port=\"8080\" proxyName=\"${JIRA_PROXY_NAME}\"/g" ${SERVERXML}
fi
if [ -n "${JIRA_PROXY_PORT}" ]; then
    sed -i "s/port=\"8080\"/port=\"8080\" proxyPort=\"${JIRA_PROXY_PORT}\"/g" ${SERVERXML}
fi
if [ -n "${JIRA_PROXY_SCHEME}" ]; then
    sed -i "s/port=\"8080\"/port=\"8080\" scheme=\"${JIRA_PROXY_SCHEME}\"/g" ${SERVERXML}
fi
if [ -n "${JIRA_CONTEXT_PATH}" ]; then
    sed -i "s:path=\"\":path=\"${JIRA_CONTEXT_PATH}\"/g" ${SERVERXML}
fi

if [ -n "${DISABLE_NOTIFICATIONS}" ]; then
    sed -i "s/\#DISABLE_NOTIFICATIONS/DISABLE_NOTIFICATIONS/g" ${SETENV}
else
    sed -i "s/^DISABLE_NOTIFICATIONS/#DISABLE_NOTIFICATIONS/g" ${SETENV}
fi

if [ -n "${JVM_MINIMUM_MEMORY}" ]; then
    sed -i "s/JVM_MINIMUM_MEMORY=\"[^\"]*\"/JVM_MINIMUM_MEMORY=\"${JVM_MINIMUM_MEMORY}\"/g" ${SETENV}
fi

if [ -n "${JVM_MAXIMUM_MEMORY}" ]; then
    sed -i "s/JVM_MAXIMUM_MEMORY=\"[^\"]*\"/JVM_MAXIMUM_MEMORY=\"${JVM_MAXIMUM_MEMORY}\"/g" ${SETENV}
fi

if [ -n "${JIRA_ARGS}" ]; then
    sed -i "s/JVM_SUPPORT_RECOMMENDED_ARGS=\"[^\"]*\"/JVM_SUPPORT_RECOMMENDED_ARGS=\"${JIRA_ARGS}\"/g" ${SETENV}
fi

if [ "x${RUN_USER}" != "x$(stat -c %U ${JIRA_HOME})" ]; then
    chown -R ${RUN_USER}:${RUN_GROUP} "${JIRA_HOME}"
fi

if [ "x${RUN_USER}" != "x$(stat -c %U ${JIRA_INSTALL})" ]; then
    chown -R ${RUN_USER}:${RUN_GROUP} "${JIRA_INSTALL}"
fi

sed -i "s/JIRA_USER=\"[^\"]*\"/JIRA_USER=\"${RUN_USER}\"/g" "${JIRA_INSTALL}/bin/user.sh"

exec "$@"