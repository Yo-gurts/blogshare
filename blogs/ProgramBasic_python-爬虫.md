# packages

**requests**: 爬取HTML页面
**BeautifulSoup**: 解析、遍历、维护“标签树”的功能库
**pandas**: 处理数据，读取网页表格很方便
**re**: 使用`python`正则表达式
**os**: 用于创建文件夹等
***selenium**: 模拟控制浏览器网页*

# beautifulSoup类
## 基本元素
|基本元素  |   说明 |
 | :----   | :---- |
|Tag  |标签,最基本的信息组织单元, 分别用<>和</>标明开头和结尾 | 
|Name  | 标签的名字, \<p>...\</p> 的名字是'p', 格式:\<tag>.name | 
|Attributes  | 标签的属性, 字典形式组织, 格式:\<tag>.attrs | 
|NavigableString  | 标签内非属性字符串, \<>...\</>中字符串, 格式:\<tag>.string | 
|Comment  | 标签内字符串的注释部分, 一种特殊的Comment类型

## Tag 访问与遍历
```python
demo = getHTMLText( url )
soup = BeautifulSoup(demo, "html.parser")
```
* soup.\<tag>    存在多个相同\<tag>对应内容时, soup.\<tag>返回第一个
* soup.\<tag>.name (.parent.name)  标签的名字
* soup.\<tag>.attrs (.attrs['class'])    标签的属性, 字典形式
* soup.\<tag>.string     标签内非属性字符串

**下行遍历**

 | 属性 | 说明 | 
 | :----   | :---- |
 | .contents  | 子节点的列表, 将\<tag>所有儿子节点存入列表 | 
 | .children  | 子节点的**迭代类型**, 与.contents类似, 用于循环遍历儿子节点 | 
 | .descendants  | 子孙节点的**迭代类型**, 包含所有子孙节点, 用于循环遍历 | 

**上行遍历**

 | 属性 | 说明 | 
 | :----   | :---- |
 | .parent  | 节点的父亲标签 | 
 | .parents  | 节点先辈标签的**迭代类型**, 用于循环遍历先辈节点 | 
 
 **平行遍历**

 | 属性 | 说明 | 
| :----   | :---- |
 | .next_sibling  | 返回按照HTML文本顺序的下一个平行节点标签 | 
 | .previous_sibling  | 返回按照HTML文本顺序的上一个平行节点标签 | 
 | .next_siblings  | 迭代类型, 返回按照HTML文本顺序的后续所有平行节点标签 | 
 | .previous_siblings  | 迭代类型, 返回按照HTML文本顺序的前续所有平行节点标签 | 

##  优化显示`.prettify()`
.prettify()为HTML文本<>及其内容增加更加'\n'；`soup.prettify()`

.prettify()可用于标签, 方法:\<tag>.prettify()； `soup.a.prettify()`

## Tag 内容查找

`soup.find_all(name, attrs, recursive, string, **kwargs)` : 返回一个列表类型, 存储查找的结果（Tag类型，有以下属性）

 | Tag属性 | 说明 | 
 | :----   | :---- |
 | name  | 对标签名称的检索字符串 (可使用 正则化 ) |
 | attrs | 对标签属性值的检索字符串, 可标注属性检索 (可使用 正则化 ) | 
 | recursive | 是否对子孙全部检索,默认True |
 | string | \<>...\</>中字符串区域的检索字符串 |

```python
###### Name ######
soup.find_all('a')  # 查找标签名为 'a' 的所有标签
soup.find_all(['p', 'a']) # 查找标签 'a' 和 'b'
soup.find_all(re.compile('b')) # 使用正则式匹配标签名 必须使用re.compile(), soup.find_all(r'b') 错误

###### Attrs ######
soup.find_all('a', id='xx', class_='xxx') # 按属性检索，class 要用 class_ , 且属性名中不能包含‘-‘，解决办法如下：
soup.find_all('a', attrs={"class":"xx", "id-n":"xxx"}) 

###### String ######
soup.find_all('a', string=re.compile('\d{4}年\d{1,2}月'))
```
tag 还有一个重要的特性，假设下面是经过BeautifulSoup处理后的内容：
```html
<tr>
    <td>
        <b>日期</b></td>
    <td>
        <b>天气状况</b></td>
    <td>
        <b>气温</b></td>
    <td>
        <b>风力风向</b></td>
</tr>
<tr>
    <td>
        <b>日期</b></td>
    <td>
        <b>天气状况</b></td>
    <td>
        <b>气温</b></td>
    <td>
        <b>风力风向</b></td>
</tr>
```
```python
trs = soup.find_all('tr')
for tr in trs:
    for td in tr:   ## 就这个，tr并不是列表类型，但可以直接这样
        print(td.string)
```

# 正则化基础 

 | 匹配规则 | 说明 | 
 | :----   | :---- |
 | \d/D  | 小写 d 匹配单个数字, 即 0~9. 大写 D 则匹配所有非数字。比如'2\d'能匹配'20', 却不能匹配'2Q' |
 | \w/W | 小写 w 匹配单个字母或数字。大写 W 取反| 
 | \s/S | 小写 s 匹配空白符, 包括空格、制表符、换行符等。大写 S 则取反 | 
 | . | 一个英文句点, 可以匹配单个任意字符(除了换行符)。如果设置了re.DOTALL, 英文句点可以匹配包括换行符在内的单个任意字符 | 
 | $ | 匹配给定字符串的结束位置, 也就是尾部。或者开始用\A, 结束用\Z | 
 | 反斜杠+元字符 | 如果你想匹配单个元字符本身, 只需要加上反斜杠 |
 | 方括号 | [Pp]ython可匹配Python或python；[a-z]，[0-9]，[a-zA-Z0-9] |
 | ^ | 尖角符号表示取反，比如[^0-9] 表示匹配除了数字以外的任意一个字符, 也就是\D |
 | * | 匹配它前面的字符 0 次到无限次。比如'ID\d* 可以匹配'ID007' 也可以匹配'ID'。再比如'h*OK' 可以匹配 hhhhhhOK |
 | + | 匹配它前面的字符 1 次到无限次。故'ID' 不能被'ID\d+' 匹配了 |
 | ? | 匹配它前面的字符 0 次或者 1 次 |
 | {n} | 匹配它前面的字符不多不少恰好 n 次 |
 | {n,m} | 匹配它前面的字符 n 到 m 次。所以{0,} 相当于 0 到无限次, 即'*'; {1,} 相当于'+';而{0,1} 相当于'?'。注意, 这里的逗号后面不可以加空格 |

另一个重要的概念是子组,也就是用圆括号包裹的内容。有一种比较有用的方法叫前向(后向)断言,用于指定匹配字符串前后的字串必须满足的条件。

 | 子组 | 说明 | 
 | :----   | :---- |
| (?=...) | 前向肯定断言。比如 male(?=wkl),表示只匹配紧跟着’wkl’ 的字 符串’male’ |
| (?!...) | 前向否定断言。比如 male(?!wkl) 表示只匹配紧跟的内容不是’wkl’ 的字符串’male’ |
| (?<=...)|  后向肯定断言。(?<=male)wkl 表示只匹配前面紧跟内容为’male’的字符串’wkl’ |
| (?<!...) | 后向否定断言。与上同理。子组可以命名,也可以有更灵活的使用方式: \ ... 引用序号 id 对应的子组。序号从 1 开始依次编号。比如'\1' |
| (?P<name>) | 命名子组为 name,方便之后调用 |
| (?P=name) | 引用一个命名过的子组 |
| (?:...) | 非捕获组。该组的内容不能被后文引用 |
| (?(id/name)yes\|no) | 这是表示如果序号为 id 或者名字为 name 的子组匹配到目标的话,此处就尝试用 yes 表达式匹配;否则尝试用 no 表达式匹配 |

匹配函数如下：

 | [re的函数](https://www.runoob.com/python/python-reg-expressions.html) | 说明 | 
 | :----   | :---- |
 | re.match(pattern, string) |  从字符串的起始位置匹配一个模式  |
 | re.search(pattern, string) |  扫描整个字符串并返回第一个成功的匹配  |
 | re.compile(pattern) | 生成一个正则表达式（ Pattern ）对象 |


# 常用函数
## 获取网页源码
```python
def getHTMLText( url ):
    """ Get Url Text
    :url:  "http:xxxx.xx.x"
    """
    try:
        ua = {'user-agent':'Mozilla/5.0'} 
        r = requests.get(url, headers=ua, timeout=30)
        r.raise_for_status()    # 返回值为200说明爬取成功
        r.encoding = r.apparent_encoding # 内容编码方式
        return r.text  # url对应的页面内容，字符串的形式
    except:
        return "网页" + url + "内容爬取错误！！"
```

## 保存图片
```python
def saveImage(url, path, name):
    """ Download Image
    url:  "http:xxxx.xx.x"
    path: "/home/yogurt/"
    name: "name.jpg"
    """
    direction = path + name
    try:
        # if not os.path.exists(path):   # 检查目录是否存在
        #     os.mkdir(path)
        if not os.path.exists(direction):  # 检查文件是否存在
            ua = {'user-agent':'Mozilla/5.0'}
            r = requests.get(url, headers=ua, timeout=30)
            r.raise_for_status()
            with open(direction, 'wb') as f:
                f.write(r.content)      # HTTP响应内容的二进制形式
                f.close()
            print("图片" + name + "保存成功～～")
        else:
            print("图片" + direction + "已存在")
    except:
        print("图片爬取出错！" + "  url:"+url)
```

## 爬取表格

```python
def getValueFromTable(soup):
    ulist = []
    trs = soup.find_all('tr')
    for tr in trs:
        ui = []
        for td in tr:
            ui.append(td.string)
        ulist.append(ui)
    return ulist
```

上面这种方法显得很麻烦，得到的数据中可能会有一些空格和换行符等，还需要手动处理，容易出错，下面使用`pandas`读取（需要安装`lxml`）

```python
def getValueFromTable(soup):
    tables = soup.select('table')
    df_list = []
    for table in tables:
        df_list.append(pd.concat(pd.read_html(table.prettify())))
    df = pd.concat(df_list)
    return df
```
