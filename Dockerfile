FROM certbot/certbot:latest
MAINTAINER Josef Reichardt

RUN apk add --no-cache curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"
