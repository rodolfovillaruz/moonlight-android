#!/bin/bash
# Builds and signs the release APKs inside the moonlight-builder container.
#
# Usage (from the repo root on the host):
#   docker build -t moonlight-builder docker/
#   read -s KS_PASS; export KS_PASS
#   docker run --rm -it --user "$(id -u):$(id -g)" \
#     -e KS_PASS -e HOME=/tmp \
#     -v "$PWD":/src -v ~/keys:/keys:ro -v moonlight-gradle:/gradle \
#     moonlight-builder bash docker/build-release.sh
#
# Set KEYSTORE to override the default /keys/moonlight-fork.jks.
# Only the nonRoot flavor is built; the signed APK is written to dist/.
set -euo pipefail

KEYSTORE="${KEYSTORE:-/keys/moonlight-fork.jks}"

if [ ! -f "$KEYSTORE" ]; then
    echo "Keystore not found at $KEYSTORE" >&2
    exit 1
fi
if [ -z "${KS_PASS:-}" ]; then
    echo "KS_PASS is not set" >&2
    exit 1
fi

git config --global --add safe.directory '*'
git submodule update --init --recursive

./gradlew --no-daemon assembleNonRootRelease

unsigned="app/build/outputs/apk/nonRoot/release/app-nonRoot-release-unsigned.apk"
aligned="$(mktemp --suffix=.apk)"
out="dist/app-nonRoot-release.apk"

mkdir -p dist
zipalign -p -f 4 "$unsigned" "$aligned"
apksigner sign --ks "$KEYSTORE" --ks-pass env:KS_PASS --out "$out" "$aligned"
rm -f "$aligned"

apksigner verify --print-certs "$out"
echo "Signed: $out"
