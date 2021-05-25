#!/bin/bash

apt update
echo "apt update!!\n"

echo "\n\n\n"
echo " -------------------------------------"
echo " --------- Part1: 基础使用 -----------"
echo " -------------------------------------"
echo "\n\n\n"

# 设置终端仅显示当前文件夹名称, 
sed -i 's/@:\\h:\\w\\\$/:\\W\\\$/g' ~/.bashrc  # for server, 不显示主机名
sed -i 's/\]\\w\\\[/\]\\W\\\[/g' ~/.bashrc  # for desktop
source ~/.bashrc
echo "设置终端仅显示当前文件夹名称!!"


# 设置page up/down 检索历史命令
sed -i 's/\#\ \"\\e\[5\~\"\:\ history/\"\\e\[5\~\"\:\ history/g' /etc/inputrc
sed -i 's/\#\ \"\\e\[6\~\"\:\ history/\"\\e\[6\~\"\:\ history/g' /etc/inputrc
echo "设置page up/down 检索历史命令"


# 添加常用别名alias !!
cat >> ~/.bashrc << EOF
# alias set
alias la='ls -A'
alias lh='ls -lh'
alias l='ls'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias vi='vim'
alias lm='ls -l|grep "^-"| wc -l'

EOF
source ~/.bashrc
echo "添加常用别名alias !!"


# 安装vim, 并设置基本配置!!
apt -y install vim
cat > ~/.vimrc << EOF
" 1. 基础配置
set title           " 窗口标题为文件名
set nobackup        " 设置覆盖文件时不保留备份文件
set noerrorbells    " 关闭error报警

" 2. 编码设置
set encoding=utf-8  " 设置文件编码

" 3. 界面设置
set number          " 显示行号
set relativenumber  " 设置相对行号
set ruler           " 显示光标所在行号和列号
set showcmd         " 显示命令
set showmode        " 显示模式

" 4. 查找设置
set hlsearch        " 高亮搜索目标
set incsearch       " 实时匹配目标
set ignorecase      " 忽略大小写
set smartcase       " 智能推测

" 5. Tab 与 缩进设置
set expandtab       " 用空格补充
set smarttab        " 插入tab时使用 shiftwidth
set shiftround      " 缩进列数对齐到 shiftwidth 值的整数倍

set shiftwidth=4    " 设置 >> 缩进列数
set tabstop=4       " 按下 Tab 键时，缩进的空格个数
set softtabstop=4   
set autoindent      " 自动缩进
set smartindent     " 智能缩进

" 6. 光标设置
set cursorcolumn    " 高亮显示光标所在行
set cursorline      " 高亮显示光标所在列

" 7. 按键映射

" F2 开启/关闭 行号显示
nnoremap <F2> :set nu! nu?<CR>  
" 是否显示特殊字符：行尾，制表符
nnoremap <F3> :set list! list?<CR>
" 是否折行
nnoremap <F4> :set wrap! wrap?<CR>
" 粘贴无自动缩进
set pastetoggle=<F5> 
" 是否语法高亮
nnoremap <F6> :exec exists('syntax_on') ? 'syn off' : 'syn on'<CR>

" 设置非输入模式时按enter也换行
nnoremap <CR> o<Esc>    
" 使用;代表:
nnoremap ; :

" 自动匹配括号
"inoremap { {}<LEFT>  

"nmap gk k
"nmap gj j 
"nmap j gj      " 替换屏幕行和实际行
"nmap k gk      " 但有bug

" 8. 提升速度
set re=1
set ttyfast
set lazyredraw
set scrolljump=10

" 9. 其他
set mouse=a         " 支持鼠标

" 10. 插件安装工具 Vundle
"set nocompatible               "去除VIM一致性，必须"
"filetype off                   "必须"
"
""设置包括vundle和初始化相关的运行时路径"
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"
""启用vundle管理插件，必须"
"Plugin 'VundleVim/Vundle.vim'
"
""在此增加其他插件，安装的插件需要放在vundle#begin和vundle#end之间"
""安装github上的插件格式为 Plugin '用户名/插件仓库名'"
"
"Plugin 'tpope/vim-surround'
"
"call vundle#end()
"filetype plugin indent on      "加载vim自带和插件相应的语法和文件类型相关脚本，必须"
EOF
echo "安装vim, 并设置基本配置!!"


# 安装autojump !!
apt -y install autojump
echo ". /usr/share/autojump/autojump.bash" >> ~/.bashrc
chmod 755 /usr/share/autojump/autojump.bash
source ~/.bashrc
echo "安装autojump !!"


# 安装git, 并配置
apt -y install git
cat > ~/.gitconfig << EOF
[color]
	ui = true
[alias]
	st = status
	co = checkout
	ci = commit
	br = branch
	lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
[credential]
    helper=store
[user]
	name = yogurt
	email = youremail@gmail.com
[core] # 解决中文显示异常问题
	quotepath = false
# [http]
# 	proxy = http://127.0.0.1:8889
EOF
echo "安装git, 并配置!!"

# 安装常用小工具：tldr, unar, aria2, poppler-utils(pdf处理), tree, make
apt -y install tldr unar poppler-utils aria2 tree make
echo "安装常用小工具：tldr, unar, aria2, poppler-utils(pdf处理), tree, make!!"


# 使用terminator终端（服务器上用不着）
# apt -y install terminator
# cp .terminator.backup ~/.config/terminator/config
# echo "使用terminator终端!!"


# 安装终端翻译工具
# apt -y install xsel python3-pip
# pip3 install pyperclip
# mv fanyi.py /usr/local/bin/fanyi
# chmod +x /usr/local/bin/fanyi
# echo "安装终端翻译工具!!"


# 更换阿里镜像源! （阿里云的服务器默认使用阿里镜像）
# cat > /etc/apt/source.list << EOF
# deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
# deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
# deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
# deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
# deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
# 
# EOF
# apt update
# echo "更换阿里镜像源!"


# 设置 ssh 相关密钥
# mkdir ~/.ssh
# cp .ssh/id_rsa.pub.backup ~/.ssh/authorized_keys
# cp .ssh/id_rsa.pub.backup ~/.ssh/id_rsa.pub
# cp .ssh/id_rsa.backup ~/.ssh/id_rsa
# chmod 700 ~/.ssh
# chmod 600 ~/.ssh/*
# echo "设置 ssh 相关密钥!!"




echo "\n\n\n"
echo " -------------------------------------"
echo " --------- Part2: 开发环境 -----------"
echo " -------------------------------------"
echo "\n\n\n"


# 安装 Go
## 下载Go并解压
wget https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.15.3.linux-amd64.tar.gz

## 设置环境变量
echo "# go" >> ~/.bashrc
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
echo "export GO111MODULE=on" >> ~/.bashrc
echo "export GOPROXY=https://goproxy.cn" >> ~/.bashrc
source ~/.bashrc

# 测试
go version
echo "查看 go 是否正常"


# 安装 docker
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
echo "安装 docker!!"

# 配置加速器
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://535ons31.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker

# install docker-compose
curl -L https://get.daocloud.io/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "安装其他版本docker，see http://get.daocloud.io/#install-compose"
chmod 666 /var/run/docker.sock   # 解决非root用户无法使用docker
echo "docker, docker-compose安装和配置"

cat >> ~/.bashrc << EOF
# alias for docker
alias dps='docker images --format "table {{.Tag}}\t{{.Repository}}"'
alias dpss='docker images --format "table {{.ID}}\t{{.Tag}}\t{{.Repository}}"'
alias cps='docker ps --format "table {{.ID}} {{.Image}}\t{{.Ports}}"'
alias dcp='docker-compose'
EOF


# # 安装 miniconda
# wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh -O conda.sh
# chmod +x conda.sh
# 
# ./conda.sh
# source ~/.bashrc
# 
