
- [配置文件说明](#配置文件说明)
	- [Service](#service)
	- [Registry](#registry)
	- [Logging](#logging)
	- [Clients](#clients)
	- [Databases](#databases)
	- [SecretStore](#secretstore)
	- [Startup](#startup)

# 配置文件说明
这些微服务的配置文件的结构都大同小异，`edgex-go`中微服务的结构在 `/internal/具体服务/config/config.go`文件中，下面是`core-data`，和`metadata`的配置结构。

```go
// metadata
type ConfigurationStruct struct {
	Writable      WritableInfo
	Clients       map[string]bootstrapConfig.ClientInfo
	Databases     map[string]bootstrapConfig.Database
	Logging       bootstrapConfig.LoggingInfo
	Notifications NotificationInfo
	Registry      bootstrapConfig.RegistryInfo
	Service       bootstrapConfig.ServiceInfo
	SecretStore   bootstrapConfig.SecretStoreInfo
	Startup       bootstrapConfig.StartupInfo
}
// core-data
type ConfigurationStruct struct {
	Writable     WritableInfo
	MessageQueue MessageQueueInfo
	Clients      map[string]bootstrapConfig.ClientInfo
	Databases    map[string]bootstrapConfig.Database
	Logging      bootstrapConfig.LoggingInfo
	Registry     bootstrapConfig.RegistryInfo
	Service      bootstrapConfig.ServiceInfo
	SecretStore  bootstrapConfig.SecretStoreInfo
	Startup      bootstrapConfig.StartupInfo
}
```
可以看到，不同微服务的配置结构中有一些常用的信息，如`Clients, Registry, Logging, Service, SecretStore, Startup`等，这些信息的结构都是统一的，在`go-mod-bootstrap/config`中定义。

也有一些信息是要根据微服务的功能来自定义的结构，如`Writeable, Notification, MessageQueue`等等，基本每个服务都有`Writeable`结构，但起具体内容是每个微服务自定义的，也在`/internal/具体服务/config/config.go`，这部分内容就具体问题具体分析了。**注意`Writeable`配置的内容可通过`consul-ui`实时的修改，而其他结构的内容也可通过`consul-ui`修改，但要重启服务才能生效**。

下面介绍常用结构的内容：

## Service
```go
// ServiceInfo contains configuration settings necessary for the basic operation of any EdgeX service.
type ServiceInfo struct {
	// BootTimeout indicates, in milliseconds, how long the service will retry connecting to upstream dependencies
	// before giving up. Default is 30,000.
	BootTimeout int
	// Health check interval
	CheckInterval string
	// Indicates the interval in milliseconds at which service clients should check for any configuration updates
	ClientMonitor int
	// Host is the hostname or IP address of the service.
	Host string
	// Port is the HTTP port of the service.
	Port int
	// The protocol that should be used to call this service
	Protocol string
	// StartupMsg specifies a string to log once service
	// initialization and startup is completed.
	StartupMsg string
	// MaxResultCount specifies the maximum size list supported
	// in response to REST calls to other services.
	MaxResultCount int
	// Timeout specifies a timeout (in milliseconds) for
	// processing REST calls from other services.
	Timeout int
}
```
## Registry
```go
// RegistryInfo defines the type and location (via host/port) of the desired service registry (e.g. Consul, Eureka)
type RegistryInfo struct {
	Host string
	Port int
	Type string
}
```
服务注册的信息，`edgex-go` 中所有微服务都要注册到`consul`，所以这里需要提供`consul`的`host, port`信息，`Type`是因为之前版本使用其他的服务管理工具，为了兼容设置的，现在填`consul`就好。
## Logging
```go
// LoggingInfo provides basic parameters related to where logs should be written.
type LoggingInfo struct {
	EnableRemote bool		// 是否使用远程日志，
	File         string
}
```
日志模块，如果不启用远程日志的话，就直接将日志输出到`stdout`。
## Clients
```go
// ClientInfo provides the host and port of another service in the eco-system.
type ClientInfo struct {
	// Host is the hostname or IP address of a service.
	Host string
	// Port defines the port on which to access a given service
	Port int
	// Protocol indicates the protocol to use when accessing a given service
	Protocol string
}
```
注意配置`Clients`是`map[string]bootstrapConfig.ClientInfo`，所以可以保存多个`ClientInfo`结构。

有些微服务的设计上就需要与其他微服务进行通信，因此需要知道其他微服务的`Host:Port`、协议等信息。如`core-data` 要通过`metadata`验证设备是否存在，因此需要`metadata`的信息。

## Databases
```go
type Database struct {
	Username string
	Password string
	Type     string		// 新版本推荐 redis，以前使用 mongo
	Timeout  int
	Host     string
	Port     int
	Name     string
}
```
`metadata, coredata` 等模块并不是自己维护一个数据库，而是有一个专门的数据库`edgex-redis`，由`metadata`这些微服务提供 将特定数据存入数据库，或者向数据库查询数据的方法。凡是需要向这样直接对数据库进行操作的微服务，都需要与数据库建立连接，因此也就需要知道数据库的`Host, Port, password`信息，至于 `Username` 等信息，是使用`Mongo`才会用到的，`redis` 并不会使用(见`edgex-go/internal/pkg/bootstrap/handlers/database/database.go: newDBClient()`)。

[数据库数据样例](https://blog.csdn.net/qq_37735796/article/details/113530873)

## SecretStore
```go
// SecretStoreInfo encapsulates configuration properties used to create a SecretClient.
type SecretStoreInfo struct {
	Host                    string
	Port                    int
	Path                    string
	Protocol                string
	Namespace               string
	RootCaCertPath          string
	ServerName              string
	Authentication          vault.AuthenticationInfo
	AdditionalRetryAttempts int
	RetryWaitPeriod         string
	retryWaitPeriodTime     time.Duration
	// TokenFile provides a location to a token file.
	TokenFile string
}
```

## Startup

```go
// StartupInfo provides the startup timer values which are applied to the StartupTimer created at boot.
type StartupInfo struct {
	Duration int
	Interval int
}
```

