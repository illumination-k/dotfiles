#!/bin/bash
set -eu

IMAGE="dotfiles-ci"

# インタラクティブモード（デバッグ用）
if [ "${1:-}" = "--interactive" ]; then
  docker build -f docker/Dockerfile.ci -t "$IMAGE" --target=nix-base .
  docker run -it --rm -v $(pwd):/workspace "$IMAGE"
  exit 0
fi

# dev podイメージビルドモード
if [ "${1:-}" = "--dev" ]; then
  docker build -f docker/Dockerfile.ci --target=dev -t "${IMAGE}-dev" .
  echo ""
  echo "=== SUCCESS (dev image: ${IMAGE}-dev) ==="
  exit 0
fi

# CI テストモード（デフォルト）
echo "=== Building and testing Home Manager ==="
docker build -f docker/Dockerfile.ci --target=runtime -t "$IMAGE" .
echo ""
echo "=== SUCCESS ==="
