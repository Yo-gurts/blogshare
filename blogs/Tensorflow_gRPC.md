> [rpc 介绍](https://learnku.com/docs/build-web-application-with-golang/084-rpc/3206)
> [grpc 介绍，存根](https://www.cnblogs.com/songgj/p/13463717.html)
> [gRPC 官方文档中文版](http://doc.oschina.net/grpc)
> [gRPC 视频讲解](https://www.bilibili.com/video/BV1Xv411t7h5?from=search&seid=9312284687788126079)
> [protobuf google官方文档](https://developers.google.com/protocol-buffers/docs/overview)
> [protobuf 非官方介绍](https://halfrost.com/protobuf_encode/#toc-0)
> [grpc 官方文档](https://www.grpc.io/docs/)
>
> 建议先阅读前面两个介绍文档，再尝试其中的例子（遇到问题，或想知道具体参数的意义，看查官方文档）

# RPC

Go语言原生rpc包提供了通过网络或其他I/O连接对一个对象的导出方法的访问。服务端注册一个对象，使它作为一个服务被暴露，服务的名字是该对象的类型名。注册之后，对象的导出方法就可以被远程访问。服务端可以注册多个不同类型的对象（服务），但注册具有相同类型的多个对象是错误的。

包文档地址：[https://studygolang.com/pkgdoc net/rpc](https://studygolang.com/pkgdoc)

# gRPC

gRPC使用和上面RPC使用方法类似，首先定义服务，指定其能够被远程调用的方法，包括参数和返回类型，这里使用protobuf来定义服务。在服务端实现定义的服务接口，并运行一个gRPC服务器来处理客户端调用。

![undefined](http://ww1.sinaimg.cn/large/006xUmvugy1gq1pup1uw0j31fy0owmxv.jpg)

## [protobuf介绍](https://www.cnblogs.com/songgj/p/11560565.html)

> protobuf 的详细介绍可看官方文档（英文），或者此[链接](https://halfrost.com/protobuf_encode/#toc-2)，查看`.proto`文件中的message的各个组成部分的详细信息

Protobuf (Protocol Buffers) 是谷歌开发的一款无关平台，无关语言，可扩展，轻量级高效的序列化结构的数据格式，用于将自定义数据结构序列化成字节流，和将字节流反序列化为数据结构。所以很适合做数据存储和为不同语言，不同应用之间互相通信的数据交换格式，只要实现相同的协议格式，即后缀为proto文件被编译成不同的语言版本，加入各自的项目中，这样不同的语言可以解析其它语言通过Protobuf序列化的数据。目前官方提供c++，java，go等语言支持。

同XML相比，Protobuf的优势在于高性能，它以高效的二进制存储方式比XML小3到10倍，快20到100倍，原因在于：

1. ProtoBuf序列化后所生成的二进制消息非常紧凑。
2. ProtoBuf封解包过程非常简单。

## 安装protobuf
```bash
# 1. 第一步git下载protobuf
git clone https://github.com/protocolbuffers/protobuf.git

# 2. 安装相关依赖
brew install automake libtool libffidev

# 3. 开始安装
cd protobuf/
./autogen.sh    #环境检查
./configure
make && make install
make check 
ldconfig  #刷新共享库

# 4. 上面安装完毕后 查看protobuf版本
protoc --version  # 输出libprotoc 3.10.0
```
## 安装protobuf的golang插件

```bash
# 1. 获取proto包
go get -v -u github.com/golang/protobuf/proto
# 2. 安装生成Go语言代码的工具protoc-gen-go
go get -u github.com/golang/protobuf/protoc-gen-go
	# 进入gopath下的protobuf目录下的protoc-gen-go目录
cd /Users/songguojun/go/src/github.com/golang/protobuf/protoc-gen-go   #这是我电脑的目录
# 3. 执行构建命令，会在当前目录生成一个protoc-gen-go可执行文件
go build
# 4. 将protoc-gen-go可执行文件复制到系统/bin目录下 (因为protoc需要依赖调用protoc-gen-go，所以它的路径必须要添加到环境变量里面去。)
cp protoc-gen-go /bin/　　# 或者将$GOPATH/bin 设置为环境变量，这样也可以使用protoc-gen-go
```

# gRPC测试

```bash
# 1. clone 
git clone --depth=1 https://github.com/grpc/grpc-go.git
# 2. 
cd grpc-go/examples/helloworld
# 3. 查看目录结构
helloworld$ tree .
.
├── greeter_client
│   └── main.go
├── greeter_server
│   └── main.go
└── helloworld
    ├── helloworld_grpc.pb.go
    ├── helloworld.pb.go
    └── helloworld.proto
# 4. 启动服务端
go run greeter_server/main.go # 启动后没有任何提示.....
# 5. 启动客户端，发送请求
go run greeter_client/main.go
```

## 使用 grpc 的一般步骤

1. 定义好服务端提供的功能；

   * rpc是让客户端像访问本地方法一样方便地访问服务端的方法，因此在设计时确定好你需要的方法，在服务端实现即可。
   * 如上面的hello，需要的方法为 输入name，输出 "hello, name"，在服务端，输出就作为返回值。

2. 编写`.proto`文件，定义服务、消息等；

   * 以上面的`helloworld.proto`为例：

     ```protobuf
     syntax = "proto3";   //指定了使用proto3语法，默认proto2 
     
     option go_package = "hello/helloworld"; 	// 至少要有一个 / 
     package helloworld;
     // 定义服务
     service Greeter {
         rpc SayHello (HelloRequest) returns (HelloReply) {}  // 定义服务的方法
     }	// 注意服务中，方法的输入参数和返回参数都是下面定义的 消息message 类型
     
     // 定义请求消息
     message HelloRequest {
         string name = 1;    // 消息字段，一般由字段限制,字段类型,字段名和编号四部分组成
     }
     
     // 定义返回消息
     message HelloReply {
         string message = 1; // 每个message的编号独立
     }
     ```

3. 使用`protoc`生成对应语言的代码

   ```go
   protoc --go_out={{path/to/output_directory}} --go-grpc_out={{path/to/output_directory}} {{input_file.proto}}
   $ tree .
   .
   ├── hello
   │   └── helloworld
   │       ├── hello_grpc.pb.go
   │       └── hello.pb.go
   └── hello.proto
   
   ```

4. 编写server端代码，要导入上一步生成的package

   ```go
   package main
   
   import (
   	"context"
   	"log"
   	"net"
   
   	"google.golang.org/grpc"
   	pb "hello/hello/helloworld"   // 通过protoc生成的文件
   )
   
   const port = "0.0.0.0:50051"   // 定义服务的ip:port
   
   type server struct {
   	pb.UnimplementedGreeterServer // .proto 中定义了服务 Greeter，会自动生成空结构体UnimplementedGreeterServer
   }
   
   // 实现 .proto 中定义的同名的服务方法，输入参数和返回参数的格式都是固定的
   // 分别对应 .proto 文件中的message类型
   // 注意对应生成的 hello_grpc.pb.go 查看
   func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
   	log.Printf("server received name: %v", in.GetName())   // 可通过 .GetName() 返回值
   	return &pb.HelloReply{Message: "hello " + in.GetName()}, nil
   }
   
   func main() {
   	lis, err := net.Listen("tcp", port)
   	if err != nil {
   		log.Fatalf("failed to listen: %v", err)
   	}
   
   	s := grpc.NewServer()
   	pb.RegisterGreeterServer(s, &server{})
   	if err := s.Serve(lis); err != nil {
   		log.Fatalf("failed to serve: %v", err)
   	}
   }
   ```

5. 编写客户端代码

   ```go
   package main
   
   import (
       "context"
       "log"
       "os"
       "time"
   
       "google.golang.org/grpc"
       pb "hello/hello/helloworld" // 导入生成的包
   )
   
   const (
       address     = "localhost:50051"
       defaultName = "world"
   )
   
   func main() {
       // 建立连接
       conn, err := grpc.Dial(address, grpc.WithInsecure(), grpc.WithBlock())
       if err != nil {
           log.Fatalf("can not connect: %v", err)
       }
       defer conn.Close()
   
       c := pb.NewGreeterClient(conn)  // 建立 client 对象
       name := defaultName
       if len(os.Args) > 1 {
           name = os.Args[1]
       }
       ctx, cancel := context.WithTimeout(context.Background(), time.Second)   // 设置超时
       defer cancel()
   
       // 通过 client 对象调用函数
       start := time.Now()
       r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name})
       end := time.Since(start)
       if err != nil {
           log.Fatalf("response err: %v", err)
       }
       log.Printf("Greeting: %s, spend time: %v", r.GetMessage(), end)
   }
   ```

   由于要使用`go mod init hello`处理相关的三方包，运行时的代码结构如下：

   ```bash
   $ tree .
   .
   ├── client.go
   ├── go.mod
   ├── go.sum
   ├── hello
   │   └── helloworld
   │       ├── hello_grpc.pb.go
   │       └── hello.pb.go
   ├── hello.proto
   └── server.go
   ```

# gRPC总结

再复习一下`grpc`的使用步骤：

1. 理清逻辑关系，定义好服务端提供的功能；
2. 编写`.proto`文件，定义服务、消息等；
3. 使用`protoc`生成对应语言的代码；
4. 编写server端代码，要导入上一步生成的package；
5. 编写客户端代码

`protoc`会将`.proto`文件中的message转为对应的结构体，而且提供`Get参数名()`方法返回参数值；`.proto`中定义的方法需要自己写一个`server.go`实现。client可直接调用该方法。

# Tensorflow Server 导出 golang 的 grpc API
> [参考文献](https://xie.infoq.cn/article/2b89ef611031a8c6ef93a517d)
> [link2](https://github.com/tobegit3hub/tensorflow_template_application/tree/master/golang_predict_client)

没搞定，下次再说

