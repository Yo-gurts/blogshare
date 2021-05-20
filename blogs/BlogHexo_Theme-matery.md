---
date: 2019-03-22
author: yogurt
---

# 主题修改————隐藏导航栏
主题作者：[https://blinkfox.github.io/](https://blinkfox.github.io/)

有导航栏也挻好的，不过笔记本上屏幕太小，再加上导航栏又遮住了一部分，所以觉得还是去掉好看一点。

1. 在主题目录下的`source/ccs/my.css`中加入如下内容：

```
header .nav-hidden {
    visibility: hidden;
}
```
也就是对属性`可见性`设为隐藏；

2. 修改`source/js/matery.js`，直接跳到文件末尾，增加两句即可：

```
    /* 回到顶部按钮根据滚动条的位置的显示和隐藏.*/
    let scroll = $(window).scrollTop();
    if (scroll < 100) {
        $nav.addClass('nav-transparent');
        $nav.removeClass('nav-hidden');  /* 增加这一句*/
        $backTop.slideUp(300);
    } else {
        $nav.removeClass('nav-transparent');
        $nav.addClass('nav-hidden');     /* 增加这一句*/
        $backTop.slideDown(300);
    }
```

