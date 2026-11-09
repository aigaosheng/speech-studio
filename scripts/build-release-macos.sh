#!/bin/bash
# Builds the Speech Studio .dmg for Apple silicon, signed ad hoc. Engines and models are downloaded in the app
# ("First run"); the bundle carries only the frontend.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
staging="$root/desktop/src-tauri/staging"

cd "$root"
npm --prefix frontend ci --no-audit --no-fund
npm --prefix frontend run build
cargo test --workspace

rm -rf "$staging"
mkdir -p "$staging/frontend"
cp -r frontend/dist "$staging/frontend/dist"
echo "[OK] bundle staged in $staging"

npm --prefix desktop ci --no-audit --no-fund
cd desktop
npm exec tauri build -- --target aarch64-apple-darwin --config src-tauri/tauri.macos-release.conf.json --bundles dmg

dmg_dir="src-tauri/target/aarch64-apple-darwin/release/bundle/dmg"
find "$dmg_dir" -name '*.dmg' -print
cat <<'EOF'

[INFO] This ad-hoc signed, non-notarized app requires a one-time Gatekeeper approval.
After copying Speech Studio.app from the mounted DMG to Applications, Control-click
the app, choose Open, then confirm Open in the dialog. This approves only this app.
Only approve a build you trust; do not disable Gatekeeper.
EOF
