#!/bin/sh
set -eu

: "${GROK2API_JWT_SECRET:?GROK2API_JWT_SECRET is required}"
: "${GROK2API_CREDENTIAL_ENCRYPTION_KEY:?GROK2API_CREDENTIAL_ENCRYPTION_KEY is required}"
: "${GROK2API_ADMIN_USERNAME:=admin}"
: "${GROK2API_ADMIN_PASSWORD:?GROK2API_ADMIN_PASSWORD is required}"
: "${PORT:=8000}"

umask 077

cat > /app/config.yaml <<EOF
server:
  listen: "0.0.0.0:${PORT}"
  maxBodyBytes: 33554432
  trustedProxies: []
  readTimeout: 15m
  requestTimeout: 2h
  swaggerEnabled: false
auth:
  accessTokenTTL: 15m
  refreshTokenTTL: 720h
  secureCookies: true
secrets:
  jwtSecret: "${GROK2API_JWT_SECRET}"
  credentialEncryptionKey: "${GROK2API_CREDENTIAL_ENCRYPTION_KEY}"
bootstrapAdmin:
  username: "${GROK2API_ADMIN_USERNAME}"
  password: "${GROK2API_ADMIN_PASSWORD}"
frontend:
  staticPath: "./frontend/dist"
database:
  driver: sqlite
  sqlite:
    path: "./data/backend.db"
runtimeStore:
  driver: memory
deployment:
  replicas: 1
media:
  driver: local
  local:
    path: "./data/media"
EOF

chown grok2api:grok2api /app/config.yaml /app/data
exec su-exec grok2api:grok2api /app/grok2api --config /app/config.yaml --listen "0.0.0.0:${PORT}"
