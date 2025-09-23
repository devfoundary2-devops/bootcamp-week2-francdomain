#!/bin/sh
# Lightweight entrypoint for development image.
# Ensures devDependencies (like nodemon) exist when running with host mounts/volumes.
set -e

APP_DIR=${APP_DIR:-/usr/src/app}

echo "[entrypoint] checking for node_modules in ${APP_DIR}..."
cd "${APP_DIR}" || { echo "[entrypoint] cannot cd to ${APP_DIR}"; exit 1; }

# If in development mode, or FORCE_NPM_CI is set, prefer to (re)install dev deps to avoid broken mounts
if [ "$NODE_ENV" = "development" ] || [ "$FORCE_NPM_CI" = "1" ]; then
  echo "[entrypoint] NODE_ENV=development or FORCE_NPM_CI=1 — ensuring dependencies are installed (including devDependencies)"
  npm ci
else
  # If node_modules is missing or empty, install everything (including dev deps)
  if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules 2>/dev/null)" ]; then
    echo "[entrypoint] node_modules missing or empty — installing dependencies (including devDependencies)"
    npm ci
  else
  echo "[entrypoint] node_modules present — checking nodemon availability"
  # Verify the .bin/nodemon points to a real file and that the package's bin exists.
  BIN_PATH="node_modules/.bin/nodemon"
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

  # Also check nodemon package bin path directly
  if [ $NEED_REPAIR -eq 0 ]; then
    if [ ! -f "node_modules/nodemon/bin/nodemon.js" ]; then
      echo "[entrypoint] node_modules/nodemon/bin/nodemon.js missing"
      NEED_REPAIR=1
    fi
  fi

    if [ $NEED_REPAIR -eq 1 ]; then
      echo "[entrypoint] nodemon appears broken — reinstalling dependencies"
      npm ci
    else
      echo "[entrypoint] node_modules present and nodemon is available — skipping install"
    fi
  fi
fi

echo "[entrypoint] starting CMD: $@"
exec "$@"
