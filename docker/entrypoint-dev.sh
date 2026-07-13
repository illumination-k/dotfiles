#!/bin/sh
# dev pod entrypoint: sshdをフォアグラウンドで起動する
# - ホストキーを/data/ssh（PVC推奨）に生成・永続化
# - Secret経由のAUTHORIZED_KEYSをユーザーのauthorized_keysへ配置
# - コンテナenvのAPIキー類をssh経由のセッションにも伝搬
set -eu

USERNAME="${DEV_USER:-illumination-k}"
HOME_DIR="/home/${USERNAME}"
BIN="${HOME_DIR}/result/home-path/bin"
SSH_DIR="${HOME_DIR}/.ssh"

USER_UID="$(id -u "${USERNAME}")"
USER_GID="$(id -g "${USERNAME}")"

# --- sshホストキー ---
mkdir -p /data/ssh
if [ ! -f /data/ssh/ssh_host_ed25519_key ]; then
  "${BIN}/ssh-keygen" -t ed25519 -N '' -f /data/ssh/ssh_host_ed25519_key
fi
chmod 600 /data/ssh/ssh_host_ed25519_key

mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# --- authorized_keys（Secretの環境変数から） ---
if [ -n "${AUTHORIZED_KEYS:-}" ]; then
  printf '%s\n' "${AUTHORIZED_KEYS}" > "${SSH_DIR}/authorized_keys"
  chmod 600 "${SSH_DIR}/authorized_keys"
fi

# --- コンテナenvをsshセッションへ伝搬 ---
# kubectl execはコンテナenvをそのまま継承するが、sshdは継承しないため、
# ホワイトリストのenvを~/.ssh/environment（sshd_configの
# PermitUserEnvironmentで有効化、600でユーザーのみ読める）に書き出す。
# 改行を含む値はsshdのパーサが扱えないためスキップする。
EXPORT_VARS="${DEV_POD_EXPORT_VARS:-ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL CLAUDE_CONFIG_DIR HTTP_PROXY HTTPS_PROXY NO_PROXY}"
NL="$(printf '\nx')"
NL="${NL%x}"
: > "${SSH_DIR}/environment"
chmod 600 "${SSH_DIR}/environment"
# PATHは常に書き出す（sshdの組み込みデフォルトPATHにはnixのbinが含まれず、
# git/claude等がssh経由で見つからなくなるため）
printf 'PATH=%s\n' "${PATH}" >> "${SSH_DIR}/environment"
for var in ${EXPORT_VARS}; do
  case "${var}" in
    *[!A-Za-z0-9_]* | [0-9]*)
      echo "entrypoint-dev: skipping invalid variable name: ${var}" >&2
      continue
      ;;
  esac
  val="$(printenv "${var}" 2>/dev/null || true)"
  [ -n "${val}" ] || continue
  case "${val}" in
    *"${NL}"*)
      echo "entrypoint-dev: skipping ${var}: multi-line values are not supported by sshd" >&2
      continue
      ;;
  esac
  printf '%s=%s\n' "${var}" "${val}" >> "${SSH_DIR}/environment"
done

# --- マウント点の所有権 ---
# PVCの初回マウント時はroot所有になるためユーザーへ渡す。
# 2回目以降のchown -R（大きなworkspaceではO(ファイル数)）を避けるため、
# トップレベルの所有者が既に一致していればスキップする。
chown -R "${USER_UID}:${USER_GID}" "${SSH_DIR}"
for d in /workspace "${HOME_DIR}/.claude"; do
  if [ -e "${d}" ] && [ "$(stat -c %u "${d}")" != "${USER_UID}" ]; then
    chown -R "${USER_UID}:${USER_GID}" "${d}"
  fi
done

exec "${BIN}/sshd" -D -e -f /etc/ssh/sshd_config
