---
author: yogurt
date: 2020-01-21 20:51:37
---

# 变量
```bash
a=4;        # 等号两边不能有空格

# 外部变量
# eg：sh xx.sh input1 input2
input1=$1;  # 外部输入第一个变量
input2=$2;  # 外部输入第二个变量

# 输入变量
read -p "input your name:" name
echo $name

# 输出变量
echo $input1 $a;    # 注意要用$号
echo ${input2};     # 使用{}号帮助识别变量名边界

# 单引号与双引号
str1='this is str1';    # 单引号里的任何字符都原样输出
str2="this is $str1";   # 双引号中可以有变量和转义字符

# 确定字符串长度
len=${#str1};
```

# 四则运算
```bash
# 使用双括号包住  ((计算式))
((i++));
((++i));    # 同c语言
((i*2));
((i/2));
```

# for循环
```bash
for item in xx;
do                  # 注意do后面没有分号
    .......
    echo $item;
done;

# xx的表示方法:
1. $(ls xx*)        # 注意根据需要限定范围
2. `ls xx*`         # 1,2中，若文件名有空格，会按照空格分开成不同的变量
3. xx*              # 直接限定范围

```

# 确定当前文件夹文件个数
```bash
# bad way
count=0;
for item in $(ls *);
do
    ((++count));
done;

# better way
count=`ls -l|grep "^-"| wc -l` # 使用``号相当于运行该段代码
```

# 内嵌命令
```
count=\`ls -l|grep "^-"| wc -l\`  # 使用``号相当于运行该段代码
count=$(ls -l|grep "^-"| wc -l) # 同上 
```

# 注释
```bash
:<<EOF
注释内容...
注释内容...
注释内容...
EOF             # EOF可用单引号'与感叹号!代替
```

