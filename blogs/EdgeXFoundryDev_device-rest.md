> device-rest-go 1.2.0

# 设备服务

设备服务用于连接设备，而对具体设备的资源操作等，都需要在设备服务中实现（即driver）

`device-rest-go`设备服务接收`restful`上传的数据，上传`url: http://ip:port/api/v1/deivceName/resourceName`，接收设备上传的数据，数据类型可能是图片、数字等等，但读取请求在body时，只分为`binary`和`string`，后续根据资源类型进行转换

给设备发送命令时，也需要在设备服务driver中写相应的代码


# 启动过程

1. 加载设备配置文件 `cmd/res/configuration.toml`
2. 向`consul`注册设备服务，上传配置文件等
3. 将`self`(设备服务)注册到`metadata`
4. 初始化本地缓存`provisionWatcher, ValueDescriptor, Device`
5. 添加`REST route`
    ```go
	// Status
	c.addReservedRoute(sdkCommon.APIPingRoute, c.statusFunc).Methods(http.MethodGet)
	// Version
	c.addReservedRoute(sdkCommon.APIVersionRoute, c.versionFunc).Methods(http.MethodGet)
	// Command
	c.addReservedRoute(sdkCommon.APIAllCommandRoute, c.commandAllFunc).Methods(http.MethodGet, http.MethodPut)
	c.addReservedRoute(sdkCommon.APIIdCommandRoute, c.commandFunc).Methods(http.MethodGet, http.MethodPut)
	c.addReservedRoute(sdkCommon.APINameCommandRoute, c.commandFunc).Methods(http.MethodGet, http.MethodPut)
	// Callback
	c.addReservedRoute(sdkCommon.APICallbackRoute, c.callbackFunc)
	// Discovery and Transform
	c.addReservedRoute(sdkCommon.APIDiscoveryRoute, c.discoveryFunc).Methods(http.MethodPost)
	c.addReservedRoute(sdkCommon.APITransformRoute, c.transformFunc).Methods(http.MethodGet)
	// Metric and Config
	c.addReservedRoute(sdkCommon.APIMetricsRoute, c.metricsFunc).Methods(http.MethodGet)
	c.addReservedRoute(sdkCommon.APIConfigRoute, c.configFunc).Methods(http.MethodGet)
    ```
6. 加载设备配置文件，并上传到`metadata`
7. 加载设备，设备信息也会上传到`metadata`
8. 启动`autoevent`，Valid time units are "ns", "us" (or "µs"), "ms", "s", "m", "h".

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210204132831938.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM3NzM1Nzk2,size_16,color_FFFFFF,t_70#pic_center)

# 设备设计

1. 上传 图片、音频文件、数值
2. 接收数据，用于返回计算结果

# todo:
    Device      设计一个server作为设备，可接收返回结果、上传数据
    Deepspeech  语音
    OCR / FACE  图片
    autoevent   间隔可设置为ms,us等
    联邦学习    电子nose 数据识别




