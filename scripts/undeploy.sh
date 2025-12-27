#!/bin/bash
set -e

# Target dirs
BIN_DIR_SERVER="/home/clubrust/server"
BIN_DIR_ADMIN="/home/clubrust/admin"
BIN_DIR_CLIENT="/home/clubrust/server/www"

# Parse args
UNDEPLOY_SERVER=false
UNDEPLOY_ADMIN=false
UNDEPLOY_CLIENT=false

for arg in "$@"; do
    case $arg in
        --server) UNDEPLOY_SERVER=true ;;
        --admin) UNDEPLOY_ADMIN=true ;;
        --client) UNDEPLOY_CLIENT=true ;;
        --all) UNDEPLOY_SERVER=true; UNDEPLOY_ADMIN=true; UNDEPLOY_CLIENT=true ;;
    esac
done

# Validate at least one target is selected
if ! $UNDEPLOY_SERVER && ! $UNDEPLOY_ADMIN && ! $UNDEPLOY_CLIENT; then
    echo "❌ No targets specified. Use --server, --admin, --client, or --all."
    exit 1
fi

# Confirm dangerous action
a=$(shuf -i 1-9 -n 1)
b=$(shuf -i 1-9 -n 1)
sum=$((a + b))

echo "⚠️  WARNING: This will DELETE deployed files. This action is irreversible."
read -p "To confirm, what is $a + $b? " confirm

if [[ "$confirm" != "$sum" ]]; then
    echo "❌ Math check failed. Aborting undeploy."
    exit 1
fi

# Remove targets
if $UNDEPLOY_SERVER; then
    echo "🧹 Removing server binary..."
    rm -f "$BIN_DIR_SERVER/server"
fi

if $UNDEPLOY_ADMIN; then
    echo "🧹 Removing admin binary..."
    rm -f "$BIN_DIR_ADMIN/admin"
fi

if $UNDEPLOY_CLIENT; then
    echo "🧹 Removing client WASM + JS..."
    rm -f "$BIN_DIR_CLIENT"/client{.wasm,_bg.wasm,.js}
fi

echo "✅ Undeploy complete."
