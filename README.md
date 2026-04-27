# 仓库作用

为自己持有的板子移植Batocera，目前支持的设备：

- BesTV R3300-L

- CAINIAO CNIoT-CORE

- CAINIAO LEMO XIAOC

- CAINIAO XiaoYi Pro

- DAMO Cockpit8250

- TIANNUO TN3399_V3

- SMART AM40

- AOC 65T33Z T7 4G Version

- CoreLab TVPro T7 8G Version

# Batocera是什么

Batocera是一个基于Linux的开源模拟器游戏系统，rootfs采用Buildroot构建。集成了RetroArch和一些独立模拟器如PPSSPP，并且带有EmulationStation模拟器前端，使打开游戏从执行命令变成操作手柄/键盘。同时Batocera还附带Kodi媒体播放器

PS：Batocera镜像只附带几个示例游戏ROM，需要玩家自己导入外部ROM和BIOS，BIOS可以在[此处](https://theminicaketv.fr/bios.html)下载

# 如何编译Batocera

官方提供了基于Dokcer的编译方法，方便在任何Linux发行版上编译，步骤如下

## 构建Docker镜像

```
cd docker
docker buildx build -t batoceralinux/batocera.linux-build:latest .
cd ..
touch .ba-docker-image-available
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

# 原README

[![Activity](https://img.shields.io/github/commit-activity/m/batocera-linux/batocera.linux)](https://github.com/batocera-linux/batocera.linux)
[![PR](https://img.shields.io/github/issues-pr-closed/batocera-linux/batocera.linux)](https://github.com/batocera-linux/batocera.linux)
[![Stars](https://img.shields.io/github/stars/batocera-linux?style=social)](https://github.com/batocera-linux/batocera.linux)
[![Forks](https://img.shields.io/github/forks/batocera-linux/batocera.linux?style=social)](https://github.com/batocera-linux/batocera.linux)
[![Website](https://img.shields.io/website?down_color=red&down_message=down&up_color=green&up_message=up&url=https%3A%2F%2Fwww.batocera.org)](https://www.batocera.org)
[![Discord Server](https://img.shields.io/discord/357518249883205632.svg)](https://discord.com/invite/JXhfRTr)\
[![Reddit](https://img.shields.io/reddit/subreddit-subscribers/batocera?style=social)](https://www.reddit.com/r/batocera/)
[![Twitter](https://img.shields.io/twitter/follow/batocera_linux?style=social)](https://twitter.com/batocera_linux/)
[![Youtube](https://img.shields.io/youtube/channel/views/UClFpqHKoXsOIV-GjyZqoZcw?style=social)](https://www.youtube.com/channel/UClFpqHKoXsOIV-GjyZqoZcw/featured)

## :video_game::penguin: Batocera Linux :video_game::penguin:
Batocera Linux is an open-source and completely free retro-gaming distribution that can be copied to a USB stick or an SD card with the aim of turning any computer/nano computer into a gaming console during a game or permanently. Batocera Linux does not require any modification on your computer. It supports [many emulators and game engines](https://www.batocera.org/compatibility.php) out of the box. 

## Get information on the project

 - :globe_with_meridians: Browse our [website](https://batocera.org/) for general information and get access to all the latest downloads
 - :memo: Documentation is available on our [wiki](https://wiki.batocera.org/doku.php) and frequently updated
 - :speech_balloon: Discuss any topic with the community on our [Discord Server](https://discord.gg/ndyUKA5)

## Do you need help with Batocera?

 - :sos: The most effective way is to join our [Discord Server](https://discord.gg/ndyUKA5) and go to the \#help-and-support channel
 - :neckbeard: There is a [Batocera subreddit](https://www.reddit.com/r/batocera/) that is fairly active

## How can you help Batocera?

 - :wrench: If you want to help with development, [we accept PRs](https://makeapullrequest.com/) -- anyone is welcome, we embrace the [Bazaar development principles](https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar)
 - :art: No need to be a developer, you can also [help with translations](https://wiki.batocera.org/help_with_translation), talk about our project on [Youtube](https://www.youtube.com/channel/UClFpqHKoXsOIV-GjyZqoZcw/featured) or [Twitter](https://twitter.com/batocera_linux/), create [themes for EmulationStation](https://wiki.batocera.org/themes)
 - :dollar: If you like Batocera, you can help us with a [Paypal donation](https://www.paypal.com/paypalme/nadenislamarre), it's always appreciated!
 - :bowtie: Finally, you can now proudly rock some offcial [Batocera T-shirts, hoodies and other merch](https://batocera.printify.me/).

## Directory navigation

 - `board` Platform-specific build configuration. This is where to include special patches/configuration files needed to have particular components work on a particular platform. It is instead encouraged to apply patches at the location of the package itself, but this may not always be possible.
 - `buildroot` Buildroot, the tool used to create the final compiled images. For newcomers, you can safely ignore this folder. Compilation instructions can be found [on the wiki](https://wiki.batocera.org/compile_batocera.linux).
 - `configs` Build flags, which define what components will be built with your image depending on your chose architecture. If you're trying to port Batocera to a new architecture (device, platform, new bit mode, etc.) this is the file you'll need to edit. More information on [the build configuration section on the buildroot compiling page](https://wiki.batocera.org/batocera.linux_buildroot_modifications#define_your_configuration).
 - `package` The "meat and potatoes" of Batocera. This is where the majority of emulator data, config generators, core packages, system utilities, etc. all go into. This is the friendliest place to start dev-work for new devs, as most of it is handled by Python and Makefile.
 - `scripts` Various miscellanous scripts that handle aspects external to Batocera, such as the report data sent to the [compatibility page](https://batocera.org/compatibility.php) or info about the Bezel Project.

A cheatsheet of notable files/folders can be found [on the wiki](https://wiki.batocera.org/notable_files).

Built with ❤️

