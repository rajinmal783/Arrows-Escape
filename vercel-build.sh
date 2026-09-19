#!/bin/bash
set -e

echo "=== Installing Flutter SDK for Vercel Deployment ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

echo "=== Flutter Version ==="
flutter --version

echo "=== Getting Dependencies ==="
flutter pub get

echo "=== Building Flutter Web Release Bundle ==="
flutter build web --release

echo "=== Build Complete ==="
