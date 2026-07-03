#!/bin/sh
# dev pod entrypoint: sshdをフォアグラウンドで起動する
# - ホストキーを/data/ssh（PVC推奨）に生成・永続化
# - Secret経由のAUTHORIZED_KEYSをユーザーのauthorized_keysへ配置
# - コンテナenvのAPIキー類をssh経由のセッションにも伝搬
set -eu

USERNAME="${DEV_USER:-illumination-k}"
HOME_DIR="/home/${USERNAME}"
BIN="${HOME_DIR}/result/home-path/bin"

uid() { awk -F: -v u="$1" '$1 == u { print $3 }' /etc/passwd; }
gid() { awk -F: -v u="$1" '$1 == u { print $4 }' /etc/passwd; }
USER_UID="$(uid "${USERNAME}")"
USER_GID="$(gid "${USERNAME}")"

# --- sshホストキー ---
mkdir -p /data/ssh
if [ ! -f /data/ssh/ssh_host_ed25519_key ]; then
  "${BIN}/ssh-keygen" -t ed25519 -N '' -f /data/ssh/ssh_host_ed25519_key
fi
chmod 600 /data/ssh/ssh_host_ed25519_key

# --- authorized_keys（Secretの環境変数から） ---
if [ -n "${AUTHORIZED_KEYS:-}" ]; then
  mkdir -p "${HOME_DIR}/.ssh"
  printf '%s\n' "${AUTHORIZED_KEYS}" > "${HOME_DIR}/.ssh/authorized_keys"
  chmod 700 "${HOME_DIR}/.ssh"
  chmod 600 "${HOME_DIR}/.ssh/authorized_keys"
fi

# --- コンテナenvをsshセッションへ伝搬 ---
# kubectl execはコンテナenvをそのまま継承するが、sshdは継承しないため、
# ホワイトリストのenvを/etc/zshenvと~/.ssh/environmentに書き出す
EXPORT_VARS="${DEV_POD_EXPORT_VARS:-ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL CLAUDE_CONFIG_DIR HTTP_PROXY HTTPS_PROXY NO_PROXY}"
: > /etc/zshenv
mkdir -p "${HOME_DIR}/.ssh"
: > "${HOME_DIR}/.ssh/environment"
for var in ${EXPORT_VARS}; do
  eval "val=\${${var}:-}"
  [ -n "${val}" ] || continue
  escaped=$(printf '%s' "${val}" | sed "s/'/'\\\\''/g")
  printf "export %s='%s'\n" "${var}" "${escaped}" >> /etc/zshenv
  printf '%s=%s\n' "${var}" "${val}" >> "${HOME_DIR}/.ssh/environment"
done
chmod 644 /etc/zshenv
chmod 600 "${HOME_DIR}/.ssh/environment"

# --- PVCマウント点の所有権（マウント直後はroot所有のため） ---
for d in /workspace "${HOME_DIR}/.claude" "${HOME_DIR}/.ssh"; do
  if [ -e "${d}" ]; then
    chown -R "${USER_UID}:${USER_GID}" "${d}"
  fi
done

exec "${BIN}/sshd" -D -e -f /etc/ssh/sshd_config
