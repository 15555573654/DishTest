<template>
  <el-dialog
    :visible.sync="visible"
    :width="dialogWidth + 'px'"
    :fullscreen="isMobile"
    :show-close="false"
    :close-on-click-modal="false"
    :modal="false"
    custom-class="screencast-control-dialog"
    @close="handleClose"
    @open="handleOpen"
  >
    <div class="screencast-wrapper" :style="{ height: dialogHeight + 'px' }">
      <!-- 顶部工具栏 - 可拖动 -->
      <div class="top-toolbar" @mousedown="startDrag">
        <div class="device-info">
          <span class="device-name">{{ deviceName }}</span>
          <span class="latency-badge" :class="getLatencyClass()">
            <i class="el-icon-time"></i>
            {{ currentStats.rtt }}ms
          </span>
          <span class="fps-badge" :class="getFpsClass()">
            <i class="el-icon-video-camera"></i>
            {{ currentStats.fps }}fps
          </span>
        </div>
        <div class="toolbar-actions">
          <i class="el-icon-setting" @click.stop="showSettings = !showSettings"></i>
          <i class="el-icon-close" @click.stop="closeDialog"></i>
        </div>
      </div>

      <!-- 主内容区 - 视频和功能栏并排 -->
      <div class="main-content">
        <!-- 视频显示区 -->
        <div class="video-container">
          <video
            ref="remoteVideo"
            autoplay
            playsinline
            class="video-stream"
            @click="handleVideoClick"
            @mousedown="handleVideoMouseDown"
            @mousemove="handleVideoMouseMove"
            @mouseup="handleVideoMouseUp"
            @touchstart="handleVideoTouchStart"
            @touchmove="handleVideoTouchMove"
            @touchend="handleVideoTouchEnd"
            @touchcancel="cancelGesture"
          ></video>
          
          <!-- 坐标网格覆盖层 -->
          <div v-if="showGrid && isStreaming" class="coordinate-grid" ref="coordinateGrid">
            <div class="grid-lines"></div>
            <div class="grid-labels"></div>
          </div>
          
          <div v-if="!isStreaming" class="stream-placeholder">
            <i class="el-icon-loading" v-if="connectionStatus === 'connecting'"></i>
            <i class="el-icon-video-camera" v-else></i>
            <p>{{ statusText }}</p>
          </div>
        </div>

        <!-- 右侧功能栏 -->
        <div class="side-toolbar">
          <div class="toolbar-item" @click.stop="captureScreenshot" :class="{ disabled: !isStreaming }" title="截图">
            <i class="el-icon-picture"></i>
          </div>
          <div class="toolbar-item" @click.stop="toggleCalibration" :class="{ disabled: !isStreaming, active: calibrationMode }" title="坐标校准">
            <i class="el-icon-aim"></i>
          </div>
          <div class="toolbar-item" @click.stop="toggleGrid" :class="{ disabled: !isStreaming, active: showGrid }" title="显示网格">
            <i class="el-icon-menu"></i>
          </div>
          <div class="toolbar-item" @click.stop="handleRefresh" :class="{ disabled: !mqttClient }" title="刷新">
            <i class="el-icon-refresh"></i>
          </div>
          <div class="toolbar-item" @click.stop="forceReconnect" :class="{ disabled: !webrtcManager }" title="重新连接">
            <i class="el-icon-connection"></i>
          </div>

          <!-- 分隔线 -->
          <div class="toolbar-divider"></div>

          <!-- Android控制按钮 - MQTT连接后即可使用 -->
          <div class="toolbar-item" @click.stop="sendVirtualKey('back')" :class="{ disabled: !mqttClient }" title="返回">
            <i class="el-icon-back"></i>
          </div>
          <div class="toolbar-item" @click.stop="sendVirtualKey('home')" :class="{ disabled: !mqttClient }" title="主页">
            <i class="el-icon-s-home"></i>
          </div>
          <div class="toolbar-item" @click.stop="sendVirtualKey('menu')" :class="{ disabled: !mqttClient }" title="任务栏">
            <i class="el-icon-menu"></i>
          </div>
        </div>
      </div>

      <!-- 设置面板 -->
      <div class="settings-panel" v-show="showSettings" @click.stop>
        <!-- 设置面板 -->
        <div class="setting-item">
          <span>传输质量</span>
          <el-select v-model="currentQuality" size="mini" @change="applyQualityPreset">
            <el-option label="高清 (1080p)" value="high" />
            <el-option label="标清 (720p)" value="medium" />
            <el-option label="流畅 (480p)" value="low" />
          </el-select>
        </div>

        <!-- 统计信息 -->
        <div class="stats-divider"></div>
        <div class="stats-section">
          <div class="stats-title">连接统计</div>
          <div class="stats-item">
            <span>视频分辨率:</span>
            <span>{{ currentStats.resolution || '-' }}</span>
          </div>
          <div class="stats-item">
            <span>实际帧率:</span>
            <span :class="{ 'stats-warning': currentStats.fps < 25 }">{{ currentStats.fps }} fps</span>
          </div>
          <div class="stats-item">
            <span>比特率:</span>
            <span>{{ currentStats.bitrate }} kbps</span>
          </div>
          <div class="stats-item">
            <span>延迟:</span>
            <span :class="{ 'stats-warning': currentStats.rtt > 200 }">{{ currentStats.rtt }} ms</span>
          </div>
          <div class="stats-item">
            <span>丢包率:</span>
            <span :class="{ 'stats-warning': currentStats.packetLoss > 5 }">{{ currentStats.packetLoss }}%</span>
          </div>
          <div class="stats-item">
            <span>抖动:</span>
            <span>{{ currentStats.jitter }} ms</span>
          </div>
        </div>
      </div>

      <!-- 缩放手柄 -->
      <div class="resize-handles" v-if="!isMobile">
        <div class="resize-handle resize-right" @mousedown="startResize($event, 'right')"></div>
        <div class="resize-handle resize-bottom" @mousedown="startResize($event, 'bottom')"></div>
        <div class="resize-handle resize-corner" @mousedown="startResize($event, 'corner')"></div>
      </div>
    </div>
  </el-dialog>
</template>

<script>
import WebRTCManager from '@/utils/webrtc/WebRTCManager';

export default {
  name: 'ScreencastDialog',
  props: {
    value: {
      type: Boolean,
      default: false
    },
    deviceName: {
      type: String,
      required: true
    },
    mqttClient: {
      type: Object,
      default: null
    },
    username: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      visible: this.value,
      connectionStatus: 'disconnected',
      statusText: '等待连接...',
      isStreaming: false,
      showSettings: false,

      // 拖动和缩放相关 - 自适应窗口大小
      dialogWidth: 400,  // 初始宽度，会根据设备分辨率自动调整
      dialogHeight: 700, // 初始高度，会根据设备分辨率自动调整
      isDragging: false,
      isResizing: false,
      resizeType: '',
      dialogDragStartX: 0,
      dialogDragStartY: 0,
      dialogLeft: 0,
      dialogTop: 0,
      resizeStartX: 0,
      resizeStartY: 0,
      resizeStartWidth: 0,
      resizeStartHeight: 0,

      // WebRTC 管理器
      webrtcManager: null,

      // 统计信息监控
      statsInterval: null,
      currentStats: {
        bitrate: 0,
        fps: 0,
        resolution: '',
        packetLoss: 0,
        jitter: 0,
        rtt: 0
      },

      videoConstraints: {
        resolution: '1280x720',
        frameRate: 24
      },

      qualityPresets: {
        high: { resolution: '1920x1080', frameRate: 30, label: '高清' },
        medium: { resolution: '1280x720', frameRate: 24, label: '标清' },
        low: { resolution: '854x480', frameRate: 20, label: '流畅' }
      },
      currentQuality: 'medium',
      videoFitMode: 'contain',

      isMobile: false,
      debugStatsLogged: false, // 调试标志，避免重复输出统计类型
      
      // 触摸和拖拽状态
      isDraggingVideo: false,
      gestureStartTime: 0,
      gestureStartX: 0,
      gestureStartY: 0,
      gestureStartClientX: 0,
      gestureStartClientY: 0,
      pendingSingleTapTimer: null,
      pendingTap: null,
      lastPointerType: 'mouse',
      
      // 校准模式
      calibrationMode: false,
      calibrationPoints: [],
      
      // 网格显示
      showGrid: false,
      
      // 调试模式
      debugMode: false,
      
      
      // 设备真实分辨率（从Android端获取）
      deviceResolution: null,
      
      // 视频传输分辨率（从Android端获取）
      videoResolution: null,
      videoRotation: 0,
      
      // 消息去重
      processedMessages: null,
      initialResolutionReceived: false,
      feedbackTopic: '',
      feedbackMessageHandler: null,
      pendingStreamId: ''
    };
  },
  computed: {
    // 判断是否已建立连接（简化逻辑，只要有WebRTC管理器且MQTT连接正常即可）
    isConnected() {
      return this.webrtcManager && 
             this.mqttClient && 
             (this.connectionStatus === 'connected' || 
              this.connectionStatus === 'connecting' ||
              this.webrtcManager.isDataChannelOpen());
    }
  },
  watch: {
    value(val) {
      this.visible = val;
    },
    visible(val) {
      this.$emit('input', val);
    }
  },
  created() {
    this.checkMobile();
    this.initWebRTC();
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('mouseup', this.handleMouseUp);
    
    // 添加键盘事件监听
    document.addEventListener('keydown', this.handleKeyDown);
    
    // 监听窗口大小变化，重新绘制网格
    this.resizeObserver = new ResizeObserver(() => {
      if (this.showGrid) {
        this.$nextTick(() => {
          this.drawGrid();
        });
      }
    });
  },
  mounted() {
    // 开始观察视频容器的大小变化
    if (this.resizeObserver && this.$refs.remoteVideo) {
      this.resizeObserver.observe(this.$refs.remoteVideo);
    }
  },

  beforeDestroy() {
    this.cleanup();
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);
    document.removeEventListener('keydown', this.handleKeyDown);
    
    // 停止观察大小变化
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
  },
  methods: {
    /** 初始化 WebRTC 管理器 */
    initWebRTC() {
      this.webrtcManager = new WebRTCManager({
        deviceName: this.deviceName,
        mqttClient: this.mqttClient,
        username: this.username
      });

      // 设置事件回调
      this.webrtcManager.on('connectionStateChange', (state) => {
        this.connectionStatus = state;

        switch (state) {
          case 'connecting':
            this.statusText = '正在连接...';
            break;
          case 'connected':
            this.statusText = '连接成功';
            this.$message.success('WebRTC连接成功');
            break;
          case 'disconnected':
            this.isStreaming = false;
            this.statusText = '连接断开';
            console.warn('WebRTC连接断开，可能是临时网络问题');
            break;
          case 'failed':
            this.isStreaming = false;
            this.statusText = '连接失败';
            this.$message.error('WebRTC连接失败');
            break;
          case 'closed':
            this.isStreaming = false;
            this.statusText = '连接已关闭';
            break;
          default:
            this.statusText = `状态: ${state}`;
        }
      });

      this.webrtcManager.on('track', (stream, { audioTracks, videoTracks }) => {
        console.log('设置视频元素srcObject...');
        if (this.$refs.remoteVideo) {
          const video = this.$refs.remoteVideo;

          // 避免 video/audio 两次 ontrack 在异步设置前重复绑定同一个流
          if (this.pendingStreamId === stream.id) {
            console.log('相同流正在绑定中，跳过重复设置');
          } else if (!video.srcObject || video.srcObject.id !== stream.id) {
            console.log('设置新的视频流，流ID:', stream.id);
            this.pendingStreamId = stream.id;

            // 先暂停当前播放，避免冲突
            if (video.srcObject) {
              video.pause();
              video.srcObject = null;
            }

            // 设置视频源
            video.srcObject = stream;

            // 优化视频播放设置 - 优先保证自动播放成功
            video.playsInline = true;
            video.muted = true;
            video.defaultMuted = true;
            video.autoplay = true;
            video.volume = 0;

            if (video.hasAttribute) {
              video.setAttribute('playsinline', '');
              video.setAttribute('webkit-playsinline', '');
              video.setAttribute('muted', '');
              video.setAttribute('autoplay', '');
            }

            try {
              if ('latencyHint' in video) {
                video.latencyHint = 0;
              }
              video.preload = 'auto';
              video.disablePictureInPicture = true;
              video.controls = false;
            } catch (err) {
              console.warn('部分视频属性设置失败:', err);
            }

            video.style.objectFit = 'contain';

            console.log('✓ 视频元素srcObject已设置');

            const playVideo = async () => {
              try {
                await video.play();
                console.log('✓ 视频开始播放');
                this.enableLowLatencyMode(video);
                this.startStatsMonitoring();
              } catch (err) {
                console.error('✗ 视频播放失败:', err);

                if (err.name === 'AbortError') {
                  console.log('检测到播放中断，300ms后重试...');
                  setTimeout(() => {
                    if (video.srcObject && video.readyState >= 2) {
                      video.play().catch(retryErr => {
                        console.error('重试播放失败:', retryErr);
                      });
                    }
                  }, 300);
                } else if (err.name === 'NotAllowedError') {
                  this.$message.warning('浏览器阻止了自动播放，请点击视频区域继续播放');
                }
              } finally {
                if (this.pendingStreamId === stream.id) {
                  this.pendingStreamId = '';
                }
              }
            };

            if (video.readyState >= 2) {
              playVideo();
            } else {
              video.addEventListener('loadedmetadata', playVideo, { once: true });
            }
          } else {
            console.log('视频元素已有相同流，跳过重复设置');
          }
        }

        this.isStreaming = true;
        this.statusText = '正在播放';

        if (audioTracks.length > 0 && videoTracks.length > 0) {
          this.$message.success('视频和音频流已连接');
        } else if (videoTracks.length > 0) {
          this.$message.warning('视频流已连接，但没有音频');
        }
      });

      this.webrtcManager.on('dataChannelMessage', (message) => {
        switch (message.type) {
          case 'status':
            break;
          case 'error':
            this.$message.error('设备错误: ' + message.message);
            break;
        }
      });

      this.webrtcManager.on('error', (error) => {
        this.$message.error(error);
      });
    },

    /** 检测移动设备 */
    checkMobile() {
      this.isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    },

    /** 弹窗打开时自动连接 */
    handleOpen() {
      console.log('=== 开始投屏 ===');
      console.log('设备名称:', this.deviceName);
      console.log('MQTT连接状态:', !!this.mqttClient);
      console.log('用户名:', this.username);

      // 初始化弹窗大小
      this.autoResizeDialog();

      // 订阅反馈消息
      if (this.mqttClient) {
        this.feedbackTopic = `control/${this.username}/${this.deviceName}/feedback`;
        this.mqttClient.subscribe(this.feedbackTopic, { qos: 1 }, (err) => {
          if (err) {
            console.error('订阅反馈消息失败:', err);
          } else {
            console.log('已订阅反馈消息:', this.feedbackTopic);
          }
        });

        this.feedbackMessageHandler = (topic, message) => {
          if (topic === this.feedbackTopic) {
            try {
              const data = JSON.parse(message.toString());
              this.handleFeedbackMessage(data);
            } catch (e) {
              console.error('解析反馈消息失败:', e);
            }
          }
        };
        this.mqttClient.on('message', this.feedbackMessageHandler);
      }

      // 更新 WebRTC 管理器配置
      this.webrtcManager.updateConfig({
        deviceName: this.deviceName,
        mqttClient: this.mqttClient,
        username: this.username
      });

      this.statusText = '正在连接...';
      this.connectionStatus = 'connecting';
      this.startScreencast();
    },

    /** 处理设备反馈消息 */
    handleFeedbackMessage(data) {
      // 防止重复处理同一条消息
      const messageId = `${data.type}-${data.timestamp || Date.now()}`;
      if (this.processedMessages && this.processedMessages.has(messageId)) {
        return; // 已处理过，跳过
      }
      
      // 记录已处理的消息（保留最近100条记录）
      if (!this.processedMessages) {
        this.processedMessages = new Set();
      }
      this.processedMessages.add(messageId);
      if (this.processedMessages.size > 100) {
        const firstItem = this.processedMessages.values().next().value;
        this.processedMessages.delete(firstItem);
      }
      
      console.log('收到设备反馈:', data);
      
      switch (data.type) {
        case 'click-confirmation':
          console.log(`✓ 设备确认点击: (${data.x}, ${data.y})`);
          // 可以在这里添加视觉反馈，比如显示一个绿色的确认标记
          break;
        case 'swipe-confirmation':
          console.log(`✓ 设备确认滑动: (${data.x1}, ${data.y1}) -> (${data.x2}, ${data.y2})`);
          // 可以在这里添加滑动轨迹的视觉反馈
          break;
        case 'refresh-confirmation':
          console.log(`✓ 设备确认视频刷新完成`);
          this.$message.success('视频刷新完成');
          break;
        case 'device-resolution':
          console.log(`✓ 收到设备分辨率: ${data.width}x${data.height}`);
          this.deviceResolution = {
            width: data.width,
            height: data.height
          };
          this.videoRotation = data.rotation || 0;
          console.log('设备分辨率已更新，坐标转换将使用真实设备分辨率');
          
          // 只在初次收到设备分辨率时调整弹窗大小，避免视频流中断
          if (!this.initialResolutionReceived) {
            this.initialResolutionReceived = true;
            this.$nextTick(() => {
              this.autoResizeDialog();
              // 如果网格正在显示，重新绘制
              if (this.showGrid) {
                this.drawGrid();
              }
            });
          }
          break;
        case 'video-resolution':
          console.log(`✓ 收到视频传输分辨率: ${data.width}x${data.height}`);
          this.videoResolution = {
            width: data.width,
            height: data.height,
            frameRate: data.frameRate || 0
          };
          console.log('视频传输分辨率已更新');
          break;
        case 'quality-change-confirmation':
          console.log(`✓ 设备确认质量变更: ${data.quality} (${data.width}x${data.height}@${data.frameRate}fps)`);
          this.$message.success(`质量已切换到${this.qualityPresets[data.quality]?.label || data.quality}`);
          // 更新视频传输分辨率
          this.videoResolution = {
            width: data.width,
            height: data.height
          };
          break;
        default:
          console.log('未知反馈类型:', data.type);
      }
    },

    /** 关闭弹窗 */
    async handleClose() {
      await this.stopScreencast();
      this.cleanup();
    },

    /** 关闭对话框 */
    closeDialog() {
      this.visible = false;
    },

    /** 开始投屏 */
    async startScreencast() {
      if (!this.mqttClient) {
        this.$message.error('MQTT未连接');
        return;
      }

      try {
        this.connectionStatus = 'connecting';
        this.statusText = '正在建立连接...';

        const preset = this.qualityPresets[this.currentQuality] || this.qualityPresets.medium;
        const [width, height] = preset.resolution.split('x').map(Number);
        const constraints = {
          width,
          height,
          frameRate: preset.frameRate
        };

        console.log('使用初始视频约束:', constraints);

        await this.webrtcManager.start(constraints);
        this.$message.success('正在建立连接...');
      } catch (e) {
        console.error('开始投屏失败:', e);
        this.$message.error('开始投屏失败: ' + e.message);
        this.connectionStatus = 'disconnected';
        this.statusText = '连接失败';
      }
    },

    /** 停止投屏 */
    async stopScreencast(options = {}) {
      const { notifyDevice = true } = options;

      if (notifyDevice) {
        await this.sendControlCommand(
          {
            action: 'stopCapture',
            deviceName: this.deviceName,
            from: 'frontend'
          },
          false
        );
      }

      if (this.webrtcManager) {
        this.webrtcManager.stop();
      }
      this.stopStatsMonitoring();
      this.connectionStatus = 'disconnected';
      this.isStreaming = false;
      this.statusText = '已停止';

      // 清除视频元素 - 改进版本
      if (this.$refs.remoteVideo) {
        const video = this.$refs.remoteVideo;
        
        // 先暂停播放
        video.pause();
        
        // 清除事件监听器
        video.removeEventListener('loadedmetadata', () => {});
        
        // 清除视频源
        video.srcObject = null;
        video.src = '';
        
        // 重置视频属性
        video.load();
        
        console.log('✓ 视频元素已清理');
      }
    },

    /** 启动统计信息监控 */
    startStatsMonitoring() {
      if (this.statsInterval) {
        clearInterval(this.statsInterval);
      }

      // 用于计算比特率和帧率的变量
      let lastBytesReceived = 0;
      let lastTimestamp = 0;
      let lastFramesDecoded = 0;

      this.statsInterval = setInterval(async () => {
        if (!this.webrtcManager || !this.webrtcManager.peerConnection) {
          return;
        }

        try {
          const stats = await this.webrtcManager.peerConnection.getStats();

          // 调试：输出所有报告类型（仅前几次）
          if (!this.debugStatsLogged) {
            const reportTypes = new Set();
            stats.forEach(report => {
              reportTypes.add(report.type);
            });
            console.log('可用的统计报告类型:', Array.from(reportTypes));
            this.debugStatsLogged = true;
          }

          stats.forEach(report => {
            // 视频统计
            if (report.type === 'inbound-rtp' && report.kind === 'video') {
              // 计算比特率
              if (lastTimestamp > 0 && report.timestamp > lastTimestamp) {
                const timeDiff = (report.timestamp - lastTimestamp) / 1000; // 转换为秒
                const bytesDiff = report.bytesReceived - lastBytesReceived;
                this.currentStats.bitrate = Math.round((bytesDiff * 8) / timeDiff / 1000); // kbps
              }

              // 帧率 - 在更新 lastTimestamp 之前计算
              if (report.framesPerSecond !== undefined && report.framesPerSecond > 0) {
                this.currentStats.fps = Math.round(report.framesPerSecond);
              } else if (report.framesDecoded !== undefined && lastTimestamp > 0 && lastFramesDecoded > 0) {
                // 备用方案：通过解码帧数增量计算
                const timeDiff = (report.timestamp - lastTimestamp) / 1000;
                const framesDiff = report.framesDecoded - lastFramesDecoded;
                if (timeDiff > 0 && framesDiff >= 0) {
                  this.currentStats.fps = Math.round(framesDiff / timeDiff);
                }
              }
              
              // 保存当前帧数用于下次计算
              if (report.framesDecoded !== undefined) {
                lastFramesDecoded = report.framesDecoded;
              }

              // 更新上次的值（放在帧率计算之后）
              lastBytesReceived = report.bytesReceived;
              lastTimestamp = report.timestamp;

              // 分辨率
              if (report.frameWidth && report.frameHeight) {
                const newResolution = `${report.frameWidth}x${report.frameHeight}`;
                
                // 只更新分辨率信息，不自动调整弹窗大小（避免视频流中断）
                if (this.currentStats.resolution !== newResolution) {
                  this.currentStats.resolution = newResolution;
                  console.log('视频分辨率已更新:', newResolution);
                }
              }

              // 丢包率
              if (report.packetsLost !== undefined && report.packetsReceived !== undefined) {
                const totalPackets = report.packetsLost + report.packetsReceived;
                if (totalPackets > 0) {
                  this.currentStats.packetLoss = ((report.packetsLost / totalPackets) * 100).toFixed(2);
                }
              }

              // 抖动
              if (report.jitter !== undefined) {
                this.currentStats.jitter = Math.round(report.jitter * 1000); // 转换为毫秒
              }
            }

            // RTT (往返时间) - 改进延迟统计
            let rttFound = false;
            
            // 优先从 remote-inbound-rtp 获取 RTT
            if (report.type === 'remote-inbound-rtp' && report.kind === 'video') {
              if (report.roundTripTime !== undefined && report.roundTripTime > 0) {
                this.currentStats.rtt = Math.round(report.roundTripTime * 1000); // 转换为毫秒
                rttFound = true;
                console.log('从 remote-inbound-rtp 获取 RTT:', this.currentStats.rtt, 'ms');
              }
            }

            // 备用方案：从 candidate-pair 获取 RTT
            if (!rttFound && report.type === 'candidate-pair' && report.state === 'succeeded') {
              if (report.currentRoundTripTime !== undefined && report.currentRoundTripTime > 0) {
                const newRtt = Math.round(report.currentRoundTripTime * 1000);
                // 只有当RTT变化超过5ms时才更新，避免频繁小幅波动
                if (Math.abs(newRtt - this.currentStats.rtt) > 5 || this.currentStats.rtt === 0) {
                  this.currentStats.rtt = newRtt;
                  console.log('从 candidate-pair 更新 RTT:', this.currentStats.rtt, 'ms');
                }
                rttFound = true;
              }
            }

            // 第三备用方案：从 inbound-rtp 的其他字段计算
            if (!rttFound && report.type === 'inbound-rtp' && report.kind === 'video') {
              // 有些浏览器可能在这里提供 RTT 信息
              if (report.roundTripTime !== undefined && report.roundTripTime > 0) {
                this.currentStats.rtt = Math.round(report.roundTripTime * 1000);
                rttFound = true;
                console.log('从 inbound-rtp 获取 RTT:', this.currentStats.rtt, 'ms');
              }
            }
          });

          // 如果延迟过高，自动调整质量 - 提高阈值避免误报
          if (this.currentStats.rtt > 500 || this.currentStats.packetLoss > 15) {
            console.warn('检测到高延迟(' + this.currentStats.rtt + 'ms)或丢包(' + this.currentStats.packetLoss + '%)，建议降低视频质量');
          }
        } catch (err) {
          console.error('获取统计信息失败:', err);
        }
      }, 1000); // 每秒更新一次
    },

    /** 停止统计信息监控 */
    stopStatsMonitoring() {
      if (this.statsInterval) {
        clearInterval(this.statsInterval);
        this.statsInterval = null;
      }
    },

    /** 启用低延迟模式 */
    enableLowLatencyMode(videoElement) {
      try {
        // 尝试使用 MediaSource 的低延迟模式（如果支持）
        if (videoElement.captureStream) {
          console.log('✓ 视频元素支持 captureStream');
        }

        // 监听缓冲事件，动态调整
        videoElement.addEventListener('waiting', () => {
          console.log('视频缓冲中...');
        });

        videoElement.addEventListener('playing', () => {
          console.log('视频播放中');

          // 尝试减少缓冲区
          if (videoElement.buffered && videoElement.buffered.length > 0) {
            const buffered = videoElement.buffered.end(0) - videoElement.currentTime;
            console.log('当前缓冲:', buffered.toFixed(2), '秒');

            // 如果缓冲超过 0.5 秒，尝试跳到最新帧
            if (buffered > 0.5) {
              videoElement.currentTime = videoElement.buffered.end(0) - 0.1;
              console.log('跳到最新帧以减少延迟');
            }
          }
        });

        // 定期检查并跳到最新帧（激进的低延迟策略）
        const latencyCheckInterval = setInterval(() => {
          if (!this.isStreaming) {
            clearInterval(latencyCheckInterval);
            return;
          }

          if (videoElement.buffered && videoElement.buffered.length > 0) {
            const buffered = videoElement.buffered.end(0) - videoElement.currentTime;

            // 如果缓冲超过 0.3 秒，跳到最新帧
            if (buffered > 0.3) {
              videoElement.currentTime = videoElement.buffered.end(0) - 0.05;
            }
          }
        }, 1000); // 每秒检查一次

        console.log('✓ 低延迟模式已启用');
      } catch (err) {
        console.warn('启用低延迟模式失败:', err);
      }
    },


    /** 强制重新连接 */
    forceReconnect() {
      console.log('🔄 强制重新连接WebRTC...');
      
      if (this.webrtcManager) {
        // 使用WebRTC管理器的强制重连方法
        this.webrtcManager.forceReconnect();
        
        // 重置本地状态
        this.connectionStatus = 'disconnected';
        this.isStreaming = false;
        this.statusText = '准备重新连接...';
        
        // 清除视频
        if (this.$refs.remoteVideo) {
          const video = this.$refs.remoteVideo;
          video.pause();
          video.srcObject = null;
          video.src = '';
          video.load();
        }
        
        // 延迟一秒后重新开始连接
        setTimeout(() => {
          console.log('🔄 开始重新建立连接...');
          this.startScreencast();
        }, 1000);
        
        this.$message.info('正在重新建立连接...');
      }
    },

    /** 处理 Answer */
    async handleAnswer(answer) {
      console.log('📥 ScreencastDialog收到Answer:', answer);
      if (this.webrtcManager) {
        try {
          await this.webrtcManager.handleAnswer(answer);
          console.log('✅ Answer处理完成');
        } catch (error) {
          console.error('❌ Answer处理失败:', error);
          this.$message.error('处理Answer失败: ' + error.message);
        }
      } else {
        console.error('❌ WebRTC管理器不存在');
      }
    },

    /** 处理 ICE 候选 */
    async handleIceCandidate(candidate) {
      if (this.webrtcManager) {
        await this.webrtcManager.handleIceCandidate(candidate);
      }
    },

    /** 发送虚拟按键 */
    sendVirtualKey(key) {
      this.sendControlCommand(
        {
          action: 'virtualKey',
          key,
          deviceName: this.deviceName,
          from: 'frontend'
        }
      );
    },

    /** 发送控制指令 */
    sendControlCommand(payload, showWarning = true) {
      if (this.webrtcManager && this.webrtcManager.isDataChannelOpen()) {
        return Promise.resolve(this.webrtcManager.sendMessage(payload));
      }

      if (!this.mqttClient) {
        if (showWarning) {
          this.$message.warning('控制通道未连接');
        }
        return Promise.resolve(false);
      }

      const controlMessage = {
        type: 'control',
        ...payload
      };
      const topic = `control/${this.username}/${this.deviceName}`;

      return new Promise((resolve) => {
        this.mqttClient.publish(topic, JSON.stringify(controlMessage), { qos: 1 }, (err) => {
          if (err) {
            console.error('发送控制指令失败:', err);
            if (showWarning) {
              this.$message.error('发送控制指令失败');
            }
            resolve(false);
            return;
          }
          resolve(true);
        });
      });
    },

    /** 根据视频分辨率自适应调整弹窗大小（以竖屏长度为基准） */
    autoResizeDialog() {
      // 优先使用从Android端获取的真实设备分辨率
      let deviceWidth, deviceHeight;
      
      if (this.deviceResolution) {
        deviceWidth = this.deviceResolution.width;
        deviceHeight = this.deviceResolution.height;
        console.log(`使用真实设备分辨率调整弹窗: ${deviceWidth}x${deviceHeight}`);
      } else if (this.currentStats.resolution) {
        [deviceWidth, deviceHeight] = this.currentStats.resolution.split('x').map(Number);
        console.log(`使用视频流分辨率调整弹窗: ${deviceWidth}x${deviceHeight}`);
      } else {
        // 默认使用常见的手机分辨率比例 (9:16)
        deviceWidth = 1080;
        deviceHeight = 1920;
        console.log(`使用默认分辨率调整弹窗: ${deviceWidth}x${deviceHeight}`);
      }
      
      if (!deviceWidth || !deviceHeight) return;

      // 动态计算合适的弹窗高度（基于屏幕高度的80%，但不超过800px）
      const maxHeight = Math.min(window.innerHeight * 0.8, 800);
      const minHeight = 500;
      const targetHeight = Math.max(minHeight, Math.min(maxHeight, 700));
      
      // 使用设备分辨率计算宽高比
      const deviceAspectRatio = deviceWidth / deviceHeight;
      
      // 计算视频显示区域的宽度（减去工具栏等空间）
      const toolbarWidth = 40; // 右侧工具栏宽度
      const topToolbarHeight = 50; // 顶部工具栏高度
      
      // 视频显示区域的高度
      const videoDisplayHeight = targetHeight - topToolbarHeight;
      
      // 根据设备宽高比计算视频显示区域的宽度
      const videoDisplayWidth = videoDisplayHeight * deviceAspectRatio;
      
      // 弹窗总宽度 = 视频显示宽度 + 工具栏宽度
      this.dialogWidth = Math.round(videoDisplayWidth + toolbarWidth);
      this.dialogHeight = targetHeight;

      console.log(`自适应弹窗大小: ${this.dialogWidth}x${this.dialogHeight} (设备: ${deviceWidth}x${deviceHeight}, 比例: ${deviceAspectRatio.toFixed(2)})`);
    },

    /** 请求屏幕共享 */
    requestScreenShare() {
      if (!this.webrtcManager || !this.webrtcManager.isDataChannelOpen()) {
        this.$message.warning('请先建立连接');
        return;
      }

      this.webrtcManager.requestScreenShare();
      this.$message.success('已发送屏幕共享请求');
    },

    /** 刷新连接 */
    async handleRefresh() {
      if (!this.mqttClient) {
        this.$message.warning('MQTT未连接');
        return;
      }

      try {
        // 停止当前连接
        await this.stopScreencast({ notifyDevice: false });

        // 等待一小段时间确保资源释放
        await new Promise(resolve => setTimeout(resolve, 500));

        // 重新开始投屏
        await this.startScreencast();
      } catch (error) {
        console.error('刷新连接失败:', error);
        this.$message.error('刷新连接失败: ' + error.message);
      }
    },

    /** 应用质量预设 */
    applyQualityPreset() {
      const preset = this.qualityPresets[this.currentQuality];
      if (!preset) return;

      console.log(`切换到${preset.label}模式:`, preset);

      // 发送质量设置给Android端
      if (this.webrtcManager && this.webrtcManager.isDataChannelOpen()) {
        const qualitySettings = {
          quality: this.currentQuality,
          resolution: preset.resolution,
          frameRate: preset.frameRate
        };

        this.webrtcManager.sendMessage({
          action: 'setQuality',
          settings: qualitySettings
        });

        this.$message.success(`已切换到${preset.label}模式，设备正在调整...`);
        console.log('发送给Android端的质量设置:', qualitySettings);
      } else {
        this.$message.warning('请先建立连接');
      }
    },

    /** 获取延迟等级样式 */
    getLatencyClass() {
      const rtt = this.currentStats.rtt;
      if (rtt === 0) return 'latency-unknown';
      if (rtt < 50) return 'latency-excellent';
      if (rtt < 100) return 'latency-good';
      if (rtt < 200) return 'latency-fair';
      return 'latency-poor';
    },

    /** 获取帧率等级样式 */
    getFpsClass() {
      const fps = this.currentStats.fps;
      if (fps === 0) return 'fps-unknown';
      if (fps >= 55) return 'fps-excellent';
      if (fps >= 45) return 'fps-good';
      if (fps >= 30) return 'fps-fair';
      return 'fps-poor';
    },

    /** 全屏切换 */
    toggleFullscreen() {
      if (!this.isStreaming) {
        return;
      }

      const video = this.$refs.remoteVideo;

      if (!document.fullscreenElement) {
        if (video.requestFullscreen) {
          video.requestFullscreen();
        } else if (video.webkitRequestFullscreen) {
          video.webkitRequestFullscreen();
        } else if (video.mozRequestFullScreen) {
          video.mozRequestFullScreen();
        }
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        } else if (document.webkitExitFullscreen) {
          document.webkitExitFullscreen();
        } else if (document.mozCancelFullScreen) {
          document.mozCancelFullScreen();
        }
      }
    },

    /** 截图 */
    captureScreenshot() {
      const video = this.$refs.remoteVideo;
      if (!video.srcObject) {
        this.$message.warning('当前没有视频流');
        return;
      }

      const canvas = document.createElement('canvas');
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      const ctx = canvas.getContext('2d');
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

      canvas.toBlob((blob) => {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `screenshot_${this.deviceName}_${Date.now()}.png`;
        a.click();
        URL.revokeObjectURL(url);
        this.$message.success('截图已保存');
      });
    },

    /** 开始拖动 */
    startDrag(e) {
      if (this.isMobile) return;

      const dialog = document.querySelector('.screencast-control-dialog');
      if (dialog) {
        const rect = dialog.getBoundingClientRect();
        
        // 如果弹窗还没有设置绝对定位，先固定在当前位置
        if (!dialog.style.left || dialog.style.left === '') {
          dialog.style.left = rect.left + 'px';
          dialog.style.top = rect.top + 'px';
          dialog.style.margin = '0';
        }
        
        // 记录当前位置作为拖动起点
        this.dialogLeft = parseFloat(dialog.style.left) || rect.left;
        this.dialogTop = parseFloat(dialog.style.top) || rect.top;
      }

      this.isDragging = true;
      this.dialogDragStartX = e.clientX;
      this.dialogDragStartY = e.clientY;

      e.preventDefault();
    },

    /** 开始缩放 */
    startResize(e, type) {
      if (this.isMobile) return;

      this.isResizing = true;
      this.resizeType = type;
      this.resizeStartX = e.clientX;
      this.resizeStartY = e.clientY;
      this.resizeStartWidth = this.dialogWidth;
      this.resizeStartHeight = this.dialogHeight;

      e.preventDefault();
      e.stopPropagation();
    },

    /** 鼠标移动 */
    handleMouseMove(e) {
      if (this.isDragging) {
        const deltaX = e.clientX - this.dialogDragStartX;
        const deltaY = e.clientY - this.dialogDragStartY;

        const dialog = document.querySelector('.screencast-control-dialog');
        if (dialog) {
          dialog.style.left = (this.dialogLeft + deltaX) + 'px';
          dialog.style.top = (this.dialogTop + deltaY) + 'px';
          dialog.style.margin = '0';
        }
      } else if (this.isResizing) {
        const deltaX = e.clientX - this.resizeStartX;
        const deltaY = e.clientY - this.resizeStartY;

        if (this.resizeType === 'right' || this.resizeType === 'corner') {
          this.dialogWidth = Math.max(300, this.resizeStartWidth + deltaX);
        }

        if (this.resizeType === 'bottom' || this.resizeType === 'corner') {
          this.dialogHeight = Math.max(400, this.resizeStartHeight + deltaY);
        }
      }
    },

    /** 鼠标释放 */
    handleMouseUp() {
      this.isDragging = false;
      this.isResizing = false;
      this.resizeType = '';
    },

    /** 清理资源 */
    cleanup() {
      this.stopStatsMonitoring();
      this.cancelPendingTap();

      if (this.webrtcManager) {
        this.webrtcManager.cleanup();
      }

      if (this.mqttClient && this.feedbackTopic) {
        if (typeof this.mqttClient.unsubscribe === 'function') {
          this.mqttClient.unsubscribe(this.feedbackTopic);
        }
        if (this.feedbackMessageHandler && typeof this.mqttClient.removeListener === 'function') {
          this.mqttClient.removeListener('message', this.feedbackMessageHandler);
        }
      }
      this.feedbackTopic = '';
      this.feedbackMessageHandler = null;

      // 清理消息去重记录
      if (this.processedMessages) {
        this.processedMessages.clear();
      }
      this.initialResolutionReceived = false;
      this.pendingStreamId = '';

      // 改进的视频元素清理
      if (this.$refs.remoteVideo) {
        const video = this.$refs.remoteVideo;
        
        try {
          // 暂停播放
          video.pause();
          
          // 清除所有事件监听器
          const events = ['loadedmetadata', 'playing', 'waiting', 'error', 'ended'];
          events.forEach(event => {
            video.removeEventListener(event, () => {});
          });
          
          // 清除视频源
          video.srcObject = null;
          video.src = '';
          
          // 重置视频元素
          video.load();
          
          console.log('✓ 视频资源完全清理');
        } catch (err) {
          console.warn('清理视频资源时出现警告:', err);
        }
      }

      this.isStreaming = false;
      this.isDraggingVideo = false;
    },

    /** 处理视频点击事件 */
    handleVideoClick(event) {
      // 注意：这个事件在鼠标拖拽时不应该触发
      // 实际的点击/滑动逻辑在 mouseUp 事件中处理
    },

    /** 添加校准点 */
    addCalibrationPoint(event, coords) {
      const rect = this.$refs.remoteVideo.getBoundingClientRect();
      const relativeX = (event.clientX - rect.left) / rect.width;
      const relativeY = (event.clientY - rect.top) / rect.height;
      
      const calibrationPoint = {
        screenX: coords.x,
        screenY: coords.y,
        videoRelativeX: relativeX,
        videoRelativeY: relativeY,
        timestamp: Date.now()
      };
      
      this.calibrationPoints.push(calibrationPoint);
      
      console.log(`校准点 ${this.calibrationPoints.length}:`, calibrationPoint);
      this.$message.success(`已记录校准点 ${this.calibrationPoints.length}/4`);
      
      if (this.calibrationPoints.length >= 4) {
        this.analyzeCalibration();
      }
    },

    /** 分析校准结果 */
    analyzeCalibration() {
      console.log('校准分析结果:');
      this.calibrationPoints.forEach((point, index) => {
        console.log(`点 ${index + 1}: 视频相对位置(${point.videoRelativeX.toFixed(3)}, ${point.videoRelativeY.toFixed(3)}) -> 设备坐标(${point.screenX}, ${point.screenY})`);
      });
      
      // 计算校准精度
      const corners = [
        { name: '左上角', expectedX: 0, expectedY: 0 },
        { name: '右上角', expectedX: 1, expectedY: 0 },
        { name: '左下角', expectedX: 0, expectedY: 1 },
        { name: '右下角', expectedX: 1, expectedY: 1 }
      ];
      
      let totalError = 0;
      this.calibrationPoints.forEach((point, index) => {
        if (corners[index]) {
          const errorX = Math.abs(point.videoRelativeX - corners[index].expectedX);
          const errorY = Math.abs(point.videoRelativeY - corners[index].expectedY);
          const error = Math.sqrt(errorX * errorX + errorY * errorY);
          totalError += error;
          console.log(`${corners[index].name} 误差: ${(error * 100).toFixed(1)}%`);
        }
      });
      
      const avgError = (totalError / this.calibrationPoints.length * 100).toFixed(1);
      this.$message.info(`校准完成，平均误差: ${avgError}%`);
      
      this.calibrationMode = false;
      this.calibrationPoints = [];
    },

    /** 切换网格显示 */
    toggleGrid() {
      this.showGrid = !this.showGrid;
      
      if (this.showGrid) {
        this.$message.info('网格已显示，可以验证坐标一致性');
        this.$nextTick(() => {
          this.drawGrid();
        });
      } else {
        this.$message.info('网格已隐藏');
      }
    },

    /** 绘制坐标网格 */
    drawGrid() {
      const video = this.$refs.remoteVideo;
      const gridContainer = this.$refs.coordinateGrid;
      
      if (!video || !gridContainer) {
        return;
      }

      // 优先使用从Android端获取的真实设备分辨率
      let deviceWidth, deviceHeight;
      
      if (this.deviceResolution) {
        deviceWidth = this.deviceResolution.width;
        deviceHeight = this.deviceResolution.height;
      } else if (this.currentStats.resolution) {
        [deviceWidth, deviceHeight] = this.currentStats.resolution.split('x').map(Number);
      } else {
        console.warn('无法获取设备分辨率，无法绘制网格');
        return;
      }

      // 清空现有网格
      const gridLines = gridContainer.querySelector('.grid-lines');
      const gridLabels = gridContainer.querySelector('.grid-labels');
      gridLines.innerHTML = '';
      gridLabels.innerHTML = '';
      const { width: videoContentWidth, height: videoContentHeight, offsetX, offsetY } = this.getVideoContentRect();

      // 绘制网格线（4x4网格）
      const gridSize = 4;
      for (let i = 0; i <= gridSize; i++) {
        // 垂直线
        const vLine = document.createElement('div');
        vLine.style.cssText = `
          position: absolute;
          left: ${offsetX + (i * videoContentWidth / gridSize)}px;
          top: ${offsetY}px;
          width: 1px;
          height: ${videoContentHeight}px;
          background: rgba(255, 255, 255, 0.5);
          pointer-events: none;
        `;
        gridLines.appendChild(vLine);

        // 水平线
        const hLine = document.createElement('div');
        hLine.style.cssText = `
          position: absolute;
          left: ${offsetX}px;
          top: ${offsetY + (i * videoContentHeight / gridSize)}px;
          width: ${videoContentWidth}px;
          height: 1px;
          background: rgba(255, 255, 255, 0.5);
          pointer-events: none;
        `;
        gridLines.appendChild(hLine);
      }

      // 添加坐标标签 - 使用设备分辨率
      for (let row = 0; row < gridSize; row++) {
        for (let col = 0; col < gridSize; col++) {
          const x = Math.round((col + 0.5) * deviceWidth / gridSize);
          const y = Math.round((row + 0.5) * deviceHeight / gridSize);
          
          const label = document.createElement('div');
          label.textContent = `${x},${y}`;
          label.style.cssText = `
            position: absolute;
            left: ${offsetX + (col + 0.5) * videoContentWidth / gridSize - 20}px;
            top: ${offsetY + (row + 0.5) * videoContentHeight / gridSize - 8}px;
            color: white;
            font-size: 10px;
            background: rgba(0, 0, 0, 0.7);
            padding: 2px 4px;
            border-radius: 2px;
            pointer-events: none;
            text-align: center;
            min-width: 40px;
          `;
          gridLabels.appendChild(label);
        }
      }
    },

    /** 显示坐标信息（调试用） */
    showCoordinateInfo(event, coords) {
      // 优先使用从Android端获取的真实设备分辨率
      let deviceWidth, deviceHeight;
      
      if (this.deviceResolution) {
        deviceWidth = this.deviceResolution.width;
        deviceHeight = this.deviceResolution.height;
      } else if (this.currentStats.resolution) {
        [deviceWidth, deviceHeight] = this.currentStats.resolution.split('x').map(Number);
      } else {
        return;
      }

      // 计算百分比位置 - 基于设备分辨率
      const percentX = ((coords.x / deviceWidth) * 100).toFixed(1);
      const percentY = ((coords.y / deviceHeight) * 100).toFixed(1);

      // 创建信息显示框
      const infoBox = document.createElement('div');
      infoBox.textContent = `${coords.x},${coords.y} (${percentX}%,${percentY}%)`;
      infoBox.style.cssText = `
        position: fixed;
        left: ${event.clientX + 10}px;
        top: ${event.clientY - 30}px;
        background: rgba(0, 0, 0, 0.8);
        color: white;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        pointer-events: none;
        z-index: 10000;
        white-space: nowrap;
      `;

      document.body.appendChild(infoBox);

      // 2秒后移除
      setTimeout(() => {
        if (infoBox.parentNode) {
          infoBox.parentNode.removeChild(infoBox);
        }
      }, 2000);
    },

    /** 处理键盘事件 */
    handleKeyDown(event) {
      // 只在投屏对话框打开时处理
      if (!this.visible) return;
      
      // Ctrl+D 切换调试模式
      if (event.ctrlKey && event.key === 'd') {
        event.preventDefault();
        this.debugMode = !this.debugMode;
        this.$message.info(`调试模式已${this.debugMode ? '开启' : '关闭'}`);
        console.log(`🔧 调试模式: ${this.debugMode ? 'ON' : 'OFF'}`);
      }
      
      // Ctrl+G 切换网格显示
      if (event.ctrlKey && event.key === 'g') {
        event.preventDefault();
        this.toggleGrid();
      }
    },

    /** 处理鼠标按下事件 */
    handleVideoMouseDown(event) {
      if (!this.isStreaming || !this.mqttClient) {
        return;
      }
      this.beginGesture(event, 'mouse');
      event.preventDefault();
    },

    /** 处理鼠标移动事件 */
    handleVideoMouseMove(event) {
      if (!this.isDraggingVideo || !this.isStreaming || !this.mqttClient) {
        return;
      }

      event.preventDefault();
    },

    /** 处理鼠标释放事件 */
    handleVideoMouseUp(event) {
      if (!this.isDraggingVideo || !this.isStreaming || !this.mqttClient) {
        return;
      }
      this.finishGesture(event, 'mouse');
      event.preventDefault();
    },

    /** 处理触摸开始事件 */
    handleVideoTouchStart(event) {
      if (!this.isStreaming || !this.mqttClient) {
        return;
      }

      const touch = event.touches[0];
      this.beginGesture(touch, 'touch');
      event.preventDefault();
    },

    /** 处理触摸移动事件 */
    handleVideoTouchMove(event) {
      if (!this.isDraggingVideo || !this.isStreaming || !this.mqttClient) {
        return;
      }

      event.preventDefault();
    },

    /** 处理触摸结束事件 */
    handleVideoTouchEnd(event) {
      if (!this.isDraggingVideo || !this.isStreaming || !this.mqttClient) {
        return;
      }

      const touch = event.changedTouches[0];
      this.finishGesture(touch, 'touch');
      event.preventDefault();
    },

    beginGesture(pointEvent, pointerType) {
      const coords = this.getVideoCoordinates(pointEvent);
      if (!coords) {
        this.isDraggingVideo = false;
        return;
      }

      this.isDraggingVideo = true;
      this.lastPointerType = pointerType;
      this.gestureStartTime = Date.now();
      this.gestureStartClientX = pointEvent.clientX;
      this.gestureStartClientY = pointEvent.clientY;
      this.gestureStartX = coords.x;
      this.gestureStartY = coords.y;
    },

    finishGesture(pointEvent, pointerType) {
      const coords = this.getVideoCoordinates(pointEvent);
      if (!coords) {
        this.cancelGesture();
        return;
      }

      const durationMs = Date.now() - this.gestureStartTime;
      const screenDragDistance = Math.hypot(
        pointEvent.clientX - this.gestureStartClientX,
        pointEvent.clientY - this.gestureStartClientY
      );
      const deviceDragDistance = Math.hypot(
        coords.x - this.gestureStartX,
        coords.y - this.gestureStartY
      );
      const swipeThreshold = pointerType === 'touch' ? 8 : 12;

      if (screenDragDistance >= swipeThreshold || deviceDragDistance >= 18) {
        this.showSwipeTrail(this.gestureStartClientX, this.gestureStartClientY, pointEvent.clientX, pointEvent.clientY);
        if (this.calibrationMode) {
          this.$message.info('校准模式下不支持滑动，请点击四个角落');
        } else {
          this.sendTouchEvent('swipe', {
            x1: this.gestureStartX,
            y1: this.gestureStartY,
            x2: coords.x,
            y2: coords.y,
            durationMs: Math.max(140, Math.min(900, durationMs))
          });
        }
        this.cancelGesture();
        return;
      }

      if (this.calibrationMode) {
        this.showClickMarker(pointEvent.clientX, pointEvent.clientY);
        this.addCalibrationPoint(pointEvent, coords);
        this.cancelGesture();
        return;
      }

      if (durationMs >= 380) {
        this.showClickMarker(pointEvent.clientX, pointEvent.clientY);
        this.sendTouchEvent('longPress', {
          x: coords.x,
          y: coords.y,
          durationMs: Math.max(380, Math.min(1200, durationMs))
        });
        this.cancelPendingTap();
      } else {
        this.queueTap(coords, pointEvent);
      }

      this.isDraggingVideo = false;
    },

    queueTap(coords, pointEvent) {
      const now = Date.now();
      const maxInterval = 260;
      const maxDistance = 28;

      if (this.pendingTap) {
        const isNear = Math.hypot(coords.x - this.pendingTap.x, coords.y - this.pendingTap.y) <= maxDistance;
        const isFast = now - this.pendingTap.timestamp <= maxInterval;
        if (isNear && isFast) {
          this.showClickMarker(pointEvent.clientX, pointEvent.clientY);
          this.cancelPendingTap();
          this.sendTouchEvent('doubleClick', { x: coords.x, y: coords.y });
          return;
        }
      }

      this.cancelPendingTap();
      this.pendingTap = {
        x: coords.x,
        y: coords.y,
        clientX: pointEvent.clientX,
        clientY: pointEvent.clientY,
        timestamp: now
      };
      this.pendingSingleTapTimer = setTimeout(() => {
        if (!this.pendingTap) {
          return;
        }
        this.showClickMarker(this.pendingTap.clientX, this.pendingTap.clientY);
        this.sendTouchEvent('click', { x: this.pendingTap.x, y: this.pendingTap.y });
        this.showCoordinateInfo(
          { clientX: this.pendingTap.clientX, clientY: this.pendingTap.clientY },
          { x: this.pendingTap.x, y: this.pendingTap.y }
        );
        this.pendingTap = null;
        this.pendingSingleTapTimer = null;
      }, maxInterval);
    },

    cancelPendingTap() {
      if (this.pendingSingleTapTimer) {
        clearTimeout(this.pendingSingleTapTimer);
        this.pendingSingleTapTimer = null;
      }
      this.pendingTap = null;
    },

    cancelGesture() {
      this.isDraggingVideo = false;
    },

    /** 显示点击位置的可视化标记 */
    showClickMarker(clientX, clientY) {
      // 创建点击标记元素
      const marker = document.createElement('div');
      marker.style.cssText = `
        position: fixed;
        left: ${clientX - 10}px;
        top: ${clientY - 10}px;
        width: 20px;
        height: 20px;
        border: 2px solid #ff4444;
        border-radius: 50%;
        background: rgba(255, 68, 68, 0.3);
        pointer-events: none;
        z-index: 9999;
        animation: clickMarker 1s ease-out forwards;
      `;

      // 添加CSS动画
      if (!document.getElementById('clickMarkerStyle')) {
        const style = document.createElement('style');
        style.id = 'clickMarkerStyle';
        style.textContent = `
          @keyframes clickMarker {
            0% { transform: scale(0.5); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.8; }
            100% { transform: scale(1.5); opacity: 0; }
          }
        `;
        document.head.appendChild(style);
      }

      document.body.appendChild(marker);

      // 1秒后移除标记
      setTimeout(() => {
        if (marker.parentNode) {
          marker.parentNode.removeChild(marker);
        }
      }, 1000);
    },

    /** 显示滑动轨迹的可视化标记 */
    showSwipeTrail(startClientX, startClientY, endClientX, endClientY) {
      // 创建滑动轨迹线
      const trail = document.createElement('div');
      
      const deltaX = endClientX - startClientX;
      const deltaY = endClientY - startClientY;
      const length = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      const angle = Math.atan2(deltaY, deltaX) * 180 / Math.PI;
      
      trail.style.cssText = `
        position: fixed;
        left: ${startClientX}px;
        top: ${startClientY}px;
        width: ${length}px;
        height: 3px;
        background: linear-gradient(to right, #409EFF, #67C23A);
        transform-origin: 0 50%;
        transform: rotate(${angle}deg);
        pointer-events: none;
        z-index: 9999;
        border-radius: 2px;
        animation: swipeTrail 1.5s ease-out forwards;
      `;

      // 添加CSS动画
      if (!document.getElementById('swipeTrailStyle')) {
        const style = document.createElement('style');
        style.id = 'swipeTrailStyle';
        style.textContent = `
          @keyframes swipeTrail {
            0% { opacity: 1; transform: rotate(${angle}deg) scaleX(0); }
            30% { opacity: 1; transform: rotate(${angle}deg) scaleX(1); }
            100% { opacity: 0; transform: rotate(${angle}deg) scaleX(1); }
          }
        `;
        document.head.appendChild(style);
      }

      document.body.appendChild(trail);

      // 添加起始和结束点标记
      this.showClickMarker(startClientX, startClientY);
      setTimeout(() => {
        this.showClickMarker(endClientX, endClientY);
      }, 300);

      // 1.5秒后移除轨迹
      setTimeout(() => {
        if (trail.parentNode) {
          trail.parentNode.removeChild(trail);
        }
      }, 1500);
    },

    /** 切换校准模式 */
    toggleCalibration() {
      this.calibrationMode = !this.calibrationMode;
      this.calibrationPoints = [];
      
      if (this.calibrationMode) {
        this.$message.info('校准模式已开启，点击视频中的四个角落进行校准');
      } else {
        this.$message.info('校准模式已关闭');
      }
    },

    /** 获取视频坐标并转换为设备坐标 */
    getVideoCoordinates(event) {
      const video = this.$refs.remoteVideo;
      if (!video) {
        console.warn('视频元素不可用');
        return null;
      }

      // 优先使用从Android端获取的真实设备分辨率
      let deviceWidth, deviceHeight;
      
      if (this.deviceResolution) {
        deviceWidth = this.deviceResolution.width;
        deviceHeight = this.deviceResolution.height;
        console.log(`使用真实设备分辨率: ${deviceWidth}x${deviceHeight}`);
      } else if (this.currentStats.resolution) {
        // 备用方案：使用视频流分辨率（可能不准确）
        [deviceWidth, deviceHeight] = this.currentStats.resolution.split('x').map(Number);
        console.warn(`使用视频流分辨率作为备用: ${deviceWidth}x${deviceHeight}`);
      } else {
        console.warn('无法获取设备分辨率信息');
        return null;
      }
      
      if (!deviceWidth || !deviceHeight) {
        console.warn('设备分辨率数据无效:', { deviceWidth, deviceHeight });
        return null;
      }

      // 获取视频元素的边界矩形
      const rect = video.getBoundingClientRect();
      const clickX = event.clientX - rect.left;
      const clickY = event.clientY - rect.top;
      const contentRect = this.getVideoContentRect();

      if (this.debugMode) {
        console.log(`=== 坐标转换调试 ===`);
        console.log(`点击位置: (${clickX.toFixed(1)}, ${clickY.toFixed(1)})`);
        console.log(`视频显示区域: ${rect.width}x${rect.height}`);
        console.log(`设备分辨率: ${deviceWidth}x${deviceHeight}`);
        if (this.videoResolution) {
          console.log(`视频传输分辨率: ${this.videoResolution.width}x${this.videoResolution.height}`);
        }
      }

      if (this.debugMode) {
        console.log(`视频内容区域: ${contentRect.width.toFixed(1)}x${contentRect.height.toFixed(1)}`);
        console.log(`内容偏移: (${contentRect.offsetX.toFixed(1)}, ${contentRect.offsetY.toFixed(1)})`);
      }

      if (clickX < contentRect.offsetX || clickX > contentRect.offsetX + contentRect.width ||
          clickY < contentRect.offsetY || clickY > contentRect.offsetY + contentRect.height) {
        console.warn('点击在视频内容区域外（黑边区域）');
        return null;
      }

      const relativeX = (clickX - contentRect.offsetX) / contentRect.width;
      const relativeY = (clickY - contentRect.offsetY) / contentRect.height;
      const deviceX = Math.round(relativeX * (deviceWidth - 1));
      const deviceY = Math.round(relativeY * (deviceHeight - 1));
      const finalX = Math.max(0, Math.min(deviceWidth - 1, deviceX));
      const finalY = Math.max(0, Math.min(deviceHeight - 1, deviceY));

      // 详细调试信息（仅在调试模式下显示）
      if (this.debugMode) {
        console.log(`相对位置: (${relativeX.toFixed(4)}, ${relativeY.toFixed(4)})`);
        console.log(`计算设备坐标: (${deviceX}, ${deviceY})`);
        console.log(`最终设备坐标: (${finalX}, ${finalY})`);
        
        // 添加一致性验证：计算理论上的相对位置
        const theoreticalRelativeX = finalX / deviceWidth;
        const theoreticalRelativeY = finalY / deviceHeight;
        console.log(`验证相对位置: (${theoreticalRelativeX.toFixed(4)}, ${theoreticalRelativeY.toFixed(4)})`);
        console.log(`相对位置误差: (${Math.abs(relativeX - theoreticalRelativeX).toFixed(6)}, ${Math.abs(relativeY - theoreticalRelativeY).toFixed(6)})`);
        console.log(`=== 转换完成 ===`);
      } else {
        // 简化输出：只显示最终结果
        console.log(`点击转换: (${clickX.toFixed(0)}, ${clickY.toFixed(0)}) → 设备(${finalX}, ${finalY}) [${(relativeX*100).toFixed(1)}%, ${(relativeY*100).toFixed(1)}%]`);
      }

      return { x: finalX, y: finalY };
    },

    getVideoContentRect() {
      const video = this.$refs.remoteVideo;
      if (!video) {
        return { width: 0, height: 0, offsetX: 0, offsetY: 0 };
      }

      const rect = video.getBoundingClientRect();
      const sourceWidth = video.videoWidth || (this.videoResolution && this.videoResolution.width) || (this.deviceResolution && this.deviceResolution.width) || rect.width;
      const sourceHeight = video.videoHeight || (this.videoResolution && this.videoResolution.height) || (this.deviceResolution && this.deviceResolution.height) || rect.height;

      if (!sourceWidth || !sourceHeight || !rect.width || !rect.height) {
        return { width: rect.width, height: rect.height, offsetX: 0, offsetY: 0 };
      }

      const sourceAspectRatio = sourceWidth / sourceHeight;
      const displayAspectRatio = rect.width / rect.height;

      if (sourceAspectRatio > displayAspectRatio) {
        return {
          width: rect.width,
          height: rect.width / sourceAspectRatio,
          offsetX: 0,
          offsetY: (rect.height - rect.width / sourceAspectRatio) / 2
        };
      }

      return {
        width: rect.height * sourceAspectRatio,
        height: rect.height,
        offsetX: (rect.width - rect.height * sourceAspectRatio) / 2,
        offsetY: 0
      };
    },

    /** 发送触摸事件到设备 */
    sendTouchEvent(action, payload) {
      if (!this.mqttClient && !(this.webrtcManager && this.webrtcManager.isDataChannelOpen())) {
        console.warn('控制通道未连接，无法发送触摸事件');
        return;
      }

      const touchMessage = {
        type: 'control',
        action: action,
        deviceName: this.deviceName,
        from: 'frontend',
        ...payload
      };

      if (this.webrtcManager && this.webrtcManager.isDataChannelOpen()) {
        const sent = this.webrtcManager.sendMessage(touchMessage);
        if (sent) {
          return;
        }
      }

      const topic = `control/${this.username}/${this.deviceName}`;
      
      this.mqttClient.publish(topic, JSON.stringify(touchMessage), { qos: 1 }, (err) => {
        if (err) {
          console.error('发送触摸事件失败:', err);
        } else {
          console.log(`✓ 发送${action}事件:`, touchMessage);
        }
      });
    }
  }
};
</script>

<style>
/* 投屏弹窗专用样式 - 点击穿透设置 */
.el-dialog__wrapper:has(.screencast-control-dialog) {
  pointer-events: none !important;
}

.screencast-control-dialog {
  pointer-events: auto !important;
}

/* 强制移除弹窗的所有边距和边框 */
::v-deep .el-dialog__wrapper .screencast-control-dialog {
  margin: 0 !important;
  padding: 0 !important;
  border: none !important;
  box-shadow: none !important;
}
</style>

<style scoped>
/* 投屏控制弹窗 - 简洁直角风格 */
.screencast-wrapper {
  position: relative;
  width: 100%;
  background: #000;
  display: flex;
  flex-direction: column;
}

/* 主内容区 - 视频和功能栏并排 */
.main-content {
  display: flex;
  flex: 1;
  overflow: hidden;
}

/* 顶部工具栏 */
.top-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 15px;
  background: rgba(0, 0, 0, 0.8);
  color: #fff;
  position: relative;
  z-index: 10;
  cursor: move;
  user-select: none;
}

.device-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.device-name {
  font-size: 14px;
  font-weight: 500;
}

.latency-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.3s;
}

.latency-badge i {
  font-size: 12px;
}

.latency-unknown {
  background: rgba(144, 147, 153, 0.3);
  color: #909399;
}

.latency-excellent {
  background: rgba(103, 194, 58, 0.3);
  color: #67C23A;
}

.latency-good {
  background: rgba(103, 194, 58, 0.2);
  color: #85CE61;
}

.latency-fair {
  background: rgba(230, 162, 60, 0.3);
  color: #E6A23C;
}

.latency-poor {
  background: rgba(245, 108, 108, 0.3);
  color: #F56C6C;
}

.fps-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.3s;
}

.fps-badge i {
  font-size: 12px;
}

.fps-unknown {
  background: rgba(144, 147, 153, 0.3);
  color: #909399;
}

.fps-excellent {
  background: rgba(103, 194, 58, 0.3);
  color: #67C23A;
}

.fps-good {
  background: rgba(103, 194, 58, 0.2);
  color: #85CE61;
}

.fps-fair {
  background: rgba(230, 162, 60, 0.3);
  color: #E6A23C;
}

.fps-poor {
  background: rgba(245, 108, 108, 0.3);
  color: #F56C6C;
}

.toolbar-actions {
  display: flex;
  gap: 15px;
}

.toolbar-actions i {
  font-size: 18px;
  cursor: pointer;
  transition: opacity 0.2s;
}

.toolbar-actions i:hover {
  opacity: 0.7;
}

/* 视频容器 - 固定大小窗口优化 */
.video-container {
  position: relative;
  flex: 1;
  background: #000;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 0; /* 确保flex子元素可以缩小 */
}

.video-stream {
  width: 100%;
  height: 100%;
  object-fit: contain; /* 完整显示视频内容，保持宽高比，不裁剪 */
}

/* 坐标网格覆盖层 */
.coordinate-grid {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 5;
}

.grid-lines {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.grid-labels {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.stream-placeholder {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  color: #fff;
}

.stream-placeholder i {
  font-size: 50px;
  margin-bottom: 12px;
  display: block;
  opacity: 0.6;
}

.stream-placeholder p {
  font-size: 13px;
  margin: 0;
  opacity: 0.6;
}

/* 右侧功能栏 */
.side-toolbar {
  display: flex;
  flex-direction: column;
  width: 40px;
  background: rgba(20, 20, 20, 0.98);
  border-left: 1px solid rgba(255, 255, 255, 0.1);
  flex-shrink: 0;
}

.toolbar-divider {
  flex: 1;
  min-height: 1px;
  background: transparent;
  margin: 0;
}

.toolbar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 40px;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  user-select: none;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  position: relative;
}

.toolbar-item:last-child {
  border-bottom: none;
}

.toolbar-item:hover:not(.disabled) {
  background: rgba(64, 158, 255, 0.15);
}

.toolbar-item:hover:not(.disabled)::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #409EFF;
}

.toolbar-item.disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.toolbar-item.active {
  background: rgba(64, 158, 255, 0.1);
  border-left: 2px solid #409EFF;
}

.toolbar-item i {
  font-size: 16px;
}

/* 设置面板 */
.settings-panel {
  position: absolute;
  top: 50px;
  right: 10px;
  background: rgba(0, 0, 0, 0.9);
  color: #fff;
  padding: 15px;
  min-width: 220px;
  max-width: 280px;
  z-index: 20;
  border-radius: 4px;
  max-height: calc(100vh - 100px);
  overflow-y: auto;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.setting-item:last-child {
  margin-bottom: 0;
}

.setting-item span {
  font-size: 13px;
  margin-right: 10px;
}

.stats-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.2);
  margin: 15px 0;
}

.stats-section {
  margin-top: 10px;
}

.stats-title {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 10px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.setting-section-title {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
  margin: 10px 0 8px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stats-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  font-size: 12px;
}

.stats-item span:first-child {
  color: rgba(255, 255, 255, 0.7);
}

.stats-item span:last-child {
  color: #67C23A;
  font-weight: 500;
}

.stats-warning {
  color: #F56C6C !important;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .screencast-wrapper {
    height: 100vh;
    max-height: none;
  }

  .top-toolbar {
    padding: 10px 12px;
  }

  .device-name {
    font-size: 13px;
  }

  .toolbar-actions i {
    font-size: 16px;
  }

  .main-content {
    flex-direction: column;
  }

  .side-toolbar {
    width: 100%;
    flex-direction: row;
    height: 60px;
    border-left: none;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
  }

  .toolbar-item {
    flex: 1;
    height: 100%;
    border-bottom: none;
    border-right: 1px solid rgba(255, 255, 255, 0.08);
  }

  .toolbar-item:last-child {
    border-right: none;
  }

  .toolbar-item:hover:not(.disabled)::before {
    left: 0;
    right: 0;
    top: 0;
    bottom: auto;
    width: auto;
    height: 3px;
  }

  .toolbar-item i {
    font-size: 16px;
  }

  .settings-panel {
    top: 45px;
    right: 8px;
    padding: 12px;
    min-width: 180px;
  }
}

/* 弹窗样式 - 移除圆角和边距 */
::v-deep .screencast-control-dialog {
  border-radius: 0;
  margin: 0 !important;
}

::v-deep .screencast-control-dialog .el-dialog__header {
  display: none;
}

::v-deep .screencast-control-dialog .el-dialog__body {
  padding: 0;
  margin: 0;
  background: #000;
}

::v-deep .screencast-control-dialog .el-dialog__headerbtn {
  display: none;
}

/* 全屏模式 */
::v-deep .screencast-control-dialog.el-dialog--fullscreen {
  margin: 0 !important;
  padding: 0 !important;
}

::v-deep .screencast-control-dialog.el-dialog--fullscreen .screencast-wrapper {
  height: 100vh;
  max-height: none;
}

/* 设置面板中的select样式 */
::v-deep .settings-panel .el-select {
  width: 110px;
}

::v-deep .settings-panel .el-input__inner {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
  color: #fff;
}

/* 缩放手柄 */
.resize-handles {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.resize-handle {
  position: absolute;
  pointer-events: auto;
  z-index: 100;
}

.resize-right {
  right: 0;
  top: 0;
  width: 5px;
  height: 100%;
  cursor: ew-resize;
}

.resize-bottom {
  bottom: 0;
  left: 0;
  width: 100%;
  height: 5px;
  cursor: ns-resize;
}

.resize-corner {
  right: 0;
  bottom: 0;
  width: 15px;
  height: 15px;
  cursor: nwse-resize;
  background: rgba(255, 255, 255, 0.3);
}

.resize-corner::after {
  content: '';
  position: absolute;
  right: 2px;
  bottom: 2px;
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 0 0 10px 10px;
  border-color: transparent transparent rgba(255, 255, 255, 0.5) transparent;
}
</style>
