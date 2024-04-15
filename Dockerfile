FROM nginx:1.23.4-alpine

# Install dependencies
RUN apk add --no-cache openssl socat bash

# Install ACME.SH
ENV AUTO_UPGRADE=0
ENV LE_WORKING_DIR=/acme.sh
ENV LE_CONFIG_HOME=/acmecerts
RUN wget -O- https://get.acme.sh | sh && crontab -l | sed 's#> /dev/null##' | crontab - \
    && $LE_WORKING_DIR/acme.sh --set-default-ca --server letsencrypt \
    && sed -i '/exec "$@"/i crond' /docker-entrypoint.sh \
    && echo "source /acme.sh/acme.sh.env" >> /etc/profile.d/locale.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY Template/ /nginx-conf/

VOLUME ["/acmecerts", "/nginx-conf", "/var/log"]

EXPOSE 80
EXPOSE 443
