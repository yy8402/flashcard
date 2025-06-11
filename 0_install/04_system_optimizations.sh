#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Applying system optimizations..."

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Configure system settings
echo -e "${YELLOW}Configuring system settings...${NC}"

# Create sysctl configuration
cat > /etc/sysctl.d/99-flashcard-optimizations.conf << 'EOF'
# Memory Management
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_background_ratio=5
vm.dirty_ratio=10
vm.dirty_bytes=0
vm.dirty_background_bytes=0

# Network Optimizations
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.netdev_max_backlog=30000
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_max_tw_buckets=2000000
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=10

# File System
fs.file-max=2097152
fs.nr_open=2097152

# NUMA Settings
kernel.numa_balancing=0
EOF

# Apply sysctl settings
echo -e "${YELLOW}Applying sysctl settings...${NC}"
sysctl -p /etc/sysctl.d/99-flashcard-optimizations.conf || {
    echo -e "${RED}Failed to apply sysctl settings${NC}"
    exit 1
}

# Configure limits
echo -e "${YELLOW}Configuring system limits...${NC}"
cat > /etc/security/limits.d/99-flashcard.conf << 'EOF'
*               soft    nofile          1048576
*               hard    nofile          1048576
*               soft    nproc           unlimited
*               hard    nproc           unlimited
*               soft    memlock         unlimited
*               hard    memlock         unlimited
*               soft    stack           unlimited
*               hard    stack           unlimited
EOF

# Create monitoring script
echo -e "${YELLOW}Creating system monitoring script...${NC}"
cat > /usr/local/bin/monitor-system << 'EOF'
#!/bin/bash

echo "=== System Monitoring ==="
echo "CPU Usage:"
top -bn1 | head -n 3
echo
echo "Memory Usage:"
free -h
echo
echo "GPU Usage:"
nvidia-smi
echo
echo "Disk Usage:"
df -h /
echo
echo "Docker Container Status:"
docker ps
echo
echo "Docker Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
EOF

chmod +x /usr/local/bin/monitor-system

# Create monitoring service
echo -e "${YELLOW}Creating monitoring service...${NC}"
cat > /etc/systemd/system/system-monitor.service << 'EOF'
[Unit]
Description=System Monitoring Service
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/monitor-system
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable monitoring service
systemctl enable system-monitor.service

# Configure Docker service
echo -e "${YELLOW}Configuring Docker service...${NC}"
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --default-runtime=nvidia --storage-driver=overlay2
LimitMEMLOCK=infinity
LimitNOFILE=1048576
TasksMax=infinity
EOF

# Configure NUMA settings if available
if command -v numactl &> /dev/null; then
    echo -e "${YELLOW}Configuring NUMA settings...${NC}"
    # Create NUMA optimization script
    cat > /usr/local/bin/optimize-numa << 'EOF'
#!/bin/bash
# Bind Docker daemon to NUMA node 0
systemctl set-property docker.service CPUAffinity=0
# Restart Docker service to apply changes
systemctl restart docker
EOF

    chmod +x /usr/local/bin/optimize-numa
    /usr/local/bin/optimize-numa
fi

# Create cleanup script
echo -e "${YELLOW}Creating cleanup script...${NC}"
cat > /usr/local/bin/cleanup-system << 'EOF'
#!/bin/bash

# Clean Docker resources
docker system prune -f
docker volume prune -f

# Clean package cache
apt clean
apt autoremove -y

# Clean journal logs
journalctl --vacuum-time=7d

# Clean temp files
find /tmp -type f -atime +7 -delete

# Clean old container logs
find /var/lib/docker/containers/ -type f -name "*.log" -exec truncate -s 0 {} \;
EOF

chmod +x /usr/local/bin/cleanup-system

# Create cleanup service
cat > /etc/systemd/system/system-cleanup.service << 'EOF'
[Unit]
Description=System Cleanup Service
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cleanup-system
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable cleanup service
systemctl enable system-cleanup.service

# Reload systemd to apply changes
systemctl daemon-reload

# Restart Docker service to apply all changes
systemctl restart docker

echo -e "${GREEN}System optimizations applied successfully!${NC}"
echo -e "${YELLOW}Please reboot your system to apply all changes${NC}"
exit 0 