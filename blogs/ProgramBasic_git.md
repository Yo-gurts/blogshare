> [中文版git cheat sheet](https://github.com/flyhigher139/Git-Cheat-Sheet)

# 初始化工作

把所有的Git仓库设置为：

```bash
$ git config --global user.name "wklchris"
$ git config --global user.email "wklchris@hotmail.com"
```

新建文件夹：

```bash
$ mkdir folder_name
$ cd folder_name
```

把这个文件夹设置为版本库：

```bash
$ git init
```

你可以定义一个别名，就能用“git lg”代替“git log”命令：

```bash
$ git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

为了偷懒，我常常使用"st"代替"status"：

```bash
$ git config --global alias.st status
```

# 设置GitHub

设置你的SSH密钥，位于c/Users/Yourname. id\_rsa是私钥，不能泄露出去，id\_rsa.pub是公钥，可以放心地告诉任何人。

```bash
$ ssh-keygen -t rsa -C "wklchris@hotmail.com"
```

之后打开SSH-Agent，复制公钥内容到你的GitHub-Setting-SSH Key-New SSH Key：

```bash
$ eval "$(ssh-agent -s)"
$ clip <~/.ssh/id_rsa.pub
```

# 分支 Branch

创建dev分支并切换过去：

```bash
$ git checkout -b dev 或者 git branch dev
```

要切换分支，使用：

```bash
$ git checkout dev
```

编写完成，要把dev分支合并到主分支，先切换到主分支再merge： 
```bash
$ git checkout master
$ git merge dev
```

最后，删除已合并过的分支用 `-d` 参数，删除未合并过的用 `-D` 参数：

```bash
$ git branch -d dev
$ git branch -D feature-vulcan
```

# 本地提交 Commit

如果你有**不想要提交的文件**，请新建一个“.gitignore”文档，写入：

```bash
# Python:
*.py[cod]
*.so
*.egg
*.egg-info
dist
build
```

其中.py[cod]并不会影响.py文件的推送。末尾的dist和build是文件夹。注意：所有注明的文件类型都不会提交，包括子文件夹中的。

调用status命令查看仓库状态。如果你定义了别名st，可以使用别名：

```bash
$ git status
$ git st 
```

在更改完成后，添加单个文件，或者添加所有文件：

```bash
$ git add filename.py
$ git add .
```

然后就是提交：

```bash
$ git commit -m "What you want ot say"
或者 $ git commit 进入输入说明的文字。输入完成后，按Esc，下方输入:wq!以退出。
```

# 回退

分三种情况：

1. **工作区**：你在工作区（workdir）的修改尚未add到暂存区（stage），现在你想放弃这些修改，回到上一次commit的状态。使用checkout回退：

    ```bash
    $ git checkout <filename>
    $ git checkout .
    ```

    这个操作不会改动你的Stage中的内容。因此你可以在重要节点add，之后回退可以保留这些内容。

2. **暂存区**：你的修改已经add到了stage中，现在你想把stage中的内容清空，但保留这些修改到workdir。

    ```bash
    $ git reset HEAD <filename>
    $ git reset HEAD
    ```

3. **提交记录**：你的修改已经commit了，但是还没有push到远程版本库。有三种情况：

    + **这个提交很蠢，我想再提交一次，用一个新提交取代这个提交。**
      
        ```bash
    $ git commit --amend 
      ```
      
    + **我想回退到某个版本。每向前回退一个版本，就在 `HEAD` 后输入一个 `^` 号。或者输入对应的commit-id.**
    
        ```bash
    $ git revert [HEAD^/commit-id]
        ```

        你可以先用这个命令来查看 `HEAD^` 这个版本具体做了什么：
    
        ```bash
        $ git show HEAD^
        ```
    
    + **我想回退版本，并将末尾的N次commit从记录中去除。**
    
        ```bash
    $ git reset [--soft/--hard/--mixed] [HEAD^/commit-id]
        ```
        
        其中参数的含义是：
        
        + soft：不修改当前的workdir和stage，同时把这几个版本的修改都添加到stage；
        + hard：完全回退到你想回去的时间点，清空该时间点后workdir的修改，并放弃stage的数据。
        + mixed：缺省值，删除你当前stage中的修改，但你回退的这几个版本修改仍存在于workdir中，你可以用add把回退前的修改重新加上。

以上的所有回退方法，即使去除了 `$ git log` 中的记录，也均可以通过 `$ git reflog` 方式查看记录。

# 推送到GitHub

第一次推送项目，需要指定你的远程版本库，比如：

```bash
$ git remote add origin https://github.com/wklchris/github-pushtest.git
```

在以后的本项目推送中，只需把本地内容推送到远端并合并：

```bash
$ git push -u origin master
```

# 标签

你可以打标签给当前提交：

	$ git tag <tag-name>

如果想给之前的版本打标签（commit-id可以通过 `$ git log` 命令查看）：

	$ git tag <tag-name> <commit-id>

用-d参数删除标签：

	$ git tag -d <tag-name>

推送标签到远端（需要先设置远程版本库）：

	$ git push --tags

# 克隆到本地

假设我有一个gitskills的项目：

	$ git clone git@github.com:wklchris/gitskills.git

如果你已有这个项目，但是想把远程的更改下载到本地，并合并本地的文件：

	$ git pull <remote> <branch>

# 一台电脑管理两个`github`账户

前提：假设已经部署好了一个`github`账户，`~/.ssh`文件夹下已经有`config  id_rsa  id_rsa_fyatt  id_rsa_fyatt.pub  id_rsa.pub  known_hosts`这几个文件，`id_rsa.pub`是绑定在当前`github`账户的，由于`id_rsa.pub`在绑定`github`账户时，不能绑定多个账户，所以新建一个`github`账户时，也得重新生成一个`ssh`公钥

> [参考链接](https://www.cnblogs.com/yu-hailong/p/11458782.html)

1. 重新生成`ssh`公钥：` ssh-keygen -t rsa -C 'your_email@example.com' -f ~/.ssh/id_rsa_fyatt`，名字随意

2. 现在`~/.ssh`文件夹下会多出`id_rsa_fyatt  id_rsa_fyatt.pub`，将`id_rsa_fyatt.pub`添加到你新建的`github`账户中

3. 通过`ssh-add`添加密钥至`ssh-agent`中：`ssh-add ~/.ssh/id_rsa_fyatt`

4. 在`~/.ssh`文件夹中新建`config`文件：

   ```yaml
   # first account
   Host github.com
       HostName github.com
       PreferredAuthentications publickey
       IdentityFile ~/.ssh/id_rsa
   
   # second user
   Host github2.com
       HostName github.com
       PreferredAuthentications publickey
       IdentityFile ~/.ssh/id_rsa_fyatt
   ```

5. 测试：`ssh -T git@github.com`,  `ssh -T git@github2.com`

6. 使用时注意修改对应的`url`，

   * 如 `clone` 用户2的仓库：`git clone --depth=1 git@github2.com:fyatt/DeepSpeech.git`
   * 我这使用时，不管`clone`哪个用户的仓库，提交在修改总是默认第一个用户，解决方法如下，在仓库中指定`user`

   ```bash
   git config user.name USERNAME
   git config user.email USERNAME@example.com
   ```

[其他链接](https://stackoverflow.com/questions/3860112/multiple-github-accounts-on-the-same-computer)
