#!/bin/bash
rclone copy out/target/product/a10s/*Unofficial* aosp:final -P || rclone copy out/target/product/a10s/*a10s*.zip aosp:final -P || rclone copy out/target/product/a10s/*UNOFFICIAL*.zip aosp:final -P || rclone copy out/target/product/a10s/*OFFICIAL*.zip aosp:final -P
