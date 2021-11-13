
配置设备服务 `device-camera-go`

1. 准备代码

    `git clone  git@github.com:edgexfoundry/device-camera-go.git`

2. `build` or `make docker`
    * 修改Dockerfile
    ```dockerfile
    ENV GOPROXY=https://goproxy.cn

    RUN sed -e 's/dl-cdn[.]alpinelinux.org/mirrors.aliyun.com/g' -i~ /etc/apk/repositories

    #ENTRYPOINT ["/device-camera-go"]
    #CMD ["--cp=consul.http://edgex-core-consul:8500", "--registry", "--confdir=/res"]
    ENTRYPOINT ["/device-camera-go","-cp=consul.http://edgex-core-consul:8500","--registry","--confdir=/res"]
    ```
    * 修改`cmd/res/configuration.toml`
    ``` toml
	LogLevel = 'DEBUG'

	# Pre-defined Devices
    [[DeviceList]]
      Name = 'Camera001'
      Profile = 'camera'
      Description = 'My test IP camera'
      Location = 'china'
      [DeviceList.Protocols]
        [DeviceList.Protocols.HTTP]
          Address = '192.168.1.102:34567'  # 这里使用的app IPcamera, 用手机做摄像头
    
    [[DeviceList.AutoEvents]]
      Frequency = "60s"
      OnChange = false
      Resource = "onvif_snapshot"
    
    # Driver configs
    [Driver]
    User = 'admin'
    Password = 'admin'

    AuthMethod = 'basic'
    ```
	* `make docker`

3. 在`docker-compose.yml`中添加：
    ```yml
    docker-device-camera-go:
      image: device-camera-go-dev:latest
      ports:
        - "0.0.0.0:49985:49985"
      container_name: edgex-device-camera-go
      hostname: edgex-device-camera-go
      networks:
        - edgex-network
      environment:
        <<: *common-variables
        Service_Host: edgex-device-camera-go
      volumes:
        - db-data:/data/db
        - log-data:/edgex/logs
        - consul-config:/consul/config
        - consul-data:/consul/data
      depends_on:
        - data
        - command
        - metadata	
	```

完事！🍉️
