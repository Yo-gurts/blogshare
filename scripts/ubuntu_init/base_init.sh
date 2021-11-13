#!/bin/bash

echo -e "\n\n\n"
echo " -------------------------------------"
echo " --------- Part1: 基础使用 -----------"
echo " -------------------------------------"
echo -e "\n\n\n"


echo "设置 root 用户密码"
sudo passwd


# 先输入passwd，之后5分钟使用不需要密码
echo "输入sudo 密码:"
sudo pwd

sudo apt update >> log.txt
echo "apt update!!\n"


# 设置终端仅显示当前文件夹名称, 
sed -i 's/h:\\w\\\$/h:\\W\\\$/g' ~/.bashrc  # for server
sed -i 's/\]\\w\\\[/\]\\W\\\[/g' ~/.bashrc  # for desktop
source ~/.bashrc
echo "设置终端仅显示当前文件夹名称!!"


# 设置page up/down 检索历史命令
sudo sed -i 's/\#\ \"\\e\[5\~\"\:\ history/\"\\e\[5\~\"\:\ history/g' /etc/inputrc
sudo sed -i 's/\#\ \"\\e\[6\~\"\:\ history/\"\\e\[6\~\"\:\ history/g' /etc/inputrc
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
sudo apt -y install vim >> log.txt
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
sudo apt -y install autojump >> log.txt
echo ". /usr/share/autojump/autojump.bash" >> ~/.bashrc
sudo chmod 755 /usr/share/autojump/autojump.bash
source ~/.bashrc
echo "安装autojump !!"


# 安装git, 并配置
sudo apt -y install git >> log.txt
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
	email = yusong1117.u@gmail.com
[core] # 解决中文显示异常问题
	editor = vim
	quotepath = false
[http]
	proxy = http://127.0.0.1:8889
EOF
echo "安装git, 并配置!!"


# 设置 ssh 相关密钥
mkdir ~/.ssh
cat > ~/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhHrOhcUagFwscCVBHJMutVWCHiNN/Q+LDkZkfhR52u9sa9BaupI0yCPJ9UmVBY6SjzuHDRf95Kxp6tfwtHc/TCHaPj7OS5JoDRz8jya09WvqzvEErtldXxn6Zsl5b1lLze2/bEtatzolv0xUMndW601iSAV6xltsOC+1OwSr89+5wYIPlsUXIBsPtjOXN0OhpB9Ps7fnjWDm1Nvwe8qgey2Vmn8a1AOcpZbXvELNGmrCSrIPIzknqQiYHx/CaCtzZ+fOrYvuP31BjHkC8WO6E0AWHPdGXL3Sp5mN24ospBjXqyrIlRJToPWfKhknKJz3bwIPKeyp8CptFsBlHdQlb yusong1117.u@gmail.com
EOF
sudo chmod 700 ~/.ssh
sudo chmod 600 ~/.ssh/*
echo "设置 ssh 相关密钥!!"


# 使用terminator终端
sudo apt -y install terminator >> log.txt
mkdir -p ~/.config/terminator
cat > ~/.config/terminator/config << EOF
[global_config]
  focus = system
  suppress_multiple_term_dialog = True
  title_transmit_bg_color = "#d30102"
[keybindings]
  split_vert = <Alt>e
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      profile = default
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    background_color = "#2d2d2d"
    background_darkness = 0.85
    copy_on_selection = True
    cursor_color = "#2D2D2D"
    font = Monospace 13
    foreground_color = "#eee9e9"
    palette = "#2d2d2d:#f2777a:#99cc99:#ffcc66:#6699cc:#cc99cc:#66cccc:#d3d0c8:#747369:#f2777a:#99cc99:#ffcc66:#6699cc:#cc99cc:#66cccc:#f2f0ec"
    scrollback_infinite = True
    scrollback_lines = 1000
    show_titlebar = False
    use_system_font = False
  [[transparent]]
    background_color = "#2d2d2d"
    background_darkness = 0.36
    background_type = transparent
    copy_on_selection = True
    cursor_color = "#2D2D2D"
    font = Monospace 13
    foreground_color = "#eee9e9"
    palette = "#2d2d2d:#f2777a:#99cc99:#ffcc66:#6699cc:#cc99cc:#66cccc:#d3d0c8:#747369:#f2777a:#99cc99:#ffcc66:#6699cc:#cc99cc:#66cccc:#f2f0ec"
    scrollback_infinite = True
    scrollback_lines = 1000
    show_titlebar = False
    use_system_font = False

EOF
echo "使用terminator终端!!"


# 安装必要的工具
sudo apt -y install net-tools unar tree make >> log.txt
echo "安装常用小工具：net-tools, unar, tree, make!!"


# 安装 ssh
sudo apt -y install openssh-server >> log.txt
sudo systemctl enable ssh
sudo systemctl start ssh
echo "安装 ssh!!"


# 将相关的配置也复制到root用户下

# 设置终端仅显示当前文件夹名称, 
sudo sed -i 's/h:\\w\\\$/h:\\W\\\$/g' /root/.bashrc  # for server
sudo sed -i 's/\]\\w\\\[/\]\\W\\\[/g' /root/.bashrc  # for desktop
source ~/.bashrc
echo "设置终端仅显示当前文件夹名称!!"

# 安装autojump !!
sudo echo ". /usr/share/autojump/autojump.bash" >> /root/.bashrc

# 添加常用别名alias for root !! cat 无法修改root下的文件，只能用tee
sudo tee -a /root/.bashrc << EOF
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
echo "添加常用别名alias for root !!"

# 安装vim, 并设置基本配置!!
sudo cp ~/.vimrc /root/

# 安装git, 并配置
sudo cp ~/.gitconfig /root/

# 设置 ssh 相关密钥
sudo mkdir /root/.ssh
sudo cp ~/.ssh/authorized_keys /root/.ssh/
