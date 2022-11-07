# New Settings with xmonad-contrib version 0.71

xmonad-contrib最近更新到了0.71版本，带来了很实用的功能swallow，可以让GUI程序在终端启动时，使用终端的窗口，而不用开启新的窗口。



## 配置的一些优化

### 修复了之前移动窗口到master后切换窗口按键失效的问题

是因为我之前重新自定义了mod+j/k 导致的


### 终于过滤掉了NSP workspace

之前只过滤掉了alt+tab切换最近的workspace时的NSP，现在使用NSP后，普通切换workspace也可以过滤掉NSP workspace


### 可以直接切换workspace的layout

使用jump to layout的功能，直接跳转layout，非常实用，以前无法实现的因为不知道layout的名称，现在才知道需要开启xmobar layout显示的选项后，才能获取到


### 重新优化脚本，带来了实用的dmenu功能

重新写了需要使用到的脚本，而且充分利用了dmenu的功能，实现了快速翻译、启动kvm image、屏幕显示旋转、快速进行浏览器搜索的功能


### 简化配置

将配置拆分，更加模块化显示，重新添加注释，删除不必要的功能
