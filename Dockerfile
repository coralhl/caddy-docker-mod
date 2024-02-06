FROM golang:alpine AS builder

RUN apk add --no-cache git ca-certificates
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
RUN xcaddy build \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/abiosoft/caddy-yaml \
    --with github.com/caddy-dns/desec \
    --with github.com/mholt/caddy-l4 \
	--with github.com/hslatman/caddy-crowdsec-bouncer/crowdsec \
    --output /usr/bin/caddy && chmod +x /usr/bin/caddy

FROM alpine:3.19

# Bring in utils
RUN apk add --no-cache bash bash-completion jq mailcap shadow \
# Bring in tzdata so users could set the timezones through the environment variables
    && apk add --no-cache tzdata \
# Bring in curl and ca-certificates to make registering on DNS SD easier
    && apk add --no-cache curl ca-certificates

# Set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/docker-library/golang/blob/1eb096131592bcbc90aa3b97471811c798a93573/1.14/alpine3.12/Dockerfile#L9
RUN echo 'hosts: files dns' > /etc/nsswitch.conf
# See https://caddyserver.com/docs/conventions#file-locations for details

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY files/app/ /app
COPY files/Caddyfile /tmp/Caddyfile
COPY files/config.yaml /tmp/config.yaml
COPY files/lsiown /usr/bin/lsiown
COPY files/start.sh /start.sh

ENV TZ=Europe/Moscow

RUN set -eux \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /home/user -s /bin/false abc \
    && usermod -G users abc \
    && mkdir -p \
        /app/conf/caddy \
        /app/data/caddy \
        /app/logs \
        /usr/share/caddy \
        /home/user \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    #&& mkdir -p /var/log/supervisor \
    && chmod +x /start.sh \
    && chmod +x /usr/bin/lsiown

#ENV XDG_CONFIG_HOME /app/conf
#ENV XDG_DATA_HOME /app/data

EXPOSE 8080 8443

WORKDIR /app

CMD ["/start.sh"]