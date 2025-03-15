# 在 amlogic-s9xxx-armbian 目录下创建文件夹 build/output/images
mkdir -p build/output/images
# 拷贝上面编译好的 Armbian 镜像到 amlogic-s9xxx-armbian/build/output/images 目录里
## Armbian 镜像文件名称中的发行版本号（如：21.11.0）和内核版本号（如：5.15.50）请保留，它将在重构后用作 Armbian 固件的名称
## 进入 amlogic-s9xxx-armbian 根目录，然后运行如下命令即可生成指定 board 的 Armbian 镜像文件

sudo ./rebuild -b s905d -k 6.1.21
