> day1: docker-edgex-consul-1.2.0

# 注册配置服务
> **服务发现、配置管理、健康检查**
0. **边缘智能网关中具有多个微服务，微服务之间通过RESTAPI相互访问**，服务调用者需要知道被调用服务的地址信息，才能进行访问。由于服务的访问信息可以动态改变，人为地添加系统中所有服务的访问信息不仅效率低，而且可靠性和稳定性无法保障。因此需要一套完善的服务发现机制来**实现服务注册、服务发现自动化，并且可以动态地实现服务的注册、查找和删除**。配置和注册服务是基于开源的Consul服务发现框架设计的。

1. 配置和注册服务是整个系统中所有服务的管理器，**负责为每个服务提供配置信息，且该配置信息可以覆盖服务内部配置**。当服务的配置信息如端口号已经被占用时，配置和注册服务会动态为其分配一个新的端口号，并向该服务发送通知，提醒端口号被改变。

2. 配置和注册服务是整个系统中的注册表，配置和注册服务掌握系统中所有服务的访问地址和当前运行状态。**每个服务在启动时，首先必须向配置和注册服务注册自己，注册信息包括服务名、IP地址、端口号等**。收到注册请求时，配置和注册服务会**以Key/Value的方式**将信息添加到注册表中。然后，**配置注册服务会定期的“ping”该服务，以检测该服务的健康状况。**

3. 当系统中的一个服务需要访问另一个服务时，**首先通过配置和注册服务检测该服务是否可以访问，如果可以，则获取对应的IP地址和端口号，再通过IP访问相关服务**。系统可以在没有配置和注册服务的情况下运行，这种情况下，系统中的服务使用默认配置在本地运行，服务之间通信时无法保证对方是否可以访问。

# 源码分析
## Makefile
```bash
.PHONY: docker build clean

DOCKERS=edgex-consul
.PHONY: $(DOCKERS)

VERSION=$(shell cat ./VERSION 2>/dev/null || echo 0.0.0)
DOCKER_TAG=$(VERSION)

GIT_SHA=$(shell git rev-parse HEAD)

GO=CGO_ENABLED=0 GO111MODULE=on go
GOFLAGS=-ldflags "-X github.com/edgexfoundry/edgex-go.Version=$(VERSION)"

build: health

.PHONY: health
health:
	$(GO) build $(GOFLAGS) -o $@ ./command/health

docker: $(DOCKERS)

edgex-consul:
	 docker build \
		-f Dockerfile \
		--label "git_sha=$(GIT_SHA)" \
		-t edgexfoundry/docker-edgex-consul:$(GIT_SHA) \
		-t edgexfoundry/docker-edgex-consul:$(DOCKER_TAG) \
		.
```

`Makefile` 可用于生成可执行文件 `health` 以及`docker` 镜像`docker-edgex-consul:版本号`。

## Dockerfile
`Dockerfile` 中写明了镜像的建立过程，也可看出容器的启动过程。

`Dockerfile` 一般分为两部分，编译环境 和 运行环境。这是因为编译过程需要的文件比较多，如果直接作为镜像，最后得到的镜像文件会比较臃肿。因此，一般步骤是先在编译环境下得到可执行文件，再将可执行文件复制到一个新的基础镜像中运行（此镜像一般很小，如`apline`只有 5M 左右）。 

镜像一般都是以linux作为基础容器，再配置好相关环境后上传到hub.docker.com，启动时就不需要手动下载相关内容。如下面的`golang:1.13-alpine`镜像是以linux `apline`作为基础环境，且已经安装好了golang:1.13的。

`dockerfile` 的介绍文件可参考 [https://blog.51cto.com/14156658/2497164](https://blog.51cto.com/14156658/2497164)
```bash
# 使用 golang:1.13-alpine 作为基础编译镜像。
FROM golang:1.13-alpine AS builder

ENV GO111MODULE=on
# 设置基础镜像中的工作目录
WORKDIR /go/src/github.com/edgexfoundry/docker-edgex-consul

# 更换镜像源
RUN sed -e 's/dl-cdn[.]alpinelinux.org/nl.alpinelinux.org/g' -i~ /etc/apk/repositories
# 下载相关文件
RUN apk update && apk add pkgconfig build-base git
# COPY Dockerfile文件所在目录下的文件  . 表示WORKDIR目录
# 将 go.mod 文件复制到 WORKDIR 下
COPY go.mod .
# 下载 go 的相关依赖
RUN go mod download
# 将 Dockerfile 所在目录的所有文件复制到 WORKDIR 目录中
COPY . .
# 编译得到可执行文件，见Makefile知，得到的文件 位于 WORKDIR/command/，文件名为 health
RUN make build

# 以 Consul 作为运行环境
FROM consul:1.7.2

LABEL license='SPDX-License-Identifier: Apache-2.0' \
    copyright='Copyright (c) 2019: Canonical; \
Copyright (c) 2019: Intel Corporation'

# for pg_isready to check when kong-db is ready
# 安装相关工具，可检测 kong-db 是否可用
RUN apk add postgresql-client jq=1.6-r0 curl=7.64.0-r3

# Make sure the default directories are created for consul
# 确保 consul 使用的配置文件的默认目录存在
RUN mkdir -p /consul/scripts && mkdir -p /consul/config

# 复制Dockerfile所在目录下的相关文件到 consul 环境指定目录中
COPY scripts /edgex/scripts
COPY config /edgex/config
# 将上面编译得到的可执行文件 health 复制到 consul 环境指定目录中
COPY --from=builder /go/src/github.com/edgexfoundry/docker-edgex-consul/health /edgex/scripts/health

# be sneaky and sneak jq into the scripts dir for now, eventually need a 
# statically compiled go program so we don't have to deal with musl/glibc issues
# but for now everything is alpine and thus everything is musl
# RUN 后的命令是在当前环境中执行
RUN cp /usr/bin/jq /consul/scripts/jq
RUN cp /usr/lib/libonig.so* /consul/scripts/

# 指定交互端口
# EXPOSE并不会让容器的端口访问到主机。要使其可访问，需要在docker run运行容器时通过-p来发布这些端口，或通过-P参数来发布EXPOSE导出的所有端口
EXPOSE 8500
EXPOSE 8400

# Copy over custom entrypoint (derived from consul entrypoint)
COPY edgex-consul-entrypoint.sh /usr/local/bin/edgex-consul-entrypoint.sh
# 设置容器启动时执行的命令
ENTRYPOINT ["edgex-consul-entrypoint.sh"]

# Override consul defaults so that container runs in production mode by default
# 设置命令的参数
CMD [ "agent", "-ui", "-bootstrap", "-server", "-client", "0.0.0.0" ]
```

## 容器运行
由上面的`Dockerfile` 知，容器已事先配置好了consul环境，并包含了编译得到的可执行文件，容器创建好之后，会运行`edgex-consul-entrypoint.sh`文件，参数为`"agent", "-ui", "-bootstrap", "-server", "-client", "0.0.0.0"`，这些参数都是用于建立Consul的server。关于Consul的说明可看此视频[https://www.bilibili.com/video/BV1pT4y1374Z?p=1](https://www.bilibili.com/video/BV1pT4y1374Z?p=3)，或此文档[https://www.cnblogs.com/cuishuai/p/8194345.html](https://www.cnblogs.com/cuishuai/p/8194345.html)

`edgex-consul-entrypoint.sh`：
```bash
#!/bin/sh
set -e
# 下面的语句，若存在变量$EDGEX_DB，则 $Database_Check=$EDGEX_DB，否则="redis"
# EDGEX_DB和EDGEX_SECURE可通过环境变量指定。见docker-compose.yml 文件中的 environment:
Database_Check="${EDGEX_DB:-redis}"   
Secure_Check="${EDGEX_SECURE:-true}"

# Set default config
cp /edgex/config/00-consul.json /consul/config/00-consul.json

# Set config files - Redis DB
if [ "$Database_Check" = 'redis' ]; then
    echo "Installing redis health checks"
    cp /edgex/config/database/01-redis.json /consul/config/01-redis.json
fi

# Set config files - Secure Setup
if [ "$Secure_Check" = 'true' ]; then
    echo "Installing security health checks"
    cp /edgex/config/secure/*.json /consul/config/
fi

# Copy health check scripts
cp -r /edgex/scripts/* /consul/scripts/

echo "Chaining to original entrypoint"
# $@ 表示全体参数，$1 表示参数列表中的第一个参数
exec "docker-entrypoint.sh" "$@"
```
`edgex-consul` 启动时就注册了`edgex-redis`服务，可以看到`docker-edgex-consul-1.2.0`代码中包含了`edgex-redis`服务 注册所需的配置信息`01-redis.json`。具体注册过程还得看`docker/consul`容器内部的启动过程。

# Consul
`Consul` 可分为3部分，`Client, Server, Server-Leader`，他们仨都能接收服务注册，但`Client`并不保存相关信息，它会将信息转发给Server，由Server来存储信息。

各个Server上注册的服务不一样，为了保证访问任何一个Server都可获得所有可用服务的信息，就需要对各个Server上注册的服务信息进行同步，这就是Server-Leader的功能。一般大型场景的Server的个数也不需要很多，3-5个即可满足需求。不过，EdgeX Foundry中只有一个Server，它本身就是leader。

[服务发现介绍，图示如下](https://www.cnblogs.com/xiaohanlin/p/8016803.html)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210201202401443.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM3NzM1Nzk2,size_16,color_FFFFFF,t_70#pic_center)

## 服务注册
[API - /agent/service/register, put, application/json](https://www.consul.io/api-docs/agent/service#register-service)

注册服务时上传的信息一般包括以下内容，[详细参数说明](https://www.consul.io/api-docs/agent/service#parameters-2)：
```json
{
    "ID": "redis1", // 每个实例对应的id，必须唯一
    "Name": "redis", // 服务名，对应一类服务，可多个服务实例使用同一个服务名，但id必须不同
    "Tags": [
        "primary",
        "v1"
    ], // These tags can be used for later filtering and are exposed via the APIs. 
    "Address": "127.0.0.1", // 服务的地址
    "Port": 8000, // 服务的端口
    "Meta": {
        "redis_version": "4.0"
    },
    "EnableTagOverride": false,
    "Check": { // consul 会定期对服务进行健康检查，这里设置相关参数
        "DeregisterCriticalServiceAfter": "90m",
        "Args": [
            "/usr/local/bin/check_redis.py"
        ],
        "Interval": "10s", // 健康检查的时间间隔
        "Timeout": "5s"
    },
    "Weights": {
        "Passing": 10,
        "Warning": 1
    }
}
```

`edgex-go`中服务注册的实现在`go-mod-registry`中，而服务的配置相关操作则在`go-mod-configuration`模块。

## 服务配置
`consul`还可以保存注册的服务的配置信息，配置信息也是KEY-VALUE的形式存储。在`edgex-go`中，服务启动时，会先检查`consul`是否存在配置信息（之前服务注册过，上传过配置信息，当服务关闭后重新启动时），若有则使用`consul`上保存的配置，否则使用本地配置文件，并将配置上传到`consul`。

说明：`consul` 管理服务的配置文件是保存在`consul`内部，而不是使用`edgex-redis`。`docker-edgex-consul` 源码中包含了`redis`数据库这个服务注册所需要的信息，应该只是为了方便。否则还需要去自定义`redis`容器，添加一些用于服务注册的代码。

# 总结
注册配置服务基本上就是直接使用的`consul`，EdgeX foundry中的每一个微服务都要注册到`consul`中，即将其ip地址，端口等信息都会存放到`consul`中。

通过api请求特定服务健康状态时，返回的是详细信息，`docker-edgex-consul`在此的工作仅仅只是增加了过滤作用的代码。使得最终得到的结果是一个bool变量，即是否可用。




