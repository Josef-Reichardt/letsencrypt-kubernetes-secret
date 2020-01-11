FROM certbot/certbot:latest
MAINTAINER Josef Reichardt

RUN apk add --no-cache curl gettext

COPY entrypoint.sh /entrypoint.sh
COPY secret-patch.template.json /secret-patch.template.json

ENTRYPOINT "/entrypoint.sh"
