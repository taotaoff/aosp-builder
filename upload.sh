#!/bin/bash
rclone copy out/target/product/mi439/*Unofficial* suzu:segawa-builds -P || rclone copy out/target/product/mi439/*mi439*.zip suzu:segawa-builds -P || rclone copy out/target/product/mi439/*UNOFFICIAL*.zip suzu:segawa-builds -P || rclone copy out/target/product/mi439/*OFFICIAL*.zip suzu:segawa-builds -P
