#!/bin/bash
set -e

SRC_DIR="/home/clubrust/source"
BIN_DIR_SERVER="/home/clubrust/server"
BIN_DIR_ADMIN="/home/clubrust/admin"
BIN_DIR_CLIENT="/home/clubrust/client" # placeholder if needed
BUILD_TARGET="release"

# Defaults
BUILD_SERVER=false
BUILD_ADMIN=false
BUILD_CLIENT=false

# Parse args
for arg in "$@"; do
    case $arg in
        --server) BUILD_SERVER=true ;;
        --admin) BUILD_ADMIN=true ;;
        --client) BUILD_CLIENT=true ;;
        --all) BUILD_SERVER=true; BUILD_ADMIN=true; BUILD_CLIENT=true ;;
    esac
done

# Validate at least one target is selected
if ! $BUILD_SERVER && ! $BUILD_ADMIN && ! $BUILD_CLIENT; then
    echo "❌ No targets specified. Use --server, --admin, --client, or --all."
    exit 1
fi

cd "$SRC_DIR"
echo "📥 Pulling latest source from GitHub..."
git pull origin main
echo "✅ Done."

# Clear deployed www dir
echo "🧹 Clearing deployed client assets..."
rm -rf "$BIN_DIR_SERVER/www"
mkdir -p "$BIN_DIR_SERVER/www"

# Copy raw client assets from source (HTML, CSS, JS)
if [ -d "$SRC_DIR/server/www" ]; then
    cp -r "$SRC_DIR/server/www/"* "$BIN_DIR_SERVER/www/" || true
else
    echo "⚠️  Warning: No static assets found in server/www/"
fi

# Build + deploy server
if $BUILD_SERVER; then
    echo "🔨 Building server..."
    cargo build --release -p server

    echo "🚀 Deploying server binary..."
    cp "target/$BUILD_TARGET/server" "$BIN_DIR_SERVER/server"

    echo "♻️ Restarting clubrust.service..."
    sudo systemctl restart clubrust
fi

# Build + deploy admin
if $BUILD_ADMIN; then
    echo "🔨 Building admin..."
    cargo build --release -p admin

    echo "🚀 Deploying admin binary..."
    cp "target/$BUILD_TARGET/admin" "$BIN_DIR_ADMIN/admin"
fi

# Build + deploy client
if $BUILD_CLIENT; then
    echo "🔨 Building client (WASM)..."
    cd "$SRC_DIR/client"

    # Build the client for WASM
    cargo build --release --target wasm32-unknown-unknown

    wasm_input="$SRC_DIR/target/wasm32-unknown-unknown/release/client.wasm"
    out_dir="$BIN_DIR_SERVER/www/"
    mkdir -p "$out_dir"

    # Postprocess with wasm-bindgen (must be installed via `cargo install wasm-bindgen-cli`)
    ~/.cargo/bin/wasm-bindgen "$wasm_input" --target web --out-dir "$out_dir"

    echo "🚀 Deploying client to $out_dir"
    cd "$SRC_DIR"
fi


echo "✅ Deploy finished."
