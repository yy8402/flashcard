#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Installing system packages..."

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt update || { echo -e "${RED}Failed to update package lists${NC}"; exit 1; }

# Upgrade existing packages
echo -e "${YELLOW}Upgrading existing packages...${NC}"
apt upgrade -y || { echo -e "${RED}Failed to upgrade packages${NC}"; exit 1; }

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    build-essential \
    python3-pip \
    python3-dev \
    numactl \
    htop \
    iotop \
    net-tools \
    || { echo -e "${RED}Failed to install required packages${NC}"; exit 1; }

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
apt autoremove -y
apt clean

echo -e "${GREEN}System packages installation completed successfully!${NC}"
exit 0 