#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.29.3"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -o /tmp/flutter.tar.xz
  tar -xf /tmp/flutter.tar.xz -C "$HOME"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

git config --global --add safe.directory "$FLUTTER_DIR"
git config --global --add safe.directory "$FLUTTER_DIR/bin/cache/dart-sdk"

flutter config --no-analytics
flutter pub get
flutter build web --release

# Pin Vercel project — prevents project.json from being overwritten by vercel link
mkdir -p build/web/.vercel
cat > build/web/.vercel/project.json <<'EOF'
{"projectId":"prj_di5mduRXxdXuFva0soDuyTKtEJfQ","orgId":"team_yo4gmMpIsl0PNUdjev1yat9k","projectName":"web"}
EOF
