# ALAPNSManager

简明扼要的描述功能


## Quick Start

目前都使用cocoapods安装，在Podfile中加入

```
pod "ALAPNSManager" 
```

## Example
通过demo code 展示此pod的主要功能，使用者阅读了demo code应该可以了解pod的大部分功能，API设计应尽量简洁易懂。

``` 
demo code here
```

## 实现原理


## 维护者

alex520biao <alex520biao@163.com>

## License

ALAPNSManager is available under the MIT license. See the LICENSE file for more info.

####已有
1. APNSManager不使用单例,可以创建多实例多处使用
2. 使用KeyPath添加监听项
3. 支持多对多监听关系
4. handleAPNSMsg方法中应该添加回调,将有filter的逐个回调进行处理。

####TODO
1. removeAPNSPattern:observer: 删除observer的所有监听项
2. 监听项需要随observer释放而自释放
3. 封装KeyPath监听管理器，包含rootNode及KeyPath管理接口
4. KeyPath监听管理器所有操作加入队列。rootNode的遍历及其他操作如果放在主线程有可能影响性能。
