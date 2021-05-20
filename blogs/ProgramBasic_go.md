

- [ ] 函数参数传递一般都是值传递，只有五类变量是引用传递：Slice、Map、指针、function、channel等。

# 数组、Slice、Map、结构体、JSON、文本、HTML模板

## 数组：长度固定，但值可修改。string 值不可修改
数组是一个由**固定长度**的特定类型元素组成的序列，因为数组的长度是固定的， 因此在Go语言中很少直接使用数组。

```go
var a [3]int

var q [3]int = [3]int{1, 2, 3}
var r [3]int = [3]int{1, 2}
fmt.Println(r[2]) // "0"

q := [...]int{1, 2, 3}
fmt.Printf("%T\n", q) // "[3]int"

months := [...]string{1: "January", /* ... */, 12: "December"}  // 声明数组时直接跳过第0个元素， 第0个元素会被自动初始化为空字符串。
r := [...]int{99: -1} // 定义了一个含有100个元素的数组r， 最后一个元素被初始化为-1， 其它元素都是用0初始化。
```

## Slice：变长序列，

一个slice由三个部分构成： **指针、 长度和容量**， 内置的len和cap函数分别返回slice的长度和容量。

slice的底层引用一个数组对象。指针指向切片中第一个数组元素，len 表示切片的大小，cap 表示切片起点到底层数组的末尾的长度，如下图。

![QQ截图20210327033846.png](http://ww1.sinaimg.cn/large/006xUmvugy1goyb8wfqtnj30is0hqgox.jpg)

如果切片操作超出cap(s)的上限将导致一个panic异常， 但是超出len(s)则是意味着扩展了slice， 因为新slice的长度会变大。

因为切片只有3个变量：指针、 长度和容量，由于指针的存在，所以参数传递时，虽然对切片来说是值复制，但修改数值实际上是修改的数组的值，所以，表现出来是引用传递！


```go
package main

import "fmt"

func main() {
	array := [...]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
	
	slice1 := array[1:4] // {1,2,3}
	slice2 := array[1:5] // {1,2,3,4}
	slice1[0] = 11
	fmt.Println(slice1)     // {11,2,3}
	fmt.Println(slice2)     // {11,2,3,4}
	array[1] = 12
	fmt.Println(slice1)     // {12,2,3}
	fmt.Println(slice2)     // {12,2,3,4}
	fmt.Printf("slice type: %T, addr: %p\n", slice1, &slice1) // addr: 0xc00000c080
	pass(slice1)
	fmt.Println(slice1)     // {13,2,3}
	fmt.Println(slice2)     // {13,2,3,4}
}

func pass(slice3 []int) {
	fmt.Printf("slice type: %T, addr: %p\n", slice3, &slice3) // addr: 0xc00000c140
	fmt.Println(slice3)     // [12 2 3]
	slice3[0] = 13
}
```

**要注意slice类型的变量和数组类型的变量的初始化语法的差异：Slice没有指明序列的长度！！**
```go
	array = [...]int {1,2,3,3,4,5,6]
	row1 := array[:3] 	// 基于数组声明
	row3 := []int {7,8,9} // 隐藏底层数组
```

和数组不同的是， slice之间不能使用==操作符比较！slice唯一合法的比较操作是和nil比较。

内置的make函数创建一个指定元素类型、 长度和容量的slice。 容量部分可以省略， 在这种情况下， 容量将等于长度

```go
make([]T, len)
make([]T, len, cap) // same as make([]T, cap)[:len]
```

### 使用内置 append 函数给Slice追加元素

1. 先检查Slice长度是否小于容量，是，则说明可以直接追加一个元素；否，则新建一个容量更大的底层数组，再复制原Slice的元素到此底层数组中。

```go
package main

import "fmt"

func main() {
	array := [...]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

	slice1 := array[7:]
	fmt.Println(slice1)	// {7,8,9}
	pass(slice1)
	fmt.Println(slice1)	// {7,8,9}	
	pass2(&slice1)
	fmt.Println(slice1)	// {7,8,9,10}
	fmt.Println(slice1)	// [77 8 9 10]
	slice1[0] = 77
	fmt.Println(array)	// [0 1 2 3 4 5 6 7 8 9]
	
	slice2 := array[1:4]
	pass2(&slice2)
	fmt.Println(slice2)	// [1 2 3 10]
	fmt.Println(array)	// [0 1 2 3 10 5 6 7 8 9]
	slice2[0] = 11
	fmt.Println(array)	[0 11 2 3 10 5 6 7 8 9]
}

func pass(slice []int) {
	slice = append(slice, 10)
	fmt.Println(slice)	// [7 8 9 10]
}

func pass2(slice *[]int) {
	*slice = append(*slice, 10)
	fmt.Println(*slice)	
}
```

2. 使用append时，若增加的变量类型是切片的基础类型时，不用加`...`，它只用于加入基础类型的切片时，才使用。
```go
func main() {
	var array [][]int
	
	row1 := []int {1,2,3}
	row2 := []int {4,5,6}
	array = append(array, row1)
	array = append(array, row2) // 也可直接放一起， append(array, row1, row2)
	
	slice := make([]int, 0)
	slice = append(slice, row1...)
}
```
## Map：哈希表 K/V

```go
var ages map[string]int{}
ages := make(map[string]int) 

ages["alice"] = 31

ages := map[string]int{
    "alice": 31,
    "charlie": 34,
}

delete(ages, "alice") // remove element ages["alice"]

ages["bob"]++
ages["bob"] += 1

for name, age := range ages {
    fmt.Printf("%s\t%d\n", name, age)
}
```

* 但是map中的元素并不是一个变量， 因此我们不能对map的元素进行取址操作! 禁止对map元素取址的原因是map可能随着元素数量的增长而重新分配更大的内存空间， 从而可能导致之前的地址无效。

* Map的迭代顺序是不确定的! 如果要按顺序遍历key/value对， 我们必须显式地对key进行排序， 可以使用sort包的Strings函数对字符串slice进行排序
```go
sort.Strings(names)
for _, name := range names {
    fmt.Printf("%s\t%d\n", name, ages[name])
}
```

* **注意：向一个nil值的map存入元素将导致一个panic异常**
```go
var ages map[string]int
fmt.Println(ages == nil) // "true"
fmt.Println(len(ages) == 0) // "true"
ages["carol"] = 21 // panic: assignment to entry in nil map

var ages = map[string]int{} // 声明空map要加{}
ages["carol"] = 21 // pass
```

* 判断值是否在 map 中 `age, ok := ages["bob"]`

* Go语言中并没有提供一个set类型， 但是map中的key也是不相同的
* Map的value类型也可以是一个聚合类型， 比如是一个map或slice。

## 结构体：结构体指针也可使用 .var 访问变量

* 通常一行对应一个结构体成员， 成员的名字在前类型在后
* 相邻的成员类型如果相同的话可以被合并到一行
```go
type Employee struct {
    ID int
    Name, Address string
}
```
* 如果结构体成员名字是以大写字母开头的， 那么该成员就是导出的（针对包）
* 一个命名为S的结构体类型将不能再包含S类型的成员，但是S类型的结构体可以包含 *S 指针类型的成员
* 结构体初始化
```go
type Point struct{ X, Y int }
p := Point{1, 2}    // 不推荐
p := Point{X:1, Y:2}    // 推荐
```

* 如果结构体的全部成员都是可以比较的， 那么结构体也是可以比较的
* 可比较的结构体类型和其他可比较的类型一样， 可以用于map的key类型。

### 嵌入与匿名成员
* 嵌入：
```go
type Point struct {
    X, Y int
}
type Circle struct {
    Center Point
    Radius int
} 
type Wheel struct {
    Circle Circle
    Spokes int
}

// 访问时比较麻烦
var w Wheel
w.Circle.Center.X = 8
w.Circle.Center.Y = 8
w.Circle.Radius = 5
w.Spokes = 20
```

* 匿名成员

```go
type Circle struct {
    Center Point
    Radius int
} 
type Wheel struct {
    Circle Circle
    Spokes int
}

// 可直接访问，也可通过嵌套的方式访问
var w Wheel
w.X = 8         // equivalent to w.Circle.Point.X = 8
w.Y = 8         // equivalent to w.Circle.Point.Y = 8
w.Radius = 5    // equivalent to w.Circle.Radius = 5
w.Spokes = 20
```

* 不幸的是， 结构体字面值并没有简短表示匿名成员的语法
```go
w = Wheel{Circle{Point{8, 8}, 5}, 20}
w = Wheel{
    Circle: Circle{
        Point: Point{X: 8, Y: 8},
        Radius: 5,
    },
    Spokes: 20, // NOTE: trailing comma necessary here (and at Radius)
}
```

* **匿名成员 更重要的作用是访问他们的方法！**

## JSON

* 将一个Go语言中的结构体slice转为JSON的过程叫编组（ marshaling） 。 编组通过调用json.Marshal函数完成：

* Marshal函数返还一个编码后的字节slice， 包含很长的字符串， 并且没有空白缩进，不利于阅读

* 为了生成便于阅读的格式， 另一个json.MarshalIndent函数将产生整齐缩进的输出

* 默认使用Go语言结构体的成员名字作为JSON的对象
* 只有导出的结构体成员才会被编码
* 编码的逆操作是解码，即将JSON字符串解析到相应的结构体中，通过json.Unmarshal函数完成，解码时只保存结构体中定义的变量

## 文本和HTML模板
text/templat和html/template等模板包提供了将变量值填充到一个文本或HTML格式的模板的机制。


