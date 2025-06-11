#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking system requirements..."

# Check Ubuntu version
echo -n "Checking Ubuntu version: "
if [[ $(lsb_release -rs) == "24.04" ]]; then
    echo -e "${GREEN}Ubuntu 24.04 detected${NC}"
else
    echo -e "${RED}This script requires Ubuntu 24.04${NC}"
    exit 1
fi

# Check CPU cores
echo -n "Checking CPU cores: "
CPU_CORES=$(nproc)
if [[ $CPU_CORES -ge 4 ]]; then
    echo -e "${GREEN}$CPU_CORES cores detected (minimum 4 required)${NC}"
else
    echo -e "${RED}Insufficient CPU cores. Found $CPU_CORES, minimum 4 required${NC}"
    exit 1
fi

# Check RAM
echo -n "Checking RAM: "
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [[ $TOTAL_RAM -ge 32 ]]; then
    echo -e "${GREEN}${TOTAL_RAM}GB RAM detected (minimum 32GB required)${NC}"
else
    echo -e "${RED}Insufficient RAM. Found ${TOTAL_RAM}GB, minimum 32GB required${NC}"
    exit 1
fi

# Check disk space
echo -n "Checking disk space: "
FREE_DISK=$(df -BG / | awk '/^\/dev/{print $4}' | tr -d 'G')
if [[ $FREE_DISK -ge 100 ]]; then
    echo -e "${GREEN}${FREE_DISK}GB free space detected (minimum 100GB required)${NC}"
else
    echo -e "${RED}Insufficient disk space. Found ${FREE_DISK}GB, minimum 100GB required${NC}"
    exit 1
fi

# Check for NVIDIA GPU
echo -n "Checking for NVIDIA GPU: "
if [ -d "/proc/driver/nvidia" ]; then
    # Driver is installed, use nvidia-smi
    GPU_NAME=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader 2>/dev/null)
    if [[ $GPU_NAME == *"Tesla P4"* ]]; then
        echo -e "${GREEN}Tesla P4 detected (with drivers)${NC}"
    else
        echo -e "${YELLOW}NVIDIA drivers installed but no Tesla P4 found. Found: $GPU_NAME${NC}"
    fi
else
    # Check for GPU without drivers using lspci
    if lspci | grep -i nvidia > /dev/null; then
        GPU_INFO=$(lspci | grep -i nvidia)
        if [[ $GPU_INFO == *"Tesla P4"* ]]; then
            echo -e "${GREEN}Tesla P4 detected (drivers not installed)${NC}"
        else
            echo -e "${RED}No Tesla P4 found. Found NVIDIA device: $GPU_INFO${NC}"
            exit 1
        fi
    else
        echo -e "${RED}No NVIDIA GPU detected${NC}"
        exit 1
    fi
fi

# Check internet connectivity
echo -n "Checking internet connectivity: "
if ping -c 1 google.com &> /dev/null; then
    echo -e "${GREEN}Connected${NC}"
else
    echo -e "${RED}No internet connection${NC}"
    exit 1
fi

echo -e "\n${GREEN}All system requirements met!${NC}"
exit 0 