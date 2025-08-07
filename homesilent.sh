#!/usr/bin/env bash

USB_LABEL="MYUSB"
MOUNT_POINT="/mnt/usbdrive"
SOURCE_DIR="$HOME"
EXTENSIONS=( "rs" "py" "env" "sh" "toml" "json" "onnx" "txt" )

# ✅ Find the correct device path using label
DEVICE_PATH=$(lsblk -lp -o NAME,LABEL | grep -iw "$USB_LABEL" | awk '{print "/dev/" $1}' | head -n 1)

if [ -z "$DEVICE_PATH" ]; then
    # echo "❌ USB device with label '$USB_LABEL' not found!"
    exit 1
fi

# ✅ Unmount if mounted
sudo umount "${DEVICE_PATH}"* 2>/dev/null

# ✅ Create mount point if not exists
if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
fi

# ✅ Mount the USB
sudo mount "$DEVICE_PATH" "$MOUNT_POINT"

# ✅ Copy files with selected extensions (excluding USB mount path)
for ext in "${EXTENSIONS[@]}"; do
    sudo find "$SOURCE_DIR" -path "$MOUNT_POINT" -prune -o -type f -iname "*.$ext" -exec sudo cp --parents {} "$MOUNT_POINT" \;
done

# ✅ Sync and unmount
sync
sudo umount "$MOUNT_POINT"
