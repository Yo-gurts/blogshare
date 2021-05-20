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

```

