#!/bin/bash

echo -e "\n\n\n"
echo " -------------------------------------"
echo " --------- Part3: 其他配置 ------------"
echo " -------------------------------------"
echo -e "\n\n\n"

# 先输入passwd，之后5分钟使用不需要密码
echo "输入sudo 密码:"
sudo pwd

sudo apt update >> log.txt
echo "apt update!!\n"


# 安装终端翻译工具
sudo apt -y install xsel python3-pip
pip3 install pyperclip
sudo mv ../fanyi.py /usr/local/bin/fanyi
sudo chmod +x /usr/local/bin/fanyi
echo "安装终端翻译工具!!"


# 安装一些有用的轻量工具
sudo apt -y install tldr poppler-utils


# pdf合并工具：pdfsam，可视化硬盘使用情况：filelight
sudo apt install pdfsam filelight


# 更换阿里镜像源! （阿里云的服务器默认使用阿里镜像）
sudo tee /etc/apt/source.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
EOF
sudo apt update
echo "更换阿里镜像源!"


# 修改conda的默认镜像源
sudo tee ~/.condarc << EOF
channels:
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
  - https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - defaults
show_channel_urls: true
EOF



echo -e "\n\n\n"
echo " -------------------------------------"
echo " --------- Part4: 比较费时的安装 ------------"
echo " -------------------------------------"
echo -e "\n\n\n"


# 安装 chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
echo "安装 chrome!!"


# 先输入passwd，之后5分钟使用不需要密码
echo "输入sudo 密码:"
sudo pwd


# 安装 texlive, 下面的内容建议一行一行的复制，运行。推荐使用网页版，https://cn.overleaf.com/
sudo apt -y install libfontconfig1-dev
wget https://mirrors.ustc.edu.cn/CTAN/systems/texlive/Images/texlive.iso
# wget https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/texlive.iso

sudo mount -o loop texlive.iso /mnt
cd /mnt
sudo ./install-tl   # 开始安装，跟着它走就行

cd ~
sudo unmount /mnt

# 添加环境变量，在~/.bashrc 文件中添加如下内容，注意修改版本，这里是 2020
cat >> ~/.bashrc << EOF
export PATH=\${PATH}:/usr/local/texlive/2020/bin/x86_64-linux
export MANPATH=\${MANPATH}:/usr/local/texlive/2020/texmf-dist/doc/man
export INFOPATH=\${INFOPATH}:/usr/local/texlive/2020/texmf-dist/doc/info"
EOF
source ~/.bashrc

# 测试！
tex --version
echo "若找不到tex，可能是因为上面的路径有问题，2020要改为对应的年份"


# 安装 vs code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt -y install apt-transport-https
sudo apt update
sudo apt -y install code >> log.txt # or code-insiders
echo "安装 vs code!!"


# 安装 typora
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt update
sudo apt -y install typora >> log.txt


# 安装 wps，新版本无法对pdf注释，所以安装旧版本
wget https://wdl1.cache.wps.cn/wps/download/ep/Linux2019/10161/wps-office_11.1.0.10161_amd64.deb
sudo dpkg -i wps-office_11.1.0.10161_amd64.deb
echo "安装 wps"



# 安装 sougou input
sudo apt -y install fcitx fcitx-libs libfcitx-qt0 libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2
wget https://ime.sogouimecdn.com/202111132016/a831ae900d6b15cb92ac76cd7486a26d/dl/index/1612260778/sogoupinyin_2.4.0.3469_amd64.deb
sudo dpkg -i sogoupinyin_2.4.0.3469_amd64.deb
echo "安装 sougou 输入法，还需要按照此blog设置 https://blog.csdn.net/lupengCSDN/article/details/80279177 "


# 安装 Qv2ray
mkdir ~/AppImage
echo "download from https://github.com/Qv2ray/Qv2ray/releases/download/v2.7.0/Qv2ray-v2.7.0-linux-x64.AppImage"
echo "download from https://github.com/v2ray/v2ray-core/releases/download/v4.28.2/v2ray-linux-64.zip"
echo "don't forget chmod +x Qv2ray-v2.7.0-linux-x64.AppImage"
