#!/bin/bash

function tg_sendText() {
curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
-d "parse_mode=html" \
-d text="${1}" \
-d chat_id=$CHAT_ID \
-d "disable_web_page_preview=true"
}

function tg_sendFile() {
curl -F chat_id=$CHAT_ID -F document=@${1} -F parse_mode=markdown https://api.telegram.org/bot$BOT_TOKEN/sendDocument
}

BUILD_START=$(date +"%s");

mkdir -p ~/.config/rclone
echo "$rclone_config" > ~/.config/rclone/rclone.conf
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$id_rsa" > ~/.ssh/id_rsa
echo "$id_rsa_pub" > ~/.ssh/id_rsa.pub
chmod 400 ~/.ssh/id_rsa
git config --global user.email "$user_email"
git config --global user.name "$user_name"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
echo "$known_hosts" > ~/.ssh/known_hosts
echo "$user_credentials" > ~/.git-credentials && git config --global credential.helper store

tg_sendText "Syncing rom (ShirayukiProject Tsushima 13)"
mkdir -p /tmp/rom
cd /tmp/rom
repo init --no-repo-verify --depth=1 -u https://github.com/shirayuki-prjkt/yuki_manifest.git -b tsushima-13 -g default,-device,-mips,-darwin,-notdefault
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j6 || repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8

tg_sendText "Downloading trees (Xiaomi Mi439)"
git clone https://github.com/ShirayukiProject-Devices/android_device_xiaomi_mi439 device/xiaomi/mi439
git clone https://github.com/ShirayukiProject-Devices/android_device_xiaomi_sdm439-common device/xiaomi/sdm439-common
git clone https://github.com/ShirayukiProject-Devices/android_kernel_xiaomi_sdm439 kernel/xiaomi/sdm439
git clone https://github.com/ShirayukiProject-Devices/android_vendor_xiaomi_mi439 vendor/xiaomi/mi439
git clone https://github.com/ShirayukiProject-Devices/android_vendor_xiaomi_sdm439-common vendor/xiaomi/sdm439-common

tg_sendText "Lunching"
# Normal build steps
. build/envsetup.sh
lunch shirayuki_mi439-userdebug
export SELINUX_IGNORE_NEVERALLOWS=true
export ALLOW_MISSING_DEPENDENCIES=true
export RELAX_USES_LIBRARY_CHECK=true
export BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES=true
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true
export BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE=true
export BUILD_BROKEN_VERIFY_USES_LIBRARIES=true
export BUILD_BROKEN_USES_BUILD_COPY_HEADERS=true
export BUILD_BROKEN_DUP_RULES=true
export BUILD_USERNAME=segawa
export BUILD_HOSTNAME=itzkaguya-server
export KBUILD_BUILD_NAME=segawa
export KBUILD_BUILD_HOST=itzkaguya-server
export BUILD_BROKEN_CLANG_ASFLAGS=true
export BUILD_BROKEN_CLANG_CFLAGS=true
export USE_CCACHE=1
export CCACHE_COMPRESS=1
export TZ=Asia/Makassar
ccache -M 20G
ccache -o compression=true
ccache -z

tg_sendText "Starting Compilation.."

mka shirayuki -j10 | tee build.txt

tg_sendText "Build completed! Uploading rom to gdrive"
rclone copy out/target/product/mi439/*Unofficial* suzu:segawa-builds -P || rclone copy out/target/product/mi439/*Alpha*.zip suzu:segawa-builds -P || rclone copy out/target/product/mi439/Shirayuki*.zip suzu:segawa-builds -P

(ccache -s && echo " " && free -h && echo " " && df -h && echo " " && ls -a out/target/product/a10/) | tee final_monitor.txt
tg_sendFile "final_monitor.txt"
tg_sendFile "build.txt"

#tg_sendText "Uploading new ccache to gdrive"
#cd /tmp
#tar --use-compress-program="pigz -k -1 " -cf corvus_ccache.tar.gz ccache
#rclone copy corvus_ccache.tar.gz aosp: -P

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
