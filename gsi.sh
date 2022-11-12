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
git clone https://github.com/MizuNotCool/treble_build_ancient.git
mkdir lineage-17.x-build-gsi; cd lineage-17.x-build-gsi
repo init -u https://github.com/Ancient-Lab/manifest.git -b ten-weeabo
git clone https://github.com/MizuNotCool/treble_build_ancient.git
git clone https://github.com/Ankits-lab/treble_patches -b lineage-17.1
git clone https://github.com/Ankits-lab/treble_build_los -b lineage-17.1
tg_sendText "Prepairing to build GSI"
tg_sendText "Building..."
export KBUILD_BUILD_USER=ItzKaguya
export KBUILD_BUILD_HOST=ItzKaguya-PC
export BUILD_USERNAME=ItzKaguya
export BUILD_HOSTNAME=ItzKaguya-PC
bash treble_build_floko/buildbot_unified.sh treble A64B
tg_sendText "Build completed! Uploading rom"
curl bashupload.com -T ancient-18.1-ItzKaguyaGSI-UNOFFICIAL-suzuhimeSharedSystem.img.xz | tee build-output-ancient.txt
curl bashupload.com -T ./build-output/ancient-18.1-ItzKaguyaGSI-UNOFFICIAL-suzuhimeSharedSystem.img.xz | tee download-link-ancient.txt
sleep 10
cat build-output-ancient.txt
cat download-link-ancient.txt
tg_sendFile "build-output-ancient.txt"
tg_sendFile "download-link-ancient.txt"

BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));


tg_sendText "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
