#!/bin/bash
set -e

cd /home/clubrust/source

echo "📤 Staging changes..."
sudo git add .

echo "📝 Commit message:"
read -r msg

sudo git commit -m "$msg"
sudo git push origin main

echo "✅ Pushed."
