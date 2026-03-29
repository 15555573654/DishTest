DishTest投屏 - Android设备端

项目结构：
- app/src/main/java/com/dishtest/screencast/
  - MainActivity.kt - 主界面
  - mqtt/MqttManager.kt - MQTT连接管理
  - webrtc/WebRTCManager.kt - WebRTC连接管理
  - webrtc/AccessibilityHelper.kt - 无障碍辅助类
  - service/ScreenCaptureService.kt - 屏幕捕获前台服务
  - service/AccessibilityControlService.kt - 无障碍控制服务

功能特性：
1. MQTT连接 - 与服务器建立MQTT通信
2. 屏幕投屏 - 使用WebRTC实时传输屏幕画面和音频
3. 远程控制 - 通过无障碍服务实现点击、滑动、返回、Home等操作

使用步骤：
1. 在Android Studio中打开项目
2. 连接Android设备或启动模拟器
3. 点击Run运行应用
4. 填写MQTT服务器信息
5. 点击"连接"建立MQTT连接
6. 点击"开始投屏"授权屏幕捕获
7. 点击"启用无障碍服务"并在设置中启用
8. 在前端页面点击"投屏控制"即可查看和控制设备

注意事项：
- 需要Android 5.0 (API 21)及以上版本
- 首次使用需要授予屏幕录制和无障碍权限
- 确保设备与MQTT服务器在同一网络或可互相访问
