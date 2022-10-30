#!/bin/bash
rclone copy out/target/product/a10s/*Unofficial* suzunetwork:final -P || rclone copy out/target/product/a10s/*a10s*.zip suzunetwork:final -P || rclone copy out/target/product/a10s/*UNOFFICIAL*.zip suzunetwork:final -P || rclone copy out/target/product/a10s/*OFFICIAL*.zip suzunetwork:final -P
