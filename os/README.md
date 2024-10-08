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

## Reference

1. <https://www.ruanyifeng.com/blog/2013/02/booting.html>
2. <https://blog.51cto.com/chrinux/1192004>

## 待办

1. systemd/ rootfs
