#!/bin/bash
# 清除images 目录下未使用的文件

imagePath="../images"
filePath="../blogs"

mergefile="/tmp/all.md"

cat ${filePath}/*.md > ${mergefile}

for folder in $(ls ${imagePath});
do
    for img in ${imagePath}/${folder}/*;
    do
        if grep -q ${img} ${mergefile}; then
            echo "${img} founded"
        else
            echo "${img} not founded"
            rm ${img}
        fi
    done
done



# reference
# https://stackoverflow.com/questions/11287861/how-to-check-if-a-file-contains-a-specific-string-using-bash
#
