> day2: edgex-go version:geneva

# 元数据微服务
1. 元数据微服务并不是自己有一个数据库，而是定义了一系列对数据库容器`edgex-redis`的操作方法。
2. 元数据负责的信息有`DeviceReports, Devices, DeviceProfiles, Addressables, DeviceServices, ProvisionWatchers, Commands` 。并提供了这些数据与数据库	`edgex-redis`的操作方法，如添加、删除、修改等。
3. 这些方法以api的方式提供给其他微服务，当收到其他服务的请求，就执行对应的动作。

# 源码分析
## 配置文件
配置文件的大部分结构都相同，所以请看此文章，[配置文件说明](https://blog.csdn.net/qq_37735796/article/details/113542154)

下面介绍元数据服务自定义的内容：

```go
type WritableInfo struct {
	LogLevel                        string	// 设定输出日志等级，有"TRACE, DEBUG, INFO, WARN, ERROR"
	EnableValueDescriptorManagement bool	// 使能值描述管理
}
```
todo!!
```go
// Notification Info provides properties related to the assembly of notification content
type NotificationInfo struct {
	Content           string
	Description       string
	Label             string
	PostDeviceChanges bool
	Sender            string
	Slug              string
}
```

## 代码结构
```yaml
. 				# /internal/core/metadata
├── config		# 配置文件的相关处理，可以看到，配置文件中的Writeable、Notification结构中的参数是各个微服务自定义的。其他参数结构相同
├── container	# 容器注入（DIC）需要用到的函数，返回实例
├── errors		# error相关函数
├── interfaces	# 定义数据库的接口，具体实现在 operators 中
│   └── mocks	# 好像是测试所用
└── operators	# 面向数据库的操作，实现与数据库通信、将数据存入数据库，以及向数据库查询信息等等。此部分操作是外部不可见的。
    ├── addressable		# 对数据库的操作按数据类型进行了分类，不同数据的操作分别位于不同的文件夹下。
    │   └── mocks		# 测试所用吧
    ├── command
    │   └── mocks
    ├── device
    │   └── mocks
    ├── device_profile
    │   └── mocks
    └── device_service
# 面向外部的操作，即为 httpserver 特定路由(​.../v1​/config, etc)设计对应的处理函数。也就是为外界提供的API的实现。
	rest_addressable.go
	rest_addressable_test.go
	rest_command.go
	rest_command_test.go
	rest_device.go
	rest_deviceprofile.go
	rest_deviceprofile_test.go
	rest_devicereport.go
	rest_deviceservice.go
	rest_deviceservice_test.go
	rest_device_test.go
	rest_provisionwatcher.go
```
## Dockerfile
过程都类似，先编译得到可执行文件，再放到一个新的环境中运行。此处用的[`scratch`](https://www.cnblogs.com/uscWIFI/p/11917662.html)，官方说明：该镜像是一个空的镜像，可以用于构建busybox等超小镜像，可以说是真正的从零开始构建属于自己的镜像。要知道，一个官方的ubuntu镜像有60MB+，CentOS镜像有70MB+。可以把一个可执行文件扔进来直接执行。

`edgex-go`源码中所有服务运行所需的配置文件都位于`/cmd/各个服务/res/configuration.toml`下，运行环境中配置文件位于`/res/configuration.toml`。

## 启动流程
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210204125700393.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM3NzM1Nzk2,size_16,color_FFFFFF,t_70#pic_center)

# 数据库接口
`Edgex-go`下面是`edgex-go`中所有微服务具有的操作数据库的方法，存储的信息包括`Events, Readings, ValueDescriptors, DeviceReports, Devices, DeviceProfiles, Addressables, DeviceServices, ProvisionWatchers, Commands, Notifications, Subscriptions, Transmissions, Intervals, IntervalActions`共15类。不同的微服务负责不同的信息并实现对应的函数，其中（通过源码中`internel/*/*/interfaces/db.go`知悉），
* `coredata`负责`Events, Readings, ValueDescriptors`3类；
* `metadata` 负责`DeviceReports, Devices, DeviceProfiles, Addressables, DeviceServices, ProvisionWatchers, Commands` 7类；
* `support-scheduler`负责`intervals, intervalActions`2类；
* `support-notifications`负责`Notifications, Subscriptions, Transmissions,`三类。

```go
type DBClient interface {
	CloseSession()

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

	/*
		Device Reports
	*/
	GetAllDeviceReports() ([]contract.DeviceReport, error)
	GetDeviceReportByName(n string) (contract.DeviceReport, error)
	GetDeviceReportByDeviceName(n string) ([]contract.DeviceReport, error)
	GetDeviceReportById(id string) (contract.DeviceReport, error)
	GetDeviceReportsByAction(n string) ([]contract.DeviceReport, error)
	AddDeviceReport(d contract.DeviceReport) (string, error)
	UpdateDeviceReport(dr contract.DeviceReport) error
	DeleteDeviceReportById(id string) error

	/*
		Devices
	*/
	GetAllDevices() ([]contract.Device, error)
	AddDevice(d contract.Device, commands []contract.Command) (string, error)
	UpdateDevice(d contract.Device) error
	DeleteDeviceById(id string) error
	GetDevicesByProfileId(id string) ([]contract.Device, error)
	GetDeviceById(id string) (contract.Device, error)
	GetDeviceByName(n string) (contract.Device, error)
	GetDevicesByServiceId(id string) ([]contract.Device, error)
	GetDevicesWithLabel(l string) ([]contract.Device, error)

	/*
		Device Profiles
	*/
	GetAllDeviceProfiles() ([]contract.DeviceProfile, error)
	GetDeviceProfileById(id string) (contract.DeviceProfile, error)
	GetDeviceProfilesByModel(model string) ([]contract.DeviceProfile, error)
	GetDeviceProfilesWithLabel(l string) ([]contract.DeviceProfile, error)
	GetDeviceProfilesByManufacturerModel(man string, mod string) ([]contract.DeviceProfile, error)
	GetDeviceProfilesByManufacturer(man string) ([]contract.DeviceProfile, error)
	GetDeviceProfileByName(n string) (contract.DeviceProfile, error)
	AddDeviceProfile(dp contract.DeviceProfile) (string, error)
	UpdateDeviceProfile(dp contract.DeviceProfile) error
	DeleteDeviceProfileById(id string) error

	/*
		Addressables
	*/
	GetAddressables() ([]contract.Addressable, error)
	UpdateAddressable(a contract.Addressable) error
	GetAddressableById(id string) (contract.Addressable, error)
	AddAddressable(a contract.Addressable) (string, error)
	GetAddressableByName(n string) (contract.Addressable, error)
	GetAddressablesByTopic(t string) ([]contract.Addressable, error)
	GetAddressablesByPort(p int) ([]contract.Addressable, error)
	GetAddressablesByPublisher(p string) ([]contract.Addressable, error)
	GetAddressablesByAddress(add string) ([]contract.Addressable, error)
	DeleteAddressableById(id string) error

	/*
		Device Services
	*/
	GetDeviceServiceByName(n string) (contract.DeviceService, error)
	GetDeviceServiceById(id string) (contract.DeviceService, error)
	GetAllDeviceServices() ([]contract.DeviceService, error)
	GetDeviceServicesByAddressableId(id string) ([]contract.DeviceService, error)
	GetDeviceServicesWithLabel(l string) ([]contract.DeviceService, error)
	AddDeviceService(ds contract.DeviceService) (string, error)
	UpdateDeviceService(ds contract.DeviceService) error
	DeleteDeviceServiceById(id string) error

	/*
		Provision Watchers
	*/
	GetAllProvisionWatchers() (pw []contract.ProvisionWatcher, err error)
	GetProvisionWatcherByName(n string) (pw contract.ProvisionWatcher, err error)
	GetProvisionWatchersByIdentifier(k string, v string) (pw []contract.ProvisionWatcher, err error)
	GetProvisionWatchersByServiceId(id string) (pw []contract.ProvisionWatcher, err error)
	GetProvisionWatchersByProfileId(id string) (pw []contract.ProvisionWatcher, err error)
	GetProvisionWatcherById(id string) (pw contract.ProvisionWatcher, err error)
	AddProvisionWatcher(pw contract.ProvisionWatcher) (string, error)
	UpdateProvisionWatcher(pw contract.ProvisionWatcher) error
	DeleteProvisionWatcherById(id string) error

	/*
		Commands
	*/
	GetAllCommands() ([]contract.Command, error)
	GetCommandById(id string) (contract.Command, error)
	GetCommandsByName(n string) ([]contract.Command, error)
	GetCommandsByDeviceId(did string) ([]contract.Command, error)
	GetCommandByNameAndDeviceId(cname string, did string) (contract.Command, error)

	ScrubMetadata() error

	/*
		Notifications
	*/
	GetNotifications() ([]contract.Notification, error)
	GetNotificationById(id string) (contract.Notification, error)
	GetNotificationBySlug(slug string) (contract.Notification, error)
	GetNotificationBySender(sender string, limit int) ([]contract.Notification, error)
	GetNotificationsByLabels(labels []string, limit int) ([]contract.Notification, error)
	GetNotificationsByStartEnd(start int64, end int64, limit int) ([]contract.Notification, error)
	GetNotificationsByStart(start int64, limit int) ([]contract.Notification, error)
	GetNotificationsByEnd(end int64, limit int) ([]contract.Notification, error)
	GetNewNotifications(limit int) ([]contract.Notification, error)
	GetNewNormalNotifications(limit int) ([]contract.Notification, error)
	AddNotification(n contract.Notification) (string, error)
	UpdateNotification(n contract.Notification) error
	MarkNotificationProcessed(n contract.Notification) error
	DeleteNotificationById(id string) error
	DeleteNotificationBySlug(slug string) error
	DeleteNotificationsOld(age int) error

	/*
		Subscriptions
	*/
	GetSubscriptionBySlug(slug string) (contract.Subscription, error)
	GetSubscriptionByCategories(categories []string) ([]contract.Subscription, error)
	GetSubscriptionByLabels(labels []string) ([]contract.Subscription, error)
	GetSubscriptionByCategoriesLabels(categories []string, labels []string) ([]contract.Subscription, error)
	GetSubscriptionByReceiver(receiver string) ([]contract.Subscription, error)
	GetSubscriptionById(id string) (contract.Subscription, error)
	DeleteSubscriptionById(id string) error
	AddSubscription(sub contract.Subscription) (string, error)
	UpdateSubscription(sub contract.Subscription) error
	DeleteSubscriptionBySlug(slug string) error
	GetSubscriptions() ([]contract.Subscription, error)

	/*
		Transmissions
	*/
	AddTransmission(t contract.Transmission) (string, error)
	UpdateTransmission(t contract.Transmission) error
	DeleteTransmission(age int64, status contract.TransmissionStatus) error
	GetTransmissionById(id string) (contract.Transmission, error)
	GetTransmissionsByNotificationSlug(slug string, limit int) ([]contract.Transmission, error)
	GetTransmissionsByNotificationSlugAndStartEnd(slug string, start int64, end int64, limit int) ([]contract.Transmission, error)
	GetTransmissionsByStartEnd(start int64, end int64, limit int) ([]contract.Transmission, error)
	GetTransmissionsByStart(start int64, limit int) ([]contract.Transmission, error)
	GetTransmissionsByEnd(end int64, limit int) ([]contract.Transmission, error)
	GetTransmissionsByStatus(limit int, status contract.TransmissionStatus) ([]contract.Transmission, error)

	Cleanup() error
	CleanupOld(age int) error

	/*
		Intervals
	*/
	Intervals() ([]contract.Interval, error)
	IntervalsWithLimit(limit int) ([]contract.Interval, error)
	IntervalByName(name string) (contract.Interval, error)
	IntervalById(id string) (contract.Interval, error)
	AddInterval(interval contract.Interval) (string, error)
	UpdateInterval(interval contract.Interval) error
	DeleteIntervalById(id string) error

	/*
		Interval Actions
	*/
	IntervalActions() ([]contract.IntervalAction, error)
	IntervalActionsWithLimit(limit int) ([]contract.IntervalAction, error)
	IntervalActionsByIntervalName(name string) ([]contract.IntervalAction, error)
	IntervalActionsByTarget(name string) ([]contract.IntervalAction, error)
	IntervalActionById(id string) (contract.IntervalAction, error)
	IntervalActionByName(name string) (contract.IntervalAction, error)
	AddIntervalAction(action contract.IntervalAction) (string, error)
	UpdateIntervalAction(action contract.IntervalAction) error
	DeleteIntervalActionById(id string) error

	ScrubAllIntervalActions() (int, error)
	ScrubAllIntervals() (int, error)
}
```

[数据库存储的数据样例可以看这](https://blog.csdn.net/qq_37735796/article/details/113530873)，应该是对应源码`go-mod-core-contracts/models`目录下各个文件中定义的结构，但并不是此结构中的所有参数都会保存到数据库。

## core-metadata `api` 列表
`API`看此网页：[网页API说明](https://app.swaggerhub.com/apis-docs/EdgeXFoundry1/core-metadata/1.2.0)

`api`除了查看文档，在源码`edgex-go/api`目录下也有说明。此处也可看出`metadata`负责对`DeviceReports, Devices, DeviceProfiles, Addressables, DeviceServices, ProvisionWatchers, Commands` 7类信息的管理。

# redis
[Redis 教程](https://www.runoob.com/redis/redis-tutorial.html)
[Redis 命令参考](http://doc.redisfans.com/)

使用`docker-compose`启动EdgeX后连接redis数据库，查看值。命令行用：`docker exec -it edgex-redis redis-cli`

`redis` 默认有16个database，但`edgex-go`中并没有说一类数据用一个database来存储，而是所有数据都存储在一个database中，所以上面连接redis数据库，查看键值会很乱。微服务的配置文件中：
```json
[Databases]
  [Databases.Primary]
  Host = 'localhost'
  Name = 'coredata'
  Password = 'password'
  Username = 'core'
  Port = 6379
  Timeout = 5000
  Type = 'redisdb'
```
`Username, Name` 可能会产生误导，让人怀疑是不是使用了不同的database，但其实那些参数是使用`Mongo`数据库时才需要的，`Redis`并未用到！

```sql
// key
keys * 		// 查看所有key
exists key	// 检查key是否存在，存在返回1
type key	// key 值类型
scan 0 match ** count 10		// 迭代数据库中的数据库键

// string 	key:"string"
get key		// 返回key对应string

// hash 	key: field1 value1 field2 value2 ...
HGETALL key	// 返回key中的所有值

// set

// sort set

```
所有ID类键都是string类型，保存了完整的信息，如设备配置文件会分配一个ID作为键，将文件内容合成一个字符串作为值保存。

使用命令行中连接redis查看数据比较麻烦，推荐用[RDM](https://rdm.dev/)  `sudo snap install redis-desktop-manager`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210410172904417.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM3NzM1Nzk2,size_16,color_FFFFFF,t_70#pic_center)
# 总结
`metadata` 管理了多中类型的数据，设备服务启动时，也会将信息注册到metadata。需要注意和`consul`区分开来，`consul`保存的是微服务的配置信息，即`/cmd/res/configuration.toml`文件，而`metadata` 保存的是设备配置文件，设备id等具体信息。
