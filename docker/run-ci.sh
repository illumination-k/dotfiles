#!/bin/bash
set -eu

# nixでOCIイメージをビルドしてローカルdockerへロードする。
#   ./docker/run-ci.sh          # runtime + dev 両方
#   ./docker/run-ci.sh --dev    # devのみ
# nixが無い環境（macOS等）ではnixos/nixコンテナ内でビルドする。
# キャッシュを持たないため毎回フル置換ダウンロードになる点に注意
# （普段のビルドはGitHub Actionsに任せる想定）。

NIX_IMAGE="nixos/nix:2.34.6@sha256:e2fe74e96e965653c7b8f16ac64d1e56581c63c84d7fa07fb0692fd055cd06b0"

build() {
  attr="$1"
  if command -v nix >/dev/null 2>&1; then
    nix build ".#${attr}" -o "result-${attr}"
    "./result-${attr}" | docker load
  else
    echo "nix not found; building inside ${NIX_IMAGE} (slow, no cache)" >&2
    docker run --rm -i -v "$(pwd)":/workspace -w /workspace "$NIX_IMAGE" \
      sh -c "nix --extra-experimental-features 'nix-command flakes' \
               build --option filter-syscalls false '.#${attr}' -o /tmp/stream \
             && /tmp/stream" \
      | docker load
  fi
}

if [ "${1:-}" = "--dev" ]; then
  build docker-dev
  echo ""
  echo "=== SUCCESS (devenv-dev:latest) ==="
  exit 0
fi

build docker-runtime
build docker-dev
echo ""
echo "=== SUCCESS (devenv:latest, devenv-dev:latest) ==="
