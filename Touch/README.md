# Touch

黑屏读心纸牌道具。观众报一张牌，你在全黑屏幕上随手划一下，App 记下这张牌；
遮挡手机顶部一次后，屏幕中央直接出现一张牌背朝上的牌，点一下翻转 —— 就是观众报的那张。

## 运行

```bash
open Touch.xcodeproj
# 选一台 iPhone 模拟器或真机，Cmd + R
```

真机需要先在 Signing & Capabilities 里选自己的开发者账号。

## 结构

```
Touch/
  TouchApp.swift            入口
  Models/Card.swift         牌、花色、5×3 网格映射
  Flow/AppModel.swift       状态机 + 遮挡解锁
  System/ProximitySensor.swift  距离传感器封装
  Views/RootView.swift      阶段路由 + 牌面舞台
  Views/Stages.swift        待机、黑屏选牌、锁定
  Views/CardViews.swift     牌面（点位排布）与牌背
  Assets.xcassets/          App 图标
  LaunchScreen.storyboard   纯黑启动屏
  Views/FlipCardView.swift  3D 翻牌
  Views/TutorialView.swift  教学页与屏幕分区图
TouchUITests/               完整链路 UI 测试
docs/superpowers/specs/     设计文档
shots/                      截图与演示录屏
```

## 测试

```bash
xcodebuild -project Touch.xcodeproj -scheme Touch \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -parallel-testing-enabled NO test
```

## 调试

- 模拟器没有距离传感器：`locked` 状态下长按屏幕 1.6s 模拟「手挡顶部」。
- 直接跳到某个状态截图：`-demoPhase idle|arming|scratch|back|face`。
## 装到自己的 iPhone

```bash
./scripts/install-to-iphone.sh
```

需要先做一次：Xcode 登录 Apple ID、手机连线信任、手机打开「开发者模式」。
免费 Apple ID 签的 app 有效期 7 天，到期重跑脚本。
