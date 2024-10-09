# 探索linux系统的引导及启动过程

## 写在前面

近来由于安装openEuler 22的系统，但是从kernel 5.1开始sd设备在sys总线上的注册也[变成异步](https://github.com/torvalds/linux/blob/f883675bf6522b52cd75dc3de791680375961769/drivers/scsi/sd.c#L610)的了,
导致在服务器在上多块磁盘时且是静默的情况下会出现os安装在不期望的磁盘上，但是你可以尝试修改将[异步改为同步](https://gitee.com/openeuler/community/issues/I66HWX)，但是今天我们提供另外一个解决方案。

## 另一个方案

通过openEuler20的低版本的kernel系统来引导安装OpenEulre22的OS

## 总结

POST加电自检-->BIOS(Boot Sequence)-->加载对应引导上的MBR(bootloader)-->主引导设置加载其BootLoader-->Kernel初始化-->initrd—>/etc/init进程加载/etc/inittab

1. 加载 BIOS 的硬件信息与硬件自检，并依据设置取得第一个可启动的设备；
2. 读取并执行第一个启动设备内的MBR的 boot loader；
3. 依据 boot loader 的设置加载内核，内核会开始检测硬件与加载驱动程序；
4. 在内核 Kernel 加载完毕后，Kernel 会主动调用 init 进程，而 init 会取得 run-level 信息；
5. init 执行 rc.sysinit 初始化系统的操作环境（网络、时区等）；
6. init 启动 run-level 的各个服务；
7. 用户登录

> 要注意init 虽然只用了一个模块展现出来，但其实在启动过程中 __init__ 占了很大的比重。
> 下面重点阐述下内核引导及init启动的阶段

### 内核引导阶段

```sh
3.1 /boot/kernel and Kernel parameter 
    内核初始化，加载基本的硬件驱动
3.2 /boot/initrd
    引导 initrd 解压载入
    3.2.1 阶段一：在内存中释放供 kernel 使用的 root filesystem
        执行 initrd 文件系统中的 init，完成加载其他驱动模块
    3.2.2 阶段二：执行真正的根文件系统中的 /sbin/init 进程
```

### Sys V init 初始化阶段

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
3. [Linux 的启动流程](https://www.ruanyifeng.com/blog/2013/08/linux_boot_process.html)
4. [Linux基础：启动流程](https://wuchong.me/blog/2014/07/14/linux-boot-process/)

## 待办

1. 当前对于这块很是有很多的盲区，对于systemd / rootfs 是如果通过引导系统`systemd`调整根分区系统`initrd.img`实现os的安装的, 以及安装后与grub2.cfg配置的关系等？
2. Custom Linux ISO
