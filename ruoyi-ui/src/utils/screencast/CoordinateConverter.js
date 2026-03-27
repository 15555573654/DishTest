/**
 * 坐标转换工具类
 * 负责将Web端坐标转换为Android设备坐标
 * 参考scrcpy的坐标转换逻辑
 */

export default class CoordinateConverter {
  constructor() {
    // 设备真实分辨率（从Android端获取）
    this.deviceResolution = null;
    // 视频传输分辨率
    this.videoResolution = null;
    // 设备旋转角度 (0, 90, 180, 270)
    this.rotation = 0;
  }

  /**
   * 设置设备分辨率
   * @param {number} width - 设备宽度
   * @param {number} height - 设备高度
   * @param {number} rotation - 旋转角度
   */
  setDeviceResolution(width, height, rotation = 0) {
    this.deviceResolution = { width, height };
    this.rotation = rotation;
    console.log(`[CoordinateConverter] 设备分辨率: ${width}x${height}, 旋转: ${rotation}°`);
  }

  /**
   * 设置视频传输分辨率
   * @param {number} width - 视频宽度
   * @param {number} height - 视频高度
   */
  setVideoResolution(width, height) {
    this.videoResolution = { width, height };
    console.log(`[CoordinateConverter] 视频分辨率: ${width}x${height}`);
  }

  /**
   * 获取有效的设备分辨率
   * 优先使用设备真实分辨率，其次使用视频分辨率
   */
  getEffectiveResolution() {
    if (this.deviceResolution && this.deviceResolution.width && this.deviceResolution.height) {
      return this.deviceResolution;
    }
    if (this.videoResolution && this.videoResolution.width && this.videoResolution.height) {
      return this.videoResolution;
    }
    return null;
  }

  /**
   * 将Web端坐标转换为设备坐标
   * @param {number} clientX - 鼠标/触摸的X坐标（相对于页面）
   * @param {number} clientY - 鼠标/触摸的Y坐标（相对于页面）
   * @param {HTMLVideoElement} videoElement - 视频元素
   * @returns {{x: number, y: number, resolution: {width: number, height: number}} | null}
   */
  convertToDeviceCoordinates(clientX, clientY, videoElement) {
    if (!videoElement) {
      console.error('[CoordinateConverter] 视频元素不存在');
      return null;
    }

    const resolution = this.getEffectiveResolution();
    if (!resolution) {
      console.error('[CoordinateConverter] 设备分辨率未设置');
      return null;
    }

    // 1. 获取视频元素的显示区域
    const rect = videoElement.getBoundingClientRect();
    
    // 2. 计算相对于视频元素的坐标
    const relativeX = clientX - rect.left;
    const relativeY = clientY - rect.top;

    // 3. 检查坐标是否在视频区域内
    if (relativeX < 0 || relativeY < 0 || relativeX > rect.width || relativeY > rect.height) {
      console.warn('[CoordinateConverter] 坐标超出视频区域');
      return null;
    }

    // 4. 获取视频的实际显示尺寸（考虑object-fit: contain）
    const videoDisplaySize = this.getVideoDisplaySize(videoElement);
    
    // 5. 计算视频内容区域的偏移（黑边）
    const offsetX = (rect.width - videoDisplaySize.width) / 2;
    const offsetY = (rect.height - videoDisplaySize.height) / 2;

    // 6. 计算相对于视频内容的坐标
    const videoContentX = relativeX - offsetX;
    const videoContentY = relativeY - offsetY;

    // 7. 检查是否在视频内容区域内（排除黑边）
    if (videoContentX < 0 || videoContentY < 0 || 
        videoContentX > videoDisplaySize.width || 
        videoContentY > videoDisplaySize.height) {
      console.warn('[CoordinateConverter] 点击在黑边区域');
      return null;
    }

    // 8. 计算归一化坐标 (0-1)
    const normalizedX = videoContentX / videoDisplaySize.width;
    const normalizedY = videoContentY / videoDisplaySize.height;

    // 9. 转换为设备坐标
    let deviceX = Math.round(normalizedX * resolution.width);
    let deviceY = Math.round(normalizedY * resolution.height);

    // 10. 处理设备旋转
    if (this.rotation !== 0) {
      const rotated = this.applyRotation(deviceX, deviceY, resolution);
      deviceX = rotated.x;
      deviceY = rotated.y;
    }

    // 11. 确保坐标在有效范围内
    deviceX = Math.max(0, Math.min(deviceX, resolution.width - 1));
    deviceY = Math.max(0, Math.min(deviceY, resolution.height - 1));

    return {
      x: deviceX,
      y: deviceY,
      resolution: {
        width: resolution.width,
        height: resolution.height
      }
    };
  }

  /**
   * 获取视频的实际显示尺寸（考虑object-fit: contain）
   * @param {HTMLVideoElement} videoElement
   * @returns {{width: number, height: number}}
   */
  getVideoDisplaySize(videoElement) {
    const rect = videoElement.getBoundingClientRect();
    const videoWidth = videoElement.videoWidth || rect.width;
    const videoHeight = videoElement.videoHeight || rect.height;

    if (videoWidth === 0 || videoHeight === 0) {
      return { width: rect.width, height: rect.height };
    }

    // 计算视频的宽高比
    const videoAspectRatio = videoWidth / videoHeight;
    const containerAspectRatio = rect.width / rect.height;

    let displayWidth, displayHeight;

    if (videoAspectRatio > containerAspectRatio) {
      // 视频更宽，以宽度为准
      displayWidth = rect.width;
      displayHeight = rect.width / videoAspectRatio;
    } else {
      // 视频更高，以高度为准
      displayHeight = rect.height;
      displayWidth = rect.height * videoAspectRatio;
    }

    return {
      width: displayWidth,
      height: displayHeight
    };
  }

  /**
   * 应用旋转变换
   * @param {number} x - 原始X坐标
   * @param {number} y - 原始Y坐标
   * @param {{width: number, height: number}} resolution - 分辨率
   * @returns {{x: number, y: number}}
   */
  applyRotation(x, y, resolution) {
    switch (this.rotation) {
      case 90:
        return {
          x: y,
          y: resolution.width - x
        };
      case 180:
        return {
          x: resolution.width - x,
          y: resolution.height - y
        };
      case 270:
        return {
          x: resolution.height - y,
          y: x
        };
      default:
        return { x, y };
    }
  }

  /**
   * 批量转换坐标（用于滑动路径）
   * @param {Array<{x: number, y: number}>} points - 坐标点数组
   * @param {HTMLVideoElement} videoElement - 视频元素
   * @returns {Array<{x: number, y: number}>}
   */
  convertMultiplePoints(points, videoElement) {
    return points
      .map(point => this.convertToDeviceCoordinates(point.x, point.y, videoElement))
      .filter(point => point !== null);
  }

  /**
   * 计算两点之间的距离
   * @param {{x: number, y: number}} point1
   * @param {{x: number, y: number}} point2
   * @returns {number}
   */
  static calculateDistance(point1, point2) {
    const dx = point2.x - point1.x;
    const dy = point2.y - point1.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  /**
   * 判断是否为有效的滑动距离
   * @param {{x: number, y: number}} start
   * @param {{x: number, y: number}} end
   * @param {number} threshold - 最小滑动距离阈值（像素）
   * @returns {boolean}
   */
  static isValidSwipe(start, end, threshold = 10) {
    return CoordinateConverter.calculateDistance(start, end) >= threshold;
  }

  /**
   * 重置所有配置
   */
  reset() {
    this.deviceResolution = null;
    this.videoResolution = null;
    this.rotation = 0;
    console.log('[CoordinateConverter] 已重置');
  }
}
