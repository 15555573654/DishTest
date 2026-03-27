/**
 * 设备控制器
 * 负责发送控制命令到Android设备
 * 参考scrcpy的控制协议
 */

export default class DeviceController {
  constructor(mqttClient, username, deviceName) {
    this.mqttClient = mqttClient;
    this.username = username;
    this.deviceName = deviceName;
    this.controlTopic = `control/${username}/${deviceName}`;
  }

  /**
   * 更新配置
   */
  updateConfig(mqttClient, username, deviceName) {
    this.mqttClient = mqttClient;
    this.username = username;
    this.deviceName = deviceName;
    this.controlTopic = `control/${username}/${deviceName}`;
  }

  /**
   * 发送控制命令
   * @param {object} command - 命令对象
   * @param {boolean} requireResponse - 是否需要响应
   * @returns {Promise}
   */
  sendCommand(command, requireResponse = false) {
    return new Promise((resolve, reject) => {
      if (!this.mqttClient || !this.mqttClient.connected) {
        reject(new Error('MQTT未连接'));
        return;
      }

      const message = JSON.stringify({
        ...command,
        deviceName: this.deviceName,
        from: 'frontend',
        timestamp: Date.now()
      });

      this.mqttClient.publish(this.controlTopic, message, { qos: 1 }, (err) => {
        if (err) {
          console.error('发送控制命令失败:', err);
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  /**
   * 点击
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {object} resolution - 分辨率 {width, height}
   */
  async click(x, y, resolution) {
    return this.sendCommand({
      action: 'click',
      x,
      y,
      resolution
    });
  }

  /**
   * 双击
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {object} resolution - 分辨率
   */
  async doubleClick(x, y, resolution) {
    return this.sendCommand({
      action: 'doubleClick',
      x,
      y,
      resolution
    });
  }

  /**
   * 长按
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {object} resolution - 分辨率
   * @param {number} durationMs - 持续时间（毫秒）
   */
  async longPress(x, y, resolution, durationMs = 500) {
    return this.sendCommand({
      action: 'longPress',
      x,
      y,
      resolution,
      durationMs
    });
  }

  /**
   * 触摸按下
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {object} resolution - 分辨率
   */
  async touchDown(x, y, resolution) {
    return this.sendCommand({
      action: 'touchDown',
      x,
      y,
      resolution
    });
  }

  /**
   * 触摸移动
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {object} resolution - 分辨率
   */
  async touchMove(x, y, resolution) {
    return this.sendCommand({
      action: 'touchMove',
      x,
      y,
      resolution
    });
  }

  /**
   * 触摸释放
   * @param {number} x - X坐标（可选）
   * @param {number} y - Y坐标（可选）
   * @param {object} resolution - 分辨率（可选）
   */
  async touchUp(x, y, resolution) {
    return this.sendCommand({
      action: 'touchUp',
      x,
      y,
      resolution
    });
  }

  /**
   * 滑动
   * @param {number} x1 - 起点X
   * @param {number} y1 - 起点Y
   * @param {number} x2 - 终点X
   * @param {number} y2 - 终点Y
   * @param {object} resolution - 分辨率
   * @param {number} durationMs - 持续时间（毫秒）
   */
  async swipe(x1, y1, x2, y2, resolution, durationMs = 300) {
    return this.sendCommand({
      action: 'swipe',
      x1,
      y1,
      x2,
      y2,
      resolution,
      durationMs
    });
  }

  /**
   * 发送虚拟按键
   * @param {string} key - 按键名称 ('back' | 'home' | 'menu')
   */
  async sendVirtualKey(key) {
    return this.sendCommand({
      action: 'virtualKey',
      key
    });
  }

  /**
   * 调整音量
   * @param {string} direction - 方向 ('up' | 'down')
   */
  async adjustVolume(direction) {
    return this.sendCommand({
      action: direction === 'up' ? 'volumeUp' : 'volumeDown'
    });
  }

  /**
   * 旋转屏幕
   */
  async rotateScreen() {
    return this.sendCommand({
      action: 'rotateScreen'
    });
  }

  /**
   * 设置剪贴板
   * @param {string} text - 文本内容
   */
  async setClipboard(text) {
    return this.sendCommand({
      action: 'setClipboard',
      text
    });
  }

  /**
   * 读取剪贴板
   */
  async readClipboard() {
    return this.sendCommand({
      action: 'readClipboard'
    }, true);
  }

  /**
   * 安装应用
   * @param {string} url - APK下载URL
   */
  async installApp(url) {
    return this.sendCommand({
      action: 'installApp',
      url
    });
  }

  /**
   * 设置视频质量
   * @param {object} settings - 质量设置
   */
  async setQuality(settings) {
    return this.sendCommand({
      action: 'setQuality',
      settings
    });
  }

  /**
   * 刷新视频
   */
  async refreshVideo() {
    return this.sendCommand({
      action: 'refresh-video'
    });
  }

  /**
   * 停止捕获
   */
  async stopCapture() {
    return this.sendCommand({
      action: 'stopCapture'
    });
  }

  /**
   * 发送文本
   * @param {string} text - 文本内容
   */
  async sendText(text) {
    return this.sendCommand({
      action: 'sendText',
      text
    });
  }

  /**
   * 发送按键码
   * @param {number} keyCode - Android按键码
   * @param {string} action - 动作 ('down' | 'up')
   */
  async sendKeyCode(keyCode, action = 'down') {
    return this.sendCommand({
      action: 'keyCode',
      keyCode,
      keyAction: action
    });
  }

  /**
   * 滚动
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {number} deltaX - X方向滚动量
   * @param {number} deltaY - Y方向滚动量
   * @param {object} resolution - 分辨率
   */
  async scroll(x, y, deltaX, deltaY, resolution) {
    return this.sendCommand({
      action: 'scroll',
      x,
      y,
      deltaX,
      deltaY,
      resolution
    });
  }
}
