#!/data/data/com.termux/files/usr/bin/bash

DEVICE_FILE="$HOME/adb_devices_names.txt"
LAST_VIDEO_FILE="$HOME/.adbtool_last_video"
COMMON_THRESHOLD_PERCENT=60
CACHE_DIR="$HOME/.adbtool_cache"

init_device_file() {
if [ ! -f "$DEVICE_FILE" ]; then
cat > "$DEVICE_FILE" <<'EOF'
k 201|10.48.154.116:5555
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
EOF
fi
}

need_cmd() {
command -v "$1" >/dev/null 2>&1 || {
echo "❌ Thiếu lệnh: $1"
exit 1
}
}

pause_enter() {
echo ""
read -p "Nhấn Enter để tiếp tục..."
}

get_name_by_ip() {
local ip="$1"
local name
name=$(grep -F "|$ip" "$DEVICE_FILE" | head -n1 | cut -d'|' -f1)
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
devices=$(list_connected_devices_raw)
if [ -z "$devices" ]; then
echo "Không có thiết bị nào đang connect."
return
fi

local i=1
while IFS= read -r dev; do
[ -z "$dev" ] && continue
echo "$i) $(get_name_by_ip "$dev") ($dev)"
i=$((i+1))
done <<EOF
$devices
EOF
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
last=$(get_last_video)

echo "Nhập đường dẫn video."
if [ -n "$last" ]; then
echo "Video lần trước: $last"
fi
echo "Ví dụ:"
echo "/storage/emulated/0/Download/vario.mp4"
echo "/sdcard/Download/vario.mp4"
read -p "Đường dẫn video: " file

if [ -z "$file" ] && [ -n "$last" ]; then
file="$last"
fi

if [ ! -f "$file" ]; then
echo "❌ Không tìm thấy file: $file"
return 1
fi

save_last_video "$file"
VIDEO_PATH="$file"
VIDEO_NAME=$(basename "$file")
return 0
}

scan_one_round() {
local patterns="$1"

for pattern in $patterns; do
case "$pattern" in
*".xxx")
base="${pattern%.xxx}"
for i in $(seq 1 254); do
ip="$base.$i"
(
ping -c 1 -W 1 "$ip" >/dev/null 2>&1 && \
nc -z -w 1 "$ip" 5555 >/dev/null 2>&1 && \
adb connect "$ip:5555" >/dev/null 2>&1
) &
done
;;
*)
echo "⚠ Bỏ qua mẫu không hợp lệ: $pattern"
;;
esac
done

wait
}

scan_ranges() {
echo "Nhập 1 hoặc nhiều dải IP."
echo "Ví dụ:"
echo "10.48.154.xxx"
echo "10.48.154.xxx 10.48.155.xxx"
echo "10.48.154.xxx,10.48.155.xxx"
read -p "Dải IP cần quét: " input

input=$(echo "$input" | tr ',' ' ')
if [ -z "$input" ]; then
echo "❌ Chưa nhập dải IP"
return
fi

echo ""
echo "📡 Đang quét lần 1..."
scan_one_round "$input"

echo ""
read -p "🔁 Quét lại lần 2 để vượt xác minh ADB? (y/n): " rescan

if [[ "$rescan" == "y" || "$rescan" == "Y" ]]; then
echo ""
echo "📡 Đang quét lần 2..."
scan_one_round "$input"
fi

echo ""
echo "✅ Quét xong. Thiết bị đang connect:"
list_connected_devices_named
echo ""
read -p "Nhấn Enter để hoàn tất việc quét..."
}

connect_manual() {
echo "Nhập 1 hoặc nhiều IP:port"
echo "Ví dụ:"
echo "10.48.154.101:5555 10.48.155.203:5555"
read -p "IP cần connect: " ips

if [ -z "$ips" ]; then
echo "❌ Chưa nhập IP"
return
fi

for dev in $ips; do
echo "🔌 $dev"
adb connect "$dev"
done

echo ""
echo "✅ Xong. Thiết bị đang connect:"
list_connected_devices_named
}

choose_devices() {
local devices
devices=$(list_connected_devices_raw)

if [ -z "$devices" ]; then
echo "❌ Không có thiết bị nào đang connect."
return 1
fi

mapfile -t DEV_ARR <<EOF
$devices
EOF

echo ""
echo "Danh sách thiết bị đang connect:"
local i=1
for dev in "${DEV_ARR[@]}"; do
[ -z "$dev" ] && continue
echo "$i) $(get_name_by_ip "$dev") ($dev)"
i=$((i+1))
done

echo ""
echo "Nhập:"
echo "all    → tất cả"
echo "1 2 5  → chọn các máy theo số"
read -p "Chọn thiết bị: " choice

SELECTED_DEVICES=()

if [ "$choice" = "all" ]; then
for dev in "${DEV_ARR[@]}"; do
[ -n "$dev" ] && SELECTED_DEVICES+=("$dev")
done
else
for idx in $choice; do
if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#DEV_ARR[@]}" ]; then
SELECTED_DEVICES+=("${DEV_ARR[$((idx-1))]}")
fi
done
fi

if [ "${#SELECTED_DEVICES[@]}" -eq 0 ]; then
echo "❌ Chưa chọn thiết bị hợp lệ"
return 1
fi

return 0
}

push_to_selected() {
pick_video_path || return
choose_devices || return

echo ""
echo "📤 Đang push: $VIDEO_NAME"
for dev in "${SELECTED_DEVICES[@]}"; do
echo "➡ $(get_name_by_ip "$dev") ($dev)"
adb -s "$dev" push "$VIDEO_PATH" /sdcard/Download/ && echo "✅ OK" || echo "❌ FAIL"
done
}

play_on_selected() {
local video_name

video_name=$(basename "$(get_last_video)")
if [ -z "$video_name" ]; then
echo "⚠ Chưa có video gần nhất."
read -p "Nhập tên file video trong /sdcard/Download/ trên máy đích: " video_name
fi

if [ -z "$video_name" ]; then
echo "❌ Chưa có tên video"
return
fi

choose_devices || return

echo ""
echo "▶ Đang mở video: $video_name"
for dev in "${SELECTED_DEVICES[@]}"; do
echo "➡ $(get_name_by_ip "$dev") ($dev)"
adb -s "$dev" shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/$video_name" -t "video/*" >/dev/null 2>&1 && echo "✅ OK" || echo "❌ FAIL"
done
}

list_videos_on_device() {
local dev="$1"

adb -s "$dev" shell "ls -1 /sdcard/Download 2>/dev/null" \
| tr -d '\r' \
| grep -Ei '\.(mp4|mkv|avi|mov|m4v|3gp|webm)$' \
| sort -u
}

show_threshold_videos_on_selected() {
choose_devices || return

local tmpdir
tmpdir=$(mktemp -d)

local dev_count="${#SELECTED_DEVICES[@]}"
local need_count=$(( (dev_count * COMMON_THRESHOLD_PERCENT + 99) / 100 ))

for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
list_videos_on_device "$dev" > "$tmpdir/$safe.txt"
done

cat "$tmpdir"/*.txt 2>/dev/null | sort | uniq -c | sort -nr > "$tmpdir/counts.txt"

echo ""
echo "=============================="
echo "Video có trên ít nhất $COMMON_THRESHOLD_PERCENT% máy đã chọn"
echo "Cần tối thiểu: $need_count / $dev_count máy"
echo "=============================="

local found=0
while read -r count name; do
[ -z "$name" ] && continue
if [ "$count" -ge "$need_count" ]; then
echo "$count/$dev_count  $name"
found=1
fi
done < "$tmpdir/counts.txt"

if [ "$found" -eq 0 ]; then
echo "❌ Không có video nào đạt ngưỡng."
fi

rm -rf "$tmpdir"
}

pick_threshold_video_sync_and_play() {
choose_devices || return

local tmpdir
tmpdir=$(mktemp -d)
mkdir -p "$CACHE_DIR"

local dev_count="${#SELECTED_DEVICES[@]}"
local need_count=$(( (dev_count * COMMON_THRESHOLD_PERCENT + 99) / 100 ))

for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
list_videos_on_device "$dev" > "$tmpdir/$safe.txt"
done

cat "$tmpdir"/*.txt 2>/dev/null | sort | uniq -c | sort -nr > "$tmpdir/counts.txt"

local candidates_file="$tmpdir/candidates.txt"
: > "$candidates_file"

while read -r count name; do
[ -z "$name" ] && continue
if [ "$count" -ge "$need_count" ]; then
echo "$name" >> "$candidates_file"
fi
done < "$tmpdir/counts.txt"

if [ ! -s "$candidates_file" ]; then
echo "❌ Không có video nào đạt ngưỡng $COMMON_THRESHOLD_PERCENT%."
rm -rf "$tmpdir"
return
fi

mapfile -t VIDEO_ARR < "$candidates_file"

echo ""
echo "Chọn video để phát:"
local i=1
for v in "${VIDEO_ARR[@]}"; do
[ -z "$v" ] && continue
local count=0
for dev in "${SELECTED_DEVICES[@]}"; do
safe=$(echo "$dev" | tr ':/' '__')
if grep -Fxq "$v" "$tmpdir/$safe.txt"; then
count=$((count+1))
fi
done
echo "$i) $v  [$count/$dev_count máy]"
i=$((i+1))
done

read -p "Chọn số: " idx

if ! [[ "$idx" =~ ^[0-9]+$ ]] || [ "$idx" -lt 1 ] || [ "$idx" -gt "${#VIDEO_ARR[@]}" ]; then
echo "❌ Lựa chọn không hợp lệ"
rm -rf "$tmpdir"
return
fi

local video_name="${VIDEO_ARR[$((idx-1))]}"
local source_dev=""
local HAVE_DEVICES=()
local MISSING_DEVICES=()

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
echo "Video đã chọn: $video_name"
echo "Máy đang có: ${#HAVE_DEVICES[@]}"
echo "Máy còn thiếu: ${#MISSING_DEVICES[@]}"

if [ "${#MISSING_DEVICES[@]}" -gt 0 ]; then
echo ""
read -p "Tự động đồng bộ sang máy còn thiếu rồi phát? (y/n): " syncans

if [[ "$syncans" == "y" || "$syncans" == "Y" ]]; then
if [ -z "$source_dev" ]; then
echo "❌ Không tìm được máy nguồn có video."
rm -rf "$tmpdir"
return
fi

local local_file="$CACHE_DIR/$video_name"

if [ ! -f "$local_file" ]; then
echo "⬇ Đang pull từ $(get_name_by_ip "$source_dev") ($source_dev)"
adb -s "$source_dev" pull "/sdcard/Download/$video_name" "$local_file" || {
echo "❌ Pull thất bại"
rm -rf "$tmpdir"
return
}
else
echo "📦 Dùng file cache: $local_file"
fi

echo ""
echo "📤 Đang push sang máy còn thiếu..."
for dev in "${MISSING_DEVICES[@]}"; do
echo "➡ $(get_name_by_ip "$dev") ($dev)"
adb -s "$dev" push "$local_file" /sdcard/Download/ && echo "✅ OK" || echo "❌ FAIL"
done
fi
fi

echo ""
echo "▶ Đang mở video trên các máy đã chọn..."
for dev in "${SELECTED_DEVICES[@]}"; do
echo "➡ $(get_name_by_ip "$dev") ($dev)"
adb -s "$dev" shell am start -a android.intent.action.VIEW -d "file:///sdcard/Download/$video_name" -t "video/*" >/dev/null 2>&1 && echo "✅ OK" || echo "❌ FAIL"
done

rm -rf "$tmpdir"
}

show_device_names_file() {
echo ""
echo "Danh sách tên máy/IP đang lưu ở:"
echo "$DEVICE_FILE"
echo ""
cat "$DEVICE_FILE"
}

menu() {
clear
echo "================================="
echo "        ADB TOOL MENU"
echo "================================="
echo "1) Quét IP và connect"
echo "2) Connect IP thủ công"
echo "3) Xem thiết bị đang connect"
echo "4) Push video lên thiết bị"
echo "5) Mở / phát video theo tên video đã nhớ"
echo "6) Xem video có trên ít nhất $COMMON_THRESHOLD_PERCENT% máy đã chọn"
echo "7) Chọn video đạt ngưỡng rồi tự đồng bộ + phát"
echo "8) Xem danh sách tên máy/IP"
echo "9) Thoát"
echo "=============================="
read -p "Chọn: " choice

case "$choice" in
1) scan_ranges ;;
2) connect_manual; pause_enter ;;
3) echo ""; list_connected_devices_named; pause_enter ;;
4) push_to_selected; pause_enter ;;
5) play_on_selected; pause_enter ;;
6) show_threshold_videos_on_selected; pause_enter ;;
7) pick_threshold_video_sync_and_play; pause_enter ;;
8) show_device_names_file; pause_enter ;;
9) exit 0 ;;
*) echo "❌ Lựa chọn không hợp lệ"; pause_enter ;;
esac
}

main() {
mkdir -p "$CACHE_DIR"
init_device_file
need_cmd adb
need_cmd ping
need_cmd nc
need_cmd grep
need_cmd awk
while true; do
menu
done
}

main