# 使用下方命令可以查看镜像分区信息
fdisk -l filename.img

# 查询下一个可用 loop 设备文件，假设是 /dev/loop0
losetup -f
# 使用 losetup -P 参数挂载 img 文件
losetup -P /dev/loop0 filename.img
lsblk
# 一般会有两个分区，分别为启动分区和文件系统分区
mkdir boot
mkdir rootfs
mount /dev/loop0p1 ./boot/
mount /dev/loop0p2 ./rootfs/
# 现在就可以根据需要修改镜像了，可执行文件别忘了赋权

umount /dev/loop0p1umount /dev/loop0p2losetup -d /dev/loop0
# 重新压缩gzip filename.img

