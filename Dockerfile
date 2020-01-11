FROM certbot/certbot:latest
MAINTAINER Josef Reichardt

RUN apk add --no-cache --virtual curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"
