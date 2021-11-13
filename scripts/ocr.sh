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
