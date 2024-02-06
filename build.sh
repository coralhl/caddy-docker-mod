#!/bin/bash

# Сборка
docker build --progress=plain -f Dockerfile -t coralhl/caddy-mod .
# Заливка в регистр
docker push coralhl/caddy-mod
