#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Installing NVIDIA drivers..."

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Check if NVIDIA driver is already installed
if [ -d "/proc/driver/nvidia" ]; then
    echo -e "${YELLOW}NVIDIA driver already installed. Checking version...${NC}"
    CURRENT_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null)
    if [[ "$CURRENT_VERSION" == "535."* ]]; then
        echo -e "${GREEN}NVIDIA driver version $CURRENT_VERSION is already installed and up to date${NC}"
        echo -e "${YELLOW}Skipping driver installation...${NC}"
    else
        echo -e "${YELLOW}Current NVIDIA driver version $CURRENT_VERSION needs update${NC}"
    fi
fi

# Add NVIDIA package repository
echo -e "${YELLOW}Adding NVIDIA package repository...${NC}"
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg || { 
    echo -e "${RED}Failed to add NVIDIA GPG key${NC}"
    exit 1
}

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list || {
        echo -e "${RED}Failed to add NVIDIA repository${NC}"
        exit 1
    }

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt update || { echo -e "${RED}Failed to update package lists${NC}"; exit 1; }

# Install NVIDIA driver
echo -e "${YELLOW}Installing NVIDIA driver...${NC}"
apt install -y nvidia-driver-535 || { echo -e "${RED}Failed to install NVIDIA driver${NC}"; exit 1; }

# Verify installation
echo -e "${YELLOW}Verifying NVIDIA driver installation...${NC}"
if nvidia-smi &> /dev/null; then
    echo -e "${GREEN}NVIDIA driver installed successfully!${NC}"
    nvidia-smi
else
    echo -e "${RED}NVIDIA driver installation verification failed${NC}"
    echo -e "${YELLOW}A system reboot is required to complete the installation${NC}"
    echo -e "${YELLOW}Please reboot your system with: 'sudo reboot'${NC}"
fi

# Create optimization script
echo -e "${YELLOW}Creating GPU optimization script...${NC}"
cat > /usr/local/bin/optimize-gpu << 'EOF'
#!/bin/bash

# Set PCIe power management to performance
echo "performance" > /sys/module/pcie_aspm/parameters/policy

# Set GPU power management to maximum performance
nvidia-smi -pm 1
nvidia-smi -ac 2505,875

# Disable GPU auto boost
nvidia-smi --auto-boost-default=0

# Set persistence mode
nvidia-smi -i 0 -pm 1

# Set application clocks to maximum
nvidia-smi -ac 877,1530
EOF

chmod +x /usr/local/bin/optimize-gpu

# Create systemd service for GPU optimization
echo -e "${YELLOW}Creating GPU optimization service...${NC}"
cat > /etc/systemd/system/gpu-optimize.service << 'EOF'
[Unit]
Description=GPU Optimization Service
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/optimize-gpu
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable gpu-optimize.service

echo -e "${GREEN}NVIDIA driver installation completed!${NC}"
echo -e "${YELLOW}Please reboot your system to complete the installation${NC}"
exit 0 