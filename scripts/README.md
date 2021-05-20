# 脚本说明

## `fanyi.py` 命令行翻译工具（仅适用于linux，WSL也可）[source code](https://github.com/Yo-gurts/dict)

基于有道翻译！！

采用双线程设计，一个用于处理标准输入，一个用于处理剪贴板内容。

可直接输入单词或句子查询，也可直接复制文字，会自动翻译。

查询多个单词时，使用`,`分隔，若用空格分隔，将几个单词视为一个短语。

可输入`exit`退出程序，或使用`ctrl + C`

安装说明：
1. `pip3 install pyperclip`
2. `sudo apt install xsel`
3. `sudo mv fanyi.py /usr/local/bin/fanyi`
4. `sudo chmod 755 /usr/local/bin/fanyi`
5. 在任何终端直接使用`fanyi`启动

## `docs2pdf.vbs ppt2pdf.vbs` 批量将word、ppt文件转为pdf（仅适用windows，office(非WPS)）

直接将`docs2pdf.vbs`文件复制到有word的文件夹中，双击运行，会将当前文件夹中的word转为pdf

`ppt2pdf.vbs`用法相同
