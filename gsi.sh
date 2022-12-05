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

ls -a
tg_sendText "Cloning GSI Builds"
mkdir evolution; cd evolution
git clone https://github.com/MizuNotCool/treble_build_evo -b tiramisu
tg_sendText "Prepairing to build GSI"
tg_sendText "Building..."
BD=/tmp/itzkaguya/builds
export BD=/tmp/itzkaguya/builds
export SELINUX_IGNORE_NEVERALLOWS=true
export ALLOW_MISSING_DEPENDENCIES=true
export RELAX_USES_LIBRARY_CHECK=true
export BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES=true
export BUILD_BROKEN_MISSING_REQUIRED_MODULES=true
export BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE=true
export BUILD_BROKEN_VERIFY_USES_LIBRARIES=true
export BUILD_BROKEN_USES_BUILD_COPY_HEADERS=true
export BUILD_BROKEN_DUP_RULES=true
export BUILD_USERNAME=ItzKaguya
export BUILD_HOSTNAME=itzkaguya-server
export KBUILD_BUILD_NAME=ItzKaguya
export KBUILD_BUILD_HOST=itzkaguya-server
export BUILD_BROKEN_CLANG_ASFLAGS=true
export BUILD_BROKEN_CLANG_CFLAGS=true
bash treble_build_evo/build.sh
tg_sendText "Build completed! Uploading rom"
rclone copy $BD/evolution_a64-ab-7.3-ItzKaguya.img.xz suzu:
rclone copy $BD/evolution_a64-ab-vndklite-7.3-ItzKaguya.img.xz suzu:
sleep 10

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
