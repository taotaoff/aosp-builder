#!/bin/bash
# AOSP Builder by ItzKaguya.

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
repo init --depth=1 --git-lfs --no-repo-verify -u https://github.com/VoltageOS/manifest.git -b 13 -g default,-mips,-darwin,-notdefault
git clone https://github.com/taotaoff/local_manifest.git --depth 1 -b master .repo/local_manifests
repo sync -c --force-sync --no-tags --no-clone-bundle -j6 --optimized-fetch --prune || repo sync -c --force-sync --no-tags --no-clone-bundle -j8 --optimized-fetch --prune

tg_sendText "Lunching (lunch moba-userdebug)"

# Normal build steps
. build/envsetup.sh
lunch voltageos_moba-userdebug
export SELINUX_IGNORE_NEVERALLOWS=true
export ALLOW_MISSING_DEPENDENCIES=true
export RELAX_USES_LIBRARY_CHECK=true
export BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES=true
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true
export BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE=true
export BUILD_BROKEN_VERIFY_USES_LIBRARIES=true
export BUILD_BROKEN_USES_BUILD_COPY_HEADERS=true
export BUILD_BROKEN_DUP_RULES=true
export BUILD_USERNAME=taotao
export BUILD_HOSTNAME=taotao-server
export KBUILD_BUILD_NAME=taotao
export KBUILD_BUILD_HOST=taotao-server
export BUILD_BROKEN_CLANG_ASFLAGS=true
export BUILD_BROKEN_CLANG_CFLAGS=true
export USE_CCACHE=1
export CCACHE_COMPRESS=1
export TZ=America/Sao_Paulo
ccache -M 14G
ccache -o compression=true
ccache -z

tg_sendText "Starting Compilation (mka moba)"

make clean
mka moba -j10 | tee build.txt

tg_sendText "Build completed! Uploading rom to gdrive"
rclone copy out/target/product/moba/*UNOFFICIAL* suzu:segawa-builds -P || rclone copy out/target/product/moba/*moba*.zip suzu:segawa-builds -P || rclone copy out/target/product/moba/*.zip suzu:segawa-builds -P

(ccache -s && echo " " && free -h && echo " " && df -h && echo " " && ls -a out/target/product/a13/) | tee final_monitor.txt
tg_sendFile "final_monitor.txt"
tg_sendFile "build.txt"

#tg_sendText "Uploading new ccache to gdrive"
#cd /tmp
#tar --use-compress-program="pigz -k -1 " -cf voltage_ccache.tar.gz ccache
rclone copy voltage_ccache.tar.gz aosp: -P

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
