#!/bin/bash

CONF_DIR="/app/conf"
DATA_DIR="/app/data"
LOGS_DIR="/app/logs"

### Set user
PUID=${PUID:-911}
PGID=${PGID:-911}

groupmod -o -g "$PGID" abc
usermod -o -u "$PUID" abc

XDG_CONFIG_HOME="${CONF_DIR}" XDG_DATA_HOME="${DATA_DIR}" HOME="${CONF_DIR}"

### Set the desired timezone
if [ ! -z "$TZ" ]; then
  rm -f /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

### Set custom http file server
if [ ! -z "$FSROOT" ]; then
  sed -i "s#root * /app/www#root ${FSROOT}#g" /app/config/Caddyfile
else
  FSROOT="/app/www"
fi

### Chown /app/www
if [[ "$CHOWN_FSROOT" == "1" ]] ; then
  echo 'Chowning $FSROOT for user abc
───────────────────────────────────────'
  lsiown -R abc:abc "$FSROOT"
else
  echo 'NOT chowning $FSROOT for user abc. Do it yourself
───────────────────────────────────────'
fi


lsiown -R abc:abc "$CONF_DIR"
lsiown -R abc:abc "$DATA_DIR"
lsiown -R abc:abc "$LOGS_DIR"


caddy_start() {
  if [[ ! -f "${CONF_DIR}/Caddyfile" ]]; then
      echo "Installing default \"Caddyfile\"..."
      cp "/tmp/Caddyfile" "${CONF_DIR}/Caddyfile"
  fi
  caddy run --config "${CONF_DIR}/Caddyfile"
}

yaml_start() {
  if [[ ! -f "${CONF_DIR}/config.yaml" ]]; then
      echo "Installing default \"config.yaml\"..."
      cp "/tmp/config.yaml" "${CONF_DIR}/config.yaml"
  fi
  caddy run --config "${CONF_DIR}/config.yaml" --adapter yaml
}

if [ ! -z "$CONF_TYPE" ]; then
  if [[ "$CONF_TYPE" == "yaml" ]]; then
    yaml_start
  fi
  if [[ "$CONF_TYPE" == "caddy" ]]; then
    caddy_start
  fi
else
  caddy_start
  CONF_TYPE="caddy"
fi

echo '
     ┌                            ┐
                                
       ███ ███ ██████ ███ ███ ███  
      ░███░███░██████░███░███░███  
      ░███████░███░░ ░███░███░███  
      ░░░███░ ░███   ░███░███░███  
       ███████░███   ░███░███░███  
      ░███░███░██████░███░███░███  
      ░███░███░██████░███░███░███  
      ░░░ ░░░ ░░░░░░ ░░░ ░░░ ░░░   
     └                            ┘
           Created by XCIII:
      https://github.com/coralhl/

───────────────────────────────────────'
echo "
PUID                    = $(id -u abc)
PGID                    = $(id -g abc)
───────────────────────────────────────
TZ                      = $TZ
CONF_DIR                = $CONF_DIR 
DATA_DIR                = $DATA_DIR
LOGS_DIR                = $LOGS_DIR
FSROOT                  = $FSROOT
CHOWN_FSROOT            = $CHOWN_FSROOT 
───────────────────────────────────────
CONF_TYPE               = $CONF_TYPE
───────────────────────────────────────
"

### Start supervisord and services
#exec /usr/bin/supervisord -n -c /etc/supervisord.conf
