#!/bin/bash
rclone copy out/target/product/mi439/*Unofficial* suzu:test -P || rclone copy out/target/product/mi439/*mi439*.zip suzu:test -P || rclone copy out/target/product/mi439/*UNOFFICIAL*.zip suzu:test -P || rclone copy out/target/product/mi439/*OFFICIAL*.zip suzu:test -P
