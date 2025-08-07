#!/usr/bin/env bash

USB_LABEL="MYUSB"
MOUNT_POINT="/mnt/usbdrive"
SOURCE_DIR="$HOME"
EXTENSIONS=( "rs" "py" "env" "sh" "toml" "json" "onnx" "txt" )

# ✅ Find the correct device path using label
DEVICE_PATH=$(lsblk -l -o NAME,LABEL | grep -iw "$USB_LABEL" | awk '{print "/dev/" $1}' | head -n 1)

if [ -z "$DEVICE_PATH" ]; then
    # echo "❌ USB device with label '$USB_LABEL' not found!"
    exit 1
fi

# ✅ Unmount if mounted
# echo "🔄 Unmounting $DEVICE_PATH (if mounted)..."
sudo umount "${DEVICE_PATH}"* 2>/dev/null

# ✅ Create mount point if not exists
if [ ! -d "$MOUNT_POINT" ]; then
    # echo "📁 Creating mount point at $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# ✅ Mount the USB
# echo "📦 Mounting $DEVICE_PATH to $MOUNT_POINT..."
sudo mount "$DEVICE_PATH" "$MOUNT_POINT"

# ✅ Copy files with selected extensions
# echo "📂 Copying selected files to USB drive..."
for ext in "${EXTENSIONS[@]}"; do
    # echo "   ➤ Copying *.$ext files..."
    sudo find "$SOURCE_DIR" -type f -iname "*.$ext" 2>/dev/null -exec sudo cp --parents {} "$MOUNT_POINT" \;
done

# ✅ Sync and unmount
# echo "💾 Syncing and unmounting..."
sync
sudo umount "$MOUNT_POINT"

# echo "✅ Copy complete. USB safely unmounted."
