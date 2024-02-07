#!/bin/bash
L4FILE=$1
CONF_DIR="/app/conf"

echo "Removing existing caddy.json file"
rm "${CONF_DIR}/caddy.json"

echo "Formatting Caddyfile"
caddy fmt --overwrite "${CONF_DIR}/Caddyfile"
echo "Generating caddy.json file"
caddy adapt --config "${CONF_DIR}/Caddyfile" --pretty --validate > "${CONF_DIR}/caddy.json"

if [ ! -z "$L4FILE" ]; then
    echo "Reading ${L4FILE}"
    layer4_content=$(<${CONF_DIR}/${L4FILE})

    echo "Inserting layer4 content into caddy.json"
    jq --argjson layer4 "$layer4_content" '.apps.layer4 = $layer4' ${CONF_DIR}/caddy.json > ${CONF_DIR}/temp.json \
    && mv ${CONF_DIR}/temp.json ${CONF_DIR}/caddy.json
fi
