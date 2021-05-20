
* Makefile 直接管理工程，但是编写比较麻烦，特别是工程较大的时候
* cmake 则编写一个相对Makefile简单的CMakeLists.txt，再用cmake自动生成Makefile


一般步骤：
```bash
(base) root:opencv-3.2.0# ls
3rdparty  cmake           CONTRIBUTING.md  doc      LICENSE  platforms  samples
apps      CMakeLists.txt  data             include  modules  README.md
```
1. 项目根目录下面编写`CMakeLists.txt`文件
2. `mkdir build`
3. `cd build`
4. `cmake ..`
5. `make`
