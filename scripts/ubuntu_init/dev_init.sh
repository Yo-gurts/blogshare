#!/bin/bash

echo -e "\n\n\n"
echo " -------------------------------------"
echo " --------- Part2: 开发环境 -----------"
echo " -------------------------------------"
echo -e "\n\n\n"


# 先输入passwd，之后5分钟使用不需要密码
echo "输入sudo 密码:"
sudo pwd

# postman and redis-desktop-manager
sudo snap install postman
sudo snap install redis-desktop-manager


# 安装 Go
wget https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.15.3.linux-amd64.tar.gz

## 设置环境变量
echo "# go" >> ~/.bashrc
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
echo "export GO111MODULE=on" >> ~/.bashrc
echo "export GOPROXY=https://goproxy.cn" >> ~/.bashrc
source ~/.bashrc
echo "查看 go version!"
go version  # 测试是否安装成功


# 安装 docker
sudo curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
echo "安装 docker!!"

# 配置加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << EOF
{
"registry-mirrors": ["https://535ons31.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
systemctl restart docker


# 安装 docker-compose
sudo curl -L https://get.daocloud.io/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "安装其他版本docker，see http://get.daocloud.io/#install-compose"
sudo chmod 666 /var/run/docker.sock   # 解决非root用户无法使用docker
echo "docker, docker-compose安装和配置"

cat >> ~/.bashrc << EOF
# alias for docker
alias dps='docker images --format "table {{.Tag}}\t{{.Repository}}"'
alias dpss='docker images --format "table {{.ID}}\t{{.Tag}}\t{{.Repository}}"'
alias cps='docker ps --format "table {{.ID}} {{.Image}}\t{{.Ports}}"'
alias dcp='docker-compose'
EOF


# 安装 miniconda
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh -O conda.sh
chmod +x conda.sh

./conda.sh
source ~/.bashrc


# pip 加速
mkdir ~/.pip
cat >> ~/.pip/pip.conf << EOF
[global]
    index-url = http://mirrors.aliyun.com/pypi/simple
[install]
    trusted-host = mirrors.aliyun.com
EOF
