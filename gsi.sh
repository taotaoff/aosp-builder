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
git clone https://github.com/AndyCGYan/treble_experimentations
mkdir floko-gsi; cd floko-gsi
git clone https://github.com/AndyCGYan/treble_experimentations
repo init -u https://github.com/FlokoROM/manifesto.git -b 11.0
git clone https://github.com/ProjectSuzu/treble_build_floko -b 11.0-unified
git clone https://github.com/FlokoROM-GSI/lineage_patches_unified -b 11.0-unified
tg_sendText "Prepairing to build GSI"
tg_sendText "Building..."
bash treble_build_floko/buildbot_unified.sh treble A64B
tg_sendText "Build completed! Uploading rom"
curl bashupload.com -T ./build-output/Floko*.img | tee download-link-floko.txt
sleep 10
curl bashupload.com -T ./build-output/*lineage*.img | tee download-link-lineage.txt
sleep 10
tg_sendFile "download-link-floko.txt"
tg_sendFile "download-link-lineage.txt"

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
