#!/bin/bash
#
# Docker CE Auto Install Script
# Supported: CentOS / RHEL / Ubuntu / Debian

echo_green(){  echo -e "\e[32m$1\e[0m"; }
echo_red(){    echo -e "\e[31m$1\e[0m"; }
echo_yellow(){ echo -e "\e[33m$1\e[0m"; }

set -e

echo_green "[INFO] Detecting system..."

# 检查系统类型
if [ -f /etc/redhat-release ]; then
    OS="centos" && echo_green "os is centos"
elif [ -f /etc/debian_version ]; then
    OS="debian"
elif grep -qi ubuntu /etc/issue; then
    OS="ubuntu"
else
    echo "[ERROR] Unsupported OS."
    exit 1
fi

echo_green "[INFO] Installing Docker on $OS ..."

if [ "$OS" == "centos" ]; then
    # 卸载旧版本
    yum remove -y docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine || true

    # 安装依赖
    yum install -y yum-utils device-mapper-persistent-data lvm2

    # 添加 Docker 源
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # 安装 Docker CE
    yum install -y docker-ce docker-ce-cli containerd.io

    systemctl enable docker
    systemctl start docker

elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
    # 卸载旧版本
    apt-get remove -y docker docker-engine docker.io containerd runc || true

    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # 添加 Docker 官方 GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/${OS}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS} \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    systemctl enable docker
    systemctl start docker
fi

echo_green "[INFO] Docker installed successfully!"
docker --version
