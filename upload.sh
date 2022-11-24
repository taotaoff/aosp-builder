#!/bin/bash
rclone copy out/target/product/a10s/*Unofficial* suzu:test -P || rclone copy out/target/product/a10s/*a10s*.zip suzu:test -P || rclone copy out/target/product/a10s/*UNOFFICIAL*.zip suzu:test -P || rclone copy out/target/product/a10s/*OFFICIAL*.zip suzu:test -P
