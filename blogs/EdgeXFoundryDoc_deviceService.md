> day4 device-sdk-go 1.4.0

# 设备服务
1. 连接设备，管理一类设备，实现与设备的直接交互。这些设备所支持的操作都必须在设备服务中用代码实现，故虽然说设备服务一般是按通信协议来分类，但并不是说只要使用此种协议的设备都可以连接，还需要将设备所支持的操作在设备服务的代码中实现；
2. 上传设备配置文件到`metadata`、上传设备数据到`core-data`；
3. `AutoEvent`，设备服务中也可添加如scheduler模块的功能；
4. 设备发现。。。todo！

# 源码分析
下面以`device-sdk-go/example`中的设备服务来分析设备服务的启动过程！

## 启动过程
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210204132831938.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM3NzM1Nzk2,size_16,color_FFFFFF,t_70#pic_center)

## 依赖服务
设备服务的依赖服务有`metadata`和`coredata`两个服务，通过`metadata`获取相关设备信息，以及将相关信息上传到`metadata`；将设备上传的数据发送到`coredata`； 而与这两个微服务通信也是通过`rest`请求的方式进行，这里将不同的请求根据地址(url)分成了不同的`client`。如：

**metadata**
* AddressableClient: host:port/api/v1/addressable
* DeviceClient: host:port/api/v1/device
* DeviceServiceClient: host:port/api/v1/deviceservice
* DeviceProfileClient: host:port/api/v1/deviceprofile
* ProvisionWatcherClient: host:port/api/v1/provisionwatcher
* GeneralClient: host:port

**coredata**
* EventClient: host:port/api/v1/event
* ValueDescriptorClient: host:port/api/v1/valuedescriptor

[coredata API说明](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-data/1.2.0)
[metadata API说明](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/metadata/1.2.0)

通过`ping`来检测服务健康状况见下方`api /v1/ping`。

# 工作流程
设备服务启动后，主要有3个协程：
* httpserver
* reading处理
* autoevent
* 设备发现

## HttpServer
`HttpServer` 处理的事情可通过`api`查看，[device-sdk的API列表见此](https://app.swaggerhub.com/apis/EdgeXFoundry1/device-sdk/1.2.1#/)。

* `/v1/callback` 设备服务在初始化时会将设备的有关信息缓存到本地，若`metadata`中保存的信息发生了变化，如新增加了一个设备、设备信息发生了变化、某一个设备信息被删除了，`metadata`就会分别通过`POST, PUT, DELETE`方法调用此`API`；
* `/v1/ping` 用于检查此设备服务是否可用；每个服务都有这个，上面流程图中检测依赖服务是否可用时，可通过`ping`的方式，即用此`API`；
* `/v1/metrics` 返回服务的metrics（用于评估当前服务状态[相关链接](https://www.cnblogs.com/duanxz/p/3506766.html)）；
* `/v1/device/name/{name}/{command}` 通过设备名、命令获取对应值或设置设备的资源等。

## Reading处理
配置文件中有两个参数与`reading`处理有关，一是`EnableAsyncReadings`是否使用异步处理`reading`，二是`AsyncBufferSize`缓冲通道的长度。

如其他`Client`给设备服务的`Server`发送请求，以`api /v1/device/name/{name}/{command}`请求特定设备的特定资源值，`Server` 对此请求的响应是通过`driver`获取该设备的数据（`driver`的返回值是下面的 `CommandValue`类型）。此时的数据是比较原始的，可能是数值、字符串、`binary`等等，它的结构如下

```go
// AsyncValues is the struct for sending Device readings asynchronously via ProtocolDrivers
type AsyncValues struct {
	DeviceName    string
	CommandValues []*CommandValue
}

// CommandValue is the struct to represent the reading value of a Get command coming
// from ProtocolDrivers or the parameter of a Put command sending to ProtocolDrivers.
type CommandValue struct {
	// DeviceResourceName is the name of Device Resource for this command
	DeviceResourceName string
	// Origin is an int64 value which indicates the time the reading
	// contained in the CommandValue was read by the ProtocolDriver instance.
	Origin int64
	// Type is a ValueType value which indicates what type of
	// value was returned from the ProtocolDriver instance in response to 
	// HandleCommand being called to handle a single ResourceOperation.
	Type ValueType
	// NumericValue is a byte slice with a maximum capacity of 64 bytes, used to hold 
	// a numeric value returned by a ProtocolDriver instance. The value can be converted to
	// its native type by referring to the the value of ResType.
	NumericValue []byte
	// stringValue is a string value returned as a value by a ProtocolDriver instance.
	stringValue string
	// BinValue is a binary value with a maximum capacity of 16 MB,
	// used to hold binary values returned by a ProtocolDriver instance.
	BinValue []byte
}
```
可以看到，数据的结构中有3种类型的数据，数值类型、字符串、binary，如果设备上传的资源值是数值或字符串，则使用此结构中对应的类型即可。而若资源是图片、音频等负责数据，则直接以二进制的方式存储。此结构中还有一个参数`Type`标明了上传的资源的类型(String, bool, binary, Uint{8,16,32,64}, Int{8,16,32,64}, float32, float64)，它会用于后续对值进行转换（上面的结构中，数值是以[]byte的形式存储的，转换后就是`Type`标明的类型的变量。~~将此结果写入reading，组成Event上传到coredata~~ ）。资源值为数值、字符串以外的类型，都是以binary的形式存储的，而Type也只是说明了他是 binary类型，那如何得知此binary到底是图片还是音频等具体类型呢？这里用到了设备配置文件！获取特定资源时，需要指定资源名，而设备配置文件中，设备资源的描述中，Value下有一个参数为 mediatype="JPG"。也就是说，只需要查找设备配置文件就可知道具体资源的媒体类型了。

* 由driver得到的值可能有多个 CommandValue，对每一个值分别进行如下处理：
	* 若配置文件中`Device.DataTransform`为`True`，则会对CommandValue进行`Transform`(String, Bool, Binary类型不处理)
	* 先转换得到对应的类型的数据value, newvalue，在按设备配置文件中的设置对newvalue进行变换（左移、缩放、掩码等等）
	* 若newvalue != value，则用newvalue 的[]byte 值替换原来的 commandValue中的NumericValue。

所以、Transform的作用就是将实际driver读取结果按设备配置文件中的配置进行偏移、缩放等变换。

然后，将CommandValue转换为reading，这里只设置参数 Name(资源名), Device(设备名), ValueType(值类型)，以及
```go
	reading := common.CommandValueToReading(cv, device.Name, dr.Properties.Value.MediaType, 
											dr.Properties.Value.FloatEncoding)
	if cv.Type == dsModels.Binary {
		reading.BinaryValue = cv.BinValue
		reading.MediaType = mediaType
	} else if cv.Type == dsModels.Float32 || cv.Type == dsModels.Float64 {
		reading.Value = cv.ValueToString(encoding)
		reading.FloatEncoding = encoding
	} else {
		reading.Value = cv.ValueToString(encoding)
	}
	// if value has a non-zero Origin, use it
	if cv.Origin > 0 {
		reading.Origin = cv.Origin
	} else {
		reading.Origin = time.Now().UnixNano()
	}
```

```go
type Reading struct {
	Id            string `json:"id,omitempty" codec:"id,omitempty"`
	Pushed        int64  `json:"pushed,omitempty" codec:"pushed,omitempty"`   // When the data was pushed out of EdgeX (0 - not pushed yet)
	Created       int64  `json:"created,omitempty" codec:"created,omitempty"` // When the reading was created
	Origin        int64  `json:"origin,omitempty" codec:"origin,omitempty"`
	Modified      int64  `json:"modified,omitempty" codec:"modified,omitempty"`
	Device        string `json:"device,omitempty" codec:"device,omitempty"`
	Name          string `json:"name,omitempty" codec:"name,omitempty"`
	Value         string `json:"value,omitempty" codec:"value,omitempty"` // Device sensor data value
	ValueType     string `json:"valueType,omitempty" codec:"valueType,omitempty"`
	FloatEncoding string `json:"floatEncoding,omitempty" codec:"floatEncoding,omitempty"`
	// BinaryValue binary data payload. This information is not persisted in the Database and is expected to be empty
	// when retrieving a Reading for the ValueType of Binary.
	BinaryValue []byte `json:"binaryValue,omitempty" codec:"binaryValue,omitempty"`
	MediaType   string `json:"mediaType,omitempty" codec:"mediaType,omitempty"`
	isValidated bool   // internal member used for validation check
}
```
> debug 级别的日志下，每得到一个reading，会输出reading的类型和值（非binary）

扯远了，上面说到

若配置文件中`EnableAsyncReadings`为 `true`，则会启动一个协程，用于处理从设备上收集来的数据。

* **数据类型：** 




## autoevent
autoevent只能读资源，并不能写。

todo1: event除了上传到coredata，会在本地缓存吗？api介绍中有说：The device service may have cached the latest event/reading for the sensor(s)


todo2: 好像核心命令给设备服务发送请求（特定设备资源）http的反馈信息中也包含了Event，也就是说处理上传给coredata，command也收到了？

todo3: ds.asynch 到底是干什么的？command微服务发送请求给设备服务后，它自己就收集数据，再上传给核心数据了，完全没用到那个asynch！

go 语言中switch语句若没有default、case也不匹配，则会直接跳过了！


