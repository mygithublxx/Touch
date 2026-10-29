#!/usr/bin/env bash
#
# 把 Touch 装到已连接的 iPhone 上。
#
# 前置条件（只需做一次）：
#   1. Xcode > Settings > Accounts 里登录你的 Apple ID（免费账号即可）
#   2. iPhone 用数据线连上 Mac，手机上点「信任此电脑」
#   3. iPhone：设置 > 隐私与安全性 > 开发者模式 > 打开（会重启一次）
#
# 用法：
#   ./scripts/install-to-iphone.sh            # 自动读 Xcode 里登录的团队
#   ./scripts/install-to-iphone.sh <TEAM_ID>  # 手动指定团队 ID
#
set -euo pipefail
cd "$(dirname "$0")/.."

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# ---------- 1. 找设备 ----------
echo "==> 查找已连接的 iPhone"

DEVICE_INFO=""
for _ in $(seq 1 20); do
  xcrun devicectl list devices --json-output /tmp/keel_devices.json >/dev/null 2>&1 || true
  DEVICE_INFO=$(python3 - <<'PY'
import json
try:
    data = json.load(open('/tmp/keel_devices.json'))
except Exception:
    raise SystemExit(0)
for dev in data.get('result', {}).get('devices', []):
    hw = dev.get('hardwareProperties', {})
    if hw.get('platform') != 'iOS':
        continue
    if hw.get('reality') not in (None, 'physical'):
        continue
    state = dev.get('connectionProperties', {}).get('tunnelState', '')
    print(hw.get('udid', ''), dev.get('identifier', ''), state)
    break
PY
)
  STATE=$(echo "${DEVICE_INFO}" | awk '{print $3}')
  if [[ "${STATE}" == "connected" || "${STATE}" == "available" || "${STATE}" == "ready" ]]; then
    break
  fi
  # 已经能拿到 UDID 就不用再等了
  if [[ -n "${STATE}" ]]; then
    break
  fi
  sleep 2
done

if [[ -z "${DEVICE_INFO}" ]]; then
  red "没有找到已连接的 iPhone。"
  dim "· 用数据线连上 Mac（要能传数据的线，纯充电线不行）"
  dim "· 手机上如果弹出「要信任此电脑吗」，点信任"
  dim "· 再跑一次这个脚本"
  exit 1
fi

UDID=$(echo "${DEVICE_INFO}" | awk '{print $1}')
DEVICE_ID=$(echo "${DEVICE_INFO}" | awk '{print $2}')
STATE=$(echo "${DEVICE_INFO}" | awk '{print $3}')

# tunnelState 常常滞后显示 disconnected，devicectl 会在需要时自己建立隧道，
# 所以这里只提示，不阻断。
if [[ "${STATE}" != "connected" && "${STATE}" != "available" && "${STATE}" != "ready" ]]; then
  dim "（列表状态是「${STATE}」，连接会在安装时自动建立）"
fi

green "找到设备：${UDID}"

# ---------- 2. 找签名团队 ----------
echo
echo "==> 查找签名团队"
TEAM_ID="${1:-${DEVELOPMENT_TEAM:-}}"

if [[ -z "${TEAM_ID}" ]]; then
  TEAM_ID=$(defaults read com.apple.dt.Xcode IDEProvisioningTeamByIdentifier 2>/dev/null \
    | grep -oE 'teamID = [A-Z0-9]{10}' | head -1 | awk '{print $3}' || true)
fi

if [[ -z "${TEAM_ID}" ]]; then
  red "没有找到可用的签名团队（Xcode 里还没登录 Apple ID）。"
  dim "打开 Xcode > Settings > Accounts，用 Apple ID 登录后再跑一次。"
  exit 1
fi
green "使用团队：${TEAM_ID}"

# ---------- 3. 编译（自动申请证书、注册设备） ----------
echo
echo "==> 编译（首次会自动申请证书和描述文件，可能要 1-2 分钟）"
xcodebuild \
  -project Touch.xcodeproj \
  -scheme Touch \
  -configuration Debug \
  -destination "id=${UDID}" \
  -derivedDataPath ./build-device \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="${TEAM_ID}" \
  CODE_SIGN_STYLE=Automatic \
  build

APP="./build-device/Build/Products/Debug-iphoneos/Touch.app"
if [[ ! -d "${APP}" ]]; then
  red "编译产物没找到：${APP}"
  exit 1
fi

# ---------- 4. 安装 ----------
echo
echo "==> 安装到手机"
xcrun devicectl device install app --device "${DEVICE_ID}" "${APP}"

echo
green "装好了，正在手机上启动…"
xcrun devicectl device process launch --device "${DEVICE_ID}" com.keel.touch >/dev/null 2>&1 || true
green "完成。手机上应该已经打开了 Touch。"
dim "免费 Apple ID 签的 app 7 天后失效，到期重新跑一次这个脚本即可。"
dim "首次打开如果提示「不受信任的开发者」，去 设置 > 通用 > VPN与设备管理 里信任一下。"