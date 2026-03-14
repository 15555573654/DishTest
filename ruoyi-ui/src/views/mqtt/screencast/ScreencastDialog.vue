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
            controls
          ></video>
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
          <div class="toolbar-item" @click.stop="handleRefresh" :class="{ disabled: !isStreaming }" title="刷新">
            <i class="el-icon-refresh"></i>
          </div>

          <!-- 分隔线 -->
          <div class="toolbar-divider"></div>

          <!-- Android控制按钮 -->
          <div class="toolbar-item" @click.stop="sendVirtualKey('back')" :class="{ disabled: !isStreaming }" title="返回">
            <i class="el-icon-back"></i>
          </div>
          <div class="toolbar-item" @click.stop="sendVirtualKey('home')" :class="{ disabled: !isStreaming }" title="主页">
            <i class="el-icon-s-home"></i>
          </div>
          <div class="toolbar-item" @click.stop="sendVirtualKey('menu')" :class="{ disabled: !isStreaming }" title="任务栏">
            <i class="el-icon-menu"></i>
          </div>
        </div>
      </div>

      <!-- 设置面板 -->
      <div class="settings-panel" v-show="showSettings" @click.stop>
        <!-- 质量预设 -->
        <div class="setting-item">
          <span>画质</span>
          <el-select v-model="currentQuality" size="mini" @change="applyQualityPreset">
            <el-option label="自动" value="auto" />
            <el-option label="流畅 (480p@30fps)" value="low" />
            <el-option label="标清 (720p@60fps)" value="medium" />
            <el-option label="高清 (1080p@60fps)" value="high" />
          </el-select>
        </div>

        <div class="stats-divider"></div>

        <!-- 自定义设置 -->
        <div class="setting-section-title">自定义设置</div>
        <div class="setting-item">
          <span>分辨率</span>
          <el-input
            v-model="videoConstraints.resolution"
            size="mini"
            :disabled="currentQuality === 'auto'"
            placeholder="如: 1920x1080"
          />
        </div>
        <div class="setting-item">
          <span>帧率</span>
          <el-select
            v-model="videoConstraints.frameRate"
            size="mini"
            :disabled="currentQuality === 'auto'"
          >
            <el-option label="30 fps" :value="30" />
            <el-option label="60 fps" :value="60" />
          </el-select>
        </div>
        <div class="setting-item" v-if="currentQuality !== 'auto'">
          <el-button
            type="primary"
            size="mini"
            style="width: 100%"
            @click="applyVideoSettings"
            :disabled="!isStreaming"
          >应用设置</el-button>
        </div>

        <!-- 统计信息 -->
        <div class="stats-divider"></div>
        <div class="stats-section">
          <div class="stats-title">连接统计</div>
          <div class="stats-item">
            <span>期望分辨率:</span>
            <span>{{ getExpectedResolution() }}</span>
          </div>
          <div class="stats-item">
            <span>实际分辨率:</span>
            <span :class="{ 'stats-warning': !isResolutionMatched() }">{{ currentStats.resolution || '-' }}</span>
          </div>
          <div class="stats-item">
            <span>期望帧率:</span>
            <span>{{ videoConstraints.frameRate }} fps</span>
          </div>
          <div class="stats-item">
            <span>实际帧率:</span>
            <span :class="{ 'stats-warning': currentStats.fps < videoConstraints.frameRate * 0.8 }">{{ currentStats.fps }} fps</span>
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

      // 拖动和缩放相关
      dialogWidth: 420,
      dialogHeight: 700,
      isDragging: false,
      isResizing: false,
      resizeType: '',
      dragStartX: 0,
      dragStartY: 0,
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
        resolution: 'auto', // 改为自动，从设备获取
        frameRate: 60 // 提高默认帧率到60
      },

      // 质量预设
      qualityPresets: {
        low: { resolution: '640x480', frameRate: 30, label: '流畅' },
        medium: { resolution: '1280x720', frameRate: 60, label: '标清' },
        high: { resolution: '1920x1080', frameRate: 60, label: '高清' },
        auto: { resolution: 'auto', frameRate: 60, label: '自动' }
      },
      currentQuality: 'auto',

      isMobile: false
    };
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
  },
  beforeDestroy() {
    this.cleanup();
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);
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

        if (state === 'connected') {
          this.statusText = '连接成功';
          this.$message.success('连接成功');
        } else if (state === 'failed' || state === 'disconnected') {
          this.isStreaming = false;
          this.statusText = '连接断开';
        }
      });

      this.webrtcManager.on('track', (stream, { audioTracks, videoTracks }) => {
        console.log('设置视频元素srcObject...');
        if (this.$refs.remoteVideo) {
          const video = this.$refs.remoteVideo;

          // 检查是否是同一个流，如果不是则更新
          if (!video.srcObject || video.srcObject.id !== stream.id) {
            console.log('设置新的视频流，流ID:', stream.id);

            // 设置视频源
            video.srcObject = stream;

            // 优化视频播放设置 - 降低延迟
            video.playsInline = true;
            video.muted = false; // 启用音频
            video.autoplay = true;

            // 设置低延迟属性
            if (video.hasAttribute) {
              video.setAttribute('playsinline', '');
              video.setAttribute('webkit-playsinline', '');
            }

            // 关键：设置视频缓冲区为最小值以降低延迟
            try {
              // 尝试设置 latencyHint（Chrome 支持）
              if ('latencyHint' in video) {
                video.latencyHint = 0; // 最低延迟
              }

              // 设置预加载策略
              video.preload = 'auto';

              // 禁用画中画
              video.disablePictureInPicture = true;

              // 设置控制条（可选）
              video.controls = false;
            } catch (err) {
              console.warn('部分视频属性设置失败:', err);
            }

            console.log('✓ 视频元素srcObject已设置');

            // 播放视频
            video.play().then(() => {
              console.log('✓ 视频开始播放');

              // 尝试进入低延迟模式
              this.enableLowLatencyMode(video);

              // 启动统计信息监控
              this.startStatsMonitoring();
            }).catch(err => {
              console.error('✗ 视频播放失败:', err);
              // 如果自动播放失败，可能需要用户交互
              if (err.name === 'NotAllowedError') {
                this.$message.warning('请点击视频区域以开始播放');
              }
            });
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

    /** 关闭弹窗 */
    handleClose() {
      this.stopScreencast();
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

        // 准备视频约束
        let constraints = null;
        if (this.videoConstraints.resolution !== 'auto') {
          const resolutionParts = this.videoConstraints.resolution.split('x');
          if (resolutionParts.length === 2) {
            constraints = {
              width: parseInt(resolutionParts[0]),
              height: parseInt(resolutionParts[1]),
              frameRate: this.videoConstraints.frameRate
            };
          }
        } else {
          // 自动模式，使用默认高质量设置
          constraints = {
            width: 1920,
            height: 1080,
            frameRate: 60
          };
        }

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
    stopScreencast() {
      if (this.webrtcManager) {
        this.webrtcManager.stop();
      }
      this.stopStatsMonitoring();
      this.connectionStatus = 'disconnected';
      this.isStreaming = false;
      this.statusText = '已停止';

      // 清除视频元素
      if (this.$refs.remoteVideo) {
        this.$refs.remoteVideo.srcObject = null;
      }
    },

    /** 启动统计信息监控 */
    startStatsMonitoring() {
      if (this.statsInterval) {
        clearInterval(this.statsInterval);
      }

      // 用于计算比特率的变量
      let lastBytesReceived = 0;
      let lastTimestamp = 0;

      this.statsInterval = setInterval(async () => {
        if (!this.webrtcManager || !this.webrtcManager.peerConnection) {
          return;
        }

        try {
          const stats = await this.webrtcManager.peerConnection.getStats();

          stats.forEach(report => {
            // 视频统计
            if (report.type === 'inbound-rtp' && report.kind === 'video') {
              // 计算比特率
              if (lastTimestamp > 0 && report.timestamp > lastTimestamp) {
                const timeDiff = (report.timestamp - lastTimestamp) / 1000; // 转换为秒
                const bytesDiff = report.bytesReceived - lastBytesReceived;
                this.currentStats.bitrate = Math.round((bytesDiff * 8) / timeDiff / 1000); // kbps
              }

              lastBytesReceived = report.bytesReceived;
              lastTimestamp = report.timestamp;

              // 帧率
              if (report.framesPerSecond !== undefined) {
                this.currentStats.fps = Math.round(report.framesPerSecond);
              } else if (report.framesDecoded !== undefined && lastTimestamp > 0) {
                // 备用方案：通过解码帧数计算
                this.currentStats.fps = Math.round(report.framesDecoded / ((report.timestamp - lastTimestamp) / 1000));
              }

              // 分辨率
              if (report.frameWidth && report.frameHeight) {
                this.currentStats.resolution = `${report.frameWidth}x${report.frameHeight}`;

                // 自动更新分辨率显示
                if (this.videoConstraints.resolution === 'auto') {
                  this.videoConstraints.resolution = this.currentStats.resolution;
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

            // RTT (往返时间) - 修复延迟统计
            if (report.type === 'remote-inbound-rtp' && report.kind === 'video') {
              // 使用 remote-inbound-rtp 的 roundTripTime
              if (report.roundTripTime !== undefined) {
                this.currentStats.rtt = Math.round(report.roundTripTime * 1000); // 转换为毫秒
              }
            }

            // 备用方案：从 candidate-pair 获取 RTT
            if (report.type === 'candidate-pair' && report.state === 'succeeded' && report.nominated) {
              if (report.currentRoundTripTime !== undefined && report.currentRoundTripTime > 0) {
                // 只有在没有从 remote-inbound-rtp 获取到时才使用
                if (this.currentStats.rtt === 0 || this.currentStats.rtt === 1) {
                  this.currentStats.rtt = Math.round(report.currentRoundTripTime * 1000);
                }
              }
            }

            // 另一个备用方案：从 transport 获取
            if (report.type === 'transport') {
              if (report.selectedCandidatePairId) {
                // 可以通过 selectedCandidatePairId 查找对应的 candidate-pair
              }
            }
          });

          // 如果延迟过高，自动调整质量
          if (this.currentStats.rtt > 200 || this.currentStats.packetLoss > 5) {
            console.warn('检测到高延迟或丢包，建议降低视频质量');
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

    /** 处理 Answer */
    async handleAnswer(answer) {
      if (this.webrtcManager) {
        await this.webrtcManager.handleAnswer(answer);
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
      if (!this.webrtcManager || !this.webrtcManager.isDataChannelOpen()) {
        this.$message.warning('连接未建立');
        return;
      }

      this.webrtcManager.sendVirtualKey(key);

      const keyNames = {
        'home': '主页',
        'back': '返回',
        'menu': '任务栏'
      };
      this.$message.success(`已发送${keyNames[key] || key}按键`);
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
      if (!this.isStreaming) {
        this.$message.warning('当前没有活动连接');
        return;
      }

      try {
        this.$message.info('正在刷新连接...');

        // 停止当前连接
        this.stopScreencast();

        // 等待一小段时间确保资源释放
        await new Promise(resolve => setTimeout(resolve, 500));

        // 重新开始投屏
        await this.startScreencast();

        this.$message.success('连接已刷新');
      } catch (error) {
        console.error('刷新连接失败:', error);
        this.$message.error('刷新连接失败: ' + error.message);
      }
    },

    /** 应用视频设置 */
    async applyVideoSettings() {
      if (!this.webrtcManager || !this.webrtcManager.peerConnection) {
        this.$message.warning('请先建立连接');
        return;
      }

      // 如果是自动模式，不发送设置
      if (this.videoConstraints.resolution === 'auto') {
        this.$message.info('自动模式将使用设备原始分辨率');
        return;
      }

      const resolutionParts = this.videoConstraints.resolution.split('x');
      if (resolutionParts.length !== 2) {
        this.$message.error('分辨率格式错误，应为: 宽x高 (如: 1920x1080)');
        return;
      }

      const width = parseInt(resolutionParts[0]);
      const height = parseInt(resolutionParts[1]);

      if (isNaN(width) || isNaN(height) || width <= 0 || height <= 0) {
        this.$message.error('分辨率数值无效');
        return;
      }

      console.log('应用新的视频设置:', { width, height, frameRate: this.videoConstraints.frameRate });

      try {
        // 使用重新协商来应用新的视频设置
        await this.webrtcManager.renegotiate({
          width: width,
          height: height,
          frameRate: this.videoConstraints.frameRate
        });

        this.$message.success(`正在应用新设置: ${width}x${height}@${this.videoConstraints.frameRate}fps，请等待设备响应...`);
      } catch (error) {
        console.error('应用视频设置失败:', error);
        this.$message.error('应用视频设置失败: ' + error.message);
      }
    },

    /** 应用质量预设 */
    applyQualityPreset() {
      const preset = this.qualityPresets[this.currentQuality];
      if (preset) {
        this.videoConstraints.resolution = preset.resolution;
        this.videoConstraints.frameRate = preset.frameRate;

        // 如果不是自动模式，立即应用设置
        if (this.currentQuality !== 'auto') {
          this.applyVideoSettings();
        } else {
          this.$message.success(`已切换到${preset.label}模式`);
        }
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

    /** 获取期望的分辨率 */
    getExpectedResolution() {
      if (this.videoConstraints.resolution === 'auto') {
        return '自动';
      }
      return this.videoConstraints.resolution;
    },

    /** 检查分辨率是否匹配 */
    isResolutionMatched() {
      if (!this.currentStats.resolution || this.videoConstraints.resolution === 'auto') {
        return true;
      }
      return this.currentStats.resolution === this.videoConstraints.resolution;
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

      this.isDragging = true;
      this.dragStartX = e.clientX;
      this.dragStartY = e.clientY;

      const dialog = document.querySelector('.screencast-control-dialog');
      if (dialog) {
        const rect = dialog.getBoundingClientRect();
        this.dialogLeft = rect.left;
        this.dialogTop = rect.top;
      }

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
        const deltaX = e.clientX - this.dragStartX;
        const deltaY = e.clientY - this.dragStartY;

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

      if (this.webrtcManager) {
        this.webrtcManager.cleanup();
      }

      if (this.$refs.remoteVideo) {
        this.$refs.remoteVideo.srcObject = null;
      }

      this.isStreaming = false;
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

/* 视频容器 */
.video-container {
  position: relative;
  flex: 1;
  background: #000;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.video-stream {
  width: 100%;
  height: 100%;
  object-fit: contain;
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

/* 弹窗样式 - 移除圆角 */
::v-deep .screencast-control-dialog {
  border-radius: 0;
}

::v-deep .screencast-control-dialog .el-dialog__header {
  display: none;
}

::v-deep .screencast-control-dialog .el-dialog__body {
  padding: 0;
  background: #000;
}

::v-deep .screencast-control-dialog .el-dialog__headerbtn {
  display: none;
}

/* 全屏模式 */
::v-deep .screencast-control-dialog.el-dialog--fullscreen {
  margin: 0;
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
