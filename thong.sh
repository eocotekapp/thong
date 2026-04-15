#!/usr/bin/env bash

DEVICE_FILE="$HOME/adb_devices_names.txt"
LAST_VIDEO_FILE="$HOME/.adbtool_last_video"
COMMON_THRESHOLD_PERCENT=60
CACHE_DIR="$HOME/.adbtool_cache"

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

init_device_file() {
if [ ! -f "$DEVICE_FILE" ]; then
cat > "$DEVICE_FILE" <<'EODEV'
k 201|10.48.154.116:5555
k 202|10.48.154.209:5555
k 202|100.101.18.125:5555
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
printf "%bThieu lenh:%b %s\n" "$BRIGHT_RED$BOLD" "$RESET" "$1"
exit 1
}
}

pause_enter() {
echo ""
printf "%bNhan Enter de tiep tuc...%b" "$BRIGHT_YELLOW$BOLD" "$RESET"
read dummy
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

intro_animation() {
local title="ADB TOOL MENU @Thoòng 🤗"
local i

clear
for i in 0 1 2 3 4 5 6 7; do
printf "${ESC}[H${ESC}[2J"
ui_line
printf "   "
rainbow_text_shift "$title" "$i"
printf "\n"
ui_line
printf "%b                Loading giao diện...%b\n" "$BRIGHT_MAGENTA$BLINK" "$RESET"
sleep 0.08
done
}

ui_title() {
intro_animation
printf "${ESC}[H${ESC}[2J"
ui_line
printf "   "
gradient_text "ADB TOOL MENU @Thoòng 🤗"
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

list_connected_devices_raw() {
adb devices | awk 'NR>1 && $2=="device" {print $1}'
}

list_connected_devices_named() {
local devices
local i
local dev
local name

devices=$(list_connected_devices_raw)
if [ -z "$devices" ]; then
ui_warn "không có thiết bị nào đang connect."
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

pick_video_path() {
local last
local file

last=$(get_last_video)

ui_info "Nhap duong dan video."
if [ -n "$last" ]; then
ui_dim "Video lan truoc: $last"
fi
ui_dim "Vi du:"
ui_dim "/storage/emulated/0/Download/vario.mp4"
ui_dim "/sdcard/Download/vario.mp4"
printf "%bDuong dan video:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read file

if [ -z "$file" ] && [ -n "$last" ]; then
file="$last"
fi

if [ ! -f "$file" ]; then
ui_err "Khong tim thay file: $file"
return 1
fi

save_last_video "$file"
VIDEO_PATH="$file"
VIDEO_NAME=$(basename "$file")
return 0
}

scan_one_round() {
local patterns="$1"
local pattern
local base
local ip
local i

for pattern in $patterns; do
case "$pattern" in
*.xxx)
base="${pattern%.xxx}"
for i in $(seq 1 254); do
ip="$base.$i"
(
ping -c 1 "$ip" >/dev/null 2>&1 && \
nc -z "$ip" 5555 >/dev/null 2>&1 && \
adb connect "$ip:5555" >/dev/null 2>&1
) &
done
;;
*)
ui_warn "Bo qua mau khong hop le: $pattern"
;;
esac
done

wait
}

scan_ranges() {
local input
local rescan

ui_info "Nhap 1 hoac nhieu dai IP."
ui_dim "Vi du:"
ui_dim "10.48.154.xxx"
ui_dim "10.48.154.xxx 10.48.155.xxx"
ui_dim "10.48.154.xxx,10.48.155.xxx"
printf "%bDai IP can quet:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read input

input=$(echo "$input" | tr ',' ' ')
if [ -z "$input" ]; then
ui_err "Chua nhap dai IP"
return
fi

echo ""
ui_info "Dang quet lan 1..."
scan_one_round "$input"

echo ""
printf "%bQuet lai lan 2 de vuot xac minh ADB? (y/n):%b " "$BRIGHT_MAGENTA$BOLD" "$RESET"
read rescan

case "$rescan" in
y|Y)
echo ""
ui_info "Dang quet lan 2..."
scan_one_round "$input"
;;
esac

echo ""
ui_ok "Quet xong. Thiet bi dang connect:"
list_connected_devices_named
echo ""
printf "%bNhan Enter de hoan tat viec quet...%b" "$BRIGHT_YELLOW$BOLD" "$RESET"
read dummy
}

connect_manual() {
local ips
local dev

ui_info "Nhap 1 hoac nhieu IP:port"
ui_dim "Vi du:"
ui_dim "10.48.154.101:5555 10.48.155.203:5555"
printf "%bIP can connect:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read ips

if [ -z "$ips" ]; then
ui_err "Chua nhap IP"
return
fi

for dev in $ips; do
printf "%b🔌 %s%b\n" "$BRIGHT_CYAN$BOLD" "$dev" "$RESET"
adb connect "$dev"
done

echo ""
ui_ok "Xong. Thiet bi dang connect:"
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
ui_err "Khong co thiet bi nao dang connect."
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
ui_info "Danh sach thiet bi dang connect:"
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
ui_dim "Nhap:"
printf "%ball%b  -> tat ca\n" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b1 2 5%b -> chon cac may theo so\n" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%bChon thiet bi:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read choice

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
ui_err "Chua chon thiet bi hop le"
return 1
fi

return 0
}

push_to_selected() {
local dev
local name
pick_video_path || return
choose_devices || return

echo ""
ui_info "Dang push: $VIDEO_NAME"
for dev in "${SELECTED_DEVICES[@]}"; do
name=$(get_name_by_ip "$dev")
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
adb -s "$dev" push "$VIDEO_PATH" /sdcard/Download/ >/dev/null 2>&1 && ui_ok "   ✅ OK" || ui_err "   ❌ FAIL"
done
}

play_on_selected() {
local video_name
local dev
local name

video_name=$(basename "$(get_last_video)")
if [ -z "$video_name" ]; then
ui_warn "Chua co video gan nhat."
printf "%bNhap ten file video trong /sdcard/Download/ tren may dich:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read video_name
fi

if [ -z "$video_name" ]; then
ui_err "Chua co ten video"
return
fi

choose_devices || return

echo ""
ui_info "Dang mo video: $video_name"
for dev in "${SELECTED_DEVICES[@]}"; do
name=$(get_name_by_ip "$dev")
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
adb -s "$dev" shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/$video_name" -t "video/*" >/dev/null 2>&1 && ui_ok "   ✅ OK" || ui_err "   ❌ FAIL"
done
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
printf "%bVideo co tren it nhat %s%% may da chon%b\n" "$BRIGHT_CYAN$BOLD" "$COMMON_THRESHOLD_PERCENT" "$RESET"
printf "%bCan toi thieu:%b %b%s / %s may%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "$need_count" "$dev_count" "$RESET"
ui_line

VIDEO_ARR=()
found=0
display_idx=1

while read -r count name; do
[ -z "$name" ] && continue
if [ "$count" -ge "$need_count" ]; then
VIDEO_ARR+=("$name")
printf "%b%s)%b %b%s%b %b[%s/%s may]%b\n" \
"$BRIGHT_WHITE$BOLD" "$display_idx" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$name" "$RESET" \
"$DIM$BRIGHT_WHITE" "$count" "$dev_count" "$RESET"
display_idx=$((display_idx+1))
found=1
fi
done < "$tmpdir/counts.txt"

if [ "$found" -eq 0 ]; then
ui_err "Khong co video nao dat nguong."
rm -rf "$tmpdir"
return
fi

echo ""
printf "%bChon so de mo video do tren cac may da chon (Enter de bo qua):%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read idx

if [ -z "$idx" ]; then
rm -rf "$tmpdir"
return
fi

case "$idx" in
''|*[!0-9]*)
ui_err "Lua chon khong hop le"
rm -rf "$tmpdir"
return
;;
esac

if [ "$idx" -lt 1 ] || [ "$idx" -gt "${#VIDEO_ARR[@]}" ]; then
ui_err "Lua chon khong hop le"
rm -rf "$tmpdir"
return
fi

video_name="${VIDEO_ARR[$((idx-1))]}"

echo ""
ui_info "Dang mo video: $video_name"
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
ui_err "Khong co video nao dat nguong $COMMON_THRESHOLD_PERCENT%."
rm -rf "$tmpdir"
return
fi

VIDEO_ARR=()
while IFS= read -r line; do
[ -n "$line" ] && VIDEO_ARR+=("$line")
done < "$candidates_file"

echo ""
ui_line
ui_info "Chon video de phat:"
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
printf "%b%s)%b %b%s%b %b[%s/%s may]%b\n" \
"$BRIGHT_WHITE$BOLD" "$i" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$v" "$RESET" \
"$DIM$BRIGHT_WHITE" "$count" "$dev_count" "$RESET"
i=$((i+1))
done

printf "%bChon so:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read idx

case "$idx" in
''|*[!0-9]*)
ui_err "Lua chon khong hop le"
rm -rf "$tmpdir"
return
;;
esac

if [ "$idx" -lt 1 ] || [ "$idx" -gt "${#VIDEO_ARR[@]}" ]; then
ui_err "Lua chon khong hop le"
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
ui_info "Video da chon: $video_name"
printf "%bMay dang co:%b %b%s%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "${#HAVE_DEVICES[@]}" "$RESET"
printf "%bMay con thieu:%b %b%s%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "${#MISSING_DEVICES[@]}" "$RESET"

if [ "${#MISSING_DEVICES[@]}" -gt 0 ]; then
echo ""
printf "%bTu dong dong bo sang may con thieu roi phat? (y/n):%b " "$BRIGHT_MAGENTA$BOLD" "$RESET"
read syncans

case "$syncans" in
y|Y)
if [ -z "$source_dev" ]; then
ui_err "Khong tim duoc may nguon co video."
rm -rf "$tmpdir"
return
fi

local_file="$CACHE_DIR/$video_name"

if [ ! -f "$local_file" ]; then
ui_info "Dang pull tu $(get_name_by_ip "$source_dev") ($source_dev)"
adb -s "$source_dev" pull "/sdcard/Download/$video_name" "$local_file" >/dev/null 2>&1 || {
ui_err "Pull that bai"
rm -rf "$tmpdir"
return
}
else
ui_warn "Dung file cache: $local_file"
fi

echo ""
ui_info "Dang push sang may con thieu..."
for dev in "${MISSING_DEVICES[@]}"; do
printf "%b→%b %b%s%b %b(%s)%b\n" \
"$BRIGHT_WHITE$BOLD" "$RESET" \
"$BRIGHT_GREEN$BOLD" "$(get_name_by_ip "$dev")" "$RESET" \
"$DIM$BRIGHT_WHITE" "$dev" "$RESET"
adb -s "$dev" push "$local_file" /sdcard/Download/ >/dev/null 2>&1 && ui_ok "   ✅ OK" || ui_err "   ❌ FAIL"
done
;;
esac
fi

echo ""
ui_info "Dang mo video tren cac may da chon..."
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
ui_info "Danh sach ten may/IP dang luu o:"
printf "%b%s%b\n" "$BRIGHT_YELLOW$BOLD" "$DEVICE_FILE" "$RESET"
echo ""
while IFS= read -r line; do
printf "%b%s%b\n" "$BRIGHT_CYAN" "$line" "$RESET"
done < "$DEVICE_FILE"
}

menu() {
local choice
ui_title
printf "%b1)%b %b📡 Quet IP va connect%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b2)%b %b🔗 Connect IP thu cong%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "$RESET"
printf "%b3)%b %b📋 Xem thiet bi dang connect%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "$RESET"
printf "%b4)%b %b📤 Push video len thiet bi%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_MAGENTA$BOLD" "$RESET"
printf "%b5)%b %b▶ Mo / phat video theo ten video da nho%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_BLUE$BOLD" "$RESET"
printf "%b6)%b %b🎬 Xem video dat nguong va chon mo luon%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_CYAN$BOLD" "$RESET"
printf "%b7)%b %b🔄 Chon video dat nguong roi tu dong dong bo + phat%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_GREEN$BOLD" "$RESET"
printf "%b8)%b %b🗂 Xem danh sach ten may/IP%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_YELLOW$BOLD" "$RESET"
printf "%b9)%b %b✖ Thoat%b\n" "$BRIGHT_WHITE$BOLD" "$RESET" "$BRIGHT_RED$BOLD" "$RESET"
ui_line
printf "%bChon:%b " "$BRIGHT_YELLOW$BOLD" "$RESET"
read choice

case "$choice" in
1) scan_ranges ;;
2) connect_manual; pause_enter ;;
3) echo ""; list_connected_devices_named; pause_enter ;;
4) push_to_selected; pause_enter ;;
5) play_on_selected; pause_enter ;;
6) show_threshold_videos_and_play; pause_enter ;;
7) pick_threshold_video_sync_and_play; pause_enter ;;
8) show_device_names_file; pause_enter ;;
9) exit 0 ;;
*) ui_err "Lua chon khong hop le"; pause_enter ;;
esac
}

main() {
mkdir -p "$CACHE_DIR"
init_device_file
need_cmd bash
need_cmd adb
need_cmd ping
need_cmd nc
need_cmd grep
need_cmd awk
need_cmd sort
need_cmd uniq
need_cmd sed
while true; do
menu
done
}

main
