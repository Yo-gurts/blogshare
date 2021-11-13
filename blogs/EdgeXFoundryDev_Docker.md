# Docker 介绍：文件系统

linux 系统 是一个文件管理系统，所有程序、驱动这些都可看作由一系列文件组成的。
Docker 也是一个虚拟的文件系统。
docker镜像就是系统所必须的文件组成。这些文件是只读的！
docker容器相当与将对应镜像的文件拷贝一份，且权限变为可读写，docker容器就成了一个可操作的虚拟的系统了。

挂载则是将宿主机的文件添加到 docker容器中，让它成为虚拟系统中的文件。

# Docker 文件挂载
[Docker进阶（一）：docker -v目录挂载](https://blog.csdn.net/sunhuaqiang1/article/details/88317987)

# 端口介绍

# 进入 Docker 容器

[Docker容器进入的4种方式](https://www.cnblogs.com/xhyan/p/6593075.html)

# Docker 命令详解

https://www.cnblogs.com/xhyan/p/6593216.html

* 清除无用镜像: `docker image prune`
* 停用全部运行中的容器: `docker stop $(docker ps -q)`
* 删除全部容器： `docker rm $(docker ps -aq)`

