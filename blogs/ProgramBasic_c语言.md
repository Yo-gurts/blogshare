---
- date: 2019-6-21
- author: yogurt
---
先推荐几个网站：
* [c++ reference](http://www.cplusplus.com/reference/cstdlib/calloc/?kw=calloc)  可以快速查找c/c++标准库中的函数说明，还有示例
* [google风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-cpp-styleguide/contents/) 规范一点看着舒服


# 修饰符

C语言中有`int` `float` `double` `char` `bool`这几个常见的数据类型，而对一个变量而言，除了数据数据外，还有修饰符。

* [`const`](https://baike.baidu.com/item/const/1036): 限定一个变量不允许被改变，相当于 readonly 。
* [`extern`](https://baike.baidu.com/item/extern): 就是在任何函数的外部定义的变量，具有“全局型“定义。全局变量也是外部型。要访问其他文件中的外部型变量前需使用`extern`声明。
* [`static`](https://baike.baidu.com/item/static/9598919#2): 分内部静态变量和外部静态变量，内部静态变量即在函数内部定义的变量，作用域类似于`auto`，仅在当前函数内部有效，不同在于函数退出后，值仍然有效。通过将变量设为外部静态型可将文件中的函数或变量隐藏，不允许别的文件存取，与`extern`相对。
* [`auto`](https://baike.baidu.com/item/auto/10128#viewPageContent): 声明为自动型变量，在函数内部声明的变量默认都是自动型(前提是不加static等)，作用域仅限当前函数。
* [`volatile`](https://baike.baidu.com/item/volatile): 确保本条指令不会因编译器的优化而省略。
* [`register`](https://baike.baidu.com/item/Register):尽可能的将变量存在CPU 内部寄存器中以提高效率。

> 上面的内容都是百度百科中摘抄的，重点关注`const extern static auto`，其他2个很少见。

# 指针

- `&` 取地址
- `*` 取出地址中的值

## 指针变量
```c
int a = 65;    // a 的地址为0x0000FF7C
int addr = &a; // 会有警告

// *(&a) 输出为 65
// *addr 输出为addr保存的值 0x0000FF7C 
// (int *)addr 将 0x0000FF7C 当地址对待
// *(int *)addr 输出 65

int *p = &a; // p 保存的值为 0x0000FF7C 
// *p 输出的值为 65
```

所以指针变量就是保存某个变量地址的一个变量，在使用`*`取值时，它会取保存的地址上的值。

而且，指针是一个用来保存指向变量的地址值的变量，地址的长度都是一样的，所以各种类型的指针所占的内存大小是一样的。
```c
#include <iostream>
using namespace std::cout;
int main() {
    int a = 1;
    int b = 2;
    int c = 3;
    int *p = &c;
    
    cout<<&c<<"\n"<<&b<<"\n"<<&p<<"\n";
    cout<<c<<"\n"<<p<<"\n"<<*p<<"\n";
    for(int i=0; i<3; i++ ) {
        cout<<*p<<"  "<<"&p:"<<&p<<"p:"<<p<<"\n";
        p++;
    }
    return 0;
}

运行结果如下：
0x7ffdeb944910
0x7ffdeb944914
0x7ffdeb944908
3
0x7ffdeb944910
3
3     &p:0x7ffdeb944908   p:0x7ffdeb944910
2     &p:0x7ffdeb944908   p:0x7ffdeb944914
1     &p:0x7ffdeb944908   p:0x7ffdeb944918
```
可知变量的地址是降序分配的，指针p本身的存储地址没有变化，但它保存的值（地址）在变化。

## 对指针分配空间
可用`malloc`和`calloc`函数，`calloc`分配时会将所分配字节置0，而`malloc`仍是原始的随机值。用法示例如下：
```c
int a[8];
int *p = (int *) malloc(sizeof(int) * 8);

int b[8] = {};
int *q = (int*) calloc(8, sizeof(int));

free(p);
free(q);
```
注意上面`malloc`和`calloc`函数用法不同，而且在使用这种方法分配空间后，要手动释放空间，使用`free`函数。

如果要改变上面分配的空间的大小，可以使用`realloc`函数，此函数会使原空间的值保持不变。用法`realloc(p, sizeof(int)*10)`, 建议使用[c++ reference](http://www.cplusplus.com/reference/cstdlib/calloc/?kw=calloc)查看函数具体说明。

## 对指针使用const限定符

### 指向常量的指针
如果要让指针指向常量，就要声明一个指向常量的指针；
```c
const int a = 1, b = 2;
int c = 5;  
const int *p = &a;
int *q = &a;    // error!! 非常量指针指向常量会报错

*p = 3;     // error!! 常量指针即不允许对值进行修改
p = &b;     // 可改变p保存的地址值。
p = &c;     // 常量指针可指向非常量
*p = 3;     // error!! 常量指针不允许通过*p来修改值
```
### 常量指针
```c
int a = 1, b = 2;
int * const p = &a;
*p = 3;     // 正确
p = &b;     // error!! 常量指针不允许修改保存的地址
```
## void指针
void指针可以指向任何变量，不过不可使用`*p`来取值，必须通过强制转换赋值给相应数据类型的指针进行操作。
```c
int a = 1, *p;
void *vp = &a;
p = (int *)vp;
cout<<*p;
```

# 数组
## 数组的初始化
如果定义时只对数组元素前几个初始化，则其他元素初始化为0；若未进行初始化，则：
1) 外部型和静态型初始化为0；(即全局变量和`extern`、`static`);
2) 寄存器型(`register`)和自动型(`auto`)初始为随机数；

```c
#include <stdio.h>
int x[6];           // 外部型变量，初始化全为0
int main() {
    int a[5] = {1, 2};  // 其余项为0
    int b[6] ;          // auto 型，为随机数
    b[6] = {1, 2, 3};   // error!! 使用{}初始化只能在声明时使用，这里b[6]是数组的第7个元素，还越界了...
    int c[6] = {0};     // auto 型，全为0
    char s[] = "hello!";// s占7个字节，最后一个为`\0`;
    char cs[7];
    for( int i=0; i<7; i++ ) {
        cs[i] = s[i];   // copy 时要将最后一位`\0`也要复制
    }
}
```
## 字符串常量
```c
char s[] = "hello!", *p = "hey", *s;
s = "hi!!";     // *p 与 *s 指向的字符串为常量(const)
p[1] = 'i';     // error!! 不可更改
s[1] = 'e';     // error!! 不可更改
s++;
cout<<s;        // 输出 "i!!" 值不可更改但指针可移动
```
## 指针数组
每一个元素都是一个指针；
```c
char *p[] = {"dog", "cat", "fish"};
```
## 二维数组
```c
// 初始化
int a[2][3] = { {1,2,3}, {4,5}};    // a[1][2] = 0
int b[2][3] = {1, 2, 3, 4, 5};      // 同上, a==b
int c[][3]  = {1, 2, 3, 4, 5};      // 同上, a==b==c

// 指针与数组
int *p;
p = a;          // error !! a代表一维数组名
p = &a[0][0];   // 不推荐
p = a[0];       // 推荐 p[0]=a[0][0], p[1]=a[0][1], p[3]=a[1][0];


// 指向一维数组的指针
int (*q)[3];    // q为指向一维数组的指针
q = a;          // 正确 p[0]=a[0] p[0][1]=a[0][1] **p = a[0][0]=*p[0]
q=a[0]          // error !!
// *(*(p+i)+k) = p[i][k]
```


# 函数
## main函数原型
```c
int main(int argc, char *argv[]); 
```
`char *argv[]`定义了一个指针数组，将上述程序生成可执行文件名为`test`，输入命令`test argc1 argc2 argc3`。那么`argv[0] = test`, `argv[1] = argc1`....

# 枚举 enum

```c
enum alpha{A,B,C,D=5,F};

int main() {
    int a=1;
    enum alpha e = A;

}

```

# c++11 thread类
> [详细说明](http://www.cplusplus.com/reference/thread/thread/?kw=thread)

线程一经定义，就开始执行

* `join()` 放主线程(main函数)中，等待该线程执行完后，再执行后续内容。
* `detach()` 用法同`join()`，但功能相反，放飞子线程，直接执行后续内容。
* `joinable()` 是否可以调用`join()`，默认构造函数定义的线程不可`join()`。
* `get_id()` 如果线程可`join()`，系统会分配一个`id`，`thread::id`是一种变量类型。

若主线程中没有加`join()`，或者使用了`detach()`, 当主线程执行完毕(return 0;)后，即使子线程未完成，也会被结束！

编译使用`g++ ***.cc -o out -std=c++11 -lpthread`
** Example **
```c
#include <iostream>       // std::cout
#include <thread>         // std::thread, std::this_thread::sleep_for
#include <chrono>         // std::chrono::seconds
 
void pause_thread(int n) // 等待n秒
{
    std::cout << n << " seconds id: " << std::this_thread::get_id() << std::endl;
    std::this_thread::sleep_for (std::chrono::seconds(n));
    std::cout << "pause of " << n << " seconds ended\n";
}
 
int main() 
{
    std::thread::id main_id = std::this_thread::get_id();    // 主线程id
    std::cout << "主线程id：" << main_id << std::endl;
    
    std::thread t1 (pause_thread,1);
    std::thread t2 (pause_thread,3);
    std::thread t3 (pause_thread,5);

    t1.join();
    t2.join();
    // t2.detach(); 
    t3.join();
    std::cout << "All threads joined!\n";

    getchar();  // 按任意键结束
    return 0;
}
```


