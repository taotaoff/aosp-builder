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
git clone https://github.com/MizuNotCool/treble_build_pe.git -b twelve --depth=1
tg_sendText "Prepairing to build GSI"
tg_sendText "Building..."
BD=/tmp/itzkaguya/builds
export BD=/tmp/itzkaguya/builds
bash treble_build_pe/build.sh twelve
tg_sendText "Build completed! Uploading rom"
$BD/PixelExperience-Plus_a64-ab-12.1-ItzKaguyaGSI-UNOFFICIAL.img.xz | tee download-link-pe.txt
sleep 10
cat download-link-pe
tg_sendFile "download-link-pe.txt"
tg_sendText "This link is one-time use, so mirror it first"
tg_sendText "Build Completed? Maybe not"

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
