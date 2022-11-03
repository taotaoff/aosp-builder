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

tg_sendText "Syncing rom"
mkdir -p /tmp/rom
cd /tmp/rom
repo init --no-repo-verify --depth=1 -u https://github.com/LineageOS/android.git -b lineage-17.1 -g default,-device,-mips,-darwin,-notdefault
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j6 || repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8

tg_sendText "Downloading trees"
git clone https://github.com/MizuNotCool/android_device_samsung_a10s device/samsung/a10s
git clone https://github.com/MizuNotCool/suzu_vendor_samsung_a10s vendor/samsung/a10s

tg_sendText "Lunching"
# Normal build steps
. build/envsetup.sh
lunch lineage_a10s-userdebug
export SELINUX_IGNORE_NEVERALLOWS=true
export ALLOW_MISSING_DEPENDENCIES=true
export RELAX_USES_LIBRARY_CHECK=true
export KBUILD_BUILD_USER=ItzKaguya
export KBUILD_BUILD_HOST=ItzKaguya-PC
export BUILD_USERNAME=ItzKaguya
export BUILD_HOSTNAME=ItzKaguya-PC
export WITH_SU=false
export WITH_GMS=false
export TZ=Asia/Makassar
export BUILD_BROKEN_USES_BUILD_COPY_HEADERS=true
export BUILD_BROKEN_DUP_RULES=true
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 20G
ccache -o compression=true
ccache -z

tg_sendText "Starting Compilation.."

make bacon -j8 | tee build.txt

tg_sendText "Build completed! Uploading rom"
curl bashupload.com -T ./out/target/product/a10s/*.zip | tee download-link.txt
curl bashupload.com -T ./out/target/product/a10s/*.zip | tee download-link-$(BUILD_START).txt

(ccache -s && echo " " && free -h && echo " " && df -h && echo " " && ls -a out/target/product/a10s/) | tee final_monitor.txt
tg_sendFile "final_monitor.txt"
tg_sendFile "build.txt"
tg_sendFile "download-link.txt"
tg_sendFile "download-link-$(BUILD_START).txt

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
