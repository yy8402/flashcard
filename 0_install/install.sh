#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHECKPOINT_FILE=".install_checkpoint"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Make all scripts executable
chmod +x ./*.sh

echo -e "${YELLOW}Starting installation process...${NC}"

# Load checkpoint
if [ -f "$CHECKPOINT_FILE" ]; then
    source "$CHECKPOINT_FILE"
fi

# Step 1: Check system requirements
if [ "$STEP1_DONE" != "1" ]; then
    echo -e "\n${YELLOW}Step 1/5: Checking system requirements...${NC}"
    ./00_check_system.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}System requirements check failed. Please check the requirements and try again.${NC}"
        exit 1
    fi
    echo "STEP1_DONE=1" >> "$CHECKPOINT_FILE"
fi

# Step 2: Install system packages
if [ "$STEP2_DONE" != "1" ]; then
    echo -e "\n${YELLOW}Step 2/5: Installing system packages...${NC}"
    ./01_system_packages.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}System packages installation failed.${NC}"
        exit 1
    fi
    echo "STEP2_DONE=1" >> "$CHECKPOINT_FILE"
fi

# Step 3: Install NVIDIA driver
if [ "$STEP3_DONE" != "1" ]; then
    echo -e "\n${YELLOW}Step 3/5: Installing NVIDIA driver...${NC}"
    ./02_nvidia_driver.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}NVIDIA driver installation failed.${NC}"
        exit 1
    fi
    echo "STEP3_DONE=1" >> "$CHECKPOINT_FILE"
    echo -e "${YELLOW}A system reboot is required before continuing with Docker installation.${NC}"
    read -p "Would you like to reboot now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Rebooting system...${NC}"
        reboot
        exit 0
    fi
fi

# Step 4: Install Docker and NVIDIA Container Toolkit
if [ "$STEP4_DONE" != "1" ]; then
    echo -e "\n${YELLOW}Step 4/5: Installing Docker and NVIDIA Container Toolkit...${NC}"
    ./03_docker.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}Docker installation failed.${NC}"
        exit 1
    fi
    echo "STEP4_DONE=1" >> "$CHECKPOINT_FILE"
fi

# Step 5: Apply system optimizations
if [ "$STEP5_DONE" != "1" ]; then
    echo -e "\n${YELLOW}Step 5/5: Applying system optimizations...${NC}"
    ./04_system_optimizations.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}System optimization failed.${NC}"
        exit 1
    fi
    echo "STEP5_DONE=1" >> "$CHECKPOINT_FILE"
fi

echo -e "\n${GREEN}Installation completed successfully!${NC}"
echo -e "${YELLOW}Please reboot your system to ensure all changes take effect.${NC}"

read -p "Would you like to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Rebooting system...${NC}"
    reboot
fi

exit 0