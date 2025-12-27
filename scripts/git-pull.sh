#!/bin/bash
set -e

cd /home/clubrust/source
echo "📥 Pulling latest from GitHub..."
sudo git pull origin main
echo "✅ Done."
