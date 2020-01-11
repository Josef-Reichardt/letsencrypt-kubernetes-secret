#!/bin/sh

if [ -z "$EMAIL" ]; then
	echo "Required environment variable EMAIL is missing!"
	exit 1
fi
if [ -z "$DOMAINS" ]; then
	echo "Required environment variable DOMAINS is missing!"
	exit 1
fi
if [ -z "$SECRET" ]; then
	echo "Required environment variable SECRET is missing!"
	exit 1
fi

echo "Start certificate update for domains $DOMAINS (email: $EMAIL)"

echo "Run certbot ..."
certbot certonly -d "$DOMAINS" --standalone -n --agree-tos -m "$EMAIL" || exit 1

echo "Looking for certificates ..."
CERTPATH=/etc/letsencrypt/live/$(echo "$DOMAINS" | cut -f1 -d',')
ls "$CERTPATH" || exit 1

export NAME="$SECRET"
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
export NAMESPACE
echo "Updating secret \"$SECRET\" (namespace: $NAMESPACE) ..."
FULLCHAIN=$(base64 "${CERTPATH}/fullchain.pem" | tr -d '\n')
export FULLCHAIN
PRIVKEY=$(base64 "${CERTPATH}/privkey.pem" | tr -d '\n')
export PRIVKEY
envsubst < /secret-patch.template.json > /secret-patch.json
echo "--- secret:"
cat /secret-patch.json
echo "---"
curl \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  -XPATCH \
  -H "Accept: application/json, */*" \
  -H "Content-Type: application/strategic-merge-patch+json" \
  -d @/secret-patch.json "https://kubernetes/api/v1/namespaces/${NAMESPACE}/secrets/${SECRET}" \
  -k -v
echo "Done"
