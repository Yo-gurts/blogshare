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


# 安装 chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
echo "安装 chrome!!"


# 安装终端翻译工具
sudo apt -y install xsel python3-pip
pip install pyperclip
sudo touch /usr/local/bin/fanyi
sudo tee -a /usr/local/bin/fanyi << EOF
#!/usr/bin/python3

import sys
import json
import signal
import urllib.request as urllib
import threading
import pyperclip
import time

class Dict:
    key = '716426270'
    keyFrom = 'wufeifei'
    api = 'http://fanyi.youdao.com/openapi.do?keyfrom=wufeifei&key=716426270&type=data&doctype=json&version=1.1&q='
    content = None

    def __init__(self, argv):
        try:
            self.api = self.api + urllib.quote(argv)
            self.translate()
        except Exception as e:
            print("exception: ", e)

    def translate(self):
        content = urllib.urlopen(self.api).read()
        self.content = json.loads(content)
        self.parse()

    def parse(self):
        code = self.content['errorCode']
        if code == 0:  # Success
            try:
                u = self.content['basic']['us-phonetic'] # English
                e = self.content['basic']['uk-phonetic']
            except KeyError:
                try:
                    c = self.content['basic']['phonetic'] # Chinese
                except KeyError:
                    c = 'None'
                u = 'None'
                e = 'None'

            try:
                explains = self.content['basic']['explains']
            except KeyError:
                explains = 'None'

            print('\033[1;31m################################### \033[0m')
            # flag
            #print('\033[1;31m# \033[0m', self.content['query'], self.content['translation'][0], end="")
            print('\033[1;31m# \033[0m', self.content['query'], self.content['translation'][0])
            if u != 'None':
                print('(U:', u, 'E:', e, ')')
            elif c != 'None':
                print('(Pinyin:', c, ')')
            else:
                print()

            if explains != 'None':
                for i in range(0, len(explains)):
                    print('\033[1;31m# \033[0m', explains[i])
            else:
                print('\033[1;31m# \033[0m Explains None')
            print('\033[1;31m################################### \033[0m')
            # Phrase
            # for i in range(0, len(self.content['web'])):
            #     print self.content['web'][i]['key'], ':'
            #     for j in range(0, len(self.content['web'][i]['value'])):
            #         print self.content['web'][i]['value'][j]
        elif code == 20:  # Text to long
            print('WORD TO LONG')
        elif code == 30:  # Trans error
            print('TRANSLATE ERROR')
        elif code == 40:  # Don't support this language
            print('CAN\'T SUPPORT THIS LANGUAGE')
        elif code == 50:  # Key failed
            print('KEY FAILED')
        elif code == 60:  # Don't have this word
            print('DO\'T HAVE THIS WORD')


class Clipboard (threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.raw = "Welcome!!"

    def run(self):
        global exitflag
        while not exitflag:
            time.sleep(0.5)
            new_raw = pyperclip.paste()
            if new_raw != self.raw:
                self.raw = new_raw
                words = self.raw.split(",")
                print()
                for word in words:
                    Dict(word)
                print(">>>", end="", flush=True)


class Outinput (threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)

    def run(self):
        global exitflag
        while not exitflag:
            raw = input(">>>")
            words = raw.split(",")
            if words == ['exit']:
                exitflag = True
            else:
                for word in words:
                    Dict(word)


def quit():
    print("bye!!")
    sys.exit()

if __name__ == '__main__':
    exitflag = False

    if len(sys.argv) >= 2:
        for item in sys.argv[1:]:
            Dict(item)
    else:
        try:
            signal.signal(signal.SIGINT, quit)
            signal.signal(signal.SIGTERM, quit)
            
            thread1 = Clipboard()
            thread2 = Outinput()

            thread1.setDaemon(True)
            thread1.start()

            thread2.setDaemon(True)     
            thread2.start()
            
            thread1.join()
            thread2.join()
            print("bye!!")
        except Exception as e:
            print(e)
EOF
sudo chmod +x /usr/local/bin/fanyi
echo "安装终端翻译工具!!"


echo -e "\n\n\n"
echo " -------------------------------------"
echo " --------- Part4: 比较费时的安装 ------------"
echo " -------------------------------------"
echo -e "\n\n\n"


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