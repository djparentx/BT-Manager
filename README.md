# R36S BT Manager

A complete Bluetooth management solution for the R36S, originally for dArkOS by Jason_3x and enhanced for use on ArkOS or dArkOs, providing a fully automated setup, system-level fixes, and an easy-to-use controller-friendly interface.

---

## Overview

This script transforms Bluetooth on the R36S from a broken or unreliable feature into a fully functional, plug-and-play experience.

It handles everything automatically:
- Installs required packages
- Fixes system Bluetooth and audio configuration
- Enables proper audio routing (A2DP)
- Provides a clean, menu-driven interface using the device controls
- Supports multiple languages based on system settings

---

## Features

- One-time automatic setup and dependency installation
- Full Bluetooth control (enable / disable)
- Scan and connect to nearby devices
- View and reconnect to known devices
- Disconnect active devices
- Forget paired devices
- Automatic audio switching between speaker and Bluetooth
- Volume button support for Bluetooth audio
- Persistent system fixes via systemd services
- Multi-language support (EN, FR, ES, PT, IT, DE, PL)
- Clean UI designed for handheld use (via `dialog`)

---

## What It Fixes

The R36S has several known Bluetooth/audio issues. This script addresses:

- Missing or broken Bluetooth dependencies
- PulseAudio not configured for Bluetooth
- No automatic audio switching
- Poor A2DP compatibility
- Volume buttons not working with Bluetooth audio
- Incorrect permissions and service setup

---

## Installation

1. Copy the script to your R36S Tools folder
2. Run it

---

## First Run

On first launch, the script will:

- Check for missing dependencies
- Require an active internet connection
- Install necessary packages
- Apply system-level fixes
- Configure services and permissions
- Prompt for a reboot

This only happens once.

---

## Controls / Menu

The main menu provides:

- Enable / Disable Bluetooth  
- Scan and Connect  
- Disconnect a Device  
- Known Devices  
- Forget a Device  
- Quit  

Navigation works with the R36S controls.

---

## Audio Behavior

- Automatically switches audio to Bluetooth when connected
- Falls back to internal speaker when disconnected
- Sets proper A2DP profile for better audio quality
- Enables volume buttons for Bluetooth audio control

---

## System Changes

The script makes persistent system modifications:

- Edits bluetooth.service for compatibility
- Configures PulseAudio system-wide
- Installs custom systemd services:
  - pulseaudio.service
  - bt-volume-monitor.service
- Updates RetroArch audio driver to SDL2
- Adjusts user permissions for Bluetooth/audio access

---

## Files Created

- /usr/local/bin/bt-volume-monitor.sh
- /etc/systemd/system/pulseaudio.service
- /etc/systemd/system/bt-volume-monitor.service
- /etc/bluetooth/main.conf
- Installation flag:
  - /home/ark/.bt_manager_installed

---

## Requirements

- R36S running Arkos or dArkOs
- Internet connection (first run only)

---

## Notes

- Designed specifically for the R36S hardware and dArkOs environment
- Safe to re-run, but installation steps are skipped after first setup
- Optimized for stability over stock Bluetooth behavior

---

## Credits

- Original script by Jason_3x 
- dArkOs Edition modifications and enhancements by djparent  

---
