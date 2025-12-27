#!/bin/bash
set -e

NOW=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/home/clubrust/backups/$NOW"
SRC_WORLDS="/home/clubrust/worlds"
SRC_DB="/home/clubrust/data"
SRC_CONFIGS="/home/clubrust/server/config"
LATEST_LINK="/home/clubrust/backups/latest"

mkdir -p "$BACKUP_DIR"

echo "📦 Backing up worlds..."
[ -d "$SRC_WORLDS" ] && cp -r "$SRC_WORLDS" "$BACKUP_DIR/" || echo "⚠️ No worlds/ dir"

echo "🧠 Backing up database..."
[ -d "$SRC_DB" ] && cp -r "$SRC_DB" "$BACKUP_DIR/" || echo "⚠️ No data/ dir"

echo "🛠️  Backing up configs..."
[ -d "$SRC_CONFIGS" ] && cp -r "$SRC_CONFIGS" "$BACKUP_DIR/" || echo "⚠️ No config/ dir"

# Update symlink
rm -f "$LATEST_LINK"
ln -s "$BACKUP_DIR" "$LATEST_LINK"

echo "✅ Backup complete → $BACKUP_DIR"
