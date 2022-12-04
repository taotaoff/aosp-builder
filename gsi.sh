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
mkdir pixel; cd pixel
git clone https://github.com/MizuNotCool/treble_build_miku -b TDA
tg_sendText "Prepairing to build GSI"
tg_sendText "Building..."
BD=/tmp/itzkaguya/builds
export BD=/tmp/itzkaguya/builds
bash treble_build_miku/build.sh
tg_sendText "Build completed! Uploading rom"
rclone copy $BD/all.7z suzu:
sleep 10

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
