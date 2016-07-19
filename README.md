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

####TODO
1. APNSManager不使用单例,可以创建多实例多处使用
2. APNSManager可以使用多条件添加监听
3. 使用KeyPath添加监听项
4. 支持多对多监听关系
5. handleAPNSMsg方法中应该添加回调,将有filter的逐个回调进行处理。
