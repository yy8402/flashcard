#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Installing Docker and NVIDIA Container Toolkit..."

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Add Docker repository
echo -e "${YELLOW}Adding Docker repository...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || {
    echo -e "${RED}Failed to add Docker GPG key${NC}"
    exit 1
}

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null || {
        echo -e "${RED}Failed to add Docker repository${NC}"
        exit 1
    }

# Update package lists
echo -e "${YELLOW}Updating package lists...${NC}"
apt update || { echo -e "${RED}Failed to update package lists${NC}"; exit 1; }

# Install Docker
echo -e "${YELLOW}Installing Docker...${NC}"
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || {
    echo -e "${RED}Failed to install Docker${NC}"
    exit 1
}

# Install NVIDIA Container Toolkit
echo -e "${YELLOW}Installing NVIDIA Container Toolkit...${NC}"
apt install -y nvidia-container-toolkit || {
    echo -e "${RED}Failed to install NVIDIA Container Toolkit${NC}"
    exit 1
}

# Configure Docker daemon to use NVIDIA runtime
echo -e "${YELLOW}Configuring Docker daemon...${NC}"
nvidia-ctk runtime configure --runtime=docker || {
    echo -e "${RED}Failed to configure Docker daemon${NC}"
    exit 1
}

# Create Docker configuration for resource limits
echo -e "${YELLOW}Creating Docker daemon configuration...${NC}"
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "default-ulimits": {
        "memlock": {
            "name": "memlock",
            "Hard": -1,
            "Soft": -1
        },
        "stack": {
            "name": "stack",
            "Hard": 67108864,
            "Soft": 67108864
        }
    }
}
EOF

# Restart Docker daemon
echo -e "${YELLOW}Restarting Docker daemon...${NC}"
systemctl restart docker || {
    echo -e "${RED}Failed to restart Docker daemon${NC}"
    exit 1
}

# Add current user to docker group
echo -e "${YELLOW}Adding current user to docker group...${NC}"
SUDO_USER=$(logname)
usermod -aG docker $SUDO_USER || {
    echo -e "${RED}Failed to add user to docker group${NC}"
    exit 1
}

# Verify Docker installation
echo -e "${YELLOW}Verifying Docker installation...${NC}"
if docker --version > /dev/null 2>&1; then
    echo -e "${GREEN}Docker installed successfully!${NC}"
    docker --version
else
    echo -e "${RED}Docker installation verification failed${NC}"
    exit 1
fi

# Verify NVIDIA Docker installation
echo -e "${YELLOW}Verifying NVIDIA Docker installation...${NC}"
if docker run --rm --gpus all nvidia/cuda:11.7.1-base-ubuntu20.04 nvidia-smi > /dev/null 2>&1; then
    echo -e "${GREEN}NVIDIA Docker installed successfully!${NC}"
else
    echo -e "${RED}NVIDIA Docker installation verification failed${NC}"
    echo -e "${YELLOW}Please ensure NVIDIA driver is installed and system has been rebooted${NC}"
fi

echo -e "${GREEN}Docker and NVIDIA Container Toolkit installation completed!${NC}"
echo -e "${YELLOW}Please log out and log back in for docker group changes to take effect${NC}"
exit 0 