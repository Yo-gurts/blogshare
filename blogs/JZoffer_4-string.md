> [run golang online](https://play.golang.org/)
> [golang api online](https://devdocs.io/go/)
>
> 一个字符串是一个不可改变的字节序列！ [Go语言基础之字符串遍历](https://www.cnblogs.com/aaronthon/p/10787176.html)
>
> ```go
> strings.Split
> strings.Join
> ```

# 1. [JZ2](https://www.nowcoder.com/practice/0e26e5551f2b489b9f58bc83aa4b6c68) 替换空格

解1：简单直接，如下：

```go
func replaceSpace( s string ) string {
    // write code here
    r := make([]rune, 0)
    for i, _ := range s {
        if s[i] == ' ' {
            r = append(r, '%', '2', '0')
        } else {
            r = append(r, s[i])
        }
    }
    return string(r)
}
```

解2：使用`strings`提供的[函数](https://devdocs.io/go/strings/index#Replace)：

```go
func replaceSpace( s string ) string {
    // write code here
    return strings.Replace(s, " ", "%20", -1)
}
```

# 2. [JZ27](https://www.nowcoder.com/practice/fe6b651b66ae47d7acce78ffdd9a96c7) 字符串的排列

解1：若各字符不一样，则最终输出的所有排列数有：$n!$。但这里存在重复字符的情况，故全排列之后要进行去重，使用`set`

* 字符全排列

```go
func Permutation( str string ) []string {
    // write code here
    if str == "" {
        return []string{}
    }
    set := make(map[string]bool)
    s := []byte(str)
    perm(0, s, set)
    res := make([]string, 0, len(set))
    for key, _ := range set {
        res = append(res, key)
    }
    return res
}

func perm(pos int, s []byte, set map[string]bool) {
    if pos+1 == len(s) {
        set[string(s)] = true
        return
    }
    
    for i := pos; i < len(s); i++ {
        s[pos], s[i] = s[i], s[pos]
        perm(pos+1, s, set)
        s[pos], s[i] = s[i], s[pos]
    }
}
```

# 3. [JZ34](https://www.nowcoder.com/practice/1c82e8cf713b4bbeb2a5b31cf5b0417c) 第一个只出现一次的字符

解1：使用哈希表（map实现）

```go
func FirstNotRepeatingChar( str string ) int {
    // write code here
    hash := make(map[rune]int)
    
    for _, r := range str {
        hash[r]++ // 可直接使用，默认值为0
    }
    
    for i, r := range str {
        if hash[r] == 1 {
            return i
        }
    }
    return -1
}
```

解2：使用哈希表（数组实现）*map更好*

```go
func FirstNotRepeatingChar( str string ) int {
    // write code here
    hash := make([]int, 128)
    
    for i, _ := range str {
        hash[str[i]]++
    }
    
    for i, _ := range str {
        if hash[str[i]] == 1 {
            return i
        }
    }
    return -1
}
```

# 4. [JZ43](https://www.nowcoder.com/practice/12d959b108cb42b1ab72cef4d36af5ec) 左旋转字符串

解1：**go语言中字符串不可修改！**所以肯定需要额外的空间来存在，则直接从第k位开始，复制到新字符串，再复制前k位字符。

```go
func LeftRotateString( str string ,  n int ) string {
    // write code here
    if len(str) < n {
        return ""
    }
    news := make([]rune, 0)
    news = append(news, []rune(str[n:])...)
    news = append(news, []rune(str[:n])...)
    return string(news)
}
```

解2：

```go
func LeftRotateString( str string ,  n int ) string {
    // write code here
    if len(str) < n {
        return ""
    }
    return str[n:]+str[:n]
}
```

# 5. [JZ44](https://www.nowcoder.com/practice/3194a4f4cf814f63919d0790578d51f3) 翻转单词序列

解1：注意此题并不是翻转字符串，单词是一个整体，需要翻转的只是单词出现的顺序！

```go
func ReverseSentence( str string ) string {
    // write code here
    words := strings.Split(str, " ")
    // 现在需要将words翻转，但没有内置的方法
    rwords := make([]string, 0)
    for i := len(words)-1; i >= 0; i-- {
        rwords = append(rwords, words[i])
    }
    return strings.Join(rwords, " ")
}
```

# 6. [JZ49](https://www.nowcoder.com/practice/1277c681251b4372bdef344468e4f26e) 把字符串转换成整数

解1：首先判断输入是否合法，`+ -`只会在首位，其余位置出现符号都不合法！

```go
func StrToInt( str string ) int {
    // write code here
    if str == "" {
        return 0
    }
    var st string
    
    if str[0] == '+' || str[0] == '-' {
        st = str[1:]
    } else {
        st = str
    }
    
    mi := len(st)-1
    res := 0
    for _, s := range st {
        if s >= 48 && s <= 57 {
            res = res*10 + int(s-48)
            mi--
        } else {
            return 0
        }
    }
    
    if str[0] == '-' {
        return -1 * res
    }

    return res
}
```

解2：用`switch`，下面的代码存在问题！当`+ -`不在首位时，下面的程序结果就错了

```go
func StrToInt( str string ) int {
    // write code here
    res, flag := 0, 1
    for _, s := range str {
        switch s {
            case '-': flag = -1
            case '+':
            case '0','1','2','3','4','5','6','7','8','9':
            res = res * 10 + int(s - '0')
            default: return 0
        }
    }
    return flag * res
}
```

解3：

```go
func StrToInt( str string ) int {
    // write code here
    res, flag := 0, 1
    for i, s := range str {
        if i == 0 && s == '-' {
            flag = -1
        } else if i == 0 && s == '+' {
            flag = 1
        } else if s >= '0' && s <= '9' {
            res = res * 10 + int(s - '0')
        } else {
            return 0
        }
    }
    return flag * res
}
```

# 7. [JZ52](https://www.nowcoder.com/practice/28970c15befb4ff3a264189087b99ad4) 正则表达式匹配

解1：

# 8. [JZ53](https://www.nowcoder.com/practice/e69148f8528c4039ad89bb2546fd4ff8) 表示数值的字符串

# 9. [JZ54](https://www.nowcoder.com/practice/00de97733b8e4f97a3fb5c680ee10720) 字符流中第一个不重复的字符	
