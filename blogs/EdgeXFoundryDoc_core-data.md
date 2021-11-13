> day3: edgex-go version: geneva

# 核心数据微服务
1. 同`metadata`，核心数据负责3类数据集`Events, Readings, ValueDescriptors`的存储，也是存储在`edgex-redis`中；
2. 节点以一定的通信协议发送数据，对应的设备服务接收到数据后，将数据转换成统一格式`Event`，然后转发到核心数据服务以请求添加到对应的数据集合，核心数据服务*先查看数据是否符合值描述，再调用元数据服务以查询该节点是否存在*，当节点存在时，核心数据服务将数据存储到数据库，否则返回异常响应；
3.  除了将数据存放到数据库，核心数据还要将数据传入`MessageBus`，以订阅发布的形式提供数据给规则引擎或者应用服务使用。

# 源码分析
## 配置文件
除了常见的配置信息，`coredata` 还用到了 `MessageBus`，
```bash
[Writable]
DeviceUpdateLastConnected = false 	# 设备连接状态更新开关，若使能，则每次设备提交数据后都会更新设备在
									# metadata中最近提交数的时间，该信息可用于检测设备是否在线正常工作
MetaDataCheck = false	# 设备有效检查使能开关，任何Event都是绑定在一个Device下，
						# 只有Device已经被注册(能够在metadata服务中查找)其相应的Event才会被认为是有效的
PersistData = true		# 数据是否永久存储，否，则将数据发布到MessageBus后不保存
ServiceUpdateLastConnected = false	# 设备微服务连接状态更新开关，若使能，则每次设备微服提交数据(无论是哪个
			# 设备的数据)后都会更新设备在metadata中最近提交数的时间，该信息可用于检测设备微服务是否在线正常工作
ValidateCheck = false	# 接收数据的有效性检查，若使能，每次接收到数据后会根据其名字匹配ValueDESCRIPTOR，
						# 只有匹配成功才能通过有效性检查
LogLevel = 'INFO'
ChecksumAlgo = 'xxHash'

[MessageQueue]
Protocol = 'tcp'
Host = '*'			# Publisher
Port = 5563
Type = 'zero'
Topic = 'events'
[MessageQueue.Optional]
    # Default MQTT Specific options that need to be here to enable evnironment variable overrides of them Client Identifiers
    Username =""
    Password =""
    ClientId ="core-data"
    # Connection information
    Qos          =  "0" 	# Quality of Sevice values are 0 (At most once), 1 (At least once) or 2 (Exactly once)
    KeepAlive    =  "10"  	# Seconds (must be 2 or greater)
    Retained     = "false"
    AutoReconnect  = "true"
    ConnectTimeout = "5" 	# Seconds
    # TLS configuration - Only used if Cert/Key file or Cert/Key PEMblock are specified
    SkipCertVerify = "false"
```

## 启动过程
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210204131535418.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM3NzM1Nzk2,size_16,color_FFFFFF,t_70#pic_center)

## 数据库接口
`coredata`负责`Events, Readings, ValueDescriptors`3类数据的管理。
```go
	/*
		Events
		NOTE: Readings that contain binary data will not be persisted.
	*/
	Events() ([]contract.Event, error)
	EventsWithLimit(limit int) ([]contract.Event, error)
	AddEvent(e correlation.Event) (string, error)
	UpdateEvent(e correlation.Event) error
	EventById(id string) (contract.Event, error)
	EventsByChecksum(checksum string) ([]contract.Event, error)
	EventCount() (int, error)
	EventCountByDeviceId(id string) (int, error)
	DeleteEventById(id string) error
	DeleteEventsByDevice(deviceId string) (int, error)
	EventsForDeviceLimit(id string, limit int) ([]contract.Event, error)
	EventsForDevice(id string) ([]contract.Event, error)
	EventsByCreationTime(startTime, endTime int64, limit int) ([]contract.Event, error)
	EventsOlderThanAge(age int64) ([]contract.Event, error)
	EventsPushed() ([]contract.Event, error)
	ScrubAllEvents() error

	/*
		Readings
		NOTE: Readings that contain binary data will not be persisted.
	*/
	Readings() ([]contract.Reading, error)
	AddReading(r contract.Reading) (string, error)
	UpdateReading(r contract.Reading) error
	ReadingById(id string) (contract.Reading, error)
	ReadingCount() (int, error)
	DeleteReadingById(id string) error
	DeleteReadingsByDevice(deviceId string) error
	ReadingsByDevice(id string, limit int) ([]contract.Reading, error)
	ReadingsByValueDescriptor(name string, limit int) ([]contract.Reading, error)
	ReadingsByValueDescriptorNames(names []string, limit int) ([]contract.Reading, error)
	ReadingsByCreationTime(start, end int64, limit int) ([]contract.Reading, error)
	ReadingsByDeviceAndValueDescriptor(deviceId, valueDescriptor string, limit int) ([]contract.Reading, error)

	/*
		ValueDescriptors
	*/
	ValueDescriptors() ([]contract.ValueDescriptor, error)
	AddValueDescriptor(v contract.ValueDescriptor) (string, error)
	UpdateValueDescriptor(cvd contract.ValueDescriptor) error
	DeleteValueDescriptorById(id string) error
	ValueDescriptorByName(name string) (contract.ValueDescriptor, error)
	ValueDescriptorsByName(names []string) ([]contract.ValueDescriptor, error)
	ValueDescriptorById(id string) (contract.ValueDescriptor, error)
	ValueDescriptorsByUomLabel(uomLabel string) ([]contract.ValueDescriptor, error)
	ValueDescriptorsByLabel(label string) ([]contract.ValueDescriptor, error)
	ValueDescriptorsByType(t string) ([]contract.ValueDescriptor, error)
	ScrubAllValueDescriptors() error
```

## core-data api列表
[网页API说明](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-data/1.2.0)

# MessageBus
`go-mod-messaging` 模块实现`MessageBus`的相关操作，建议查看[go-mod-messaging/README.md](https://github.com/edgexfoundry/go-mod-messaging/blob/master/README.md)。

其原理估计与redis的发布订阅类似，可以先看[redis的文档](https://www.runoob.com/redis/redis-pub-sub.html)

`MessageBus`的连接信息存储在服务的配置文件`configuration.toml`中，下面是`ZeroMQ` 实现的 MessageBus，还有`MQTT, RedisStream`，具体看上面的[go-mod-messaging/README.md](https://github.com/edgexfoundry/go-mod-messaging/blob/master/README.md)。

发布者：
```json
[MessageQueue]
Protocol = 'tcp'
Host = '*'
Port = 5563
Type = 'zero'
Topic = 'events'
```
订阅者：
```json
[MessageQueue]
Protocol = 'tcp'
Host = 'localhost'
Port = 5563
Type = 'zero'
Topic = 'events'
```

# 总结

~~todo： 核心数据是如何接收设备服务上传的数据呢？有点迷！已经看到core-data的代码中会建立metadata的`DeviceClient, DeviceServiceClient`，也就是说，核心数据在向metadata请求信息时，是通过直接调用这些Client的方法？还是说通过`api`访问metadata微服务呢？~~ 

有专门的Client结构，在`go-mod-core-contracts/clients`中定义。设备服务中会初始化一个`eventClient`实例，通过它的`AddBytes`方法，以`POST`请求`coredatahost:port/api/v1/event`的方式，`event`作为此请求的`Body`部分实现将数据上传到`coredata`。

核心数据微服务的功能可以总结为3点：
1. 接收数据
2. 存储数据
3. 发布数据

