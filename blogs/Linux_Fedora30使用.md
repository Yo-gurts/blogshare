---
date: 2019-03-22 
author: yogurt
---

fedora 版本：fedora workstation live x86-64-30

<details>
<summary>目录</summary>
    
- [基础设置](#基础设置)
  - [set root passwd](#set-root-passwd)
  - [配置terminal](#配置terminal)
    - [添加快捷键](#添加快捷键)
- [常用软件安装](#常用软件安装)
  - [安装五笔输入法](#安装五笔输入法)
  - [安装chrome](#安装chrome)
  - [安装 vim](#安装-vim)
  - [安装 VS code](#安装-vs-code)
  - [解压rar文件](#解压rar文件)
  - [安装 tex live](#安装-tex-live)
  - [mathpix 将图片转为latex公式](#mathpix-将图片转为latex公式)
  - [安装 xmind-zen（知识图谱）](#安装-xmind-zen知识图谱)
  - [安装福昕pdf阅读器](#安装福昕pdf阅读器)
  - [安装flash player](#安装flash-player)
  - [安装 tesseract](#安装-tesseract)
    - [截屏后自动ocr文字识别到剪贴板](#截屏后自动ocr文字识别到剪贴板)
  - [视音频处理工具`ffmpeg`](#视音频处理工具ffmpeg)
  - [视频播放器 VLC](#视频播放器-vlc)
  - [install matlab](#install-matlab)
  - [壁纸](#壁纸)
  - [安装 octave](#安装-octave)
  - [安装nvidia显卡驱动](#安装nvidia显卡驱动)
  - [安装 snap](#安装-snap)
  - [安装 scrcpy](#安装-scrcpy)
- [Coding Time](#coding-time)
  - [安装 anaconda](#安装-anaconda)
  - [安装tensorflow](#安装tensorflow)
  - [安装g++](#安装g)
  - [安装opencv-c++](#安装opencv-c)
  - [git配置](#git配置)
- [实用设置](#实用设置)
  - [关闭更新提醒](#关闭更新提醒)
  - [图片反色](#图片反色)
  - [终端使用代理](#终端使用代理)
  - [好用的工具](#好用的工具)
  - [本地与云服务器互传文件](#本地与云服务器互传文件)
  - [文件编码转换 iconv](#文件编码转换-iconv)
  - [文件名编码转换 convmv](#文件名编码转换-convmv)
  - [磁盘挂载错误(fedora上还没有遇到过！)](#磁盘挂载错误fedora上还没有遇到过)
  - [(.ppt .doc) to pdf](#ppt-doc-to-pdf)
  - [软件数据线(app)](#软件数据线app)
  - [清除旧的内核`kernel`](#清除旧的内核kernel)
  - [gnome桌面自定义工具](#gnome桌面自定义工具)
  - [linux 下的'photoshop'--gimp](#linux-下的photoshop--gimp)
  - [音频处理--audacity](#音频处理--audacity)
  - [pdf remove passwd](#pdf-remove-passwd)
  - [终端翻译工具(需网络)](#终端翻译工具需网络)
  - [后台支行命令，并将log输出到myout.file中](#后台支行命令并将log输出到myoutfile中)
  - [释放空间](#释放空间)
</details>

# 基础设置

## set root passwd
刚开始的时候是没有设置root密码的，所以好像是用不了su，设置下就好了
```bash
sudo passwd root
```

## 配置terminal
自带的terminal不好用，可以下载`terminator`.
```bash
sudo dnf install terminator

# 安装好后，编译配置文件 ~/.config/terminator/config, 内容如下

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
    show_titlebar = False
    use_system_font = False

```
### 添加快捷键
1. 打开 Setting/Devices/keyboard/custom shortcuts
2. 添加快捷键如下

```
Name: terminal or something what you like
Command: terminator
Shortcut: 设置快捷键
```

# 常用软件安装

## 安装五笔输入法
**ubuntu下直接使用搜狗输入法，既支持拼音又支持五笔输入**

```bash
sudo dnf install ibus*wubi*
reboot # 重启才生效，再在设置里面添加输入法，使用极点挺好的
```

## 安装chrome
```bash
sudo dnf install google-chrome-stable
```

## 安装 vim
安装没啥，主要是配置，下面的都是很基础的一些配置，其他的参考[vim教程网](https://vim.ink/)

vim ~/.vimrc 
```vim
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
```

## 安装 VS code 
> [官方指南](https://code.visualstudio.com/docs/setup/linux)

```
markdown : Markdown all in one
latex : latex workshop
汉化   : Chinese(simplified) langugae package
```

## 解压rar文件

在ubuntu上可以通过unrar来解压rar压缩文件，然而，在fedora上并没有unrar这个命令。不过，它提供了另一个更好用的命令`unar`(需要自己安装)。不仅对rar类型的文件适用，也可用于其他格式的压缩文件。
```bash
unar *.zip/rar/tar...
```


##  安装 tex live 
> [参考](https://ghou.me/2017/06/06/install-tex-live-on-linux/)
>
> [安装包有点不好找....](http://mirror.lzu.edu.cn/CTAN/systems/texlive/Images/)
> [安装包清华镜像](https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/)

----更新-------
在fedora30上可以直接使用`sudo dnf install texlive`安装即可，下面是以前在ubuntu上的步骤

file:///usr/local/texlive/2019/index.html
```bash
sudo mount -o loop texlive.iso /mnt
cd /mnt
sudo ./install-tl # 开始安装，跟着它走就行

cd ~
sudo unmount /mnt

# 添加环境变量，在~/.bashrc 文件中添加如下内容
# TeX Live 2018
export PATH=${PATH}:/usr/local/texlive/2018/bin/x86_64-linux

# 使用如下命令使上面的更改生效（或者直接退出当前terminal，重新打开也行）
source ~/.bashrc

# 测试
tex --version
```
tex的编辑器强烈推荐 vs code！！！, 其他的用着不舒服......
在code里面安装插件latex workshop， 使用中文时，用ctex的包
在文件开头加 `%!TEX program = xelatex`， 指定使用xelatex编译，支持中文好。注意：这句格式别错了, =两边有空格，不能省！！！

- ctrl+alt+b: 编译
- ctrl+alt+c: 删除编译产生的无用文件

## mathpix 将图片转为latex公式
[mathpix ](https://mathpix.com/)

也可通过`snap install mathpix`

## 安装 xmind-zen（知识图谱）

> [安装包官网下载](https://www.xmind.net/download/)

`sudo dnf install ~/Downloads/Xmind*.rmp`

## 安装福昕pdf阅读器
添加了fzug源后，就可直接使用`sudo dnf install FoxitReader｀来安装了。 我在官网上下载的.rpm安装包安装好后无法使用，但这个可以！！！

自带的也挺好用的，如果只是阅读的话，在终端直接使用 `evince *.pdf` 就打开了

okular添加自定义印章，将下载的图片复制到`/usr/share/okular/pics/`或者`~/.local/share/okular/pics/`自己创建pics，图片格式png或者svg，名称全小写

## 安装flash player
未安装时，firefox浏览器无法播放视频......
```bash
## 添加仓库 Adobe Repository 64-bit x86_64 ##
sudo rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux

下载安装
sudo dnf install flash-plugin # 下载有些慢，下载好后就能用了
```

## 安装 tesseract

tesseract 是一个OCR工具，具体怎么解释自己google一下吧～～
之前在`ubuntu`上安装下了一堆东西，而且直接使用apt安装的版本太低，识别率不怎么行。自己编译又各种错误....可能是我太菜了....
```bash
# 安装
sudo dnf install tesseract
# 上面的命令默认只安装英文的字体，大小只有19M左右，由于还会用到中文，所以要单独下载中文的
# 下载简体中文库
sudo dnf install tesseract-langpack-chi-sim
# 如果你需要其他的语言，执行下面的语句查看支持的语言及其简写的名字
sudo dnf search tesseract-langpack
# 再下载对应的语言就好了
```
用法还是使用`tldr tesseract`和`man`自己看了吧～

### 截屏后自动ocr文字识别到剪贴板
下面是实现标题功能的脚本文件：  
```bash
#!/bin/bash
#require: xsel tesseract tesseract-langpack-chi-sim;

# 临时文件的保存路径
imgAddress='/home/yogurt/Documents/tmp/screenshot.png';
txtAddress='/home/yogurt/Documents/tmp/screenshot';

# 命令说明：-a 自己选定截屏区域 
gnome-screenshot -a -f $imgAddress;

# 命令说明：-l 指定文字类型，设为中文时，英文同样能识别
tesseract -l chi_sim $imgAddress $txtAddress;

# 命令说明：xsel -ib 复制到粘贴板
cat $txtAddress.txt | xsel -ib;

rm $txtAddress.txt  $imgAddress;
```
自己定义临时截屏文件和识别文件的保存路径， 将该文件放到`/usr/local/bin/`下，添加执行权限，再设置快捷键即可。

## 视音频处理工具`ffmpeg`
> [安装](https://www.cyberciti.biz/faq/how-to-install-ffmpeg-on-fedora-linux-using-dnf/)

```bash
# 1. 添加.repo
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. 安装
sudo dnf install ffmpeg
```
`ffmpeg`是一个很强的视音频处理工具，可以实现从**视频中提取音频**、**几张图片生成gif**、以及各种格式相互转换等等.... 使用`tldr ffmpeg`查看部分用法

同时安装时会带有播放器`ffplay`，也是一个命令行工具。

[ffmpeg - 替换视频中的音频](http://www.kbase101.com/question/39566.html)

```bash
ffmpeg -i v.mp4 -i a.wav -c:v copy -map 0:v:0 -map 1:a:0 new.mp4
```

## 视频播放器 VLC
`fedora`自带的播放器经常会遇到无法打开的问题，比如`.mkv`文件，还有一些使用`chrome`都可以轻松打开的文件，它作为专门的视频播放器却打开不了....

而`fedora`自带的音乐播放器`rhy....`对中文的支持也很有问题....于是可以把它俩都卸了～～ 
```bash
sudo dnf remove totem # 卸载视频播放器
sudo dnf remove rhythmbox # 卸载音频播放器
```

VLC算是一个专业的视音频播放器吧，[安装教程](https://www.tecmint.com/install-vlc-media-player-in-fedora/)
```bash
# 1. 添加包
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. 安装
sudo dnf install vlc
```

## install matlab

安装包可使用bt搜索查找，下载会快很多

安装教程可参考这个[https://www.cnblogs.com/taoyuyeit/p/8823311.html](https://www.cnblogs.com/taoyuyeit/p/8823311.html)

破解：
安装好后，到bin目录下，运行`./matlab`，选择许可证文件（不需要再将许可证文件复制到licenses文件夹下），完成后，再将.so 文件替换glnax文件夹下的.so文件，注意不是直接复制到glnax文件夹下，而是glnax里面的文件夹下。

[**centos**服务器上安装matlab](https://blog.csdn.net/u011387593/article/details/84883474)
安装好后如有报错
```
(base) [root@yogurt ~]# matlab -nodesktop
MATLAB is selecting SOFTWARE OPENGL rendering.
Fatal Internal Error: Unexpected exception: 'N9MathWorks6System15SimpleExceptionE: Dynamic exception type: St13runtime_error
std::exception::what: Bundle#2 start failed: libXt.so.6: cannot open shared object file: No such file or directory
' in createMVMAndCallParser phase 'Creating local MVM'
```
只需要安装`yum install xorg-x11-server-utils`


## 壁纸
推荐一个软件`fondo`，也就是网站[Unsplash.com](https://unsplash.com)
界面如下：
![](http://ww1.sinaimg.cn/large/006CByeUly1g30t5cgs9uj311y0lcn1l.jpg)

安装: `sudo dnf install fondo`

## 安装 octave

虽然没有matlab好用，但免费啊，而且对linux支持好，打开速度飞快，用来进行简单的矩阵计算还是很好用的。`sudo dnf install octave'。

终端输入`octave`会自动打开图形界面，仅在终端使用可输入`octave --no-gui`

[Octave官网](https://www.gnu.org/software/octave/)

[Octave Forge地址](https://octave.sourceforge.io/)


## 安装nvidia显卡驱动
未安装显示驱动，且chrome打开了硬件加速的话，全屏时会闪烁，可以选择在设置里面关闭硬件加速，或者安装显卡驱动
```bash
sudo dnf install akmod-nvidia
```
安装好后重启电脑，第一次会有点慢

## 安装 snap
`snap` 相当于一个应用商店，通过它来下载应用会省事很多(如果`dnf`找不到的话);

``` bash
# enable snap
sudo dnf install snapd
sudo ln -s /var/lib/snapd/snap /snap
```

## 安装 scrcpy
> [参考链接1](https://www.iplaysoft.com/scrcpy.html)、[参考链接2](http://zuimeia.com/app/6771/?platform=2)、[参考链接3](http://blog.lujun9972.win/blog/2019/03/20/%E4%BD%BF%E7%94%A8scrcpy%E6%8E%A7%E5%88%B6%E4%BD%A0%E7%9A%84%E6%89%8B%E6%9C%BA/)

``` bash
# 使用snap安装scrcpy
sudo snap install scrcpy

# 安装adb
sudo dnf install android-tools

# adb常用命令
adb start-server
adb kill-server
adb devices
```
使用教程请直接查看上面的参考链接

# Coding Time 
## 安装 anaconda
> [在这下载minianaconda，运行就完事](https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda) 
> 
> [具体说明](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)看这吧，很详细了。

安装好后为Conda添加镜像
```bash
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --set show_channel_urls yes
```
## 安装tensorflow

虽然可以直接用pip、conda等安装tensorflow，不过可能会提示你有些什么SSE、AEX、啥的没用上，浪费资源是吧，自己编译又太麻烦，只好拿别人编译好了的咯～～～[给个star表示感谢](https://github.com/lakshayg/tensorflow-build)

如果不知道自己电脑能用哪些资源，那就先用 `conda install tensorflow` 安装一下，再运行一个需要用到 `tensorflow` 的程序，它会给出提示的...

下载好后直接`pip install *.whl`

## 安装g++
注意安装时使用gcc-c++而不是g++，｀sudo dnf install gcc-c++`:

## 安装opencv-c++
``` cpp
sudo dnf install opencv opencv-devel

#测试代码 cam.cc

#include <opencv2/opencv.hpp>
using namespace cv;
int main()
{
        VideoCapture capture(0);
 
        Mat frame;
        capture >> frame;
        while (!frame.empty())
        {
                imshow("OpenCV Demo", frame);
                waitKey(30);
                capture >> frame;
        }
        waitKey(0);
        return 0;
}

# 编译
g++ `pkg-config opencv --cflags --libs opencv` -o out cam.cc

# 运行测试
./out
```

## git配置
> [廖雪峰教程](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)

```bash
git config --list 显示当前的Git配置
git config -e [--global] 编辑Git配置文件 
git config [--global] user.name "[name]" 设置提交代码时的用户信息
git config [--global] user.email "[email address]"
git config --global color.ui true  让Git显示颜色，会让命令输出看起来更醒目

配置别名
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

配置SSH Key
ssh-keygen -t rsa -C "youremail@example.com"

配置免密
vim ~/.gitconfig # 在后面追加如下两行

[credential]
	helper=store
下次执行git push再次输入用户名之后，git就会记住用户名密码并在上述目录下创建.git-credentials文件，记录的就是输入的用户名密码。
```

# 实用设置

## 关闭更新提醒
设置里面Notifications 关闭software提醒

## 图片反色
直接｀convert －negate old.png new.png`就可以将单张图片反色了
要直接转多个文件可以写个.sh
```bash
for item in `ls *.png`;
do
    convert -negate $item output/$item;
done
```
还是麻烦对吧～～～

推荐另一个工具 `ImageMagick`， 通过 `sudo dnf install ImageMagick` 安装, 然后就可以用 `mogrify -negate *.png` 就可以直接将当前文件夹的图片反色了。

命令不好记？？？使用别名（alias）!!!
在~/.bashrc里面加上下面这一行：
``` bash
    alias img='mogrify -negate'
```


## 终端使用代理
> [参考地址](https://blog.fazero.me/2015/09/15/%E8%AE%A9%E7%BB%88%E7%AB%AF%E8%B5%B0%E4%BB%A3%E7%90%86%E7%9A%84%E5%87%A0%E7%A7%8D%E6%96%B9%E6%B3%95/)

我觉得最好用的是这个：
```bash
export ALL_PROXY=socks5://127.0.0.1:1080
```

## 好用的工具
> [参考地址](http://fech.in/2017/5_linux_command_surprised/)

1. tldr （命令手册）
2. tree （目录树）
3. autojump （目录直达）
4. pdfseparate （pdf文件拆分）
5. pdfunite （pdf文件合并）

#1. 安装tldr，要通过npm安装，所以先要安装npm， npm是node.js的一部分，所以....
```bash
sudo dnf install nodejs
sudo npm install -g tldr
```
之后也可用用npm安装一些使用dnf找不到的工具了～～

#3. autojump安装非常方便，但[安装后不能直接使用](https://github.com/wting/autojump/issues/488)
```bash
1. 安装
    sudo dnf install autojump
2. 添加到 .bashrc, 注意下面命令中 ". /usr/" 不能省略
    echo ". /usr/share/autojump/autojump.bash" >> ~/.bashrc
3. 更改权限
    sudo chmod 755 /usr/share/autojump/autojump.bash
4. 更新 .bashrc
    source ~/.bashrc
```

#4、5. pdfseparte 和 `pdfunite` 的用法直接使用 `man pdfunite` 来查看，不过应注意，这两个命令好像不是自带的，需要安装 `Tex Live` 后，才能使用。

## 本地与云服务器互传文件

注意，下面的命令都是在本地的终端运行～

1、本地文件发送到云服务器
```bash
    scp 本地位置/文件 username@ip-adress:/home/....
```
2、从云服务器拷文件 
```bash
    scp username@ip-adress:/home/.... 本地位置
```
3、设置`ssh/scp`免密
    使用`ssh-keygen -t rsa "youremail@email.com"生成密钥，如果已经存在就不需要重复
    再将`.ssh/id_rsa.pub`文件发送到服务器用户目录下`.ssh`文件夹中，并改名为`authorized_keys`


## 文件编码转换 iconv
如果文件是从 `windows` 上面搬过来的，那么就会遇到乱码的问题，因为 `windows` 默认使用 `gb2312` ， 而 `linux` 则使用 `utf-8`。因此，需要先将文件进行格式转换。 

目前我知道的两个转换文件编码的工具： `iconv` 和 `enca`

`iconv` 好像只能用于单个文件转换，所以具体用法请参考 `tldr iconv`

`enca` 就很好用了，通过 `enca -L chinese -x utf-8 *.m` 就可以直接将当前文件夹下的所有文件转换为 `utf-8` 格式了。

## 文件名编码转换 convmv
类似上面的`iconv`，不过这个命令只修改文件名。   
```bash
  Convert filenames (NOT file content) from one encoding to another.

  - Test filename encoding conversion (don't actually change the filename):
    convmv -f from_encoding -t to_encoding input_file

  - Convert filename encoding and rename the file to the new encoding:
    convmv -f from_encoding -t to_encoding --notest input_file
```

## 磁盘挂载错误(fedora上还没有遇到过！)
在没有弹出设备的情况下直接拨u盘等可移动磁盘，再次插上时就会出现这个错误！
解决办法：
```bash
sudo fdisk -l # 查看挂载情况
sudo ntfsfix /dev/sdb* # 修复错误
```

## (.ppt .doc) to pdf

个人觉得，在linux下使用office系列都不怎么方便，我喜欢将文件转化为pdf后查看。通常可以打开相应的文件后选择`export as pdf`来转化，不过对处理课件这种通常有好几个文件的就显得很麻烦......
>[原文链接](https://askubuntu.com/questions/11130/how-can-i-convert-a-ppt-to-a-pdf-from-the-command-line)

1. unoconv -f pdf *.ppt
2. libreoffice --headless --invisible --convert-to pdf *.ppt


## 软件数据线(app)
> https://askubuntu.com/questions/626941/how-to-access-my-androids-files-using-wi-fi-in-ubuntu

功能：不用数据线，实现电脑与手机文件互传

如果电脑手机均连接同一个wifi，那么就不用下载任何软件，打开手机上的文件管理，点击功能键，会有远程管理选项，如下图

<img src="http://ww1.sinaimg.cn/large/006CByeUly1g2g4aezpikj30tc1g9n10.jpg" width="50%" height="50%">

打开后按提示操作即可，在电脑端的文件系统中输入对应的地址即可。

![](http://ww1.sinaimg.cn/large/006CByeUly1g2g4gof3o5j30oq05laa1.jpg)

如果没有wifi，也可以通过下载一个名为**软件数据线**的app，用手机热点的方式来实现上述功能。


## 清除旧的内核`kernel`
> [原文](https://www.if-not-true-then-false.com/2012/delete-remove-old-kernels-on-fedora-centos-red-hat-rhel/)

```bash
# 查看存在哪些内核
rpm -qa kernel\* | sort -V
# 查看当前使用的内核
uname -r
# 删除内核，(--latest-limit=-2 ,仅保留最新的2个）
dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q)
```

## gnome桌面自定义工具

gnome-tweaks-tool, 用来自定义gnome图形界面，虽然能进行的改动也不是很大，不过还是有一些很有意思的设置。

安装 gnome-tweaks：`sudo dnf install gnome-tweaks`

然后就自行探索吧

一个有意思的扩展程序可以在应用商店里面搜索下载，名字叫`Dash to dock`

## linux 下的'photoshop'--gimp

## 音频处理--audacity

## pdf remove passwd

tldr qpdf 

## 终端翻译工具(需网络)

* 将下面的代码保存到`/usr/local/bin/fy`目录下,`fy`为文件名

* 添加执行权限`sudo chmod +x /usr/local/bin/fy`

使用方法：
* 使用`fy`进入
* 查询单个单词直接输入，多个使用`,`间隔，也支持查询短语
* 使用`exit`退出
```bash
[yogurt@ss ~]$ fy
>>hello
################################### 
#  hello 你好 (U: helˈō E: həˈləʊ )
#  n. 表示问候， 惊奇或唤起注意时的用语
#  int. 喂；哈罗，你好，您好
#  n. (Hello) 人名；（法）埃洛
################################### 
>>hello, hi
################################### 
#  hello 你好 (U: helˈō E: həˈləʊ )
#  n. 表示问候， 惊奇或唤起注意时的用语
#  int. 喂；哈罗，你好，您好
#  n. (Hello) 人名；（法）埃洛
################################### 
################################### 
#  hi 嗨 (U: haɪ E: haɪ )
#  int. 嗨！（表示问候或用以唤起注意）
#  n. (Hi)人名；(柬)希
################################### 
>>bear in mind, hello
################################### 
#  bear in mind 记住
#  vi. 记住；考虑到
################################### 
################################### 
#  hello 你好 (U: helˈō E: həˈləʊ )
#  n. 表示问候， 惊奇或唤起注意时的用语
#  int. 喂；哈罗，你好，您好
#  n. (Hello) 人名；（法）埃洛
################################### 
>>exit
[yogurt@ss ~]$ 
```

也可以下载原作者的代码`wget https://raw.githubusercontent.com/dantangfan/fanyi/master/fanyi.py` 我只是修改了一下输入方式，更适合我用一点，代码如下:
```python

#!/usr/bin/env python3.7

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
        except:
            print("Input invalid！！")

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
    except:
        print()
```
## 后台支行命令，并将log输出到myout.file中
nohup command > myout.file 2>&1 & 

## 释放空间
1. 用`filelight`查看硬盘使用情况，可直接通过`apt install filelight`下载！
2. 清理`/var/log/journal`文件夹中的内容：`sudo journalctl --vacuum-time=10d`清理超过10天的文件[ref](https://ma.ttias.be/clear-systemd-journal/)
