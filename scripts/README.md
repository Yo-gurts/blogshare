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


## `ocr.sh` 文字识别（仅适用于linux）注意修改其中的路径！！
该脚本利用截屏工具将图片截取到指定路径，再使用`tesseract`实现图片的文字识别，并通过`xsel`将文字复制到剪贴板！

最后，将该脚本复制到`/usr/local/bin`目录下，并设置快捷键，即可方便的使用文字识别！
 
**安装说明（ubuntu）**:
1. 安装tesseract, xsel, tesseract的中文包
    * `sudo apt install xsel tesseract-ocr tesseract-ocr-chi-sim`
    * 默认有英语的识别，如果要其他语言的支持，用`sudo apt search tesseract-ocr`搜索支持的包，安装即可  
2. 修改`ocr.sh`中的临时文件的保存路径，用户名这些，路径要存在才行
3. `cp ocr.sh /usr/local/bin/ocr` 复制文件到`/usr/local/bin/`， 并改名为`ocr`，不要后缀。
4. `sudo chmod 755 /usr/local/bin/ocr`
5. 增加快捷方式，ubuntu的设置中，有快捷键设置，可自定义执行的命令`ocr`和快捷键

