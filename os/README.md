# 探索linux系统的引导及启动过程

## 写在前面

近来由于安装openEuler 22的系统，但是从kernel 5.1开始sd设备在sys总线上的注册也[变成异步](https://github.com/torvalds/linux/blob/f883675bf6522b52cd75dc3de791680375961769/drivers/scsi/sd.c#L610)的了,
导致在服务器在上多块磁盘时且是静默的情况下会出现os安装在不期望的磁盘上，但是你可以尝试修改将[异步改为同步](https://gitee.com/openeuler/community/issues/I66HWX)，但是今天我们提供另外一个解决方案。

## 另一个方案

## 总结

POST加电自检-->BIOS(Boot Sequence)-->加载对应引导上的MBR(bootloader)-->主引导设置加载其BootLoader-->Kernel初始化-->initrd—>/etc/init进程加载/etc/inittab


硬件的初始化，图像界面启动的初始化（如果设置了默认启动基本）  

主机RAID的设置初始化，device mapper 及相关的初始化，  

检测根文件系统，以只读方式挂载  

激活udev和selinux  

设置内核参数 /etc/sysctl.conf  

设置系统时钟  

启用交换分区，设置主机名  

加载键盘映射  

激活RAID和LVM逻辑卷  

挂载额外的文件系统 /etc/fstab  

最后根据mingetty程序调用login让用户登录->用户登录（完成系统启动）

### 第一阶段：硬件引导启动阶段

```sh
1.1 POST(Power On Self Test) 加电自检
1.2 BIOS
    1.2.1 初始化硬件
    1.2.2 查找启动介质
        HDD: 查找启动硬盘的第一个扇区（MBR/BootSector）
1.3 MBR
    1.3.1 Bootloader（启动装载程序）
        GRUB
        分区表

```

### 第二阶段：BootLoader 启动引导阶段

```sh
2.1 Stage1
    执行 BootLoader 主程序(位于 MBR 前 446个字节)，它的作用是启动 Stage1.5 或 Stage2
2.2 Stage1.5
    Stage1.5 是桥梁，由于 Stage2 较大，存放在文件系统中，需要 Stage1.5 引导位于文件系统中的 Stage2
2.3 Stage2
    Stage2 是 GRUB 的核心映像
2.4 grub.conf
    Stage2 解析 grub.conf 配置文件，加载内核到内存中
```

### 第三阶段：内核引导阶段

```sh
3.1 /boot/kernel and Kernel parameter 
    内核初始化，加载基本的硬件驱动
3.2 /boot/initrd
    引导 initrd 解压载入
    3.2.1 阶段一：在内存中释放供 kernel 使用的 root filesystem
        执行 initrd 文件系统中的 init，完成加载其他驱动模块
    3.2.2 阶段二：执行真正的根文件系统中的 /sbin/init 进程
```

### 第四阶段：Sys V init 初始化阶段

```sh
4.1 /sbin/init
    4.1.1 /etc/inittab
        init 进程读取 /etc/inittab 文件，确定系统启动的运行级别
    4.1.2 /etc/rc.d/rc.sysinit
        执行系统初始化脚本，对系统进行基本的配置
    4.1.3 /etc/rc.d/rcN.d
        根据先前确定的运行级别启动对应运行级别中的服务
    4.1.4 /etc/rc.d/rc.local
        执行用户自定义的开机启动程序
4.2 登录
    4.2.1 /sbin/mingetty (命令行登录)
        验证通过 执行 /etc/login 
        加载 /etc/profile  ~/.bash_profile  ~/.bash_login  ~/profile
        取得 non-login Shell

    4.2.2 /etc/X11/prefdm (图形界面登录)
        gdm kdm xdm
        Xinit
        加载 ~/.xinitrc  ~/.xserverrc
```

## Reference

1. <https://www.ruanyifeng.com/blog/2013/02/booting.html>
2. <https://blog.51cto.com/chrinux/1192004>

## 待办

1. systemd/ rootfs
