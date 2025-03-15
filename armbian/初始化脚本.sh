#!/bin/bash

# 1.写入EMMC
lsblk -o NAME,MOUNTPOINT | grep -E 'mmcblk[0-9]p[0-9]' | \
    sed 's/├─//g;s/└─//g' | \
    awk '{print $1}' | \
    xargs -I{} mkfs.ext4 /dev/{}

# 斐讯N1为例，其他设备需要修改101为对应选项
echo -e "101\n1" | (/usr/sbin/armbian-install)

# 2.写入初始化脚本
ROOTFS=$(lsblk -o NAME,MOUNTPOINT | grep -E 'mmcblk[0-9]p2' | \
    sed 's/├─//g;s/└─//g' | \
    awk '{print $1}')

mount /dev/${ROOTFS} /mnt

cat >/mnt/root/init.sh <<'EEE'
#!/bin/bash

#DEL BEGIN
# 1.修改 DNS
cat >/etc/resolv.conf <<'EOF'
nameserver 114.114.114.114
nameserver 119.29.29.29
nameserver 223.5.5.5
EOF

# 2.修改默认SSH端口
sed -i 's/Port 22/Port 60001/g' /etc/ssh/sshd_config
systemctl restart sshd

# 3.删除环境初始化
sed -i '/#DEL BEGIN/,/#DEL END/d' /root/init.sh
#DEL END

# 3.提示信息
clear
echo -e "\033[33mThe system will automatically shut down within 10 seconds\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
echo -e "\033[33mPlease remove the USB flash drive after the system shuts down\033[0m"
sleep 10
poweroff
EEE



