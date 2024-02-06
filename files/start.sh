#!/bin/bash

CONF_DIR="/app/conf"
DATA_DIR="/app/data"
LOGS_DIR="/app/logs"

### Set user
PUID=${PUID:-911}
PGID=${PGID:-911}

groupmod -o -g "$PGID" abc
usermod -o -u "$PUID" abc

echo "
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

───────────────────────────────────────
PUID                    = $(id -u abc)
PGID                    = $(id -g abc)
───────────────────────────────────────
TZ                      = $TZ
CONF_DIR                = $CONF_DIR 
DATA_DIR                = $DATA_DIR
LOGS_DIR                = $LOGS_DIR
───────────────────────────────────────
CONF_TYPE               = $CONF_TYPE
───────────────────────────────────────
"

### Set the desired timezone
if [ ! -z "$TZ" ]; then
  rm -f /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi


caddy_start() {
  if [[ ! -f "${CONF_DIR}/Caddyfile" ]]; then
      echo "Installing default \"Caddyfile\"..."
      cp "/tmp/Caddyfile" "${CONF_DIR}/Caddyfile"
  fi
  exec /usr/bin/supervisord -n -c /etc/supervisord-caddy.conf
}

yaml_start() {
  if [[ ! -f "${CONF_DIR}/config.yaml" ]]; then
      echo "Installing default \"config.yaml\"..."
      cp "/tmp/config.yaml" "${CONF_DIR}/config.yaml"
  fi
  exec /usr/bin/supervisord -n -c /etc/supervisord-yaml.conf
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

lsiown -R abc:abc "$CONF_DIR"
lsiown -R abc:abc "$DATA_DIR"
lsiown -R abc:abc "$LOGS_DIR"
lsiown -R abc:abc /etc/supervisor/conf.d/
