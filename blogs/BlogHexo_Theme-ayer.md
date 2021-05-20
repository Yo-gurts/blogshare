> 主题地址:[https://github.com/Shen-Yu/hexo-theme-ayer](https://github.com/Shen-Yu/hexo-theme-ayer)

# 修改主题`_config.yml`
参考作者的主题说明,首先在`_config.yml`里面对基本信息进行修改. 

可选安装的插件有(需要去根目录配置_config.yml):
    * RSS订阅: hexo-generator-feed
    * 搜索: hexo-generator-searchdb
    * 文章置顶: hexo-generator-index-pin-top
    * 文章加密: hexo-blog-encrypt
    * 评论：Valine[一款快速、简洁且高效的无后端评论系统](https://github.com/xCss/Valine)

emmmm, 嗯! 我一个都没装....

# 去除脚标

emmmm, 简单粗暴点, 直接将主题目录下`layout/_partial/footer.ejs`里面的内容全部注释掉......


# 修改文章背景
白色太刺眼了, 看着不舒服!!!!

直接修改主题目录下`source/css/main.css`文件，不要去折腾`source-rsc/`下的那些文件，虽然看起来就是设置这些的 :)  不过事实上可能也是，不过是要通过其他软件如`stylus`等将样式文件转换成css文件，所以直接修改已经生成的css文件就好，而且将`source-rsc`删掉也不影响什么！

使用chrome或者firefox的右键查看元素功能，找到背景颜色，`source/css/main.css`中修改对应颜色即可。

银河白    #FFFFFF    rgb(255, 255, 255)
杏仁黄    #FAF9DE    rgb(250, 249, 222)
秋叶褐    #FFF2E2    rgb(255, 242, 226)
胭脂红    #FDE6E0    rgb(253, 230, 224)
青草绿    #E3EDCD    rgb(227, 237, 205)
海天蓝    #DCE2F1    rgb(220, 226, 241)
葛巾紫    #E9EBFE    rgb(233, 235, 254)
极光灰    #EAEAEF    rgb(234, 234, 239)
缓解眼睛疲劳的rgb(199, 237, 204)

我的背景颜色`rgba(0,84,130,0.3)`

# 使用背景图片
在上面的`background-color`前增加`background-image:url(xxx.jpg);`即可！

此外，将文字颜色改为全黑`#000`更好


