<template>
  <el-dialog
    :visible.sync="visible"
    :width="dialogWidth + 'px'"
    :fullscreen="isMobile || isDialogFullscreen"
    :show-close="false"
    :close-on-click-modal="false"
    :modal="false"
    custom-class="screencast-control-dialog"
    @close="handleClose"
    @open="handleOpen"
  >
    <div class="screencast-wrapper" :style="{ height: dialogHeight + 'px' }">
      <!-- 顶部工具栏 - 可拖动 -->
      <div class="top-toolbar" :class="{ 'fullscreen-mode': isDialogFullscreen }" @mousedown="startDrag">
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
          <i class="el-icon-refresh" @click.stop="reconnectScreencast" :class="{ disabled: !mqttClient }" title="重新连接"></i>
          <i class="el-icon-setting" @click.stop="showSettings = !showSettings" title="设置"></i>
          <i class="el-icon-close" @click.stop="closeDialog" title="关闭"></i>
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
          
          <div v-if="!isStreaming" class="stream-placeholder">
            <i class="el-icon-loading" v-if="connectionStatus === 'connecting'"></i>
            <i class="el-icon-video-camera" v-else></i>
            <p>{{ statusText }}</p>
          </div>
        </div>

        <!-- 右侧功能栏 -->
        <div class="video-overlay-toolbar">
          <div class="side-toolbar">
            <div class="toolbar-item" @click.stop="rotateDeviceScreen" :class="{ disabled: !mqttClient }" title="rotate">
              <i class="el-icon-refresh-right"></i>
            </div>
            <div class="toolbar-item" @click.stop="adjustDeviceVolume('up')" :class="{ disabled: !mqttClient }" title="volume up">
              <i class="el-icon-plus"></i>
            </div>
            <div class="toolbar-item" @click.stop="adjustDeviceVolume('down')" :class="{ disabled: !mqttClient }" title="volume down">
              <i class="el-icon-minus"></i>
            </div>
            <div class="toolbar-item" @click.stop="toggleDialogFullscreen" :class="{ disabled: !isStreaming }" :title="isDialogFullscreen ? '退出全屏' : '全屏'">
              <i :class="isDialogFullscreen ? 'el-icon-rank' : 'el-icon-full-screen'"></i>
            </div>
            <div class="toolbar-item" @click.stop="copyAndroidClipboardToWeb" :class="{ disabled: !mqttClient }" title="copy to web">
              <i class="el-icon-document-copy"></i>
            </div>
            <div class="toolbar-item" @click.stop="captureScreenshot" :class="{ disabled: !isStreaming }" title="screenshot">
              <i class="el-icon-picture"></i>
            </div>
            <div class="toolbar-item" @click.stop="pushWebClipboardToAndroid" :class="{ disabled: !mqttClient }" title="write to android">
              <i class="el-icon-edit-outline"></i>
            </div>
            <div class="toolbar-item" @click.stop="openFileManagerDialog" :class="{ disabled: !mqttClient }" title="file manager">
              <i class="el-icon-folder-opened"></i>
            </div>
          </div>

          <div class="bottom-toolbar">
            <div class="bottom-toolbar-item" @click.stop="sendVirtualKey('menu')" :class="{ disabled: !mqttClient }" title="task">
              <i class="el-icon-menu"></i>
            </div>
            <div class="bottom-toolbar-item" @click.stop="sendVirtualKey('home')" :class="{ disabled: !mqttClient }" title="home">
              <i class="el-icon-s-home"></i>
            </div>
            <div class="bottom-toolbar-item" @click.stop="sendVirtualKey('back')" :class="{ disabled: !mqttClient }" title="back">
              <i class="el-icon-back"></i>
            </div>
          </div>
        </div>
      </div>
      <div class="settings-panel" v-show="showSettings" @click.stop>
        <!-- 设置面板 -->
        <div class="setting-item">
          <span>传输质量</span>
          <el-select v-model="currentQuality" size="mini" @change="applyQualityPreset">
            <el-option label="高清" value="high" />
            <el-option label="标清" value="medium" />
            <el-option label="流畅" value="low" />
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
      <div class="resize-handles" v-if="!isMobile && !isDialogFullscreen">
        <div class="resize-handle resize-right" @mousedown="startResize($event, 'right')"></div>
        <div class="resize-handle resize-bottom" @mousedown="startResize($event, 'bottom')"></div>
        <div class="resize-handle resize-corner" @mousedown="startResize($event, 'corner')"></div>
      </div>
    </div>

    <!-- 文件管理对话框 -->
    <FileManagerDialog
      v-model="fileManagerDialogVisible"
      :device-name="deviceName"
      :username="username"
      :mqtt-client="mqttClient"
      :default-path="uploadTargetPath"
    />
  </el-dialog>
</template>

<script>
import WebRTCManager from '@/utils/webrtc/WebRTCManager';
import FileManagerDialog from '../device/FileManagerDialog.vue';
import {
  CoordinateConverter,
  GestureRecognizer,
  DeviceController,
  StatsMonitor,
  VideoPlayer
} from '@/utils/screencast';

export default {
  name: 'ScreencastDialog',
  components: {
    FileManagerDialog
  },
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
      dialogWidth: 400,
      dialogHeight: 760,
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

      // 新模块实例
      coordinateConverter: null,
      gestureRecognizer: null,
      deviceController: null,
      statsMonitor: null,
      videoPlayer: null,

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

      qualityPresets: {
        high: { resolution: '1920x1080', frameRate: 30, label: '高清' },
        medium: { resolution: '1280x720', frameRate: 24, label: '标清' },
        low: { resolution: '854x480', frameRate: 20, label: '流畅' }
      },
      currentQuality: 'high',
      videoFitMode: 'contain',

      isMobile: false,
      isDialogFullscreen: false,
      debugStatsLogged: false, // 调试标志，避免重复输出统计类型
      
      // 触摸和拖拽状态
      isDraggingVideo: false,
      gestureStartTime: 0,
      gestureStartX: 0,
      gestureStartY: 0,
      gestureStartClientX: 0,
      gestureStartClientY: 0,
      gesturePath: [],
      longPressTimer: null,
      longPressTriggered: false,
      longPressSent: false,
      touchDownSent: false,
      lastTouchMoveSentAt: 0,
      lastTouchMoveX: 0,
      lastTouchMoveY: 0,
      lastPointerType: 'mouse',
      
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
      pendingStreamId: '',
      isReconnecting: false,
      
      // 文件管理对话框
      fileManagerDialogVisible: false,
      uploadTargetPath: ''
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
    this.initModules();
    this.initWebRTC();
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('mouseup', this.handleMouseUp);
    window.addEventListener('resize', this.handleViewportResize);
    
    // 添加键盘事件监听
    document.addEventListener('keydown', this.handleKeyDown);
  },

  beforeDestroy() {
    this.cleanup();
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);
    document.removeEventListener('keydown', this.handleKeyDown);
    window.removeEventListener('resize', this.handleViewportResize);
  },
  methods: {
    /** 初始化模块 */
    initModules() {
      // 初始化坐标转换器
      this.coordinateConverter = new CoordinateConverter();
      
      // 初始化手势识别器
      this.gestureRecognizer = new GestureRecognizer({
        longPressDelay: 420,
        clickThreshold: 10,
        swipeThreshold: 20,
        moveThrottleDelay: 16
      });
      
      // 初始化设备控制器
      this.deviceController = new DeviceController(
        this.mqttClient,
        this.username,
        this.deviceName
      );
      
      console.log('[ScreencastDialog] 模块初始化完成');
    },

    getEffectiveDeviceResolution() {
      if (this.deviceResolution && this.deviceResolution.width && this.deviceResolution.height) {
        return {
          width: this.deviceResolution.width,
          height: this.deviceResolution.height
        };
      }
      return null;
    },

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

      this.webrtcManager.on('track', async (stream, { audioTracks, videoTracks }) => {
        console.log('收到视频流，使用VideoPlayer处理...');
        
        try {
          // 初始化视频播放器（如果还没有）
          if (!this.videoPlayer && this.$refs.remoteVideo) {
            this.videoPlayer = new VideoPlayer(this.$refs.remoteVideo, {
              enableLowLatency: true,
              maxBufferSize: 0.5,
              targetLatency: 0.1,
              enableLogging: false
            });
            
            // 设置播放回调
            this.videoPlayer.setOnPlay(() => {
              this.isStreaming = true;
              this.statusText = '正在播放';
              console.log('✓ 视频开始播放');
            });
            
            this.videoPlayer.setOnBuffering((isBuffering) => {
              if (isBuffering) {
                console.log('视频缓冲中...');
              }
            });
          }
          
          // 设置视频流
          if (this.videoPlayer) {
            await this.videoPlayer.setStream(stream);
            this.startStatsMonitoring();
            
            if (audioTracks.length > 0 && videoTracks.length > 0) {
              this.$message.success('视频和音频流已连接');
            } else if (videoTracks.length > 0) {
              this.$message.warning('视频流已连接，但没有音频');
            }
          }
        } catch (error) {
          console.error('设置视频流失败:', error);
          this.$message.error('视频播放失败: ' + error.message);
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
      this.isMobile = window.innerWidth <= 768;
    },

    getPcDialogHeight() {
      return Math.min(760, Math.max(620, window.innerHeight - 48));
    },

    centerDialog() {
      if (this.isMobile) return;

      this.$nextTick(() => {
        const dialog = document.querySelector('.screencast-control-dialog');
        if (!dialog) return;

        const left = Math.max(16, Math.round((window.innerWidth - this.dialogWidth) / 2));
        const top = Math.max(24, Math.round((window.innerHeight - this.dialogHeight) / 2));

        dialog.style.left = left + 'px';
        dialog.style.top = top + 'px';
        dialog.style.margin = '0';

        this.dialogLeft = left;
        this.dialogTop = top;
      });
    },

    handleViewportResize() {
      this.checkMobile();
      if (!this.visible) return;
      this.autoResizeDialog();
    },

    /** 弹窗打开时自动连接 */
    handleOpen() {
      console.log('=== 开始投屏 ===');
      console.log('设备名称:', this.deviceName);
      console.log('MQTT连接状态:', !!this.mqttClient);
      console.log('用户名:', this.username);

      // 初始化弹窗大小
      this.autoResizeDialog();
      this.centerDialog();

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

      // 更新设备控制器配置
      if (this.deviceController) {
        this.deviceController.updateConfig(
          this.mqttClient,
          this.username,
          this.deviceName
        );
        console.log('[ScreencastDialog] 设备控制器配置已更新');
      }

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
      
      if (data.type === 'clipboard-content') {
        this.writeTextToWebClipboard(data.text || '');
        return;
      }
      if (data.type === 'clipboard-write-confirmation') {
        this.$message.success('安卓剪切板已更新');
        return;
      }
      if (data.type === 'volume-confirmation') {
        this.$message.success(`音量已${data.direction === 'up' ? '调高' : '调低'}`);
        return;
      }
      if (data.type === 'install-app-confirmation') {
        this.$message.success('已发送安装请求到安卓端');
        return;
      }
      if (data.type === 'rotation-confirmation') {
        this.$message.success('已切换屏幕方向');
        return;
      }

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
          
          // 更新坐标转换器
          if (this.coordinateConverter) {
            this.coordinateConverter.setDeviceResolution(
              data.width,
              data.height,
              data.rotation || 0
            );
          }
          
          console.log('设备分辨率已更新，坐标转换将使用真实设备分辨率');
          
          // 只在初次收到设备分辨率时调整弹窗大小，避免视频流中断
          if (!this.initialResolutionReceived) {
            this.initialResolutionReceived = true;
            this.$nextTick(() => {
              this.autoResizeDialog();
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
          
          // 更新坐标转换器
          if (this.coordinateConverter) {
            this.coordinateConverter.setVideoResolution(data.width, data.height);
          }
          
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
        case 'orientation-change':
          console.log(`✓ 设备屏幕旋转: 设备${data.deviceWidth}x${data.deviceHeight}, 视频${data.videoWidth}x${data.videoHeight}`);
          this.$message.info('设备屏幕已旋转，正在调整窗口...');
          
          // 更新设备分辨率
          this.deviceResolution = {
            width: data.deviceWidth,
            height: data.deviceHeight
          };
          
          // 更新视频传输分辨率
          this.videoResolution = {
            width: data.videoWidth,
            height: data.videoHeight
          };
          
          // 自动调整弹窗大小以适应新的屏幕方向
          this.$nextTick(() => {
            this.autoResizeDialog();
            // 如果网格正在显示，重新绘制
            if (this.showGrid) {
              this.drawGrid();
            }
          });
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

        console.log('初始连接不发送视频质量约束，交由设备端按最高能力推流');

        await this.webrtcManager.start();
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
      if (!this.webrtcManager || !this.webrtcManager.peerConnection) {
        return;
      }

      // 停止旧的监控
      if (this.statsMonitor) {
        this.statsMonitor.stop();
      }

      // 创建新的统计监控器
      this.statsMonitor = new StatsMonitor(
        this.webrtcManager.peerConnection,
        {
          updateInterval: 1000,
          enableLogging: false
        }
      );

      // 设置统计更新回调
      this.statsMonitor.setOnStatsUpdate((stats) => {
        this.currentStats = {
          bitrate: stats.bitrate,
          fps: stats.fps,
          resolution: stats.resolution,
          packetLoss: stats.packetLoss,
          jitter: stats.jitter,
          rtt: stats.rtt
        };
      });

      // 设置质量变化回调
      this.statsMonitor.setOnQualityChange((quality) => {
        if (quality.overall === 'poor') {
          console.warn('连接质量较差，建议降低视频质量');
        }
      });

      // 开始监控
      this.statsMonitor.start();
      console.log('[ScreencastDialog] 统计监控已启动');
    },

    /** 停止统计信息监控 */
    stopStatsMonitoring() {
      if (this.statsMonitor) {
        this.statsMonitor.stop();
        this.statsMonitor = null;
        console.log('[ScreencastDialog] 统计监控已停止');
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
    async sendVirtualKey(key) {
      if (this.deviceController) {
        await this.deviceController.sendVirtualKey(key);
      }
    },

    /** 发送控制指令 */
    async adjustDeviceVolume(direction) {
      if (this.deviceController) {
        await this.deviceController.adjustVolume(direction);
      }
    },

    async copyAndroidClipboardToWeb() {
      if (this.deviceController) {
        await this.deviceController.readClipboard();
      }
    },

    async pushWebClipboardToAndroid() {
      if (!navigator.clipboard || !navigator.clipboard.readText) {
        this.$message.warning('当前浏览器不支持读取Web剪切板');
        return;
      }

      try {
        const text = await navigator.clipboard.readText();
        if (!text) {
          this.$message.warning('Web剪切板为空');
          return;
        }
        if (this.deviceController) {
          await this.deviceController.setClipboard(text);
        }
      } catch (error) {
        this.$message.error('读取Web剪切板失败: ' + error.message);
      }
    },

    async writeTextToWebClipboard(text) {
      if (!navigator.clipboard || !navigator.clipboard.writeText) {
        this.$message.warning('当前浏览器不支持写入Web剪切板');
        return;
      }

      try {
        await navigator.clipboard.writeText(text || '');
        this.$message.success('已复制到Web剪切板');
      } catch (error) {
        this.$message.error('写入Web剪切板失败: ' + error.message);
      }
    },

    /** 打开文件管理对话框 */
    openFileManagerDialog() {
      if (!this.mqttClient) {
        this.$message.warning('MQTT未连接');
        return;
      }
      this.fileManagerDialogVisible = true;
    },

    /** 打开APK安装对话框 */
    openApkInstallDialog() {
      if (!this.mqttClient) {
        this.$message.warning('MQTT未连接');
        return;
      }
      this.apkInstallDialogVisible = true;
    },

    /** 打开文件上传对话框 */
    openFileUploadDialog() {
      if (!this.mqttClient) {
        this.$message.warning('MQTT未连接');
        return;
      }
      this.fileUploadDialogVisible = true;
    },

    /** 打开文件浏览器对话框 */
    openFileBrowserDialog() {
      if (!this.mqttClient) {
        this.$message.warning('MQTT未连接');
        return;
      }
      this.fileBrowserDialogVisible = true;
    },

    /** 从文件浏览器打开上传对话框 */
    handleOpenUploadFromBrowser(targetPath) {
      console.log('ScreencastDialog: handleOpenUploadFromBrowser called, targetPath:', targetPath);
      this.uploadTargetPath = targetPath;
      this.fileUploadDialogVisible = true;
      console.log('ScreencastDialog: fileUploadDialogVisible set to true');
    },

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
      if (this.isMobile) {
        this.dialogWidth = window.innerWidth;
        this.dialogHeight = window.innerHeight;
        return;
      }

      if (this.isDialogFullscreen) {
        this.dialogWidth = window.innerWidth;
        this.dialogHeight = window.innerHeight;
        return;
      }

      const deviceResolution = this.getEffectiveDeviceResolution();
      if (!deviceResolution) return;

      const deviceWidth = deviceResolution.width;
      const deviceHeight = deviceResolution.height;

      const targetHeight = this.getPcDialogHeight();
      const deviceAspectRatio = deviceWidth / deviceHeight;
      const toolbarWidth = 44;
      const topToolbarHeight = 50;
      const bottomToolbarHeight = 48;
      const videoDisplayHeight = targetHeight - topToolbarHeight - bottomToolbarHeight;
      const videoDisplayWidth = videoDisplayHeight * deviceAspectRatio;
      const maxDialogWidth = window.innerWidth - 32;

      this.dialogWidth = Math.round(Math.max(360, Math.min(maxDialogWidth, videoDisplayWidth + toolbarWidth)));
      this.dialogHeight = targetHeight;
      this.centerDialog();
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

    /** 重新连接 */
    async reconnectScreencast() {
      if (!this.mqttClient) {
        this.$message.warning('MQTT未连接');
        return;
      }

      if (this.isReconnecting) {
        console.warn('重连请求已在进行中，忽略本次重复触发');
        return;
      }

      this.isReconnecting = true;
      try {
        await this.stopScreencast({ notifyDevice: false });
        await new Promise(resolve => setTimeout(resolve, 500));
        this.statusText = '准备重新连接...';
        this.connectionStatus = 'connecting';
        await this.startScreencast();
      } catch (error) {
        console.error('重新连接失败:', error);
        this.$message.error('重新连接失败: ' + error.message);
      } finally {
        this.isReconnecting = false;
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
    toggleDialogFullscreen() {
      if (!this.isStreaming) {
        return;
      }

      this.isDialogFullscreen = !this.isDialogFullscreen;
      
      this.$nextTick(() => {
        const dialog = document.querySelector('.screencast-control-dialog');
        if (!dialog) return;

        if (this.isDialogFullscreen) {
          // 进入全屏模式：添加全屏类，覆盖整个屏幕
          dialog.classList.add('fullscreen-dialog');
          
          // 更新内部尺寸
          this.dialogWidth = window.innerWidth;
          this.dialogHeight = window.innerHeight;
        } else {
          // 退出全屏模式：移除全屏类，恢复正常大小
          dialog.classList.remove('fullscreen-dialog');
          
          // 恢复自适应大小
          this.autoResizeDialog();
          this.centerDialog();
        }
      });
    },

    async rotateDeviceScreen() {
      if (this.deviceController) {
        await this.deviceController.rotateScreen();
      }
    },

    /** 截图 */
    async captureScreenshot() {
      if (!this.videoPlayer) {
        this.$message.warning('视频播放器未初始化');
        return;
      }

      try {
        await this.videoPlayer.downloadScreenshot(
          `screenshot_${this.deviceName}_${Date.now()}.png`
        );
        this.$message.success('截图已保存');
      } catch (error) {
        this.$message.error('截图失败: ' + error.message);
      }
    },

    /** 开始拖动 */
    startDrag(e) {
      // 移动端或全屏模式下禁用拖动
      if (this.isMobile || this.isDialogFullscreen) return;

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
      // 移动端或全屏模式下禁用缩放
      if (this.isMobile || this.isDialogFullscreen) return;

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
      this.isReconnecting = false;
      this.stopStatsMonitoring();
      this.releaseHeldTouch();
      this.cancelLongPressTimer();

      // 清理WebRTC管理器
      if (this.webrtcManager) {
        this.webrtcManager.cleanup();
      }

      // 清理新模块
      if (this.coordinateConverter) {
        this.coordinateConverter.reset();
      }

      if (this.gestureRecognizer) {
        this.gestureRecognizer.reset();
      }

      if (this.statsMonitor) {
        this.statsMonitor.stop();
        this.statsMonitor = null;
      }

      if (this.videoPlayer) {
        this.videoPlayer.cleanup();
        this.videoPlayer = null;
      }

      // 清理MQTT订阅
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

      this.isStreaming = false;
      this.isDraggingVideo = false;
      
      console.log('[ScreencastDialog] 资源清理完成');
    },

    /** 处理视频点击事件 */
    handleVideoClick(event) {
      // 注意：这个事件在鼠标拖拽时不应该触发
      // 实际的点击/滑动逻辑在 mouseUp 事件中处理
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

      this.updateGesture(event, 'mouse');
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

      const touch = event.touches[0];
      this.updateGesture(touch, 'touch');
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
      this.gesturePath = [{
        clientX: pointEvent.clientX,
        clientY: pointEvent.clientY,
        x: coords.x,
        y: coords.y,
        timestamp: this.gestureStartTime
      }];
      this.longPressTriggered = false;
      this.longPressSent = false;
      this.touchDownSent = false;
      this.lastTouchMoveSentAt = this.gestureStartTime;
      this.lastTouchMoveX = this.gestureStartX;
      this.lastTouchMoveY = this.gestureStartY;
      this.cancelLongPressTimer();
      this.longPressTimer = setTimeout(() => {
        if (!this.isDraggingVideo || this.longPressTriggered) {
          return;
        }
        this.longPressTriggered = true;
        this.longPressSent = true;
        this.sendTouchEvent('touchDown', {
          x: this.gestureStartX,
          y: this.gestureStartY
        });
        this.touchDownSent = true;
        this.lastTouchMoveSentAt = Date.now();
        this.lastTouchMoveX = this.gestureStartX;
        this.lastTouchMoveY = this.gestureStartY;
      }, 420);
    },

    updateGesture(pointEvent, pointerType) {
      if (!this.isDraggingVideo) {
        return;
      }

      const screenDragDistance = Math.hypot(
        pointEvent.clientX - this.gestureStartClientX,
        pointEvent.clientY - this.gestureStartClientY
      );
      const coords = this.getVideoCoordinates(pointEvent);
      const deviceDragDistance = coords
        ? Math.hypot(coords.x - this.gestureStartX, coords.y - this.gestureStartY)
        : 0;
      const swipeThreshold = pointerType === 'touch' ? 8 : 12;
      const longPressCancelThreshold = pointerType === 'touch' ? 18 : 24;
      const longPressDeviceCancelThreshold = 32;

      if (coords) {
        const lastPoint = this.gesturePath[this.gesturePath.length - 1];
        if (!lastPoint || Math.hypot(coords.x - lastPoint.x, coords.y - lastPoint.y) >= 4) {
          this.gesturePath.push({
            clientX: pointEvent.clientX,
            clientY: pointEvent.clientY,
            x: coords.x,
            y: coords.y,
            timestamp: Date.now()
          });
        }
      }

      if (this.longPressTriggered && this.touchDownSent && coords) {
        const now = Date.now();
        const movedDistance = Math.hypot(coords.x - this.lastTouchMoveX, coords.y - this.lastTouchMoveY);
        if (movedDistance >= 3 && now - this.lastTouchMoveSentAt >= 16) {
          this.sendTouchEvent('touchMove', {
            x: coords.x,
            y: coords.y
          });
          this.lastTouchMoveSentAt = now;
          this.lastTouchMoveX = coords.x;
          this.lastTouchMoveY = coords.y;
        }
      }

      if (screenDragDistance >= longPressCancelThreshold || deviceDragDistance >= longPressDeviceCancelThreshold) {
        this.cancelLongPressTimer();
      }
    },

    finishGesture(pointEvent, pointerType) {
      this.cancelLongPressTimer();
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
        const gesturePath = this.buildGesturePath(pointEvent, coords);
        const swipeDuration = this.resolveSwipeDuration(gesturePath, durationMs);

        if (this.longPressTriggered) {
          this.releaseHeldTouch(coords.x, coords.y);
          this.cancelGesture();
          return;
        }

        this.sendTouchEvent('swipe', {
          x1: this.gestureStartX,
          y1: this.gestureStartY,
          x2: coords.x,
          y2: coords.y,
          durationMs: swipeDuration
        });
        this.showSwipeTrail(gesturePath);
        this.cancelGesture();
        return;
      }

      if (this.longPressTriggered) {
        this.releaseHeldTouch(coords.x, coords.y);
      } else {
        this.sendTouchEvent('click', {
          x: this.gestureStartX,
          y: this.gestureStartY
        });
        this.showClickMarker(this.gestureStartClientX, this.gestureStartClientY);
      }
      this.cancelGesture();
    },

    cancelLongPressTimer() {
      if (this.longPressTimer) {
        clearTimeout(this.longPressTimer);
        this.longPressTimer = null;
      }
    },

    releaseHeldTouch(x = null, y = null) {
      if (!this.touchDownSent) {
        return;
      }

      this.sendTouchEvent('touchUp', {
        x: x == null ? this.gestureStartX : x,
        y: y == null ? this.gestureStartY : y
      });
      this.touchDownSent = false;
    },

    buildGesturePath(pointEvent, coords) {
      const path = [...this.gesturePath];
      const lastPoint = path[path.length - 1];

      if (!lastPoint || lastPoint.clientX !== pointEvent.clientX || lastPoint.clientY !== pointEvent.clientY) {
        path.push({
          clientX: pointEvent.clientX,
          clientY: pointEvent.clientY,
          x: coords.x,
          y: coords.y,
          timestamp: Date.now()
        });
      }

      return path;
    },

    resolveSwipeDuration(path, fallbackDurationMs) {
      if (!Array.isArray(path) || path.length < 2) {
        return Math.min(Math.max(fallbackDurationMs || 180, 120), 260);
      }

      const firstPoint = path[0];
      const lastPoint = path[path.length - 1];
      const measuredDuration = Math.max((lastPoint.timestamp || 0) - (firstPoint.timestamp || 0), 1);
      const distance = Math.hypot(
        (lastPoint.x || 0) - (firstPoint.x || 0),
        (lastPoint.y || 0) - (firstPoint.y || 0)
      );

      if (distance >= 900) {
        return Math.min(Math.max(measuredDuration, 110), 180);
      }

      if (distance >= 500) {
        return Math.min(Math.max(measuredDuration, 120), 220);
      }

      return Math.min(Math.max(measuredDuration, 140), 260);
    },

    cancelGesture() {
      this.releaseHeldTouch();
      this.cancelLongPressTimer();
      this.longPressTriggered = false;
      this.longPressSent = false;
      this.touchDownSent = false;
      this.lastTouchMoveSentAt = 0;
      this.gesturePath = [];
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
    showSwipeTrail(path) {
      if (!path || path.length < 2) {
        return;
      }

      const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      const polyline = document.createElementNS('http://www.w3.org/2000/svg', 'polyline');
      const points = path.map(point => `${point.clientX},${point.clientY}`).join(' ');

      svg.setAttribute('style', `
        position: fixed;
        left: 0;
        top: 0;
        width: 100vw;
        height: 100vh;
        pointer-events: none;
        z-index: 9999;
        overflow: visible;
        animation: swipeTrailFade 1.5s ease-out forwards;
      `);

      polyline.setAttribute('points', points);
      polyline.setAttribute('fill', 'none');
      polyline.setAttribute('stroke', 'url(#swipeTrailGradient)');
      polyline.setAttribute('stroke-width', '4');
      polyline.setAttribute('stroke-linecap', 'round');
      polyline.setAttribute('stroke-linejoin', 'round');

      const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
      const gradient = document.createElementNS('http://www.w3.org/2000/svg', 'linearGradient');
      gradient.setAttribute('id', 'swipeTrailGradient');
      gradient.setAttribute('x1', '0%');
      gradient.setAttribute('y1', '0%');
      gradient.setAttribute('x2', '100%');
      gradient.setAttribute('y2', '0%');

      const startStop = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
      startStop.setAttribute('offset', '0%');
      startStop.setAttribute('stop-color', '#409EFF');
      const endStop = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
      endStop.setAttribute('offset', '100%');
      endStop.setAttribute('stop-color', '#67C23A');

      gradient.appendChild(startStop);
      gradient.appendChild(endStop);
      defs.appendChild(gradient);
      svg.appendChild(defs);
      svg.appendChild(polyline);

      if (!document.getElementById('swipeTrailStyle')) {
        const style = document.createElement('style');
        style.id = 'swipeTrailStyle';
        style.textContent = `
          @keyframes swipeTrailFade {
            0% { opacity: 1; }
            100% { opacity: 0; }
          }
        `;
        document.head.appendChild(style);
      }

      document.body.appendChild(svg);

      const firstPoint = path[0];
      const lastPoint = path[path.length - 1];
      this.showClickMarker(firstPoint.clientX, firstPoint.clientY);
      setTimeout(() => {
        this.showClickMarker(lastPoint.clientX, lastPoint.clientY);
      }, 300);

      setTimeout(() => {
        if (svg.parentNode) {
          svg.parentNode.removeChild(svg);
        }
      }, 1500);
    },

    /** 获取视频坐标并转换为设备坐标 */
    getVideoCoordinates(event) {
      if (!this.coordinateConverter) {
        console.warn('[ScreencastDialog] 坐标转换器未初始化');
        return null;
      }

      const coords = this.coordinateConverter.convertToDeviceCoordinates(
        event.clientX,
        event.clientY,
        this.$refs.remoteVideo
      );

      if (this.debugMode && coords) {
        console.log(`[ScreencastDialog] 坐标转换: (${event.clientX}, ${event.clientY}) -> (${coords.x}, ${coords.y})`);
      }

      return coords;
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

/* 全屏模式样式 */
.screencast-control-dialog.fullscreen-dialog {
  position: fixed !important;
  left: 0 !important;
  top: 0 !important;
  width: 100vw !important;
  height: 100vh !important;
  margin: 0 !important;
  max-width: none !important;
  transform: none !important;
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
  position: relative;
  padding-right: 40px;
  padding-bottom: 48px;
  box-sizing: border-box;
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

/* 全屏模式下的标题栏 */
.top-toolbar.fullscreen-mode {
  cursor: default;
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
  align-items: center;
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

.toolbar-actions i.disabled {
  opacity: 0.35;
  cursor: not-allowed;
  pointer-events: none;
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
.video-overlay-toolbar {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 8;
}

.side-toolbar {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 48px;
  display: flex;
  flex-direction: column;
  width: 40px;
  background: rgba(15, 15, 15, 0.92);
  border-left: 1px solid rgba(255, 255, 255, 0.08);
  flex-shrink: 0;
  pointer-events: auto;
}

.toolbar-divider {
  flex: 1;
  min-height: 1px;
  background: transparent;
  margin: 0;
}

.toolbar-item {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 40px;
  padding: 0;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  user-select: none;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
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

.toolbar-item span {
  display: none;
}

.bottom-toolbar {
  position: absolute;
  left: 0;
  right: 40px;
  bottom: 0;
  display: flex;
  align-items: stretch;
  background: rgba(12, 12, 12, 0.92);
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  pointer-events: auto;
}

.bottom-toolbar-item {
  flex: 1;
  min-height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
}

.bottom-toolbar-item:hover:not(.disabled) {
  background: rgba(64, 158, 255, 0.15);
}

.bottom-toolbar-item.disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

.bottom-toolbar-item i {
  font-size: 16px;
}

.bottom-toolbar-item span {
  display: none;
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
    padding-right: 36px;
    padding-bottom: 44px;
  }

  .side-toolbar {
    width: 36px;
    bottom: 44px;
  }

  .toolbar-item {
    width: 100%;
    min-height: 36px;
    border-bottom: none;
    border-right: none;
  }

  .bottom-toolbar-item {
    min-height: 44px;
  }

  .bottom-toolbar {
    right: 36px;
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
