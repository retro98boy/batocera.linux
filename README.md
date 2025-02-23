# 仓库作用

为自己持有的板子移植Batocera，目前支持的设备：

- TIANNUO TN3399_V3

- SMART AM40

# Batocera是什么

Batocera是一个基于Linux的开源模拟器游戏系统，rootfs采用Buildroot构建。原项目[地址](https://github.com/batocera-linux/batocera.linux)，原[README](https://github.com/retro98boy/batocera.linux/blob/41/README.orig.md)

Batocera集成了RetroArch和一些独立模拟器如PPSSPP，并且带有EmulationStation模拟器前端，使打开游戏从执行命令变成操作手柄/键盘。同时Batocera还附带Kodi媒体播放器

PS：Batocera镜像只附带几个示例游戏ROM，需要玩家自己导入外部ROM

# 如何编译Batocera

[这里](https://pan.baidu.com/s/1vD1iyD0hk2TpH0c3WGPV-w?pwd=elp1)打包了编译过程中需要额外下载的源码

官方提供了基于Dokcer的编译方法，方便在任何Linux发行版上编译，步骤如下

## 下载源码

```
cd Desktop
git clone -b 41 --recursive https://github.com/retro98boy/batocera.linux.git

# 将提供的额外源码解压，免去编译过程中再下载
cat dl.tar.zst* | unzstd -T0 -c | tar -xv -C ~/Desktop/batocera.linux
```

## 编译

不同平台的编译命令不同，例如RK3399平台只需：

```
make rk3399-build
```

具体支持哪些平台可见[此处](https://github.com/batocera-linux/batocera.linux/tree/master/configs)

编译完成后，目标镜像在batocera.linux/output/<平台>/images/batocera/images

# 如何升级Batocera

移植的设备不在官方的设备支持列表内，系统自带的在线升级不可用，但是官方为39及以后的版本提供本地升级方法：

将对应板子的boot.tar.xz文件上传到板子的/userdata/system/upgrade目录（不存在就自行创建），然后在板子的shell执行batocera-upgrade manual即可
