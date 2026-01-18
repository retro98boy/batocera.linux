# 仓库作用

为自己持有的板子移植Batocera，目前支持的设备：

- BesTV R3300-L

- CAINIAO CNIoT-CORE

- CAINIAO LEMO XIAOC

- DAMO Cockpit8250

- TIANNUO TN3399_V3

- SMART AM40

# Batocera是什么

Batocera是一个基于Linux的开源模拟器游戏系统，rootfs采用Buildroot构建。原项目[地址](https://github.com/batocera-linux/batocera.linux)，原[README](https://github.com/retro98boy/batocera.linux/blob/41/README.orig.md)

Batocera集成了RetroArch和一些独立模拟器如PPSSPP，并且带有EmulationStation模拟器前端，使打开游戏从执行命令变成操作手柄/键盘。同时Batocera还附带Kodi媒体播放器

PS：Batocera镜像只附带几个示例游戏ROM，需要玩家自己导入外部ROM

# 如何编译Batocera

官方提供了基于Dokcer的编译方法，方便在任何Linux发行版上编译，步骤如下

## 构建Docker镜像

```
docker buildx build -t batoceralinux/batocera.linux-build:latest .
```

## 编译

首先下载源码

```
git clone --recursive https://github.com/retro98boy/batocera.linux.git
```

不同平台的编译命令不同，例如RK3399平台只需：

```
make rk3399-source
make rk3399-build
```

具体支持哪些平台可见[此处](https://github.com/batocera-linux/batocera.linux/tree/master/configs)

编译完成后，目标镜像在batocera.linux/output/<平台>/images/batocera/images

# 如何升级Batocera

移植的设备不在官方的设备支持列表内，系统自带的在线升级不可用，但是官方为39及以后的版本提供本地升级方法：

将对应板子的boot.tar.xz文件上传到板子的/userdata/system/upgrade目录（不存在就自行创建），然后在板子的shell执行batocera-upgrade manual即可

# 源码对比

[retro98boy/batocera.linux:master <- batocera-linux/batocera.linux:master](https://github.com/retro98boy/batocera.linux/compare/master...batocera-linux:batocera.linux:master)

[batocera-linux/batocera.linux:master <- retro98boy/batocera.linux:master](https://github.com/batocera-linux/batocera.linux/compare/master...retro98boy:batocera.linux:master)

# 替代

[REG-Linux](https://github.com/REG-Linux/REG-Linux)

[ROCKNIX](https://github.com/ROCKNIX/distribution)
