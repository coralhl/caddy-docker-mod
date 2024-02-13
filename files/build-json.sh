#!/bin/bash
L4FILE=$1
CONF_DIR="/app/conf"

echo "Removing existing config.json file"
rm "${CONF_DIR}/config.json"

echo "Formatting Caddyfile"
caddy fmt --overwrite "${CONF_DIR}/Caddyfile"
echo "Generating config.json file"
caddy adapt --config "${CONF_DIR}/Caddyfile" --pretty --validate > "${CONF_DIR}/config.json"

if [ ! -z "$L4FILE" ]; then
    echo "Reading ${L4FILE}"
    layer4_content=$(<${CONF_DIR}/${L4FILE})

    echo "Inserting layer4 content into config.json"
    jq --argjson layer4 "$layer4_content" '.apps.layer4 = $layer4' ${CONF_DIR}/config.json > ${CONF_DIR}/temp.json \
    && mv ${CONF_DIR}/temp.json ${CONF_DIR}/config.json
fi
