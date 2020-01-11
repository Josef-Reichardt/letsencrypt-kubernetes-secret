FROM certbot/certbot:latest
MAINTAINER Josef Reichardt

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"
