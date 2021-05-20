**结论!!!： 将 golang 包放在github上时，`package 名字`和`github 账号`的名字绝对不要有大写字母或者`-`, `_`等特殊符号！！小写字母就好🙃️**

| go mod [args] | 参数说明                                                   |
| ------------- | ---------------------------------------------------------- |
| **download**  | 下载相关的依赖包到本地`$gopath/pkg/mod/*`目录              |
| edit          | edit go.mod from tools or scripts                          |
| **graph**     | 打印需要依赖的包的关系图                                   |
| init          | initialize new module in current directory                 |
| **tidy**      | 在go.mod中添加缺少的包（会自动下载到本地）以及移除无用的包 |
| **vendor**    | 将依赖的包复制到当前项目目录下面的`vendor`文件夹中         |
| verify        | verify dependencies have expected content                  |
| why           | explain why packages or modules are needed                 |

# 1. 上传包到`github`上

下面假设有一个自己的包，其目录结构如下：

```josn
gomodone
└── pack1
    └── say.go
```

`say.go` 内容如下：

```go
package pack1

import "fmt"

// say Hi to someone
func SayHi(name string) {
   fmt.Printf("Hi, %s\n", name)
}
```

只有一个函数，将这个项目上传的`github`中，**注意要设置好相应的`tag`标签！！**

![Screenshot from 2021-04-13 10-21-34.png](http://ww1.sinaimg.cn/large/006xUmvugy1gphwk54808j30mz0eyt9o.jpg)

现在我有另外一个项目要用到上面的这个包，如下：

```json
test
└── test.go
```

```go
package main

import (
    "github.com/fyatt/gomodone/pack1"
)

func main() {
    pack1.SayHi("joke")
}
```

注意这里导入包的时候是直接由`github.com + 用户名 + 仓库名`的方式，接下来，使用`go mod`来处理相关的依赖包：

1. 使用`go mod init test` ，会得到一个`go.mod`文件：（此时可以直接用`go run`运行，会自动下载相关依赖包的最新版本，如果要指定版本号，可通过tidy自动添加修改的依赖包到`go.mod`文件中，再修改其中的版本号）

   ```bash
   yogurt@s:test$ go mod init test
   go: creating new go.mod: module test	
   yogurt@s:test$ tree .
   .
   ├── go.mod
   └── test.go
   yogurt@s:test$ cat go.mod
   module test
   
   go 1.15
   ```

2. 可以看到，现在`go.mod`中module 声明，并没有需要依赖的包的名字。需要通过`go mod tidy`自动添加需要的包：

   ```bash
   yogurt@s:test$ go mod tidy
   go: finding module for package github.com/fyatt/gomodone/pack1
   go: found github.com/fyatt/gomodone/pack1 in github.com/fyatt/gomodone v0.1.4
   yogurt@s:test$ cat go.mod
   module test
   
   go 1.15
   
   require github.com/fyatt/gomodone v0.1.4
   ```

3. 这里自动将最新版本的包添加上了，并且下载到了本地缓存中`~/go/pkg/mod/github.com/fyatt/`，现在直接运行`go run test.go`就能直接启动了。

   ```bash
   yogurt@s:test$ go run test.go
   Hi, joke
   ```

4. 此外，也可自己编辑`go.mod`文件，比如修改其中的版本号，再使用`go mod download`下载相关的版本

5. 如果向修改一下依赖包中的内容，比如上面的`SayHi`那个函数，但那个仓库是别人的，只有`fork`到自己的`github`上面，再进行修改，然后设置`tag`啥的，还有修改本地文件中`import`的路径（修改`github`用户名），很麻烦，这时就可以使用`go mod vendor`，将依赖包下载到当前项目下的`vendor`文件夹中：

   ```bash
   (base) yogurt@s:test$ go mod vendor
   (base) yogurt@s:test$ tree .
   .
   ├── go.mod
   ├── go.sum
   ├── test.go
   └── vendor
       ├── github.com
       │   └── fyatt
       │       └── gomodone
       │           └── pack1
       │               └── say.go
       └── modules.txt
   ```

   当在本地修改完之后，如：

   ```go
   func SayHi(name string) {
      fmt.Printf("Hi, %s, this is changed by vendor\n", name)
   }
   ```

   运行或编译项目时，添加上`-mod=vendor`就会使用`vendor`路径下的包，如：

   ```bash
   yogurt@s:test$ go run -mod=vendor test.go 
   Hi, joke, this is changed by vendor
   yogurt@s:test$ go build -mod=vendor test.go
   ```

**再次强调：如果github用户名有大写、或者`-`,`_`，会出现找不到包的情况！！`package name`声明时，也不要用特殊符号和大写字母！！**

> 其他链接：
> [go语言自定义包](http://c.biancheng.net/view/5123.html)


# 2. `go.mod replace`介绍

上面介绍了使用`vendor`的方式修改依赖包中的内容，但本地修改后，团队中其他人想要使用不方便！下面是另一个例子：

```bash
(base) yogurt@s:module_test2$ tree .
.
├── go.mod
├── go.sum
└── main.go
(base) yogurt@s:module_test2$ cat go.mod
module github.com/fyatt/module_test2

go 1.15
require github.com/sirupsen/logrus v1.8.1
(base) yogurt@s:module_test2$ cat main.go
package main

import log "github.com/sirupsen/logrus"

func main() {
    log.Info("this is a log")
    log.Warn("this is a log 2")
}
```

这里用到了其他三方包，`github.com/sirupsen/logrus`，上面的程序已经可以直接运行，但如果增加一个函数，可通过将该项目`fork`到自己的`github`，然后修改内容，用上面作为自己的包那样使用，不过需要修改`import log "github.com/fyatt/logrus"`中的账户名。如果项目中文件很多，修改的话就比较麻烦。

`go module`提供了一种解决方案，在`go.mod`中用`replace`替换指定的包，如下：

```go
module github.com/fyatt/module_test2

go 1.15

require github.com/sirupsen/logrus v1.8.1
replace github.com/sirupsen/logrus v1.8.1 => github.com/fyatt/logrus v1.8.2
```

`main.go`文件中并不需要修改`import`中的内容，但可以直接用你修改后的功能，如下面的`SayHi`函数：

```go
package main

import log "github.com/sirupsen/logrus"

func main() {
    log.Info("this is a log")
    log.Warn("this is a log 2")
    log.SayHi("it's work!!!!")
}
```

