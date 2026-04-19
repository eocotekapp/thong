#ver 1.3
#!/usr/bin/env bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

DEVICE_FILE="$HOME/adb_devices_names.txt"
LAST_VIDEO_FILE="$HOME/.adbtool_last_video"
COMMON_THRESHOLD_PERCENT=60
CACHE_DIR="$HOME/.adbtool_cache"
TMP_URL_LIST="$CACHE_DIR/.tmp_url_files.txt"

SAVED_IPS=(
"100.117.125.74"
"100.101.18.125"
"10.48.154.1"
"10.48.154.5"
"10.48.154.152"
"10.48.154.122"
"10.48.154.125"
"10.48.154.217"
"10.48.154.75"
"10.48.154.151"
"10.48.154.177"
"10.48.154.137"
"10.48.154.249"
"10.48.154.154"
"10.48.154.83"
"10.48.154.85"
"10.48.154.193"
"10.48.154.196"
"10.48.154.175"
"10.48.154.22"
"10.48.154.63"
"10.48.154.250"
"10.48.154.252"
"10.48.154.107"
"10.48.154.50"
"10.48.155.26"
"10.48.155.58"
"10.48.155.128"
"10.48.155.145"
"10.48.155.253"
"10.48.155.92"
"10.48.155.62"
"10.48.155.29"
"10.48.155.82"
"10.48.155.171"
"10.48.155.59"
"10.48.155.173"
"10.48.155.61"
"10.48.155.248"
"10.48.155.50"
"10.48.155.228"
"10.48.155.240"
"10.48.155.115"
"10.48.155.97"
"10.48.155.244"
"10.48.155.48"
"10.48.155.32"
"10.48.155.201"
"10.48.155.191"
"10.48.155.68"
"10.48.155.27"
"10.48.155.30"
"10.48.155.125"
"10.48.155.83"
"10.48.155.86"
"10.48.155.36"
"10.48.155.245"
"10.48.155.57"
"10.48.154.98"
"10.48.154.101"
"10.48.154.102"
"10.48.154.103"
"10.48.154.109"
"10.48.154.110"
"10.48.154.113"
"10.48.154.116"
"10.48.154.118"
"10.48.154.134"
"10.48.154.147"
"10.48.154.149"
"10.48.154.158"
"10.48.154.183"
"10.48.154.209"
"10.48.154.234"
"10.48.154.243"
"10.48.155.47"
"10.48.155.129"
"10.48.155.172"
"10.48.155.203"
"10.48.155.238"
)

ESC=$'\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
BLINK="${ESC}[5m"

BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"

BRIGHT_BLACK="${ESC}[90m"
BRIGHT_RED="${ESC}[91m"
BRIGHT_GREEN="${ESC}[92m"
BRIGHT_YELLOW="${ESC}[93m"
BRIGHT_BLUE="${ESC}[94m"
BRIGHT_MAGENTA="${ESC}[95m"
BRIGHT_CYAN="${ESC}[96m"
BRIGHT_WHITE="${ESC}[97m"

COLORS=(
"$BRIGHT_RED"
"$BRIGHT_YELLOW"
"$BRIGHT_GREEN"
"$BRIGHT_CYAN"
"$BRIGHT_BLUE"
"$BRIGHT_MAGENTA"
)

cleanup_temp_files() {
if [ -f "$TMP_URL_LIST" ]; then
while IFS= read -r f; do
[ -n "$f" ] && [ -f "$f" ] && rm -f "$f"
done < "$TMP_URL_LIST"
: > "$TMP_URL_LIST"
fi
}

register_temp_file() {
local f="$1"
[ -n "$f" ] || return 0
grep -Fxq "$f" "$TMP_URL_LIST" 2>/dev/null || echo "$f" >> "$TMP_URL_LIST"
}

init_device_file() {
if [ ! -f "$DEVICE_FILE" ]; then
cat > "$DEVICE_FILE" <<'EODEV'
k 201|10.48.154.116:5555
k 202|100.101.18.125:5555
k 202|10.48.154.209:5555
k 203|10.48.155.203:5555
k 204|10.48.155.238:5555
k 205|10.48.155.129:5555
k 240|10.48.154.217:5555
k 251|10.48.154.125:5555
k 252|10.48.155.172:5555
k 253|10.48.154.154:5555
k 254|10.48.154.151:5555
k 255|10.48.154.152:5555
k 256|10.48.154.149:5555
k 261|10.48.154.234:5555
k 264|10.48.154.118:5555
k 266|10.48.155.97:5555
k 267|10.48.155.145:5555
k 268|10.48.154.5:5555
k 269|10.48.154.109:5555
k 270|10.48.154.110:5555
k 271|10.48.154.183:5555
k 273|10.48.155.48:5555
k 274|10.48.154.113:5555
k 275|10.48.154.99:5555
k 276|10.48.154.98:5555
k 277|10.48.154.102:5555
k 278|10.48.154.103:5555
k 280|10.48.155.47:5555
k 282|10.48.154.147:5555
k 283|10.48.154.134:5555
k 284|10.48.154.101:5555
k 285|10.48.154.243:5555
k 286|10.48.154.158:5555
EODEV
fi
}

need_cmd() {
command -v "$1" >/dev/null 2>&1 || {
printf "%bThiếu lệnh:%b %s\n" "$BRIGHT_RED$BOLD" "$RESET" "$1"
exit 1
}
}

pause_enter() {
echo ""
printf "%bNhấn Enter để tiếp tục...%b" "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r dummy
}

rand_color() {
local idx=$((RANDOM % ${#COLORS[@]}))
printf "%b" "${COLORS[$idx]}"
}

gradient_text() {
local text="$1"
local i char idx total
total=${#COLORS[@]}
for ((i=0; i<${#text}; i++)); do
char="${text:$i:1}"
idx=$((i % total))
printf "%b%s%b" "${COLORS[$idx]}$BOLD" "$char" "$RESET"
done
}

rainbow_text_shift() {
local text="$1"
local shift="$2"
local i char idx total
total=${#COLORS[@]}
for ((i=0; i<${#text}; i++)); do
char="${text:$i:1}"
idx=$(((i + shift) % total))
printf "%b%s%b" "${COLORS[$idx]}$BOLD" "$char" "$RESET"
done
}

ui_line() {
local color
color=$(rand_color)
printf "%b=======================================================%b\n" "$color$BOLD" "$RESET"
}

ui_ok() {
printf "%b%s%b\n" "$BRIGHT_GREEN$BOLD" "$1" "$RESET"
}

ui_warn() {
printf "%b%s%b\n" "$BRIGHT_YELLOW$BOLD" "$1" "$RESET"
}

ui_err() {
printf "%b%s%b\n" "$BRIGHT_RED$BOLD" "$1" "$RESET"
}

ui_info() {
printf "%b%s%b\n" "$BRIGHT_CYAN$BOLD" "$1" "$RESET"
}

ui_dim() {
printf "%b%s%b\n" "$DIM$BRIGHT_WHITE" "$1" "$RESET"
}

draw_progress_bar_spinner() {
local label="$1"
local done="$2"
local total="$3"
local color="$4"
local spin_idx="$5"
local width=20
local percent=0
local filled=0
local empty=0
local filled_bar=""
local empty_bar=""

[ "$total" -le 0 ] && total=1

percent=$((done * 100 / total))
filled=$((done * width / total))
empty=$((width - filled))

filled_bar=$(printf "%${filled}s" "" | sed 's/ /🇻🇳/g')
empty_bar=$(printf "%${empty}s" "" | tr ' ' '·')

printf "\r%b%s%b %b[%s%b%b%s%b] %3d%% (%d/%d)%b" \
"$color$BOLD" "$label" "$RESET" \
"$color$BOLD" "$filled_bar" "$RESET" \
"$BRIGHT_BLACK" "$empty_bar" "$RESET" \
"$percent" "$done" "$total" "$RESET"
}

show_progress_until_done() {
local progress_file="$1"
local total="$2"
local label="$3"
local color="$4"
local done=0
local spin_idx=0

while true; do
done=$(wc -l < "$progress_file" 2>/dev/null | tr -d ' ')
[ -z "$done" ] && done=0
draw_progress_bar_spinner "$label" "$done" "$total" "$color" "$spin_idx"
[ "$done" -ge "$total" ] && break
spin_idx=$((spin_idx + 1))
sleep 0.08
done

echo ""
}

intro_animation() {
local title="ADB TOOL MENU - ©Thoòng 🤗"
local i

clear
for i in 0 1 2 3 4 5 6 7; do
printf "${ESC}[H${ESC}[2J"
ui_line
printf "   "
rainbow_text_shift "$title" "$i"
printf "\n"
ui_line
printf "%b                Đang tải giao diện...%b\n" "$BRIGHT_MAGENTA$BLINK" "$RESET"
sleep 0.08
done
}

ui_title() {
intro_animation
printf "${ESC}[H${ESC}[2J"
ui_line
printf "   "
gradient_text "ADB TOOL MENU - ©Thoòng 🤗"
printf "\n"
ui_line
}

get_name_by_ip() {
local ip="$1"
local name
name=$(grep -F "|$ip" "$DEVICE_FILE" | head -n 1 | cut -d'|' -f1)
if [ -n "$name" ]; then
echo "$name"
else
echo "$ip"
fi
}

adb_start_clean() {
adb start-server >/dev/null 2>&1
}

list_connected_devices_raw() {
adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {print $1}'
}

list_connected_devices_named() {
local devices
local i
local dev
local name

devices=$(list_connected_devices_raw)
if [ -z "$devices" ]; then
ui_warn "Không có thiết bị nào đang connect."
return
fi

i=1
while IFS= read -r dev; do
[ -z "$dev" ] && continue
name=$(get_name_by_ip "$dev")
printf "%b%s)%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$i" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
i=$((i+1))
done <<EOLIST
$devices
EOLIST
}

save_last_video() {
echo "$1" > "$LAST_VIDEO_FILE"
}

get_last_video() {
if [ -f "$LAST_VIDEO_FILE" ]; then
cat "$LAST_VIDEO_FILE"
fi
}

sanitize_filename() {
local name="$1"
name="${name##*/}"
name="${name%%\?*}"
name="${name%%\#*}"
name="${name//\\/}"
name="${name//\//_}"
echo "$name"
}

get_file_ext() {
local f="$1"
local base="${f##*/}"
if [[ "$base" == *.* ]]; then
echo ".${base##*.}"
else
echo ""
fi
}

show_download_progress() {
local url="$1"
local out="$2"

echo ""
ui_info "⬇ Đang tải video vào cache tạm..."
if command -v curl >/dev/null 2>&1; then
curl -L --progress-bar "$url" -o "$out"
else
/system/bin/curl -L --progress-bar "$url" -o "$out"
fi
local rc=$?
echo ""
return $rc
}

adb_push_with_progress() {
local serial="$1"
local src="$2"
local dst="$3"
adb -s "$serial" push "$src" "$dst"
}

adb_pull_with_progress() {
local serial="$1"
local src="$2"
local dst="$3"
adb -s "$serial" pull "$src" "$dst"
}

open_upload_web_local() {
local url="https://thong-url-1.onrender.com"

echo ""
ui_info "🌐 Đang mở trang web upload trên thiết bị này..."

if [ -x /system/bin/am ]; then
/system/bin/am start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã mở web bằng /system/bin/am"
return 0
}
fi

if [ -x /system/bin/cmd ]; then
/system/bin/cmd activity start-activity -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã mở web bằng /system/bin/cmd"
return 0
}
/system/bin/cmd activity start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã mở web bằng /system/bin/cmd"
return 0
}
fi

if command -v am >/dev/null 2>&1; then
am start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã mở web bằng am"
return 0
}
fi

if command -v cmd >/dev/null 2>&1; then
cmd activity start-activity -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã mở web bằng cmd"
return 0
}
cmd activity start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã mở web bằng cmd"
return 0
}
fi

if command -v uiopen >/dev/null 2>&1; then
uiopen "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã gửi lệnh mở web trên iOS / iSH"
return 0
}
fi

if command -v open >/dev/null 2>&1; then
open "$url" >/dev/null 2>&1 && {
ui_ok "✅ Đã gửi lệnh mở web trên iOS / iSH"
return 0
}
fi

ui_warn "⚠ Không mở tự động được."
ui_warn "Hãy copy link bên dưới để mở tay:"
printf "%b%s%b\n" "$BRIGHT_YELLOW$BOLD" "$url" "$RESET"
return 0
}

pick_video_path() {
local last
local file

last=$(get_last_video)

ui_info "Nhập đường dẫn video."
if [ -n "$last" ]; then
ui_dim "Video lần trước: $last"
fi
ui_dim "Ví dụ:"
ui_dim "/storage/emulated/0/Download/vario.mp4"
ui_dim "/sdcard/Download/vario.mp4"
printf "%bĐường dẫn video:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r file

if [ -z "$file" ] && [ -n "$last" ]; then
file="$last"
fi

if [ ! -f "$file" ]; then
ui_err "Không tìm thấy file: $file"
return 1
fi

save_last_video "$file"
VIDEO_PATH="$file"
VIDEO_NAME=$(basename "$file")
return 0
}

connect_saved_ip_list() {
local tmp_ips="$CACHE_DIR/.saved_ips.tmp"
local tmp_open="$CACHE_DIR/.open_ips.tmp"
local tmp_ok="$CACHE_DIR/.ok_ips.tmp"
local tmp_progress_scan="$CACHE_DIR/.progress_scan.tmp"
local tmp_progress_connect="$CACHE_DIR/.progress_connect.tmp"
local ip
local dev
local name
local total=0
local open_total=0
local ok=0
local fail=0
local batch_size=12
local c=0

adb_start_clean
set +m 2>/dev/null

: > "$tmp_ips"
: > "$tmp_open"
: > "$tmp_ok"
: > "$tmp_progress_scan"
: > "$tmp_progress_connect"

printf "%s\n" "${SAVED_IPS[@]}" | sort -u > "$tmp_ips"
total=$(wc -l < "$tmp_ips" | tr -d ' ')

echo ""
ui_info "📡 Đang lọc IP mở port 5555..."

while IFS= read -r ip; do
[ -z "$ip" ] && continue

(
nc -w 1 "$ip" 5555 </dev/null >/dev/null 2>&1 && echo "$ip" >> "$tmp_open"
echo 1 >> "$tmp_progress_scan"
) &

c=$((c+1))
if [ "$c" -ge "$batch_size" ]; then
wait
c=0
fi
done < "$tmp_ips"

show_progress_until_done "$tmp_progress_scan" "$total" "Đang lọc IP mở port 5555..." "$BRIGHT_CYAN"

wait
sort -u "$tmp_open" -o "$tmp_open"
open_total=$(wc -l < "$tmp_open" | tr -d ' ')

if [ ! -s "$tmp_open" ]; then
echo ""
ui_warn "Không có IP nào mở port 5555."
rm -f "$tmp_ips" "$tmp_open" "$tmp_ok" "$tmp_progress_scan" "$tmp_progress_connect"
return
fi

echo ""
ui_info "🔗 Đang connect 2 lần tới các IP online..."

c=0
while IFS= read -r ip; do
[ -z "$ip" ] && continue

(
dev="$ip:5555"
adb connect "$dev" >/dev/null 2>&1
sleep 0.15
adb connect "$dev" >/dev/null 2>&1
echo 1 >> "$tmp_progress_connect"
) &

c=$((c+1))
if [ "$c" -ge "$batch_size" ]; then
wait
c=0
fi
done < "$tmp_open"

show_progress_until_done "$tmp_progress_connect" "$open_total" "Đang connect 2 lần tới các IP online..." "$BRIGHT_GREEN"

wait

adb devices 2>/dev/null | awk 'NR>1 && $1 ~ /:5555$/ && $2=="device" {print $1}' | sort -u > "$tmp_ok"

echo ""
while IFS= read -r dev; do
[ -z "$dev" ] && continue
name=$(get_name_by_ip "$dev")
printf "%b✅%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_GREEN$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
done < "$tmp_ok"

ok=$(wc -l < "$tmp_ok" | tr -d ' ')
fail=$((open_total - ok))

echo ""
ui_info "Tổng IP trong danh sách: $total"
ui_info "IP mở port 5555: $open_total"
ui_info "Kết quả connect: OK=$ok | FAIL=$fail"

echo ""
ui_ok "✅ Thiết bị đang connect:"
list_connected_devices_named

rm -f "$tmp_ips" "$tmp_open" "$tmp_ok" "$tmp_progress_scan" "$tmp_progress_connect"
}

connect_manual() {
local ips
local dev

adb_start_clean

ui_info "Nhập 1 hoặc nhiều IP:port"
ui_dim "Ví dụ:"
ui_dim "10.48.154.101:5555 10.48.155.203:5555"
printf "%bIP cần connect:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r ips

if [ -z "$ips" ]; then
ui_err "❌ Chưa nhập IP"
return
fi

for dev in $ips; do
printf "%b🔌 %s%b\n" "$BRIGHT_CYAN$BOLD" "$dev" "$RESET"
adb connect "$dev"
sleep 0.3
adb connect "$dev" >/dev/null 2>&1
done

echo ""
ui_ok "✅ Xong. Thiết bị đang connect:"
list_connected_devices_named
}

choose_devices() {
local devices
local line
local i
local choice
local idx
local dev
local name

devices=$(list_connected_devices_raw)

if [ -z "$devices" ]; then
ui_err "❌ Không có thiết bị nào đang connect."
return 1
fi

DEV_ARR=()
while IFS= read -r line; do
[ -n "$line" ] && DEV_ARR+=("$line")
done <<EODEVS
$devices
EODEVS

echo ""
ui_line
ui_info "Danh sách thiết bị đang connect:"
i=1
for dev in "${DEV_ARR[@]}"; do
[ -z "$dev" ] && continue
name=$(get_name_by_ip "$dev")
printf "%b%s)%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$i" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
i=$((i+1))
done

echo ""
ui_dim "Nhập:"
printf "%ball%b  -> tất cả\n" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b1 2 5%b -> chọn các máy theo số\n" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%bChọn thiết bị:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r choice

SELECTED_DEVICES=()

if [ "$choice" = "all" ]; then
for dev in "${DEV_ARR[@]}"; do
[ -n "$dev" ] && SELECTED_DEVICES+=("$dev")
done
else
for idx in $choice; do
case "$idx" in
''|*[!0-9]*)
;;
*)
if [ "$idx" -ge 1 ] && [ "$idx" -le "${#DEV_ARR[@]}" ]; then
SELECTED_DEVICES+=("${DEV_ARR[$((idx-1))]}")
fi
;;
esac
done
fi

if [ "${#SELECTED_DEVICES[@]}" -eq 0 ]; then
ui_err "❌ Chưa chọn thiết bị hợp lệ"
return 1
fi

return 0
}

push_video_file_to_selected_devices() {
local src="$1"
local name="$2"
local dev
local devname
local ok=0
local fail=0

choose_devices || return 1

echo ""
ui_info "📤 Đang push: $name"
for dev in "${SELECTED_DEVICES[@]}"; do
devname=$(get_name_by_ip "$dev")
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$devname" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"

adb_push_with_progress "$dev" "$src" /sdcard/Download/
if [ $? -eq 0 ]; then
ui_ok "   ✅ OK"
ok=$((ok+1))
else
ui_err "   ❌ FAIL"
fail=$((fail+1))
fi
echo ""
done

ui_info "Kết quả push: OK=$ok | FAIL=$fail"
}

push_to_selected() {
pick_video_path || return
push_video_file_to_selected_devices "$VIDEO_PATH" "$VIDEO_NAME"
}

download_video_url_to_cache_and_push() {
local url
local tmp_name
local ext
local tmp_file
local new_name
local final_file
local final_name
local mode

echo ""
ui_info "Nhập URL video để tải tạm vào cache app."
printf "%bURL video:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r url

if [ -z "$url" ]; then
ui_err "❌ URL trống"
return
fi

tmp_name="$(sanitize_filename "$url")"
[ -z "$tmp_name" ] && tmp_name="video_url.mp4"

ext="$(get_file_ext "$tmp_name")"
[ -z "$ext" ] && ext=".mp4"

tmp_file="$CACHE_DIR/$tmp_name"

show_download_progress "$url" "$tmp_file" || {
ui_err "❌ Tải video thất bại"
[ -f "$tmp_file" ] && rm -f "$tmp_file"
return
}

if [ ! -f "$tmp_file" ]; then
ui_err "❌ Không thấy file sau khi tải"
return
fi

ui_ok "✅ Đã tải xong vào cache tạm:"
ui_dim "$tmp_file"
echo ""
printf "%bĐổi tên file (không cần đuôi, Enter để giữ nguyên):%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r new_name

if [ -n "$new_name" ]; then
case "$new_name" in
*.*) final_name="$new_name" ;;
*) final_name="$new_name$ext" ;;
esac
final_file="$CACHE_DIR/$final_name"
mv -f "$tmp_file" "$final_file"
else
final_file="$tmp_file"
final_name="$(basename "$tmp_file")"
fi

register_temp_file "$final_file"
save_last_video "$final_file"

echo ""
printf "%b1)%b %b📤 Push lên tất cả / chọn máy%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "$RESET"
printf "%b2)%b %b📦 Chỉ tải tạm vào cache, chưa push%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%bChọn:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r mode

case "$mode" in
1)
push_video_file_to_selected_devices "$final_file" "$final_name"
;;
2)
ui_warn "Đã giữ file tạm trong cache. Khi thoát script/app sẽ tự xóa."
;;
*)
ui_warn "Bỏ qua push."
;;
esac
}

list_videos_on_device() {
local dev="$1"

adb -s "$dev" shell "ls -1 /sdcard/Download 2>/dev/null" \
| tr -d '\r' \
| grep -Ei '\.(mp4|mkv|avi|mov|m4v|3gp|webm)$' \
| sort -u
}

show_threshold_videos_and_play() {
local tmpdir
local dev_count
local need_count
local dev
local safe
local count
local name
local found
local idx
local video_name
local display_idx

choose_devices || return

tmpdir=$(mktemp -d)
dev_count="${#SELECTED_DEVICES[@]}"
need_count=$(( (dev_count * COMMON_THRESHOLD_PERCENT + 99) / 100 ))

for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
list_videos_on_device "$dev" > "$tmpdir/$safe.txt"
done

cat "$tmpdir"/*.txt 2>/dev/null | sort | uniq -c | sort -nr > "$tmpdir/counts.txt"

echo ""
ui_line
printf "%bVideo có trên ít nhất %s%% máy đã chọn%b\n" "$BRIGHT_CYAN$BOLD" "$COMMON_THRESHOLD_PERCENT" "$RESET"
printf "%bCần tối thiểu:%b %b%s / %s máy%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "$need_count" "$dev_count" "$RESET"
ui_line

VIDEO_ARR=()
found=0
display_idx=1

while read -r count name; do
[ -z "$name" ] && continue
if [ "$count" -ge "$need_count" ]; then
VIDEO_ARR+=("$name")
printf "%b%s)%b %b%s%b %b[%s/%s máy]%b\n" \
"$BRIGHT_WHITE$BOLD" "$display_idx" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$count" "$dev_count" "$RESET"
display_idx=$((display_idx+1))
found=1
fi
done < "$tmpdir/counts.txt"

if [ "$found" -eq 0 ]; then
ui_err "❌ Không có video nào đạt ngưỡng."
rm -rf "$tmpdir"
return
fi

echo ""
printf "%bChọn số để mở video đó trên các máy đã chọn (Enter để bỏ qua):%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r idx

if [ -z "$idx" ]; then
rm -rf "$tmpdir"
return
fi

case "$idx" in
''|*[!0-9]*)
ui_err "❌ Lựa chọn không hợp lệ"
rm -rf "$tmpdir"
return
;;
esac

if [ "$idx" -lt 1 ] || [ "$idx" -gt "${#VIDEO_ARR[@]}" ]; then
ui_err "❌ Lựa chọn không hợp lệ"
rm -rf "$tmpdir"
return
fi

video_name="${VIDEO_ARR[$((idx-1))]}"

echo ""
ui_info "▶ Đang mở video: $video_name"
for dev in "${SELECTED_DEVICES[@]}"; do
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$(get_name_by_ip "$dev")" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
adb -s "$dev" shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/$video_name" -t "video/*" >/dev/null 2>&1 && ui_ok "   ✅ OK" || ui_err "   ❌ FAIL"
done

rm -rf "$tmpdir"
}

pick_threshold_video_sync_and_play() {
local tmpdir
local dev_count
local need_count
local dev
local safe
local candidates_file
local count
local name
local i
local v
local idx
local video_name
local source_dev
local local_file
local syncans
local line

choose_devices || return

tmpdir=$(mktemp -d)
mkdir -p "$CACHE_DIR"

dev_count="${#SELECTED_DEVICES[@]}"
need_count=$(( (dev_count * COMMON_THRESHOLD_PERCENT + 99) / 100 ))

for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
list_videos_on_device "$dev" > "$tmpdir/$safe.txt"
done

cat "$tmpdir"/*.txt 2>/dev/null | sort | uniq -c | sort -nr > "$tmpdir/counts.txt"

candidates_file="$tmpdir/candidates.txt"
: > "$candidates_file"

while read -r count name; do
[ -z "$name" ] && continue
if [ "$count" -ge "$need_count" ]; then
echo "$name" >> "$candidates_file"
fi
done < "$tmpdir/counts.txt"

if [ ! -s "$candidates_file" ]; then
ui_err "❌ Không có video nào đạt ngưỡng $COMMON_THRESHOLD_PERCENT%."
rm -rf "$tmpdir"
return
fi

VIDEO_ARR=()
while IFS= read -r line; do
[ -n "$line" ] && VIDEO_ARR+=("$line")
done < "$candidates_file"

echo ""
ui_line
ui_info "Chọn video để phát:"
i=1
for v in "${VIDEO_ARR[@]}"; do
[ -z "$v" ] && continue
count=0
for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
if grep -Fxq "$v" "$tmpdir/$safe.txt"; then
count=$((count+1))
fi
done
printf "%b%s)%b %b%s%b %b[%s/%s máy]%b\n" \
"$BRIGHT_WHITE$BOLD" "$i" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$v" "$RESET" \
"$DIM$BRIGHT_WHITE" "$count" "$dev_count" "$RESET"
i=$((i+1))
done

printf "%bChọn số:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r idx

case "$idx" in
''|*[!0-9]*)
ui_err "❌ Lựa chọn không hợp lệ"
rm -rf "$tmpdir"
return
;;
esac

if [ "$idx" -lt 1 ] || [ "$idx" -gt "${#VIDEO_ARR[@]}" ]; then
ui_err "❌ Lựa chọn không hợp lệ"
rm -rf "$tmpdir"
return
fi

video_name="${VIDEO_ARR[$((idx-1))]}"
source_dev=""
HAVE_DEVICES=()
MISSING_DEVICES=()

for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
if grep -Fxq "$video_name" "$tmpdir/$safe.txt"; then
HAVE_DEVICES+=("$dev")
[ -z "$source_dev" ] && source_dev="$dev"
else
MISSING_DEVICES+=("$dev")
fi
done

echo ""
ui_info "Video đã chọn: $video_name"
printf "%bMáy đang có:%b %b%s%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "${#HAVE_DEVICES[@]}" "$RESET"
printf "%bMáy còn thiếu:%b %b%s%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "${#MISSING_DEVICES[@]}" "$RESET"

if [ "${#MISSING_DEVICES[@]}" -gt 0 ]; then
echo ""
printf "%bTự động đồng bộ sang máy còn thiếu rồi phát? (y/n):%b " "$BRIGHT_MAGENTA$BOLD" "$RESET"
read -r syncans

case "$syncans" in
y|Y)
if [ -z "$source_dev" ]; then
ui_err "❌ Không tìm được máy nguồn có video."
rm -rf "$tmpdir"
return
fi

local_file="$CACHE_DIR/$video_name"

if [ ! -f "$local_file" ]; then
ui_info "⬇ Đang pull từ $(get_name_by_ip "$source_dev") ($source_dev)"
adb_pull_with_progress "$source_dev" "/sdcard/Download/$video_name" "$local_file" || {
ui_err "❌ Pull thất bại"
rm -rf "$tmpdir"
return
}
else
ui_warn "📦 Dùng file cache: $local_file"
fi

echo ""
ui_info "📤 Đang push sang máy còn thiếu..."
for dev in "${MISSING_DEVICES[@]}"; do
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$(get_name_by_ip "$dev")" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
adb_push_with_progress "$dev" "$local_file" /sdcard/Download/
if [ $? -eq 0 ]; then
ui_ok "   ✅ OK"
else
ui_err "   ❌ FAIL"
fi
echo ""
done
;;
esac
fi

echo ""
ui_info "▶ Đang mở video trên các máy đã chọn..."
for dev in "${SELECTED_DEVICES[@]}"; do
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$(get_name_by_ip "$dev")" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
adb -s "$dev" shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/$video_name" -t "video/*" >/dev/null 2>&1 && ui_ok "   ✅ OK" || ui_err "   ❌ FAIL"
done

rm -rf "$tmpdir"
}

show_device_names_file() {
echo ""
ui_info "Danh sách tên máy/IP đang lưu ở:"
printf "%b%s%b\n" "$BRIGHT_YELLOW$BOLD" "$DEVICE_FILE" "$RESET"
echo ""
while IFS= read -r line; do
printf "%b%s%b\n" "$BRIGHT_CYAN" "$line" "$RESET"
done < "$DEVICE_FILE"
}

menu() {
local choice
ui_title
printf "%b1)%b %b🔗 Lọc IP mở 5555 rồi connect 2 lần%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b2)%b %b🔗 Connect IP thủ công%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "$RESET"
printf "%b3)%b %b📋 Xem thiết bị đang connect%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "$RESET"
printf "%b4)%b %b📤 Push video lên thiết bị%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_MAGENTA$BOLD" "$RESET"
printf "%b5)%b %b🎬 Xem video đạt ngưỡng và chọn mở luôn%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b6)%b %b🔄 Chọn video đạt ngưỡng rồi tự đồng bộ + phát%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "$RESET"
printf "%b7)%b %b🗂 Xem danh sách tên máy/IP%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "$RESET"
printf "%b8)%b %b🌐 Tải video từ URL vào cache tạm rồi push%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b9)%b %b🌍 Mở web upload (Android/iOS nếu được)%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_BLUE$BOLD" "$RESET"
printf "%b0)%b %b✖ Thoát%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_RED$BOLD" "$RESET"
ui_line
printf "%bChọn:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read -r choice

case "$choice" in
1) connect_saved_ip_list; pause_enter ;;
2) connect_manual; pause_enter ;;
3) echo ""; list_connected_devices_named; pause_enter ;;
4) push_to_selected; pause_enter ;;
5) show_threshold_videos_and_play; pause_enter ;;
6) pick_threshold_video_sync_and_play; pause_enter ;;
7) show_device_names_file; pause_enter ;;
8) download_video_url_to_cache_and_push; pause_enter ;;
9) open_upload_web_local; pause_enter ;;
0)
clear
ui_ok "Đã thoát."
exit 0
;;
*) ui_err "❌ Lựa chọn không hợp lệ"; pause_enter ;;
esac
}

main() {
mkdir -p "$CACHE_DIR"
touch "$TMP_URL_LIST"
trap cleanup_temp_files EXIT INT TERM

init_device_file
need_cmd bash
need_cmd adb
need_cmd nc
need_cmd grep
need_cmd awk
need_cmd sort
need_cmd uniq
need_cmd sed
need_cmd curl

adb_start_clean

echo ""
ui_info "🚀 Tự động lọc IP mở 5555 và connect khi mở app..."
connect_saved_ip_list
sleep 1.2
printf '\033c'

while true; do
clear
menu
done
}

main
