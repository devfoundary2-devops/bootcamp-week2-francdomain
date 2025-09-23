#!/bin/sh
set -e

APP_DIR=${APP_DIR:-/usr/src/app}

echo "[entrypoint] frontend checking for node_modules in ${APP_DIR}..."
cd "${APP_DIR}" || { echo "[entrypoint] cannot cd to ${APP_DIR}"; exit 1; }

if [ "$NODE_ENV" = "development" ] || [ "$FORCE_NPM_CI" = "1" ]; then
  echo "[entrypoint] NODE_ENV=development or FORCE_NPM_CI=1 — ensuring dependencies are installed (including devDependencies)"
  npm ci
else
  if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules 2>/dev/null)" ]; then
    echo "[entrypoint] node_modules missing or empty — installing dependencies (including devDependencies)"
    npm ci
  else
    BIN_PATH="node_modules/.bin/react-scripts"
    NEED_REPAIR=0
    if [ -e "$BIN_PATH" ]; then
      TARGET=$(readlink -f "$BIN_PATH" 2>/dev/null || true)
      if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
        echo "[entrypoint] $BIN_PATH points to missing target: $TARGET"
        NEED_REPAIR=1
      else
        echo "[entrypoint] $BIN_PATH -> $TARGET (exists)"
      fi
    else
      echo "[entrypoint] $BIN_PATH does not exist"
      NEED_REPAIR=1
    fi

    if [ $NEED_REPAIR -eq 1 ]; then
      echo "[entrypoint] react-scripts appears broken — reinstalling dependencies"
      npm ci
    else
      echo "[entrypoint] node_modules present and react-scripts is available — skipping install"
    fi
  fi
fi

echo "[entrypoint] starting CMD: $@"
exec "$@"
