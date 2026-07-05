#!/bin/sh
# kubectl exec から開発ユーザーのログインシェルに入るヘルパー:
#   kubectl exec -it claude-dev-0 -- /usr/local/bin/dev-login
# イメージにはsu/setprivが無いため、coreutilsのchroot --userspecでroot権限を落とす。
# コンテナenv（ANTHROPIC_API_KEY等）はそのまま引き継がれる。
set -eu

U="${DEV_USER:-illumination-k}"
H="/home/${U}"
BIN="${H}/result/home-path/bin"

exec chroot --userspec="${U}:${U}" --groups="${U}" / \
  env HOME="${H}" USER="${U}" LOGNAME="${U}" SHELL="${BIN}/zsh" \
  "${BIN}/zsh" -l
