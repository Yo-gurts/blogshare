# 1. [JZ5](https://www.nowcoder.com/practice/54275ddae22f475981afa2244dd448c6) 用两个栈实现队列

解1：golang中没有专门的栈结构，栈和队列都是直接通过`slice`实现，所以，这里直接实现的队列....

```go
func Push(node int) {
    stack1 = append(stack1, node)
}

func Pop() int{
    val := stack1[0]
    stack1 = stack1[1:]
    return val
}
```

# 2. [JZ9](https://www.nowcoder.com/practice/22243d016f6b47f2a6928b4313c85387) 跳台阶扩展问题

解1：此题容易想到动态规划求解，若青蛙一次只能跳1阶或2阶，则 `D(n)=D(n-1)+D(n-2)`，但这里青蛙一次最多可跳`n`阶，故$D(n) = \sum_{i=1..n} D(n-i)$，代入`D(1)=1, D(2)=2, D(3)=1+2+1=4, D(4)=1+2+4+1=8, ..., D(n)=2^(n-1)`。注意这里的`(number-1)`括号不能省！

```go
func jumpFloorII( number int ) int {
    // write code here
    return 1 << (number-1)
}
```

# 3. [JZ20](https://www.nowcoder.com/practice/4c776177d2c04c2494f2555c9fcc1e49) 包含`min`的栈

解1：使用辅助栈

![ ](../images/JZoffer_5-others/284295_1587290406796_0EDB8C9599BA026855B6DCCC1D5EDAE5)

```go
package main

var vmin []int
var stack []int

func Push(node int) {
    stack = append(stack, node)
    if len(vmin) == 0 || node <= vmin[len(vmin)-1] {
        vmin = append(vmin, node)
    } else {
        vmin = append(vmin, vmin[len(vmin)-1])
    }
}

func Pop() {
    stack = stack[0:len(stack)-1]
    vmin = vmin[0:len(vmin)-1]
}

func Top() int {
    return stack[len(stack)-1]
}
func Min() int {
    return vmin[len(vmin)-1]
}
```

解2：对辅助栈的空间开销还可以进行些许优化，stack: 4 2 2 3, vmin: 4 2 2; 3比最小值大，所以不需要push到vmin

```go
func Push(node int) {
    stack = append(stack, node)
    if len(vmin) == 0 || node <= vmin[len(vmin)-1] {
        vmin = append(vmin, node)
    }
}

func Pop() {
    top := stack[len(stack)-1]
    stack = stack[0:len(stack)-1]
    if top == vmin[len(vmin)-1] {
        vmin = vmin[0:len(vmin)-1]
    }
}

func Top() int {
    return stack[len(stack)-1]
}
func Min() int {
    return vmin[len(vmin)-1]
}
```

# 4. [JZ21](https://www.nowcoder.com/practice/d77d11405cc7470d82554cb392585106) 栈的压入、弹出序列

解1：

```go
func IsPopOrder( pushV []int ,  popV []int ) bool {
    var stack []int
    i := 0
    for _, v := range pushV {
        stack = append(stack, v)
        for len(stack) > 0 && popV[i] == stack[len(stack)-1] {
            stack = stack[0:len(stack)-1]
            i++
        }
    }
    return len(stack) == 0 
}
```

# [JZ31](https://www.nowcoder.com/practice/bd7f978302044eee894445e244c7eee6) 整数中1出现的次数

解1：[ref](https://leetcode-cn.com/problems/1nzheng-shu-zhong-1chu-xian-de-ci-shu-lcof/solution/mian-shi-ti-43-1n-zheng-shu-zhong-1-chu-xian-de-2/)

```go
func NumberOf1Between1AndN_Solution( n int ) int {
    digit, res := 1, 0
    high, cur, low := n/10, n%10, 0
    for high !=0 || cur != 0 {
        if cur == 0 {
            res += high * digit
        } else if cur == 1 {
            res += high * digit + low + 1
        } else {
            res += (high + 1) * digit
        }
        low += cur * digit
        cur = high % 10
        high = high / 10
        digit = digit * 10
    }
    return res
}
```

解2：没看懂

```go
func NumberOf1Between1AndN_Solution( n int ) int {
    cnt := 0
    for m := 1; m <= n; m *= 10 {
        a, b := n/m, n%m
        if a%10 == 0 {
            cnt += a / 10 * m
        } else if a%10 == 1 {
            cnt += a/10*m + b + 1
        } else {
            cnt += (a/10 + 1) * m
        }
    }
 
    return cnt
}
```


# [JZ40](https://www.nowcoder.com/practice/389fc1c3d3be4479a154f63f495abff8) 数组中只出现一次的两个数字

解1：先统计数字的出现次数，在遍历mp，找出仅出现依次的数字！由于golang中对map的遍历随机的，所以最后需要检查res是否为从小到大。

```go
func FindNumsAppearOnce( array []int ) []int {
    mp := make(map[int]int, 0)
    for _, v := range array {
        mp[v] += 1
    }
    res := make([]int, 0, 2)
    for k, v := range mp {
        if v == 1 {
            res = append(res, k)
        }
    }
    if res[0] > res[1] {
        res[0], res[1] = res[1], res[0]
    }
    return res
}
```

# [JZ47](https://www.nowcoder.com/practice/7a0da8fc483247ff8800059e12d7caf1) 求1+2+3+...+n

解1：

```go
func Sum_Solution( n int ) int {
    // write code here
    var s int
    var sum func(n int) bool
    sum = func(n int) bool {
        s += n
        return n > 0 && sum(n-1)
    }
    sum(n)
    return s
}
```

# [JZ41](https://www.nowcoder.com/practice/c451a3fd84b64cb19485dad758a55ebe) 和为S的连续正数序列

解1：由于序列至少要有2个数，所以sum=1,2直接排除，且遍历时只需要到`sum/2`即可！

```go
func FindContinuousSequence( sum int ) [][]int {
    res := make([][]int, 0)
    if sum <= 2 {
        return res
    }
    tsum := 0
    tmp := make([]int, 0)
    for i := 1; i <= sum/2 + 1; i++ {
        tmp = append(tmp, i)
        tsum += i
        for tsum > sum { // 如果大于sum，则必须去掉头部的数，使得 <= sum
            tsum -= tmp[0]
            tmp = tmp[1:]
        }
        if tsum == sum {
            res = append(res, tmp)
            next := i+1
            for next > 0 { // 至少减去下一个数的大小，才能保证
                next -= tmp[0]
                tsum -= tmp[0]
                tmp = tmp[1:]
            }
        }
    }
    return res
}
```

解2：别人的写法，和上面原理类似，注意这里并不是每个for循环都进行了`i++`

```go
func FindContinuousSequence( sum int ) [][]int {
    // write code here
    if sum <= 0 {
        return [][]int{{0}}
    }
    res := make([][]int,0)
    win := make([]int,0)
    temp := 0
    for i:=1;i<=sum/2; {
        if temp < sum {
            temp += i
            win = append(win, i)
            i++
        }else if temp > sum {
            temp-=win[0]
            win = win[1:]
        }else {
            res = append(res, win)
            temp -= win[0]
            win = win[1:]
        }
    }
    return res
}
```

解3：解1中的第二个循环和第一个循环实质上是一样的作用，所以去掉也是正常的，显得更简洁

```go
func FindContinuousSequence( sum int ) [][]int {
    res := make([][]int, 0)
    if sum <= 2 {
        return res
    }
    tsum := 0
    tmp := make([]int, 0)
    for i := 1; i <= sum/2 + 1; i++ {
        tmp = append(tmp, i)
        tsum += i
        for tsum > sum { // 如果大于sum，则必须去掉头部的数，使得 <= sum
            tsum -= tmp[0]
            tmp = tmp[1:]
        }
        if tsum == sum {
            res = append(res, tmp)
        }
    }
    return res
}
```

# [JZ45](https://www.nowcoder.com/practice/762836f4d43d43ca9deb273b3de8e1f4) 扑克牌顺子

解1：找规律，首先，非0数不能重复，其次，要满足连续的话，非0数的最大最小之差<=4（1，2， 0，0，0）

```go
import "sort"
func IsContinuous( numbers []int ) bool {
    tmp := make([]int, 0, 5)
    for _, v := range numbers {
        if v != 0 {
            tmp = append(tmp, v)
        }
    }
    tlen := len(tmp)
    if tlen == 1 {
        return true
    } else {
        sort.Ints(tmp)
        for i := 0; i < tlen-1; i++ {
            if tmp[i] == tmp[i+1] {
                return false
            }
        }
        if tmp[tlen-1] - tmp[0] <= 4 {
            return true
        } else {
            return false
        }
    }
}
```

解2：

```go
func IsContinuous( numbers []int ) bool {
    // write code here
    length := len(numbers)
    if length != 5 {
        return false
    }
    // printArray(numbers)
    sort.Ints(numbers)
    // printArray(numbers)
    count := 0
    for i := 0; i < length-1; i++ {
        if numbers[i] == 0 {
            count++
        } else if numbers[i+1] == numbers[i]{
            return false
        }else{
            count -= numbers[i+1] - numbers[i] - 1
        }
    }
    return count >= 0
}
```

# [JZ64](https://www.nowcoder.com/practice/1624bc35a45c42c0bc17d17fa0cba788) 滑动窗口的最大值

解1：暴力求解

```go
func maxInWindows( num []int ,  size int ) []int {
    if len(num) < size || size == 0 {
        return nil
    }
    res := make([]int, len(num)-size+1, len(num)-size+1)
    var max = func (sub []int) int {
        max := sub[0]
        for _, v := range sub {
            if max < v {
                max = v
            }
        }
        return max
    }
    for i := 0; i <= len(num)-size; i++ {
        res[i] = max(num[i:i+size])
    }
    return res
}
```

