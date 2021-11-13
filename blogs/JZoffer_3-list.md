> [run golang online](https://play.golang.org/)
> [golang api online](https://devdocs.io/go/)

# 1.  [JZ3](https://www.nowcoder.com/practice/d0267f7f55b3412ba93bd35cfa8e8035) 从尾到头打印链表

* 解1：先依次将节点的值保存到一个数组，再倒序遍历该数组，并得到新数组，即为返回值

  ```go
  func printListFromTailToHead( head *ListNode ) []int {
      // write code here
      arr1 := make([]int, 0)
      for ; head != nil; head = head.Next {
          arr1 = append(arr1, head.Val)
      }
      len1 := len(arr1)-1
      arr := make([]int, len(arr1))
      for i, _ := range arr {
          arr[i] = arr1[len1-i]
      }
      return arr
  }
  ```

* 解2：递归

  ```go
  func printListFromTailToHead( head *ListNode ) []int {
      // write code here
      arr := make([]int, 0)
      if head != nil {
          dg(head, &arr)
      }
      return arr
  }
  
  func dg(head *ListNode, arr *[]int) {
      if head.Next != nil {
          dg(head.Next, arr)
      }
      *arr = append(*arr, head.Val)
  }
  ```

* 解3：反转链表

  ```go
  func printListFromTailToHead( head *ListNode ) []int {
      // write code here
      var pre *ListNode = nil
      var tmp *ListNode = nil
      arr := make([]int, 0)
      if head == nil {
          return arr
      }
      
      for head.Next != nil {
          tmp = head.Next
          head.Next = pre
          pre = head
          head = tmp
      }
      head.Next = pre
      
      tmp = head
      for ; tmp != nil; tmp = tmp.Next {
          arr = append(arr, tmp.Val)
      }
      return arr
  }
  ```

# 2. [JZ14](https://www.nowcoder.com/practice/886370fe658f41b498d40fb34ae76ff9) 链表中倒数最后k个结点

* 解1：~~直接反转链表，然后按顺序取k个结点即可~~；题目要求按顺序输出，所以还得反向，或者递归

  ```go
  func FindKthToTail( pHead *ListNode ,  k int ) *ListNode {
      // 反转链表
      var pPre *ListNode = nil
      var pTmp *ListNode = nil
      lenOfList := 0
      for pHead.Next != nil {
          pTmp = pHead.Next
          pHead.Next = pPre
          pPre = pHead
          pHead = pTmp
          lenOfList++
      }
      pHead.Next = pPre
      lenOfList++
      
      if lenOfList < k {
          return nil
      }
      
      pTmp = pHead
      for k>1 {
          pTmp = pTmp.Next
          k--
      }
      pTmp.Next = nil
      return pHead
  }
  ```

* 解2：遍历链表，建立指针数组，时间复杂度为O(n)，空间复杂度O(n)

  ```go
  func FindKthToTail( pHead *ListNode ,  k int ) *ListNode {
      arr := make([]*ListNode, 0)
      length := 0
      for pHead != nil {
          arr = append(arr, pHead)
          pHead = pHead.Next
          length++
      }
      if length < k || k <= 0 {
          return nil
      } else {
          return arr[length-k]
      }
  }
  ```

* 解3：双指针间隔为k，从起始位置移动，到达末尾时结束

  ```go
  func FindKthToTail( pHead *ListNode ,  k int ) *ListNode {
      p, pk := pHead, pHead
      for ; k > 0; k-- {
          if pk == nil {
              return nil
          }
          pk = pk.Next
      }
      
      for pk != nil {
          p = p.Next
          pk = pk.Next
      }
      return p
  }
  ```

# 3. [JZ15](https://www.nowcoder.com/practice/75e878df47f24fdc9dc3e400ec6058ca) 反转链表

* 解1：

```go
func ReverseList( pHead *ListNode ) *ListNode {
    // write code here
    var pTmp *ListNode = nil
    var pPre *ListNode = nil
    
    if pHead == nil {
        return pHead
    }
    
    for pHead.Next != nil {
        pTmp = pHead.Next
        pHead.Next = pPre
        pPre = pHead
        pHead = pTmp
    }
    pHead.Next = pPre
    return pHead
}
```

# 4. [JZ16]() 合并两个排序的链表

解1：头部设置一个空结点（哨兵结点）是处理链表类的常用方法，再依次比较两个链表的值。

```go
func Merge( pHead1 *ListNode ,  pHead2 *ListNode ) *ListNode {
    // write code here
    if pHead1 == nil {
        return pHead2
    }
    if pHead2 == nil {
        return pHead1
    }
    
    var pHead ListNode
    pTail := &pHead
    for pHead1 != nil && pHead2 != nil {
        if pHead1.Val <= pHead2.Val {
            pTail.Next = pHead1
            pTail = pTail.Next
            pHead1 = pHead1.Next
        } else {
            pTail.Next = pHead2
            pTail = pTail.Next
            pHead2 = pHead2.Next
        }
    }
    if pHead1 != nil {
        pTail.Next = pHead1
    } else {
        pTail.Next = pHead2
    }
    
    return pHead.Next
}
```

# 5. [JZ25]() 复杂链表的复制

解1：先遍历链表，复制其基本结构，同时将原结点和clone结点做一个映射！

```go
func Clone( head *RandomListNode ) *RandomListNode {
    //write your code here
    var pHead RandomListNode
    pTail := &pHead
    
    // 原结点 key 和 复制结点 value 的映射
    mp := make(map[*RandomListNode]*RandomListNode)
    
    for p := head; p != nil; p = p.Next {
        node := RandomListNode{Label:p.Label, Next:p.Next, Random:p.Random}
//         node.Label = p.Label
//         node.Next = p.Next
//         node.Random = p.Random
        mp[p] = &node
        pTail.Next = &node
        pTail = pTail.Next
    }
    
    for p := pHead.Next; p != nil; p = p.Next {
        p.Random = mp[p.Random]
    }
    return pHead.Next
}
```

# 6. [JZ36]() 两个链表的第一个公共结点

解1：注意理解题意，结点只有一个Next，所以从第一个公共结点开始，后面都是两个链表的公共部分！先遍历第一个链表，将结点放入一个集合，再遍历另一个链表，检查结点是否在集合中，若在，则此结点是第一个公共结点！！但空间复杂度有点高！

```go
func FindFirstCommonNode( pHead1 *ListNode ,  pHead2 *ListNode ) *ListNode {
    // write code here
    mp := make(map[*ListNode]int)
    
    for p := pHead1; p != nil; p = p.Next {
        mp[p] = 1
    }
    
    for p := pHead2; p != nil; p = p.Next {
        if mp[p] == 1 {
            return p
        }
    }
    return nil
}
```

解2：双指针法，如图所示，`len(A+B) = len(B+A)`，所以直接双指针同时遍历A、B，再比较结点是否相同。注意实现时并不需要额外的空间！

![图片说明](../images/JZoffer_3-list/284295_1587394616610_37C15C411477833D2C2325823D927212)

```go
func FindFirstCommonNode( pHead1 *ListNode ,  pHead2 *ListNode ) *ListNode {
    // write code here
    p1, p2 := pHead1, pHead2
    for p1 != p2 {
        if p1 != nil {
            p1 = p1.Next
        } else {
            p1 = pHead2
        }
        
        if p2 != nil {
            p2 = p2.Next
        } else {
            p2 = pHead1
        }
    }
    return p1
}
```

# 7. [JZ55]() 链表中环的入口结点

解1：双指针，一个慢指针一次前进一步，另一个快指针一次前进两步！若存在环，则快、慢指针一定会在环上相遇，如下图所示，蓝色为慢指针（长度为a），红色为快指针路线（长度为2a），黑色部分为快指针多走的长度a，除去公共部分后，特别标注的部分长度相等！

<img src="../images/JZoffer_3-list/0" alt="img" style="zoom:50%;" />

```go
func EntryNodeOfLoop(pHead *ListNode) *ListNode{
    if pHead == nil {
        return nil
    }
    
    pfast, pslow := pHead, pHead
    for pfast.Next != nil && pfast.Next.Next != nil {
        pslow = pslow.Next
        pfast = pfast.Next.Next    
        if pslow == pfast {
            p1 := pHead
            for p1 != pslow {
                p1 = p1.Next
                pslow = pslow.Next
            }
            return pslow
        }
    }
    return nil
}
```

# 8. [JZ56]() 删除链表中重复的结点

解1：理解题意，重复结点是指值相同的结点，而且此链表已经排好序！可遍历链表，使用哈希表存入重复值，再次遍历链表并删去重复值。注意头结点就重复的情况。

```go
func deleteDuplication( pHead *ListNode ) *ListNode {
    // write code here
    hash := make(map[int]int)
    
    if pHead == nil || pHead.Next == nil {
        return pHead
    }
    
    node := ListNode{Val:9999, Next:pHead}
    
    p2, p1 := &node, node.Next
    // 创建重复值的哈希表
    for p1 != nil {
        if p1.Val == p2.Val {
            hash[p1.Val] = 1
        }
        p2, p1 = p1, p1.Next
    }
    
    p2, p1 = &node, node.Next
    p2.Next = nil
    for p1 != nil {
        if hash[p1.Val] == 0 {  // 不是重复结点
            p2.Next = p1
            p2 = p1
            p1 = p1.Next
            p2.Next = nil 
        } else {
            p1 = p1.Next
        }
    }
    return node.Next
}
```

解2：递归求解！

```go
func deleteDuplication( pHead *ListNode ) *ListNode {
    // write code here
    if pHead == nil || pHead.Next == nil {
        return pHead
    }
    
    if pHead.Val == pHead.Next.Val {
        p := pHead.Next
        for p != nil && pHead.Val == p.Val {
            p = p.Next
        }
        return deleteDuplication(p)
    } else {
        pHead.Next = deleteDuplication(pHead.Next)
        return pHead
    }
}
```

