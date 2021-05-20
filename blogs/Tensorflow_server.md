
> [Train and serve a TensorFlow model with TensorFlow Serving](https://www.tensorflow.org/tfx/tutorials/serving/rest_simple)

# 1 准备模型，用SaveModel保存

模型可自己训练（用SaveModel模块保存模型），也可从[Tensorflow Hub](https://www.tensorflow.org/hub)下载别人训练的模型使用。

下面是手写数字识别的模型训练与保存的代码：
```python
import tensorflow as tf
from tensorflow import keras

# 加载数据集
mnist = tf.keras.datasets.mnist

# 加载数据
(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

# 定义模型结构
model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation='softmax')
])

# 设置优化器算法、损失函数
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# 开始训练
model.fit(x_train, y_train, epochs=5)

# 模型测试
model.evaluate(x_test,  y_test, verbose=2)


# Fetch the Keras session and save the model
# The signature definition is defined by the input and output tensors,
# and stored with the default serving key

# 模型保存路径
MODEL_DIR = "/mnt/c/Users/yogurt/Desktop/TensorflowServer/Model/mnist"
version = 1
export_path = os.path.join(MODEL_DIR, str(version))
print('export_path = {}\n'.format(export_path))

# 保存模型
tf.keras.models.save_model(
    model,
    export_path,
    overwrite=True,
    include_optimizer=True,
    save_format=None,
    signatures=None,
    options=None
)

print('\nSaved model！')
```

# 2 检测模型 `saved_model_cli`

可输出模型输入格式等信息！
```bash
saved_model_cli show --dir {export_path} --all
```

> [关于 tensorflowServer 更多的信息](https://www.tensorflow.org/tfx/guide/serving)

# 3 启动服务

## 1. 直接在本地启动（ubuntu系统下）

(1) 向包管理器中添加相关地址
```bash
echo "deb http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | sudo tee /etc/apt/sources.list.d/tensorflow-serving.list && \
curl https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | sudo apt-key add -

sudo apt update
```

(2) 下载 `tensorflow-model-server`

```bash
sudo apt-get install tensorflow-model-server
```

(3) 启动服务

```bash
tensorflow_model_server \
  --port=8111\  
  --rest_api_port=8501 \
  --model_name=mnist \
  --model_base_path="${MODEL_DIR}"
```
`--port=8111`指定grpc访问的端口，默认使用 8500

`tensorflow_model_server`还支持很多其他命令，如`--model_config_file`，这些通过`-h`查看

(4) 发送rest请求
```python
import tensorflow as tf
import requests
import json
import numpy as np

mnist = tf.keras.datasets.mnist

(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

data = json.dumps({"signature_name": "serving_default", "instances": x_test[0:3].tolist()})

headers = {"content-type": "application/json"}
json_response = requests.post('http://localhost:8501/v1/models/mnist:predict', data=data, headers=headers)
predictions = json.loads(json_response.text)['predictions']

for i in range(3):
    print('The model thought this was a {} (class {}), and it was actually a {} (class {})'.format(
    np.argmax(predictions[i]), np.argmax(predictions[i]), y_test[i], y_test[i]))
```
使用本地图片，go语言版本：`go run ***.go img1.png img2.png`
```go
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"image/png"
	"log"
	"net/http"
	"os"
	"strings"
    "time"
)

type RequestJSON struct {
	signature_name string
	instances      string
}

type Prediction struct {
	Predictions [][10]float64
}

func main() {
	dir := "/home/yogurt/Desktop/EdgeX_Tutorial/TensorflowServer/test_mnist/"
    imgstrbody := ""
    for _, name := range os.Args[1:] {
        imgdir := dir + name
        imgstr := readImage(imgdir)
        imgstrbody = imgstrbody + "," + imgstr
    }

    reqs := `{"signature_name": "serving_default", "instances": [` + imgstrbody[1:] + "]}"

	r := []byte(reqs)

    t1 := time.Now()
    resp, err := http.Post("http://localhost:8501/v1/models/mnist/versions/1:predict", "application/json", bytes.NewBuffer(r))
    elapsed := time.Since(t1)
    fmt.Println("app elapsed:", elapsed)
	if err != nil {
		fmt.Printf("request error: %v", err)
	}
	defer resp.Body.Close()

	var result Prediction
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		log.Fatalf("json unmarshal error: %v", err)
	}
    for _, res := range result.Predictions {
        fmt.Println(getIndex(res))
    }
}

func getIndex(res [10]float64) int {
	var index int = 0
	maxvalue := res[0]
	for i := 1; i < 10; i++ {
		if maxvalue < res[i] {
			index = i
			maxvalue = res[i]
		}
	}
	return index
}

func readImage(dir string) string {
	imgio, err := os.Open(dir)
	if err != nil {
		fmt.Printf("open image error: %v", err)
		os.Exit(0)
	}

	img, err := png.Decode(imgio)
	if err != nil {
		fmt.Printf("image decode error: %v", err)
		os.Exit(0)
	}

	imgArray := make([][28]float64, 28)
	for i := 0; i < 28; i++ {
		for j := 0; j < 28; j++ {
			_, g, _, _ := img.At(i, j).RGBA()
			g_uint8 := uint8(g >> 8)
			imgArray[j][i] = float64(g_uint8) / 255.0001
		}
	}

	imgbody := fmt.Sprintf("%v", imgArray)
	imgstrbody := strings.ReplaceAll(imgbody, " ", ", ")
    return imgstrbody
}
```

> [docker 命令大全](https://www.runoob.com/docker/docker-command-manual.html)

## 2. 使用docker启动

**启动方法1：** 直接指定模型的路径（注意修改路径）
```bash
docker run -t -d --rm -p 8501:8501 -p 8111:8500 --name tfserver \
--mount type=bind,source=/home/yogurt/Desktop/EdgeX_Tutorial/TensorflowServer/Model/mnist,target=/models/mnist \
-e MODEL_NAME=mnist tensorflow/serving 
```
注意上面的命令中 `,`后面不能有空格！！否则会报错。 端口映射时，由于grpc的默认端口与consul默认端口冲突了，所以将容器的8500端口映射到其他端口！
```text
–mount: 表示要进行挂载
source: 指定要运行部署的模型地址， 也就是挂载的源，这个是在宿主机上的servable模型目录（pb格式模型而不是checkpoint模型）
        注意：此地址必须是模型的绝对路径！！！
target: 这个是要挂载的目标位置，也就是挂载到docker容器中的哪个位置，这是docker容器中的目录，
        模型默认挂在/models/目录下，如果改变路径会出现找不到model的错误
-t: 为容器重新分配一个伪输入终端，通常与 -i 同时使用；
-d: 后台运行
-p: 指定主机到docker容器的端口映射
-e: 添加环境变量
-v: docker数据卷
–name: 指定容器name，后续使用比用container_id更方便
--rm: 关闭后自动删除容器
```

**启动方法2：** 通过model.config文件启动，[watch this video](https://www.youtube.com/watch?v=CUpUPY5g8NE)
首先编辑一个`model.config`文件: [该配置文件的官方文档见此！](https://www.tensorflow.org/tfx/serving/serving_config#model_server_configuration)
```yaml
model_config_list: {
    config: {
        name: "mnist",
        base_path: "/models/mnist",
        model_platform: "tensorflow",
        model_version_policy:{
            all: {}
        }
    }
}
```
启动命令如下：
```bash
docker run -t -d --rm -p 8501:8501 -p 8111:8500 --name tfserver \
--mount type=bind,source=/home/yogurt/Desktop/EdgeX_Tutorial/TensorflowServer/Model/mnist,target=/models/mnist \
--mount type=bind,source=/home/yogurt/Desktop/EdgeX_Tutorial/TensorflowServer/Model/model.config,target=/models/model.config \
tensorflow/serving --model_config_file=/models/model.config
```
上面将模型文件夹挂载到容器`/models/mnist/`, 并将`model.config`也挂载上去了，最后一个参数`--model_config_file`是`tensorflow_model_server`的参数，而不是docker的，支持的其它参数也可以这样写在后面！

进入docker容器：`docker exec -it tfserver /bin/bash`

**启动方法3：** 同方法2，直接挂载`/Model`文件夹，`models.config`在此文件夹中，就不需要单独挂载此文件了，每次直接修改`models.config`文件即可
```bash
docker run -t -d --rm -p 8501:8501 -p 8111:8500 --name tfserver \
--mount type=bind,source=/home/yogurt/Desktop/EdgeX_Tutorial/TensorflowServer/Model,target=/models \
tensorflow/serving --model_config_file=/models/model.config
```

## 3. 使用docker-compose 启动
docker启动时，参数太多，所以直接写成文件，用docker-compose启动！

[参数介绍](https://www.cnblogs.com/wutao666/p/11332186.html)
todo ...

## 4. 多版本测试
上面的启动方法2中 `model.config`文件中有参数`model_version_policy`，它用来对启用模型的版本进行管理，上面用的`all: {}`就是启用所有版本！
![Screenshot from 2021-04-11 20-00-07.png](http://ww1.sinaimg.cn/large/006xUmvugy1gpg2km4hrkj31h40khgsx.jpg)
在文件夹中添加一个新版本模型（这里只是复制，但版本号不一样了），tensorflow_modle_server会自动将模型部署上去，此时两个版本的模型都可以用！

## [5. 创建带有特定模型的服务镜像](https://www.tensorflow.org/tfx/serving/docker#creating_your_own_serving_image)

# 4. TensorflowServer 配置

[具体看官方文档，这里只说明哪些内容可以配置](https://www.tensorflow.org/tfx/serving/serving_config#model_server_configuration)
1. 模型服务器配置
    * 模型名称，路径
    * 通过配置文件启动 model_config
    * 重新加载配置文件 --model_config_file_poll_wait_seconds，可修改配置文件增加新模型
    * 模型服务器配置详细信息，可部署多个不同类型的模型
    * 同一类模型也可以部署多个版本，可指定启用哪个版本，也可配置全部启动
    * 可为模型设置 版本标签，发送请求时可根据标签来
    * --port：用于侦听gRPC API的端口
    * --rest_api_port：用于侦听HTTP / REST API的端口
    * --rest_api_timeout_in_ms：HTTP / REST API调用超时
    * --file_system_poll_wait_seconds：服务器在每个模型各自的model_base_path上轮询文件系统以获取新模型版本的时间


# 5. 相关说明
## [REST api官方文档（推荐看这个）！](https://www.tensorflow.org/tfx/serving/api_rest)

1. 发生错误时，所有API都会在响应主体中返回一个JSON对象，其 error键为键，错误消息为值：
```yaml
{
  "error": <error message string>
}
```
2. 查询模型状态
```bash
GET http://host:port/v1/models/${MODEL_NAME}[/versions/${VERSION}|/labels/${LABEL}]
```
返回信息如下[code](https://github.com/tensorflow/serving/blob/5369880e9143aa00d586ee536c12b04e945a977c/tensorflow_serving/apis/get_model_status.proto#L64)，其中`state`可能的结果为：`{UNKNOWN, START, LOADING, AVAILABLE, UNLOADING, END}`
```bash
(base) yogurt@s:source$ GET http://localhost:8501/v1/models/mnist/versions/2
{
 "model_version_status": [
  {
   "version": "2",
   "state": "AVAILABLE",
   "status": {
    "error_code": "OK",
    "error_message": ""
   }
  }
 ]
}
```
3. 分类、回归请求
```bash
POST http://host:port/v1/models/${MODEL_NAME}[/versions/${VERSION}|/labels/${LABEL}]:(classify|regress)
```
请求正文必须为JSON对象，格式如下：
```yaml
{
  // Optional: serving signature to use.
  // If unspecifed default serving signature is used.
  "signature_name": <string>,

  // Optional: Common context shared by all examples.
  // Features that appear here MUST NOT appear in examples (below).
  "context": {
    "<feature_name3>": <value>|<list>
    "<feature_name4>": <value>|<list>
  },

  // List of Example objects
  "examples": [
    {
      // Example 1
      "<feature_name1>": <value>|<list>,
      "<feature_name2>": <value>|<list>,
      ...
    },
    {
      // Example 2
      "<feature_name1>": <value>|<list>,
      "<feature_name2>": <value>|<list>,
      ...
    }
    ...
  ]
}
```

4. 预测请求
```bash
POST http://host:port/v1/models/${MODEL_NAME}[/versions/${VERSION}|/labels/${LABEL}]:predict
```
predictAPI的请求正文必须为JSON对象，格式如下：
```yaml
{
  // (Optional) Serving signature to use.
  // If unspecifed default serving signature is used.
  "signature_name": <string>,

  // Input Tensors in row ("instances") or columnar ("inputs") format.
  // A request can have either of them but NOT both.
  "instances": <value>|<(nested)list>|<list-of-objects>
  "inputs": <value>|<(nested)list>|<object>
}
```
