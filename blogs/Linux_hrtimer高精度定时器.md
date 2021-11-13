# Hrtimer 高精度定时器的使用

关于原理可以参看

*   [**Linux-UNIX系统编程手册（上册）.pdf**](https://github.com/stelectronic/doc/blob/master/Linux-UNIX%E7%B3%BB%E7%BB%9F%E7%BC%96%E7%A8%8B%E6%89%8B%E5%86%8C%EF%BC%88%E4%B8%8A%E5%86%8C%EF%BC%89.pdf)
*   [**Linux-UNIX系统编程手册（下册）.pdf**](https://github.com/stelectronic/doc/blob/master/Linux-UNIX%E7%B3%BB%E7%BB%9F%E7%BC%96%E7%A8%8B%E6%89%8B%E5%86%8C%EF%BC%88%E4%B8%8B%E5%86%8C%EF%BC%89.pdf) 第10章 时间和第23章 定时器与休眠
*   [**深入Linux内核架构**](https://github.com/hongye612430/awesome-programming-books-1/blob/master/linux/%E6%B7%B1%E5%85%A5Linux%E5%86%85%E6%A0%B8%E6%9E%B6%E6%9E%84.pdf) 的第15章 时间管理。

## 测试代码1：

-   `timer.c`

    ```c
    #include <linux/module.h>
    #include <linux/kernel.h>
    #include <linux/hrtimer.h>
    #include <linux/jiffies.h>
    #include <linux/time.h>
    #include <linux/timekeeping.h>
    
    static struct hrtimer timer;	// 定时器
    long long int Num = 0;
    long long int old = 0;	// ns
    long long int now = 0;	// ns	
    
    static enum hrtimer_restart hrtimer_hander(struct hrtimer *timer)
    {
        now = ktime_get_ns();	// 获得当前时间 ns
        ++Num;
        if(Num % 1000 == 0) {	// 每隔 1000 * 10us = 10ms，打印输出，now-old表示定时器10us的精度，ns
            printk(KERN_INFO "Num = %lld, diff = %lld !!", Num, now-old);
        }
        old = now;
        
        hrtimer_forward_now(timer, ns_to_ktime(10000)); // 将定时器到期时间延后10us
        return HRTIMER_RESTART;
    }
    
    static int __init test_init(void)
    {
        printk("---------test start-----------\r\n");
        hrtimer_init(&timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);	// 初始化
        timer.function = hrtimer_hander;	// 设置到期处理函数
        hrtimer_start(&timer, ns_to_ktime(1000000000), HRTIMER_MODE_REL);	// 启动定时器，1s后到期
        return 0;
    }
    
    static void __exit test_exit(void)
    {
        hrtimer_cancel(&timer);	// destroy 定时器
        printk("------------test over---------------\r\n");
    }
    
    module_init(test_init);
    module_exit(test_exit);
    MODULE_LICENSE("GPL");
    ```

    

-   `Makefile`

    ```makefile
    obj-m:=timer.o
    PWD:=$(shell pwd)
    KERNELPATH:=/lib/modules/$(shell uname -r)/build
    all:
    	make -C $(KERNELPATH) M=$(PWD) modules
    clean:
    	make -C $(KERNELPATH) M=$(PWD) clean
    ```

    

1.  `make`

    ```bash
    (base) s@s:test2$ make
    make -C /lib/modules/5.11.0-38-generic/build M=/home/s/Music/test2 modules
    make[1]: Entering directory '/usr/src/linux-headers-5.11.0-38-generic'
      CC [M]  /home/s/Music/test2/timer.o
      MODPOST /home/s/Music/test2/Module.symvers
      CC [M]  /home/s/Music/test2/timer.mod.o
      LD [M]  /home/s/Music/test2/timer.ko
    make[1]: Leaving directory '/usr/src/linux-headers-5.11.0-38-generic'
    (base) s@s:test2$ ls
    Makefile       Module.symvers  timer.dwo  timer.mod    timer.mod.dwo  timer.o
    modules.order  timer.c         timer.ko   timer.mod.c  timer.mod.o
    ```

2.  `sudo insmod timer.ko` 安装module，等几秒钟，然后执行下面的删除命令！

3.  `sudo rmmod timer` 删除module

`printk`的输出是在`/var/log/kern.log`文件中，也可以使用`dmesg`命令查看。

`tail -n 1000 /var/log/kern.log > tmp` 将文件末尾的1000行输出到`tmp`文件，然后就可以使用vim查看文件。

```bash
Nov 11 16:00:40 s kernel: [280625.206689] Num = 1066000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280625.216689] Num = 1067000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.226689] Num = 1068000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280625.236689] Num = 1069000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280625.246689] Num = 1070000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.256689] Num = 1071000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.266690] Num = 1072000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280625.276690] Num = 1073000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.286690] Num = 1074000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.296690] Num = 1075000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.306690] Num = 1076000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.316690] Num = 1077000, diff = 9491 !!
Nov 11 16:00:41 s kernel: [280625.326690] Num = 1078000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280625.336690] Num = 1079000, diff = 9969 !!
Nov 11 16:00:41 s kernel: [280625.346691] Num = 1080000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.356691] Num = 1081000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.366691] Num = 1082000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280625.376691] Num = 1083000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.386691] Num = 1084000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.396691] Num = 1085000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.406692] Num = 1086000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.416692] Num = 1087000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.426702] Num = 1088000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280625.436702] Num = 1089000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280625.446702] Num = 1090000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.456702] Num = 1091000, diff = 9993 !!
Nov 11 16:00:41 s kernel: [280625.466713] Num = 1092000, diff = 9996 !!
Nov 11 16:00:41 s kernel: [280625.476713] Num = 1093000, diff = 10033 !!
Nov 11 16:00:41 s kernel: [280625.486713] Num = 1094000, diff = 9996 !!
Nov 11 16:00:41 s kernel: [280625.496713] Num = 1095000, diff = 9967 !!
Nov 11 16:00:41 s kernel: [280625.506713] Num = 1096000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.516713] Num = 1097000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280625.526714] Num = 1098000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.536714] Num = 1099000, diff = 10004 !!
Nov 11 16:00:41 s kernel: [280625.546714] Num = 1100000, diff = 9995 !!
Nov 11 16:00:41 s kernel: [280625.556714] Num = 1101000, diff = 9969 !!
Nov 11 16:00:41 s kernel: [280625.566714] Num = 1102000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.576714] Num = 1103000, diff = 10014 !!
Nov 11 16:00:41 s kernel: [280625.586714] Num = 1104000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.596714] Num = 1105000, diff = 10005 !!
Nov 11 16:00:41 s kernel: [280625.606715] Num = 1106000, diff = 9974 !!
Nov 11 16:00:41 s kernel: [280625.616715] Num = 1107000, diff = 10005 !!
Nov 11 16:00:41 s kernel: [280625.626715] Num = 1108000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.636715] Num = 1109000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.646715] Num = 1110000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.656715] Num = 1111000, diff = 10020 !!
Nov 11 16:00:41 s kernel: [280625.666715] Num = 1112000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.676716] Num = 1113000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.686716] Num = 1114000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.696716] Num = 1115000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.706716] Num = 1116000, diff = 9961 !!
Nov 11 16:00:41 s kernel: [280625.716716] Num = 1117000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.726716] Num = 1118000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.736716] Num = 1119000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.746717] Num = 1120000, diff = 9996 !!
Nov 11 16:00:41 s kernel: [280625.756717] Num = 1121000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.766717] Num = 1122000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.776717] Num = 1123000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.786717] Num = 1124000, diff = 9996 !!
Nov 11 16:00:41 s kernel: [280625.796717] Num = 1125000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.806717] Num = 1126000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.816718] Num = 1127000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.826718] Num = 1128000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.836718] Num = 1129000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.846718] Num = 1130000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.856718] Num = 1131000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280625.866718] Num = 1132000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.876718] Num = 1133000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.886719] Num = 1134000, diff = 10010 !!
Nov 11 16:00:41 s kernel: [280625.896719] Num = 1135000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.906719] Num = 1136000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.916719] Num = 1137000, diff = 10002 !!
Nov 11 16:00:41 s kernel: [280625.926719] Num = 1138000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280625.936719] Num = 1139000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280625.946720] Num = 1140000, diff = 10044 !!
Nov 11 16:00:41 s kernel: [280625.956720] Num = 1141000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280625.966720] Num = 1142000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.976720] Num = 1143000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280625.986720] Num = 1144000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280625.996720] Num = 1145000, diff = 10041 !!
Nov 11 16:00:41 s kernel: [280626.006721] Num = 1146000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280626.016720] Num = 1147000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280626.026721] Num = 1148000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280626.036721] Num = 1149000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280626.046731] Num = 1150000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280626.056731] Num = 1151000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280626.066731] Num = 1152000, diff = 9976 !!
Nov 11 16:00:41 s kernel: [280626.076731] Num = 1153000, diff = 9999 !!
Nov 11 16:00:41 s kernel: [280626.086732] Num = 1154000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280626.096732] Num = 1155000, diff = 10000 !!
Nov 11 16:00:41 s kernel: [280626.106732] Num = 1156000, diff = 10003 !!
Nov 11 16:00:41 s kernel: [280626.116732] Num = 1157000, diff = 9997 !!
Nov 11 16:00:41 s kernel: [280626.126732] Num = 1158000, diff = 9833 !!
Nov 11 16:00:41 s kernel: [280626.136732] Num = 1159000, diff = 9996 !!
Nov 11 16:00:41 s kernel: [280626.146732] Num = 1160000, diff = 10018 !!
Nov 11 16:00:41 s kernel: [280626.156732] Num = 1161000, diff = 9991 !!
Nov 11 16:00:41 s kernel: [280626.166732] Num = 1162000, diff = 9609 !!
Nov 11 16:00:41 s kernel: [280626.176732] Num = 1163000, diff = 10048 !!
Nov 11 16:00:41 s kernel: [280626.186733] Num = 1164000, diff = 10001 !!
Nov 11 16:00:41 s kernel: [280626.196733] Num = 1165000, diff = 9998 !!
Nov 11 16:00:41 s kernel: [280626.206733] Num = 1166000, diff = 9999 !!
Nov 11 16:00:42 s kernel: [280626.216733] Num = 1167000, diff = 10002 !!
Nov 11 16:00:42 s kernel: [280626.226733] Num = 1168000, diff = 10003 !!
```

大部分误差只有几纳秒，只有个别`diff = 9609 !!`有几百纳秒的误差！

>   在虚拟机中测试时很不稳定，有时可以达到上面的精度，但有时1ms的精度都不行！
>
>   ```bash
>   Nov 11 16:34:19 c kernel: [  138.516417] Num = 1071000, diff = 13356 !!
>   Nov 11 16:34:19 c kernel: [  138.526708] Num = 1072000, diff = 13338 !!
>   Nov 11 16:34:19 c kernel: [  138.537042] Num = 1073000, diff = 13509 !!
>   Nov 11 16:34:19 c kernel: [  138.547284] Num = 1074000, diff = 6498 !!
>   Nov 11 16:34:19 c kernel: [  138.557372] Num = 1075000, diff = 13524 !!
>   Nov 11 16:34:19 c kernel: [  138.567497] Num = 1076000, diff = 13572 !!
>   Nov 11 16:34:19 c kernel: [  138.577542] Num = 1077000, diff = 13365 !!
>   Nov 11 16:34:19 c kernel: [  138.587577] Num = 1078000, diff = 13567 !!
>   Nov 11 16:34:19 c kernel: [  138.597652] Num = 1079000, diff = 13629 !!
>   Nov 11 16:34:19 c kernel: [  138.607844] Num = 1080000, diff = 6679 !!
>   Nov 11 16:34:19 c kernel: [  138.617898] Num = 1081000, diff = 6456 !!
>   Nov 11 16:34:19 c kernel: [  138.628037] Num = 1082000, diff = 13435 !!
>   Nov 11 16:34:19 c kernel: [  138.638092] Num = 1083000, diff = 13568 !!
>   Nov 11 16:34:19 c kernel: [  138.651904] Num = 1084000, diff = 8806 !!
>   Nov 11 16:34:19 c kernel: [  138.662006] Num = 1085000, diff = 6389 !!
>   Nov 11 16:34:19 c kernel: [  138.672065] Num = 1086000, diff = 13645 !!
>   Nov 11 16:34:19 c kernel: [  138.682166] Num = 1087000, diff = 6492 !!
>   Nov 11 16:34:19 c kernel: [  138.695009] Num = 1088000, diff = 6426 !!
>   Nov 11 16:34:19 c kernel: [  138.705266] Num = 1089000, diff = 7993 !!
>   Nov 11 16:34:19 c kernel: [  138.706959] ------------test over---------------
>   Nov 11 16:35:03 c kernel: [  182.595769] ---------test start-----------
>   Nov 11 16:35:07 c kernel: [  185.205891] Num = 1000, diff = 6308526 !!
>   Nov 11 16:35:09 c kernel: [  187.075194] Num = 2000, diff = 614712 !!
>   Nov 11 16:35:11 c kernel: [  188.691389] Num = 3000, diff = 98007 !!
>   Nov 11 16:35:12 c kernel: [  190.262311] Num = 4000, diff = 17629 !!
>   Nov 11 16:35:12 c kernel: [  191.212745] Num = 5000, diff = 22993 !!
>   Nov 11 16:35:13 c kernel: [  192.089352] Num = 6000, diff = 11363 !!
>   Nov 11 16:35:13 c kernel: [  192.907548] ------------test over---------------
>   Nov 11 16:37:03 c kernel: [  302.451823] ---------test start-----------
>   Nov 11 16:37:08 c kernel: [  305.007173] Num = 1000, diff = 7886 !!
>   Nov 11 16:37:09 c kernel: [  307.334860] Num = 2000, diff = 47303 !!
>   Nov 11 16:37:11 c kernel: [  308.960930] Num = 3000, diff = 10169 !!
>   Nov 11 16:37:12 c kernel: [  310.416341] Num = 4000, diff = 385 !!
>   Nov 11 16:37:14 c kernel: [  312.011817] Num = 5000, diff = 648777 !!
>   Nov 11 16:37:15 c kernel: [  313.266661] Num = 6000, diff = 26907 !!
>   Nov 11 16:37:15 c kernel: [  314.130837] Num = 7000, diff = 414354 !!
>   Nov 11 16:37:17 c kernel: [  315.100562] Num = 8000, diff = 18292 !!
>   Nov 11 16:37:18 c kernel: [  316.135313] Num = 9000, diff = 703767 !!
>   ```
>
>   第一次运行时，以10us的频率，有几us的误差，但再次运行时，就完全不行了.....

