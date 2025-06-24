#!/usr/bin/env sh
set -eu

: "${BLUEMAP_PROXY_TARGET:?required}"

envsubst '${BLUEMAP_PROXY_TARGET}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
