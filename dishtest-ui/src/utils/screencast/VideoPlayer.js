/**
 * 视频播放管理器
 * 负责视频流的播放、低延迟优化和缓冲管理
 * 参考scrcpy的视频播放优化策略
 */

export default class VideoPlayer {
  constructor(videoElement, options = {}) {
    this.videoElement = videoElement;
    
    // 配置参数
    this.config = {
      enableLowLatency: options.enableLowLatency !== false,  // 启用低延迟模式
      maxBufferSize: options.maxBufferSize || 0.5,           // 最大缓冲大小（秒）
      targetLatency: options.targetLatency || 0.1,           // 目标延迟（秒）
      latencyCheckInterval: options.latencyCheckInterval || 1000,  // 延迟检查间隔（毫秒）
      enableLogging: options.enableLogging || false          // 是否启用日志
    };

    // 播放状态
    this.state = {
      isPlaying: false,
      isPaused: false,
      currentStream: null,
      pendingStreamId: null
    };

    // 定时器
    this.latencyCheckTimer = null;

    // 事件监听器
    this.eventListeners = new Map();

    // 回调函数
    this.onPlay = null;
    this.onPause = null;
    this.onEnded = null;
    this.onError = null;
    this.onBuffering = null;
  }

  /**
   * 设置视频流
   */
  async setStream(stream) {
    if (!this.videoElement) {
      throw new Error('视频元素不存在');
    }

    // 检查是否是相同的流
    if (this.state.currentStream && this.state.currentStream.id === stream.id) {
      console.log('[VideoPlayer] 相同流正在播放，跳过重复设置');
      return;
    }

    // 检查是否有待处理的流
    if (this.state.pendingStreamId === stream.id) {
      console.log('[VideoPlayer] 相同流正在绑定中，跳过重复设置');
      return;
    }

    console.log('[VideoPlayer] 设置新的视频流，流ID:', stream.id);
    this.state.pendingStreamId = stream.id;

    try {
      // 停止当前播放
      await this.stop();

      // 设置视频源
      this.videoElement.srcObject = stream;
      this.state.currentStream = stream;

      // 配置视频元素
      this.configureVideoElement();

      // 等待元数据加载
      await this.waitForMetadata();

      // 开始播放
      await this.play();

      // 启用低延迟模式
      if (this.config.enableLowLatency) {
        this.enableLowLatencyMode();
      }

    } catch (error) {
      console.error('[VideoPlayer] 设置视频流失败:', error);
      throw error;
    } finally {
      if (this.state.pendingStreamId === stream.id) {
        this.state.pendingStreamId = null;
      }
    }
  }

  /**
   * 配置视频元素
   */
  configureVideoElement() {
    const video = this.videoElement;

    // 基本属性
    video.playsInline = true;
    video.muted = false;
    video.defaultMuted = false;
    video.autoplay = true;
    video.volume = 1;

    // HTML属性
    if (video.hasAttribute) {
      video.setAttribute('playsinline', '');
      video.setAttribute('webkit-playsinline', '');
      video.setAttribute('autoplay', '');
      video.removeAttribute('muted');
    }

    // 高级属性
    try {
      if ('latencyHint' in video) {
        video.latencyHint = 0;  // 最低延迟
      }
      video.preload = 'auto';
      video.disablePictureInPicture = true;
      video.controls = false;
    } catch (err) {
      console.warn('[VideoPlayer] 部分视频属性设置失败:', err);
    }

    // 样式
    video.style.objectFit = 'contain';

    console.log('[VideoPlayer] 视频元素配置完成');
  }

  /**
   * 等待元数据加载
   */
  waitForMetadata() {
    return new Promise((resolve, reject) => {
      const video = this.videoElement;

      if (video.readyState >= 2) {
        resolve();
        return;
      }

      const onLoadedMetadata = () => {
        video.removeEventListener('loadedmetadata', onLoadedMetadata);
        clearTimeout(timeout);
        resolve();
      };

      const timeout = setTimeout(() => {
        video.removeEventListener('loadedmetadata', onLoadedMetadata);
        reject(new Error('等待元数据超时'));
      }, 10000);

      video.addEventListener('loadedmetadata', onLoadedMetadata);
    });
  }

  /**
   * 播放视频
   */
  async play() {
    if (!this.videoElement || !this.videoElement.srcObject) {
      throw new Error('视频源未设置');
    }

    try {
      await this.videoElement.play();
      this.state.isPlaying = true;
      this.state.isPaused = false;
      
      console.log('[VideoPlayer] 视频开始播放');
      
      if (this.onPlay) {
        this.onPlay();
      }

    } catch (error) {
      console.error('[VideoPlayer] 播放失败:', error);

      // 处理特定错误
      if (error.name === 'AbortError') {
        console.log('[VideoPlayer] 检测到播放中断，300ms后重试...');
        await new Promise(resolve => setTimeout(resolve, 300));
        
        if (this.videoElement.srcObject && this.videoElement.readyState >= 2) {
          try {
            await this.videoElement.play();
            this.state.isPlaying = true;
            this.state.isPaused = false;
          } catch (retryError) {
            console.error('[VideoPlayer] 重试播放失败:', retryError);
            throw retryError;
          }
        }
      } else if (error.name === 'NotAllowedError') {
        console.warn('[VideoPlayer] 浏览器阻止了自动播放');
        throw new Error('浏览器阻止了带声音自动播放，请点击视频区域继续播放');
      } else {
        throw error;
      }
    }
  }

  /**
   * 暂停视频
   */
  pause() {
    if (!this.videoElement) {
      return;
    }

    this.videoElement.pause();
    this.state.isPlaying = false;
    this.state.isPaused = true;

    console.log('[VideoPlayer] 视频已暂停');

    if (this.onPause) {
      this.onPause();
    }
  }

  /**
   * 停止视频
   */
  async stop() {
    if (!this.videoElement) {
      return;
    }

    // 停止低延迟检查
    this.disableLowLatencyMode();

    // 暂停播放
    this.videoElement.pause();

    // 清除视频源
    this.videoElement.srcObject = null;
    this.videoElement.src = '';

    // 重置状态
    this.state.isPlaying = false;
    this.state.isPaused = false;
    this.state.currentStream = null;

    // 重新加载视频元素
    this.videoElement.load();

    console.log('[VideoPlayer] 视频已停止');
  }

  /**
   * 启用低延迟模式
   */
  enableLowLatencyMode() {
    if (!this.videoElement) {
      return;
    }

    console.log('[VideoPlayer] 启用低延迟模式');

    // 监听缓冲事件
    this.addEventListener('waiting', () => {
      console.log('[VideoPlayer] 视频缓冲中...');
      if (this.onBuffering) {
        this.onBuffering(true);
      }
    });

    this.addEventListener('playing', () => {
      console.log('[VideoPlayer] 视频播放中');
      if (this.onBuffering) {
        this.onBuffering(false);
      }

      // 检查并减少缓冲
      this.reduceBuffer();
    });

    // 定期检查延迟
    this.startLatencyCheck();
  }

  /**
   * 禁用低延迟模式
   */
  disableLowLatencyMode() {
    if (this.latencyCheckTimer) {
      clearInterval(this.latencyCheckTimer);
      this.latencyCheckTimer = null;
      console.log('[VideoPlayer] 低延迟模式已禁用');
    }
  }

  /**
   * 开始延迟检查
   */
  startLatencyCheck() {
    if (this.latencyCheckTimer) {
      return;
    }

    this.latencyCheckTimer = setInterval(() => {
      if (!this.state.isPlaying) {
        return;
      }

      this.reduceBuffer();
    }, this.config.latencyCheckInterval);
  }

  /**
   * 减少缓冲区
   */
  reduceBuffer() {
    const video = this.videoElement;
    
    if (!video || !video.buffered || video.buffered.length === 0) {
      return;
    }

    try {
      const buffered = video.buffered.end(0) - video.currentTime;

      if (this.config.enableLogging) {
        console.log('[VideoPlayer] 当前缓冲:', buffered.toFixed(2), '秒');
      }

      // 如果缓冲超过阈值，跳到最新帧
      if (buffered > this.config.maxBufferSize) {
        const newTime = video.buffered.end(0) - this.config.targetLatency;
        video.currentTime = Math.max(0, newTime);
        
        if (this.config.enableLogging) {
          console.log('[VideoPlayer] 跳到最新帧以减少延迟');
        }
      }
    } catch (err) {
      console.warn('[VideoPlayer] 减少缓冲失败:', err);
    }
  }

  /**
   * 获取当前缓冲大小
   */
  getBufferSize() {
    const video = this.videoElement;
    
    if (!video || !video.buffered || video.buffered.length === 0) {
      return 0;
    }

    try {
      return video.buffered.end(0) - video.currentTime;
    } catch (err) {
      return 0;
    }
  }

  /**
   * 获取播放状态
   */
  getState() {
    return {
      ...this.state,
      currentTime: this.videoElement?.currentTime || 0,
      duration: this.videoElement?.duration || 0,
      buffered: this.getBufferSize(),
      readyState: this.videoElement?.readyState || 0
    };
  }

  /**
   * 添加事件监听器
   */
  addEventListener(event, handler) {
    if (!this.videoElement) {
      return;
    }

    this.videoElement.addEventListener(event, handler);
    
    // 保存监听器引用以便清理
    if (!this.eventListeners.has(event)) {
      this.eventListeners.set(event, []);
    }
    this.eventListeners.get(event).push(handler);
  }

  /**
   * 移除事件监听器
   */
  removeEventListener(event, handler) {
    if (!this.videoElement) {
      return;
    }

    this.videoElement.removeEventListener(event, handler);

    // 从保存的引用中移除
    if (this.eventListeners.has(event)) {
      const handlers = this.eventListeners.get(event);
      const index = handlers.indexOf(handler);
      if (index > -1) {
        handlers.splice(index, 1);
      }
    }
  }

  /**
   * 清理所有事件监听器
   */
  clearEventListeners() {
    if (!this.videoElement) {
      return;
    }

    this.eventListeners.forEach((handlers, event) => {
      handlers.forEach(handler => {
        this.videoElement.removeEventListener(event, handler);
      });
    });

    this.eventListeners.clear();
    console.log('[VideoPlayer] 事件监听器已清理');
  }

  /**
   * 设置回调函数
   */
  setOnPlay(callback) {
    this.onPlay = callback;
  }

  setOnPause(callback) {
    this.onPause = callback;
  }

  setOnEnded(callback) {
    this.onEnded = callback;
  }

  setOnError(callback) {
    this.onError = callback;
  }

  setOnBuffering(callback) {
    this.onBuffering = callback;
  }

  /**
   * 截图
   */
  captureScreenshot() {
    if (!this.videoElement || !this.videoElement.srcObject) {
      throw new Error('当前没有视频流');
    }

    const canvas = document.createElement('canvas');
    canvas.width = this.videoElement.videoWidth;
    canvas.height = this.videoElement.videoHeight;

    const ctx = canvas.getContext('2d');
    ctx.drawImage(this.videoElement, 0, 0, canvas.width, canvas.height);

    return new Promise((resolve, reject) => {
      canvas.toBlob((blob) => {
        if (blob) {
          resolve(blob);
        } else {
          reject(new Error('截图失败'));
        }
      }, 'image/png');
    });
  }

  /**
   * 下载截图
   */
  async downloadScreenshot(filename) {
    try {
      const blob = await this.captureScreenshot();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename || `screenshot_${Date.now()}.png`;
      a.click();
      URL.revokeObjectURL(url);
      
      console.log('[VideoPlayer] 截图已保存:', a.download);
    } catch (error) {
      console.error('[VideoPlayer] 下载截图失败:', error);
      throw error;
    }
  }

  /**
   * 清理资源
   */
  cleanup() {
    console.log('[VideoPlayer] 清理资源');

    // 停止播放
    this.stop();

    // 禁用低延迟模式
    this.disableLowLatencyMode();

    // 清理事件监听器
    this.clearEventListeners();

    // 清除回调
    this.onPlay = null;
    this.onPause = null;
    this.onEnded = null;
    this.onError = null;
    this.onBuffering = null;

    // 重置状态
    this.state = {
      isPlaying: false,
      isPaused: false,
      currentStream: null,
      pendingStreamId: null
    };
  }
}
