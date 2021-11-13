> [使用`list, slice`作为队列](https://blog.wolfogre.com/posts/slice-queue-vs-list-queue/)

* 二叉树的前序遍历：根左右

  ```go
  func PreOrder(root *TreeNode) {
      if root != nil {
          fmt.Println(root.Val)
          PreOrder(root.Left)
          PreOrder(root.Right)
      }
  }
  func PreOrder(root *TreeNode) {
      if root == nil {
          return
      }
      var stack []*TreeNode
      for stack 
  }
  ```

* 二叉树的中序遍历：左根右

  ```go
  func InOrder(root *TreeNode) {
      if root != nil {
          InOrder(root.Left)
          fmt.Println(root.Val)
          InOrder(root.Right)
      }
  }
  ```

* 二叉树的后序遍历：左右根

  ```go
  func PostOrder(root *TreeNode) {
      if root != nil {
          PostOrder(root.Left)
          PostOrder(root.Right)
          fmt.Println(root.Val)
      }
  }
  ```

  

* 二叉树的层次遍历：

  ```go
  func cenci(root *TreeNode) {
      if root == nil {
          return
      }
      var queue []*TreeNode
      queue = append(queue, root)
      for len(queue) > 0 {
          node := queue[0]
          fmt.Println(node.Val)
          queue = queue[1:]		// 弹出最早入队的元素
          if node.Left != nil {	// 左
              queue = append(queue, node.Left)
          }
          if node.Right != nil {	// 右
              queue = append(queue, node.Right)
          }
      }
  }
  ```


# 1. [JZ4](https://www.nowcoder.com/practice/8a19cbe657394eeaac2f6ea9b0f6fcf6) 重建二叉树

* 解1：前序遍历`pre[0]`是根节点对吧，在中序遍历`vin`中，找到根节点的位置，左右两侧分别是根节点的左右子树！此时`pre[1]`是其左子树的根节点.....
  * 二叉树的前序遍历：根左右
  * 二叉树的中序遍历：左根右
  * 二叉树的后序遍历：左右根

```go
func reConstructBinaryTree( pre []int ,  vin []int ) *TreeNode {
    // write code here
    if len(pre) == 0 {
        return nil
    }
    
    root := &TreeNode{Val: pre[0]}
    index := getIndex(vin, pre[0])
    root.Left = reConstructBinaryTree(pre[1:index+1], vin[:index])
    root.Right = reConstructBinaryTree(pre[index+1:], vin[index+1:])
    return root
}

func getIndex(slice []int, value int) int {
    for i, v := range slice {
        if v == value {
            return i
        }
    }
    return -1
}
```

# 2. [JZ17](https://www.nowcoder.com/practice/6e196c44c7004d15b1610b9afca8bd88) 树的子结构

解1：

```go
func HasSubtree( pRoot1 *TreeNode ,  pRoot2 *TreeNode ) bool {
    // write code here
    if pRoot1 == nil || pRoot2 == nil {
        return false
    }
    return isSub(pRoot1, pRoot2) || HasSubtree(pRoot1.Left, pRoot2) || HasSubtree(pRoot1.Right, pRoot2)
}
 
func isSub( pRoot1 *TreeNode ,  pRoot2 *TreeNode ) bool {
    if pRoot2 == nil {
        return true
    }
    if pRoot1 == nil {
        return false
    }
    return pRoot1.Val == pRoot2.Val && isSub(pRoot1.Left, pRoot2.Left) && isSub(pRoot1.Right, pRoot2.Right)
}
```

# 3. [JZ18](https://www.nowcoder.com/practice/a9d0ecbacef9410ca97463e4a5c83be7) 镜像二叉树

解1：递归实现

```go
func Mirror( pRoot *TreeNode ) *TreeNode {
    // write code here
    if pRoot != nil {
        pRoot.Left, pRoot.Right = pRoot.Right, pRoot.Left
        Mirror(pRoot.Left)
        Mirror(pRoot.Right)
    }
    return pRoot
}
```

# 4. [JZ22](https://www.nowcoder.com/practice/7fe2212963db4790b57431d9ed259701) 从上往下打印二叉树

解1：二叉树的层次遍历......

```go
func PrintFromTopToBottom( root *TreeNode ) []int {
    // write code here
    if root == nil {
        return nil
    }
    queue := [](*TreeNode){root}
    var value []int
    for len(queue) > 0 {
        node := queue[0]
        queue = queue[1:]
        value = append(value, node.Val)
        if node.Left != nil {
            queue = append(queue, node.Left)
        }
        if node.Right != nil {
            queue = append(queue, node.Right)
        }
    }
    return value
}
```

# 5. [JZ23](https://www.nowcoder.com/practice/a861533d45854474ac791d90e447bafd) 二叉搜索树的后序遍历序列

解1：输入序列是二叉树的层次遍历，而且遵循左节点值 < 根节点 < 右节点。根节点位于序列末尾，根据根节点值将序列分为左序列和右序列（按第一个大于根节点值的位置划分），按此种方式划分时，已经确保了左序列的有效性（左序列的值都小于根节点值），而右序列还需要检测是否有值比根节点值小，有的话就不对！

```go
func VerifySquenceOfBST( sequence []int ) bool {
    if len(sequence) == 0 {
        return false
    }
    
    return helper(sequence)
}

func helper(sequence []int) bool {
    cd := len(sequence)
    if cd == 0 {
        return true
    }
    rootVal := sequence[cd-1]
    var i, v int
    for i, v = range sequence {
        if v > rootVal {
            break
        }
    }
    left := sequence[0:i]
    right := sequence[i:cd-1]
    
    for i, v = range right {
        if v < rootVal {
            return false
        }
    }
    return helper(left) && helper(right)
}
```

# 6. [JZ24](https://www.nowcoder.com/practice/b736e784e3e34731af99065031301bca) 二叉树中和为某一值的路径

解1：递归实现

```go
func FindPath( root *TreeNode ,  expectNumber int ) [][]int {
    result := make([][]int, 0)
    res := make([]int, 0)
    helper(root, expectNumber, res, &result)
    return result
}

func helper(root *TreeNode, expectNumber int, res []int, result *[][]int) {
    if root == nil {
        return
    }
    expectNumber -= root.Val
    res = append(res, root.Val)
    if expectNumber == 0 && root.Left == nil && root.Right == nil {
        *result = append(*result, res)
    } else {
        helper(root.Left, expectNumber, res, result)
        helper(root.Right, expectNumber, res, result)
    }
    res = res[:len(res)-1]
}
```

# 7. [JZ26](https://www.nowcoder.com/practice/947f6eb80d944a84850b0538bf0ec3a5) 二叉搜索树与双向链表

解1：由题意可以看出，就是二叉树的中序遍历：左根右！先按中序遍历将各个节点的地址存入一个队列，再依次处理前后顺序关系！`Right: forward, Left: backward`，时间复杂度`O(n)`，空间复杂度`O(n)`！

```go
var queue = make([]*TreeNode, 0)
func Convert( pRootOfTree *TreeNode ) *TreeNode {
    if pRootOfTree == nil {
        return nil
    }
    
    inOrder(pRootOfTree)
    if len(queue) == 1 {
        return queue[0]
    }
    queue[0].Right = queue[1]
    queue[0].Left = nil
    for i := 1; i < len(queue)-1; i++ {
        queue[i].Right = queue[i+1]
        queue[i].Left = queue[i-1]
    }
    queue[len(queue)-1].Left = queue[len(queue)-2]
    queue[len(queue)-1].Right = nil
    return queue[0]
}

func inOrder( pRoot *TreeNode ) {
    if pRoot != nil {
        inOrder(pRoot.Left)
        queue = append(queue, pRoot)
        inOrder(pRoot.Right)
    }
}
```

解2：直接中序遍历，并完成双向链表实现

```go
```

# 8. [JZ38](https://www.nowcoder.com/practice/435fb86331474282a3499955f0a41e8b) 二叉树的深度

解1：

```go
var max int
func TreeDepth( pRoot *TreeNode ) int {
    preOrder(pRoot, 0)
    return max
}

func preOrder( pRoot *TreeNode, depth int) {
    if pRoot != nil {
        depth++     // cur node
        if depth > max {
            max = depth
        }
        preOrder(pRoot.Left, depth)
        preOrder(pRoot.Right, depth)
    }
}
```

解2：

```go
func TreeDepth( pRoot *TreeNode ) int {
    if pRoot == nil {
        return 0
    }
    left := TreeDepth(pRoot.Left)
    right := TreeDepth(pRoot.Right)
    switch left > right {
        case true: return left+1
        default: return right+1
    }
}
```

# 9. [JZ57](https://www.nowcoder.com/practice/9023a0c988684a53960365b889ceaf5e) 二叉树的下一个结点

解1：最直接的方法，先找到根节点，再中序遍历，并建立一个数组将遍历到的节点存放进去，最后查找就行，但这样时间、空间复杂度都比较高！这里的解法是对输入节点的右子树以中序遍历的方式查找，返回第一个非空节点，若不存在，则找其父节点，并判断其本身是否是其父节点的左节点。然后在根据题目中的一些特殊情况进行了处理。

```go
func GetNext(pNode *TreeLinkNode) *TreeLinkNode {
    if p := inOrder(pNode.Right); p != nil {
        return p
    }
    for pNode.Next != nil && pNode.Next.Left != pNode {
        pNode = pNode.Next
    }
    return pNode.Next
}

func inOrder(p *TreeLinkNode) *TreeLinkNode {
    if p != nil {
        if l := inOrder(p.Left); l != nil {
            return l
        }
    }
    return p
}
```

# 10. [JZ58](https://www.nowcoder.com/practice/ff05d44dfdb04e1d83bdbdab320efbcb) 对称的二叉树

解1：对二叉树进行层次遍历，将值存入一个输入，再按照值来判断是否对称！
version1: 对于完全二叉树有效，但非完全二叉树不能确定每一层的节点数量，所以有问题！放弃

```go
func isSymmetrical( pRoot *TreeNode ) bool {
    // write code here
    value := cengci(pRoot)
    value = value[1:]
    for i := 1; len(value) != 0 ; i++ {
        if len(value) < (1<<i) {
            return false
        }
        tmp := value[:(1<<i)]
        for f, l := 0, len(tmp)-1; f < l; {
            if tmp[f] != tmp[l] {
                return false
            }
            f++
            l--
        }
        value = value[(1<<i):]
    }
    return true
}

func cengci( pRoot *TreeNode ) []int {
    value := make([]int, 0)
    queue := make([]*TreeNode, 0)
    queue = append(queue, pRoot)
    for len(queue) > 0 {
        p := queue[0]
        queue = queue[1:]
        if p != nil {
            queue = append(queue, p.Left)
            queue = append(queue, p.Right)
            value = append(value, p.Val)
        } else {
            value = append(value, -1)
        }
    }
    return value
}
```

解2：标准答案

```go
func isSymmetrical( pRoot *TreeNode ) bool {
    return pRoot == nil || jude(pRoot.Left, pRoot.Right)
}

func jude( p1, p2 *TreeNode ) bool {
    if p1 == nil && p2 == nil {
        return true
    } else if p1 == nil || p2 == nil {
        return false
    }
    
//    if p1.Val == p2.Val {
//        return jude(p1.Left, p2.Right) && jude(p1.Right, p2.Left)
//    } else {
//       return false
//    }
    return p1.Val == p2.Val && jude(p1.Left, p2.Right) && jude(p1.Right, p2.Left)
}
```

# 11. [JZ60](https://www.nowcoder.com/practice/445c44d982d04483b04a54f298796288) 把二叉树打印成多行

解1：编译有问题

```go
func Print( pRoot *TreeNode ) [][]int {
    value := make([][]int, 0)
    queue := make([]*TreeNode, 0)
    queue = append(queue, pRoot)
    layerNodes := 1
    for len(queue) > 0 {
        var dealLayers = func (nums int) int {
            subValue := make([]int, 0)
            count := 0
            for _, p := range(queue[:nums]) {
                subValue = append(subValue, p.Val)
                if p.Left != nil {
                    queue = append(queue, p.Left)
                    count++
                }
                if p.Right != nil {
                    queue = append(queue, p.Right)
                    count++
                }
            }
            queue = queue[nums:]
            value = append(value, subValue)
            return count
        }
        layerNodes = dealLayers(layerNodes)
    }
    return value
}
```

# [JZ61](https://www.nowcoder.com/practice/cf7e25aa97c04cc1a68c8f040e71fb84) 序列化二叉树

解1：

