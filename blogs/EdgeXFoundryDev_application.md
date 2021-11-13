> 分析一下应用服务的代码！以`edgex-examples/application-services/custom/simple-cbor-filter`为例！

# 应用服务简介
![undefined](http://ww1.sinaimg.cn/large/006xUmvugy1gqa4wef0g7j30nd06tt8p.jpg)

如上图所示，应用服务就是一个触发器Trigger + 一系列函数组成的函数管道！

这里的触发器可以是`MessageBus Trigger`，通过设置`Topic`（在应用服务的配置文件中）可以用于接收由核心数据微服务发布的`Event`。
```yaml
[MessageBus]
Type = 'zero'
    [MessageBus.PublishHost]
        Host = '*'
        Port = 5564
        Protocol = 'tcp'
    [MessageBus.SubscribeHost]
        Host = 'localhost'
        Port = 5563
        Protocol = 'tcp'
```

也可以设置为`HTTP Trigger`，用于监听`http`请求。在`edgex-examples/application-services/custom/send-command`实现了一个由云服务器发送请求到应用服务，再由应用服务下发命令给设备。
```yaml
[Binding]
Type="http"
```

可以说，`MessageBus Trigger`是面向`EdgeXFoundry`内部的，应用服务主要对是`Event`进行一定的处理。

而`HTTP Trigger`是面向三方Client，应用服务用来传递一些外部的请求！

# Example 分析

以`github.com/edgexfoundry/edgex-examples/application-services/custom/simple-cbor-filter`为例！

1. 为了方便依赖包中的代码，通过`go mod vendor`命令将所有的依赖文件保存到当前目录下的`vendor`文件夹中!虽然我们只需要看看`github.com/edgexfoundry`中的部分代码！
<details>
<summary>目录结构（有删减）</summary>

```bash
simple-cbor-filter$ tree -L 3 .
.
├── app-service
├── Device Simple Switch commands.postman_collection.json
├── go.mod
├── go.sum
├── main.go
├── Makefile
├── README.md
├── res
│   └── configuration.toml
└── vendor
    ├── github.com
    │   ├── edgexfoundry
    │   ├── go-redis
    │   └── xdg
    ├── golang.org
    │   └── x
    ├── go.mongodb.org
    │   └── mongo-driver
    └── modules.txt
```
</details>

## 主程序分析
下面就是应用服务的主程序的一般流程！该应用服务设置的是`MessageBus Trigger`（这个得看配置文件`res/configuration.toml`），接收到`Event`后，通过两个函数对`Event`进行处理！一个是sdk中提供的值描述过滤（只允许通过指定的值【设备资源名，reading的名字】），另一个是自定义的函数！

```go
import (
	"github.com/edgexfoundry/go-mod-core-contracts/models"
	"github.com/edgexfoundry/app-functions-sdk-go/appcontext"
	"github.com/edgexfoundry/app-functions-sdk-go/appsdk"
	"github.com/edgexfoundry/app-functions-sdk-go/pkg/transforms"
)

const (
	serviceKey = "sampleCborFilter" // 设定应用服务的名称
)

func main() {
	// 演示时关闭安全模式，生产环境中不推荐！！
	os.Setenv("EDGEX_SECURITY_SECRET_STORE", "false")
    // 1) 首先要初始化一个 sdk 对象，通过它可以调用很多已有的方法
	edgexSdk := &appsdk.AppFunctionsSDK{ServiceKey: serviceKey}
	if err := edgexSdk.Initialize(); err != nil {
		edgexSdk.LoggingClient.Error(fmt.Sprintf("SDK initialization failed: %v\n", err))
		os.Exit(-1)
	}

    // 2) 获取一些应用特定的配置信息！也是从配置文件中得到，这些信息会用于下面的 函数管道
	valueDescriptors, err := edgexSdk.GetAppSettingStrings("ValueDescriptors")
	if err != nil {
		edgexSdk.LoggingClient.Error(err.Error())
		os.Exit(-1)
	}
	edgexSdk.LoggingClient.Info(fmt.Sprintf("Filtering for ValueDescriptors %v", valueDescriptors))

    // 3) 配置函数管道，每一个收到的event都会按顺序传入这些函数，进行处理
	edgexSdk.SetFunctionsPipeline(
		transforms.NewFilter(valueDescriptors).FilterByValueDescriptor, // 这个是sdk中提供的函数
		processImages,  // 这个是下面实现的，自己要实现一个函数方法也类似!
	)

	// 4) 前面都只是配置，现在让程序跑起来！！！
	err = edgexSdk.MakeItRun()
	if err != nil {
		edgexSdk.LoggingClient.Error("MakeItRun returned error: ", err.Error())
		os.Exit(-1)
	}

	// Do any required cleanup here
	os.Exit(0)
}
```

## AppFunctionsSDK 实例

由上面的主函数可以看到，整个应用服务其实就是一个 AppFunctionSDK 实例！`SetFunctionsPipeline()`, `MakeItRun()`都只是该实例的一个方法！

它的定义在`app-function-sdk-go/appsdk/sdk.go`中：
```go
type AppFunctionsSDK struct {
	ServiceKey string   // ServiceKey 是用于向 consul 中注册服务时使用的服务名
	LoggingClient logger.LoggingClient  // LoggingClient 日志记录

	// TargetType 指定期望输入的数据类型，必须是指针，默认为 &models.Event{}，
    // 输入的数据是上面指定类型的 unmarshal的 json 数据。除非前面指定输入的数据类型为 &[]byte{}.
	TargetType interface{}

	// EdgexClients 用于接入EdgeX中的其他微服务的Client，如 CommandClient（通过它可以给设备下发命令），它需要在应用服务的配置文件中
    // [Clients] 下指定其 Host, Port 等信息，建议使用之前判断其是否为nil.
    // logger.LoggingClient, coredata.EventClient, command.CommandClient, coredata.ValueDescriptorClient,
    // notifications.NotificationsClient, 这里只有这五种Clients，应该够用了吧，如果要用到其他Client的话，还需要在app-sdk-go中进行添加。
	EdgexClients common.EdgeXClients

	RegistryClient            registry.Client       // RegistryClient 用于和 consul 注册.
	transforms                []appcontext.AppFunction  // transforms 函数管道！ AppFunction is a type alias for func(edgexcontext *appcontext.Context, params ...interface{}) (bool, interface{})
	skipVersionCheck          bool
	usingConfigurablePipeline bool          // 是否使用可配置的函数管道
	httpErrors                chan error
	runtime                   *runtime.GolangRuntime    // 运行时，通过它运行函数管道中的内容
	webserver                 *webserver.WebServer
	config                    *common.ConfigurationStruct   // 应用服务的配置文件
	storeClient               interfaces.StoreClient        // 这个能存啥？
	secretProvider            security.SecretProvider
	storeForwardWg            *sync.WaitGroup
	storeForwardCancelCtx     context.CancelFunc
	appWg                     *sync.WaitGroup
	appCtx                    context.Context
	appCancelCtx              context.CancelFunc
	deferredFunctions         []bootstrap.Deferred
	serviceKeyOverride        string
	backgroundChannel         <-chan types.MessageEnvelope
}
```

### AppFunctionSDK 初始化

