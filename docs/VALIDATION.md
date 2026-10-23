# 验证记录

验证日期：2026-10-23（Asia/Tokyo）。

## 环境

- macOS 26.5.2 / Xcode 26.0.1。
- Flutter 3.41.6 / Dart 3.11.4。
- iPhone 16e / iOS 26.0，独立模拟器名称 `Elexto QA`。
- 原生截图尺寸 1170 × 2532，共 76 张（38 个检查点 × 两套主题）。

## 已通过

| 检查 | 结果 |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 8 项单元及 Widget 测试全部通过 |
| iPhone 模拟器集成测试 | 深色、浅色完整流程均通过 |
| 原生音频验证 | 播放状态为 true、实际进度大于 0、无播放器错误 |
| 本地音乐库 | 收藏、加入歌单、离线预览标记、关注、复制歌单通过 |
| 主题与布局 | 主要路由深浅主题无布局异常，320 × 568 小屏关键路由通过 |
| 均衡器回归 | 编辑值不受播放状态通知重置，保存后可恢复 |
| iOS simulator debug 构建 | 成功 |
| Web release 构建 | 成功 |
| Android debug 构建 | 成功 |
| Android release 分架构构建 | ARMv7 / ARM64 / x86_64 均成功 |
| Markdown 图片及本地链接 | 全部指向现有文件 |
| Pixso 临时资源链接 | 运行代码中不存在 |

模拟器完整日志见 [simulator-test.log](simulator-test.log)。截图见 [SCREENSHOTS.md](SCREENSHOTS.md)。

## Android 安装包

建议普通 ARM64 Android 手机使用：

[app-arm64-v8a-release.apk](../build/app/outputs/flutter-apk/app-arm64-v8a-release.apk)

- 版本：1.0.0+1。
- 文件大小：26.0 MiB。
- SHA-256：`c8993b8e3372205b1f14caf157fee31d8cf612b237c9d0dada7324ee687786ce`。
- 使用 Flutter 工程的本地调试签名，适合安装演示；商店发布需配置正式签名。

Android 已验证编译与打包；本次实际交互与截图验证在 iOS 模拟器完成。

## 演示能力边界

认证、短信、远程下载、视频流、真实歌词/评论与硬件均衡器未对接外部服务。当前版本提供本地交互、原创短音频播放、视频海报音频预览及均衡器参数存储。详见 [README](../README.md)。
