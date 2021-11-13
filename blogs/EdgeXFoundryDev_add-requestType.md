
> 目标：EdgeX的设备都有一个设备配置文件，里面包含了设备所能提供的“设备资源”以及支持的命令等。现在，我们要为设备提供AI计算服务，通过在设备资源中增加“计算类型”参数，当设备上传该设备资源时，就相当于发起了一次计算请求。reading 中包含了一些设备资源的一些信息，如MediaType，reading中也要添加计算类型参数。（多个）reading会被封装为Event，发送给core-data模块，再通过MessageBus传递给应用服务，应用服务读取reading，并根据reading中计算类型变量requestType，分别请求不同的服务。

要修改的内容：
* 设备服务 device-rest-go v1.2.0
    * 1. 该代码目录 cmd/res/ 中包含了3个虚拟设备的配置文件，其中`sample-image`可用于上传图片，在该配置文件中增加`requestType`:
    ```json
    properties:
      value:
        { type: "Binary", readWrite: "W", mediaType : "image/jpeg", requestType: "ocr" }
    ```
    * 2. 设备服务启动时，会检查 `cmd/res/` 目录下的设备配置文件，分别解析为`ValueDescriptor, PropertyValue`等等，这些结构体都定义在`go-mod-core-contracts`这个包中，因此我们需要在相关的结构体中增加`requestType`。
    * 3. EdgeX是通过go module进行包管理的，用默认的Makefile, Dockerfile编译时，是从各个第三方网站上下载对应的包，`go mod download`会将包缓存到`$gopath/pkg/mod/`目录下，若在此路径下修改相关的文件，本地编译时，对应的修改有效，但！！生成docker时，它是在容器中重新使用`go mod download`下载相关的包，所以我们之前的修改就没有意义！
    * 4. go mod 还提供了一种方法`vendor`，可以将go.mod中相关的包下载到当前文件夹下的`vendor`中，如下所示：
    ```bash
    device-rest-go-1.2.0$ tree -L 2 .
    .
    ├── cmd
    │   ├── main.go
    │   └── res
    ├── go.mod
    ├── vendor
    │   ├── bitbucket.org
    │   ├── github.com
    │   ├── gopkg.in
    │   └── modules.txt
    └── version.go
    ```
    编译时通过`go build -mod=vendor`指定使用vendor进行编译，它就会从vendor文件夹中去读取相关的包，而不是在`gopath/pkg/mod`目录下！所以，我们只需要在vendor中修改相关的包，编译或生成docker时指定使用vendor，就是想要的结果了！
    * 5. 需要修改的包有：`go-mod-core-contracts, device-sdk-go`:
        * 在go-mod-core-contracts包中，利用VScode查找MediaType，在对应的`.go`文件中类比MediaType，添加RequestType！
        * device-sdk-go包则需要修改`internal/handler/command.go, internal/common/utils.go, pkg/service/async.go` 
        ```go
        // command.go （dr.Properties.Value.RequestType 是需要增加的）
        reading := common.CommandValueToReading(cv, device.Name, dr.Properties.Value.MediaType, dr.Properties.Value.RequestType, dr.Properties.Value.FloatEncoding)
        // utils.go  （requestType string 需要增加）
        func CommandValueToReading(cv *dsModels.CommandValue, devName string, mediaType string, requestType string, encoding string) *contract.Reading {
    	if cv.Type == dsModels.Binary {
            reading.BinaryValue = cv.BinValue
            reading.MediaType = mediaType
            reading.RequestType = requestType
	    // async.go  （dr.Properties.Value.RequestType 是需要增加的）
	    reading := common.CommandValueToReading(cv, device.Name, dr.Properties.Value.MediaType, dr.Properties.Value.RequestType, dr.Properties.Value.FloatEncoding)
        ```
    * 6. Makefile中build增加 -mod=vendor, Dockerfile中注释掉`#RUN make update`
    
* edgex-go version:geneva
    * 与上面device-rest-go类似，修改vendor中相关的包，以及各个Dockerfile中删除`RUN go mod download`，Makefile中build后增加`-mod=vendor`即可。
    * 注意edgex-go依赖的go-mod-core-contracts与device-rest-go用的版本不一样，不能直接复制前面修改后的文件。


至此，修改成功！在应用服务中可以访问到reading中的requestType参数！🍉️🍉️🍉️🍉️


-----------------------------------------------------------

一步一个坑😭️😭️

使用device-rest-go 设备服务，为sample-image设备的 png，jpeg资源添加 requesttype 类型描述。

# test1 

1. 修改设备配置文件，在value：中添加 requesttype:"ocr"
2. 修改程序中reading的结构，添加requesttype一栏
    1. edgex中所有结构描述都在 go-mod-core-contracts中规定
    2. 检查 device-rest-go 的 go.mod文件，查看对应的go-mod-core-contarcts 包的 version
    3. 在$gopath/pkg/mod/github/edgexfoundry目录下找到对应版本的 contracts包，并修改其中文件
    4. 涉及到的文件包括：models/ {reading.go propertyvalue.go value-descriptors.go} 三个文件

3. 上述只是修改设备服务中的内容，但edgex-go包中的metadata等也可能会受到影响！也需要修改
    1. edgex-go 用到的contracts的版本与 device-rest-go的不同，需要单独修改
    2. 同上，修改contracts中的对应文件

4. 重新编译对应的镜像，edgex-go 和 rest
5. 测试
    1. 进入redis数据库，检查对应的设备配置文件，发现无 requesttype
    2. 在rest的日志中，上传的设备配置文件包括 requesttype:"ocr"
    3. 经过调试，确定设备服务上传的配置文件信息中包括 requesttype:"ocr"，怀疑是metadata中解析时漏掉了相关信息


# test2
1. metadata处理上传配置文件对应的函数是 rest_deviceprofile.go / restAddDeviceProfile()-> addDeviceProfile()
2. 在addDeviceProfile()中添加 打印输出接收到的 配置信息字符串 和 json解析后的 信息
3. 测试
    1. 收到的原始配置文件数据中 有requesttype，但解析后的 deviceprofile 无requesttype！
    2. 难道这里的dp 结构中没有requesttype？但contracts已经修改了！

# test3
1. 修改go-mod-core-contracts，添加打印输出信息，确认修改是否生效！
2. 测试
    1. 并无输出，应该是在生成docker镜像时，它是通过go.mod 重新下载相关的依赖包，所以直接在 go/pkg/mod中修改不会生效！！！
    2. docker构建镜像时，使用了cache，但用的是docker的层缓存，而不是go module 机制，所以之前的修改无效!!

# test4
1. clone edgexfoundry/go-mod-core-contracts 到我的github，然后切换到tag v0.1.58，修改后，重新标记为 v0.1.58
2. 修改edgex-go 下的go.mod，以及各个.go文件中的包路径，然后进行编译
3. 测试
    1. module github.com/Yo-gurts/go-mod-core-contracts@latest found (v0.1.149, replaced by github.com/Yo-gurts/go-mod-core-contracts@v0.1.58), but does not contain package github.com/Yo-gurts/go-mod-core-contracts
    2. 它总是自动找到最新的 v0.1.149版本，go.mod 中强制 replace 后，仍然报错如上！

# test5
1. 新建一个仓库，只保留 v0.1.58,并修改，再次尝试
2. 测试
    1. 失败！！！！ 人傻了
    2. 自己新建一个包，传到github，本地imports，可以go mod download，但一build，就说GOROOT下找不到包，都不是一个位置好吧!!!
    3. ##################### to do: try using go module imports #######################

# test6
1. 发现go mod vendor 可以将所有依赖的包下载到当前文件夹下面，编译的时候通过 go build -mod=vendor * 使用本地文件夹进行编译。这样就可以直接修改相关依赖包里面的内容了！！！
2. 修改的地方：
    1. edgex-go: 
		1.1 每一个Dockerfile，注释掉 go mod download!
		```bash
		modified:   cmd/core-command/Dockerfile
		modified:   cmd/core-data/Dockerfile
		modified:   cmd/core-metadata/Dockerfile
		modified:   cmd/security-proxy-setup/Dockerfile
		modified:   cmd/security-secrets-setup/Dockerfile
		modified:   cmd/security-secretstore-setup/Dockerfile
		modified:   cmd/support-logging/Dockerfile
		modified:   cmd/support-notifications/Dockerfile
		modified:   cmd/support-scheduler/Dockerfile
		modified:   cmd/sys-mgmt-agent/Dockerfile
		```
		1.2 Makefile: build 后面添加 -mod=vendor

	2. vendor/github.com/edgexfoundry/go-mod-core-contracts: 
		2.1 利用VS code的查找 MediaType，在下面几个文件中各个结构体下，类比MediaType，添加RequestType！ 
		```bash
		modified:   vendor/github.com/edgexfoundry/go-mod-core-contracts/models/propertyvalue.go
		modified:   vendor/github.com/edgexfoundry/go-mod-core-contracts/models/reading.go
		modified:   vendor/github.com/edgexfoundry/go-mod-core-contracts/models/value-descriptor.go
		```
	3. device-rest-go 
	 

 

