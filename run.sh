#!/bin/sh
set -e

# Railway provides individual MySQL env vars
DB_HOST="${MYSQLHOST:-localhost}"
DB_PORT="${MYSQLPORT:-3306}"
DB_NAME="${MYSQLDATABASE:-survey_master}"
DB_USER="${MYSQLUSER:-root}"
DB_PASS="${MYSQLPASSWORD:-}"

# Also support DATABASE_URL if provided (some add-ons use this format)
if [ -n "$DATABASE_URL" ] && [ -z "$MYSQLHOST" ]; then
  # Extract from DATABASE_URL: mysql://user:pass@host:port/dbname
  DB_HOST=$(echo "$DATABASE_URL" | sed -n 's|.*@\([^:]*\):\([0-9]*\)/.*|\1|p')
  DB_PORT=$(echo "$DATABASE_URL" | sed -n 's|.*@\([^:]*\):\([0-9]*\)/.*|\2|p')
  DB_NAME=$(echo "$DATABASE_URL" | sed -n 's|.*/\([^?]*\).*|\1|p')
  DB_USER=$(echo "$DATABASE_URL" | sed -n 's|://\([^:]*\):.*|\1|p')
  DB_PASS=$(echo "$DATABASE_URL" | sed -n 's|://[^:]*:\([^@]*\)@.*|\1|p')
fi

JDBC_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"

PORT="${PORT:-8080}"

exec java ${JAVA_OPTS} \
  -Dserver.port=${PORT} \
  -Dspring.datasource.url="${JDBC_URL}" \
  -Dspring.datasource.username="${DB_USER}" \
  -Dspring.datasource.password="${DB_PASS}" \
  -Dapp.db.init-schema=true \
  -jar app.war
