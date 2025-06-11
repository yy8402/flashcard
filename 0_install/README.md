# Installation Scripts for AI-Powered Flashcard Generator

This directory contains automated installation scripts for setting up the AI-Powered Flashcard Generator on Ubuntu 24.04 with NVIDIA Tesla P4 GPU support.

## Prerequisites

- Ubuntu 24.04 LTS
- NVIDIA Tesla P4 GPU (8GB VRAM)
- At least 32GB RAM
- At least 100GB free disk space
- Root access

## Installation Scripts

1. `00_check_system.sh`: Verifies system requirements
   - Ubuntu version
   - CPU cores
   - RAM
   - Disk space
   - NVIDIA GPU presence (with or without drivers)
   - Internet connectivity

2. `01_system_packages.sh`: Installs required system packages
   - Basic development tools
   - Python dependencies
   - System utilities

3. `02_nvidia_driver.sh`: Installs NVIDIA drivers and optimizations
   - Checks for existing driver installation
   - Installs or updates to NVIDIA driver 535
   - GPU optimization scripts
   - Systemd service for GPU optimization

4. `03_docker.sh`: Installs Docker and NVIDIA Container Toolkit
   - Docker CE
   - Docker Compose
   - NVIDIA Container Toolkit
   - Docker daemon configuration

5. `04_system_optimizations.sh`: Applies system-wide optimizations
   - Sysctl configurations
   - System limits
   - NUMA settings
   - Monitoring tools
   - Cleanup services

## Usage

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd flashcard/install
   ```

2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installation script as root:
   ```bash
   sudo ./install.sh
   ```

The installation process will:
1. Check system requirements (including Tesla P4 detection)
2. Install necessary packages
3. Install/update NVIDIA drivers (if needed)
4. Prompt for a reboot
5. Install Docker and NVIDIA Container Toolkit
6. Apply system optimizations
7. Prompt for final reboot

## Post-Installation

After installation and final reboot:

1. Verify the installation:
   ```bash
   nvidia-smi  # Check GPU
   docker run --rm --gpus all nvidia/cuda:11.7.1-base-ubuntu20.04 nvidia-smi  # Check NVIDIA Docker
   ```

2. Start the services:
   ```bash
   cd /path/to/flashcard
   docker compose up -d
   ```

3. Monitor the system:
   ```bash
   /usr/local/bin/monitor-system
   ```

## Maintenance

The installation includes several maintenance tools:

1. System Monitoring:
   ```bash
   /usr/local/bin/monitor-system
   ```

2. System Cleanup:
   ```bash
   /usr/local/bin/cleanup-system
   ```

3. GPU Optimization:
   ```bash
   /usr/local/bin/optimize-gpu
   ```

4. NUMA Optimization:
   ```bash
   /usr/local/bin/optimize-numa
   ```

## Troubleshooting

If you encounter issues:

1. Check the system requirements:
   ```bash
   ./00_check_system.sh
   ```

2. Check GPU detection without drivers:
   ```bash
   lspci | grep -i nvidia
   ```

3. Check GPU with drivers:
   ```bash
   nvidia-smi
   ```

4. View service logs:
   ```bash
   docker compose logs -f
   ```

5. Verify Docker status:
   ```bash
   systemctl status docker
   ```

6. Check system logs:
   ```bash
   journalctl -xe
   ```

## Common Issues

1. **NVIDIA GPU not detected**
   - Check if the GPU is properly seated
   - Verify PCIe power connections
   - Run `lspci | grep -i nvidia` to check hardware detection

2. **NVIDIA driver installation fails**
   - Check secure boot is disabled
   - Verify kernel headers are installed
   - Check installation logs: `dmesg | grep -i nvidia`

3. **Docker permission issues**
   - Verify user is in docker group
   - Try logging out and back in
   - Check Docker daemon status

## Security Notes

1. The installation scripts require root access
2. Default configurations are optimized for development/testing
3. For production deployment, consider:
   - Setting up SSL/TLS
   - Configuring firewall rules
   - Implementing access controls
   - Regular security updates

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review service logs
3. Open an issue on the repository
4. Contact the maintainers 