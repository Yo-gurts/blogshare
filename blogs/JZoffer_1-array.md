> [run golang online](https://play.golang.org/)
> [golang api online](https://devdocs.io/go/)
>
> 总结：这一系列的题更多的是找规律？还有就是熟悉基础语法:joy:

# 1. JZ1 二维数组中的查找

* 解1：从数组右上角开始，左边的数都比它小，下面的数都比它大！

```go
func Find( target int,  array [][]int ) bool {
    // write code here
    row, col := 0, len(array[0])-1
    for row < len(array) && col >= 0 {
        if array[row][col] == target {
            return true
        } else if array[row][col] > target {
            col--
        } else {
            row++
        }
    }
    return false
}
```

# 2. JZ7 斐波那契数列

* 解1

```go
func Fibonacci( n int ) int {
    // write code here
    b, c := 0, 1
    if n == 0 {
        return 0
    }
    for ; n > 1; n-- {
        b, c = c, b+c
    }
    return c
}
```

# 3. [JZ13](https://www.nowcoder.com/practice/ef1f53ef31ca408cada5093c8780f44b) 调整数组顺序使奇数位于偶数前面

* 解1：不新建切片，在原切片上面进行修改，过程比较复杂

```go
func reOrderArray( array []int ) []int {
    // write code here
    j := 0
    for i, number := range array {
        if number % 2 == 1 {
            k := i
            for k > j {
                array[k] = array[k-1]
                k--
            }
            array[k] = number
            j++
        }
    }
    return array
}
```

* 解2：新建一个切片，两次遍历原切片，第一次找到奇数，第二次找偶数加入，时间复杂度`O(2n)`

```go
func reOrderArray( array []int ) []int {
    // write code here
    arr := make([]int, len(array))
    i := 0
    for _, v := range array {
        if v % 2 == 1 {    // odd
            arr[i] = v
            i++
        }
    }
    for _, v := range array {
        if v % 2 == 0 {    // even
            arr[i] = v
            i++
        }
    }
    return arr
}
```

* 解3：分别新建偶数、奇数的切片，不确定`append`效率怎么样
  * `append` 注意什么时候使用`...`

```go
func reOrderArray( array []int ) []int {
    // write code here
    odd := make([]int, 0)
    even := make([]int, 0)
    for _, v := range array {
        if v % 2 == 1 {    // odd
            odd = append(odd, v)
        } else {
            even = append(even, v)
        }
    }
    odd = append(odd, even...)
    return odd
}
```

# 4. [JZ19](https://www.nowcoder.com/practice/9b4c81a02cd34f76be2659fa0d54342a) 顺时针打印矩阵

* 解1：递归，每次只打印矩阵最外面一圈的数字，再递归处理内层矩阵（未完成）
  * 二维切片获取行、列数
  * **切片变量是值传递，但表现为引用传递**，当函数中使用`append`，且超出切片的`cap`时，会为切片重新分配空间，此时不会对原切片底层数组进行修改。如下面代码中的`arr`，如不使用切片指针，由于`arr`的地产数组长度为0，调用`dg`函数后，`arr`仍然为0！！！！

```go
func printMatrix( matrix [][]int ) []int {
    // write code here
    arr := make([]int, 0)
    dg(matrix, &arr)
    return arr
}

func dg (matrix [][]int, arr *[]int) {
    row := len(matrix)
    col := len(matrix[0])
    *arr = append(*arr, matrix[0]...)
    for i := 1; i < row-1; i++ {
        *arr = append(*arr, matrix[i][col-1])
    }
//     arr = append(arr, matrix[1:row-1][col-1]...) // not work!
    for i := col-1; i >= 0; i-- {
        *arr = append(*arr, matrix[row-1][i])
    }
    for i := row-2; i > 0; i-- {
        *arr = append(*arr, matrix[i][0])
    }
}
```

* 解2：和上面类似，直接用4个for循环来取值

```go
func printMatrix( matrix [][]int ) []int {
    // write code here
    output := make([]int, 0)
    row := len(matrix)
    col := len(matrix[0])
    totals := row*col    // 总个数
    
    layers := 0    // 层数
    for totals > 0 { 
        
        startN, endN := layers, row-1-layers    // 行
        startM, endM := layers, col-1-layers    // 列
        for i := startM; i <= endM && totals > 0; i++ {    // 上-横
            output = append(output, matrix[startN][i])
            totals--
        }
        for i := startN+1; i <= endN && totals > 0; i++ {    // 右 竖
            output = append(output, matrix[i][endM])
            totals--
        }
        for i := endM-1; i >= startM && totals > 0; i-- {    // 下 横
            output = append(output, matrix[endN][i])
            totals--
        }
        for i := endN-1; i > startN && totals > 0; i-- {    // 左 竖
            output = append(output, matrix[i][startM])
            totals--
        }
        layers++
    }
    return output
}
```

* 解3：取出第一行（从矩阵中删去），逆时针旋转90度！重复~直到没有元素可取！（未完成）

```go
todo...
```

# 5. [JZ28](https://www.nowcoder.com/practice/e8a1b01a2df14cb2b228b30ee6a92163) 数组中出现次数超过一半的数字

* 解1：使用`map`实现
  * `range`遍历`map`时是随机的，且返回为`key, value`

```go
func MoreThanHalfNum_Solution( numbers []int ) int {
    // write code here
    count := make(map[int]int, 0)
    for _, v := range numbers {
        count[v]++
    }
    length := len(numbers)/2
    for k, v := range count {
        if v > length {
            return k
        }
    }
    return 0
}
```

* 解2：没看懂！有点意思

```go
func MoreThanHalfNum_Solution( numbers []int ) int {
    // write code here
    Out:=0
    if len(numbers)==1{
        return numbers[0]
    }
    for i:=1;i<len(numbers);i+=2{
        if numbers[i-1]!=numbers[i]{
            numbers[i]=-1
            numbers[i-1]=-1
        }
        if numbers[i]!=-1{
            Out=numbers[i]
        }
    }
    return Out
}
```

# 6. [JZ32](https://www.nowcoder.com/practice/8fecd3f8ba334add803bf2a06af1b993)  把数组排成最小的数

* 解1：先把数组变为字符串数组，再对字符串从小到大排序，拼接起来就得到最后的值
  * 字符串比较大小
    * "123" < "223"，先比较第一个字母，再依次比较字母（ASCII）
    * "12" < "123"
  * 排序 `"sort"`
  * 数 与 字符串的转换 `"strconv"`

```go
func PrintMinNumber( numbers []int ) string {
    // write code here
    str := make([]string, len(numbers))
    for i, v := range numbers {
        str[i] = strconv.Itoa(v)
    }
    sort.Slice(str, func(i, j int) bool { return str[i] < str[j] })	// 有bug [3, 32] -> 332  [3, 34] -> 334
    return strings.Join(str, "")
}
```

* 解2：

```go
func PrintMinNumber( numbers []int ) string {
    // write code here
    str := make([]string, len(numbers))
    for i, v := range numbers {
        str[i] = strconv.Itoa(v)
    }
    sort.Slice(str, func(i, j int) bool { return str[i] + str[j] < str[j] + str[i] })
    return strings.Join(str, "")
}
```

# 7. [JZ35](https://www.nowcoder.com/practice/96bd6684e04a44eb80e6a68efc0ec6c5) 数组中的逆序对

* 解1：暴力，时间复杂度：$O(\frac{n(n-1)}{2})$

```go
func InversePairs( data []int ) int {
    // write code here
    count := 0
    for i := 0; i < len(data)-1; i++ {
        for j := i+1; j < len(data)-1; j++ {
            if data[i] > data[j] {
                count++
            }
        }
    }
    return count % 1000000007
}
```

* 解2：归并排序思想

```go
todo ...
```

# 8. [JZ37](https://www.nowcoder.com/practice/70610bf967994b22bb1c26f9ae901fa2)  数字在排序数组中出现的次数

* 解1：遍历

```go
func GetNumberOfK( data []int ,  k int ) int {
    // write code here
    count := 0
    for _, v := range data {
        if v == k {
            count++
        } else if v > k {
            break
        }
    }
    return count
}
```

* 解2：二分查找，分别找到该数第一次出现和最后一次出现的位置

```go
func GetNumberOfK( data []int ,  k int ) int {
    // write code here
    first := firstIndex(data, k)
    last := lastIndex(data, k)
    return last - first
}

func firstIndex( data []int, k int ) int {
    
}

func lastIndex( data []int, k int ) int {
    
}
```

# 9. [JZ42](https://www.nowcoder.com/practice/390da4f7a00f44bea7c2f3d19491311b) 和为S的两个数字

* 解1：分别从数组的头部和尾部查找，寻找和为S的数。**第一对满足条件的数就是乘积最小的解！！**
  * 匿名切片的表示方法！`[]int{}`，对了，空切片就是`nil`:smile:

```go
func FindNumbersWithSum( array []int ,  sum int ) []int {
    // write code here
    head, tail := 0, len(array)-1
    for head < tail {
        if array[head] > sum {
            return nil
        }
        
        if array[head] + array[tail] == sum {
            return []int{array[head], array[tail]}
        } else if array[head] + array[tail] < sum {
            head++
        } else {
            tail --
        }
    }
    return nil // or []int{} or make([]int, 0)
}
```

# 10. [JZ50](https://www.nowcoder.com/practice/6fe361ede7e54db1b84adc81d09d8524) 数组中重复的数字

* 解1：使用map统计数字出现的频率，再遍历map，找出频率不为1的数返回。时间、空间复杂度都不理想:cry:

```go
func duplicate( numbers []int ) int {
    // write code here
    count := make(map[int]int)
    lenNumbers := len(numbers)
    for _, v := range numbers {
        if v > lenNumbers - 1 {    // 检查输入是否合法
            return -1
        }
        count[v]++
    }
    for k, v := range count {
        if v > 1 {
            return k
        }
    }
    return -1    // 没有重复数字，输入不合法
}
```

* 解2：在将数加入`map`前，先判断`map`中是否存在该值！！:sun_with_face: 
  * map 查找 `ok`

```go
func duplicate( numbers []int ) int {
    // write code here
    count := make(map[int]int)
    lenNumbers := len(numbers)
    for _, v := range numbers {
        if v > lenNumbers - 1 {    // 检查输入是否合法
            return -1
        }
        if _, ok := count[v]; ok { // 检查数字是否出现过
            return v
        }
        count[v]++
    }
    return -1    // 没有重复数字，输入不合法
}
```

* 解3：不想看了，而且感觉对原切片进行修改不太安全！！意义不大

```go
func duplicate( numbers []int ) int {
    // write code here
    for i:=0;i<len(numbers);i++{
        for numbers[i] != i{
            if numbers[i] == numbers[numbers[i]]{
                return numbers[i]
            }else{
                numbers[i],numbers[numbers[i]] = numbers[numbers[i]],numbers[i]
            }
        }
    }
    return -1
}
```

# 11. [JZ51](https://www.nowcoder.com/practice/94a4d381a68b47b7a8bed86f2975db46) 构建乘积数组

* 解1：暴力，简单粗暴

```go
func multiply( A []int ) []int {
    // write code here
    lenA := len(A)
    B := make([]int, lenA)
    tmp := 1
    for i := 1; i < lenA - 1; i++ {
        tmp *= A[i]
    }
    B[0] = tmp * A[lenA-1]
    B[lenA-1] = tmp * A[0]
    
    for i := 1; i < lenA - 1; i++ {
        B[i] = 1
        for j := 0; j <= i-1; j++ {  	// A[0]***A[i-1]
            B[i] *= A[j]
        }
        for j := i+1; j < lenA; j++ {    // A[i+1]***A[n-1]
            B[i] *= A[j]
        }
        B[i] = B[i]
    }
    return B
}
```

* 解2：如下图，先分别计算出左边和右边的值！右下图确定：

  ```go
  B[i] = left[i] * right[i]
  B[0] = left[0] * right[0] // left[0] = 1
  B[1] = left[1] * right[1] // left[1] = A[0]
  B[n-1] = left[n-1] * right[n-1] // right[n-1] = 1, right[n-2] = A[n-1]
  ```

  ![undefined](http://ww1.sinaimg.cn/large/006xUmvugy1gptycy5xb1j30lu088wf0.jpg)

```go
func multiply( A []int ) []int {
    // write code here
    lenA := len(A)
    left := make([]int, lenA)
    right := make([]int, lenA)
    B := make([]int, lenA)
    
    left[0] = 1
    right[lenA-1] = 1
    
    for i := 0; i < lenA-1; i++ {
        left[i+1] = left[i] * A[i]    // left[1] = A[0]
        right[lenA-2-i] = right[lenA-1-i] * A[lenA-1-i]    // right[n-2] = A[n-1]
    }
    
    for i := 0; i < lenA; i++ {
        B[i] = left[i]*right[i]
    }
    return B
}
```

* 解3：思路和上面一样，但不需要`left, right`！！！:cry:

```go
func multiply( A []int ) []int {
    // write code here
    lenA := len(A)
    B := make([]int, lenA)
    tmp := 1
    for i := 0; i < n; i++ {
        B[i] = tmp
        tmp *= A[i]
    }
    tmp = 1
    for i := n - 1; i >= 0; i-- {
        B[i] *= tmp
        tmp *= A[i]
    }
    return B
}
```

# 12. [JZ66](https://www.nowcoder.com/practice/6e5207314b5241fb83f2329e89fdecc8) 机器人的运动范围

* 解1：暴力暴力！没这么简单:sob: 机器人是从0，0点出发，每次只能移动一格，不能跳过无法进入的格子！所以不能简单遍历所有节点！！
  * BFS 广度优先搜索

```go

```

