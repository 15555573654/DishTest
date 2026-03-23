/**
 * WebRTC 连接管理器
 * 负责处理 WebRTC 连接、信令交换、媒体流管理等
 */
import { getTurnCredentials } from '@/api/webrtc/turn';

export default class WebRTCManager {
  constructor(options = {}) {
    this.deviceName = options.deviceName || '';
    this.mqttClient = options.mqttClient || null;
    this.username = options.username || '';
    
    // ICE 服务器配置优先使用业务后端下发的动态 TURN，失败时回退到保底 TURN
    this.iceServers = Array.isArray(options.iceServers) ? options.iceServers : [];
    this.fallbackIceServers = Array.isArray(options.fallbackIceServers) && options.fallbackIceServers.length > 0
      ? options.fallbackIceServers
      : [
          {
            urls: ['turn:openrelay.metered.ca:80', 'turn:openrelay.metered.ca:443?transport=tcp'],
            username: 'openrelayproject',
            credential: 'openrelayproject'
          }
        ];
    this.turnConfigSource = 'unknown';
    
    // WebRTC 对象
    this.peerConnection = null;
    this.dataChannel = null;
    this.remoteStream = null;
    
    // 状态
    this.connectionState = 'disconnected'; // disconnected, connecting, connected
    
    // 视频约束配置（用于重新协商）
    // 初次连接默认不主动约束，由设备端按自身最高能力推流。
    this.videoConstraints = null;
    
    // 事件回调
    this.callbacks = {
      onConnectionStateChange: null,
      onTrack: null,
      onDataChannelMessage: null,
      onIceCandidate: null,
      onError: null
    };

    this.lastIceStatsSnapshotAt = 0;
    this.iceCandidateStats = this.createEmptyIceStats();
    this.relayCheckTimer = null;
  }
  
  /**
   * 设置事件回调
   */
  on(event, callback) {
    if (this.callbacks.hasOwnProperty(`on${event.charAt(0).toUpperCase()}${event.slice(1)}`)) {
      this.callbacks[`on${event.charAt(0).toUpperCase()}${event.slice(1)}`] = callback;
    }
  }
  
  /**
   * 更新配置
   */
  updateConfig(config) {
    if (config.deviceName) this.deviceName = config.deviceName;
    if (config.mqttClient) this.mqttClient = config.mqttClient;
    if (config.username) this.username = config.username;
    if (Array.isArray(config.iceServers)) this.iceServers = config.iceServers;
    if (Array.isArray(config.fallbackIceServers) && config.fallbackIceServers.length > 0) {
      this.fallbackIceServers = config.fallbackIceServers;
    }
  }

  async refreshIceServers() {
    try {
      const response = await getTurnCredentials();
      const iceServer = response?.data?.iceServer;
      const urls = iceServer?.urls;
      const expiresAt = response?.data?.expiresAt;
      const credentialUsername = iceServer?.username;

      if (!iceServer || !Array.isArray(urls) || urls.length === 0) {
        throw new Error('未获取到可用的 TURN 配置');
      }

      this.iceServers = [
        {
          urls,
          username: iceServer.username,
          credential: iceServer.credential
        }
      ];
      this.turnConfigSource = 'backend-dynamic-turn';

      console.log('>>> 已加载动态 TURN 凭证:', urls.join(', '));
      console.log('>>> TURN 凭证来源: 后端动态接口 /webrtc/turn/credentials');
      console.log('>>> TURN 用户名(临时):', credentialUsername);
      if (expiresAt) {
        console.log('>>> TURN 凭证过期时间(Unix):', expiresAt);
      }
      return this.iceServers;
    } catch (error) {
      const fallbackUrls = this.fallbackIceServers.map(server => server.urls).flat().join(', ');
      console.error('>>> 后端 TURN 不可用，切换到保底 TURN:', error);
      console.error('>>> 保底 TURN 地址:', fallbackUrls);
      this.iceServers = this.fallbackIceServers;
      this.turnConfigSource = 'fallback-turn';
      return this.iceServers;
    }
  }
  
  /**
   * 创建 PeerConnection
   */
  async createPeerConnection() {
    const configuration = {
      iceServers: this.iceServers,
      iceCandidatePoolSize: 6,
      // 优化 ICE 候选策略
      iceTransportPolicy: 'all', // 使用所有可用的候选
      bundlePolicy: 'max-bundle', // 最大化复用传输
      rtcpMuxPolicy: 'require',
      sdpSemantics: 'unified-plan'
    };
    
    this.peerConnection = new RTCPeerConnection(configuration);
    this.resetIceDebugState();
    console.log('>>> ICE服务器配置:', this.iceServers.map(server => server.urls).flat().join(', '));
    
    // 添加视频接收器，配置优化参数
    console.log('>>> 添加视频接收器...');
    const videoTransceiver = this.peerConnection.addTransceiver('video', { 
      direction: 'recvonly'
    });
    
    // 设置视频接收参数以降低延迟
    if (videoTransceiver.receiver && videoTransceiver.receiver.playoutDelayHint !== undefined) {
      videoTransceiver.receiver.playoutDelayHint = 0; // 最小化播放延迟
    }
    console.log('✓ 视频接收器已添加');
    
    // 添加音频接收器
    console.log('>>> 添加音频接收器...');
    const audioTransceiver = this.peerConnection.addTransceiver('audio', { 
      direction: 'recvonly'
    });
    
    // 设置音频接收参数以降低延迟
    if (audioTransceiver.receiver && audioTransceiver.receiver.playoutDelayHint !== undefined) {
      audioTransceiver.receiver.playoutDelayHint = 0; // 最小化播放延迟
    }
    console.log('✓ 音频接收器已添加');
    
    // ICE 候选事件
    this.peerConnection.onicecandidate = (event) => {
      if (event.candidate) {
        const description = this.describeIceCandidate(event.candidate);
        this.recordIceCandidate('local', event.candidate);
        console.log('>>> 生成ICE候选，准备发送:', description);
        this.sendSignaling({
          type: 'ice-candidate',
          deviceName: this.deviceName,
          candidate: event.candidate,
          from: 'frontend'
        });
      } else {
        console.log('>>> ICE候选收集完成');
        this.logIceCandidateSummary('local-gather-complete');
        this.warnIfRelayMissing('local-gather-complete');
      }
    };

    this.peerConnection.onicegatheringstatechange = () => {
      console.log('>>> ICE收集状态变化:', this.peerConnection.iceGatheringState);
      if (this.peerConnection.iceGatheringState === 'gathering') {
        this.scheduleRelayCheck();
      }
      if (this.peerConnection.iceGatheringState === 'complete') {
        this.logIceCandidateSummary('ice-gathering-complete');
        this.warnIfRelayMissing('ice-gathering-complete');
      }
    };

    this.peerConnection.onsignalingstatechange = () => {
      console.log('>>> 信令状态变化:', this.peerConnection.signalingState);
    };
    
    // 连接状态变化
    this.peerConnection.onconnectionstatechange = () => {
      console.log('>>> PeerConnection状态变化:', this.peerConnection.connectionState);
      
      this.connectionState = this.peerConnection.connectionState;
      
      if (this.callbacks.onConnectionStateChange) {
        this.callbacks.onConnectionStateChange(this.connectionState);
      }
      
      switch (this.connectionState) {
        case 'connecting':
          console.log('🔄 WebRTC正在连接...');
          break;
        case 'connected':
          console.log('✓ WebRTC连接成功！');
          this.logIceDiagnostics('peer-connected');
          break;
        case 'disconnected':
          console.warn('⚠️ WebRTC连接已断开');
          // 不立即报错，可能是临时断开
          setTimeout(() => {
            if (this.connectionState === 'disconnected') {
              console.error('✗ WebRTC连接持续断开状态');
            }
          }, 5000);
          break;
        case 'failed':
          console.error('✗ WebRTC连接失败');
          this.logIceDiagnostics('peer-failed');
          if (this.callbacks.onError) {
            this.callbacks.onError('WebRTC连接失败');
          }
          break;
        case 'closed':
          console.log('WebRTC连接已关闭');
          break;
        default:
          console.log('WebRTC状态:', this.connectionState);
      }
    };
    
    // ICE 连接状态变化
    this.peerConnection.oniceconnectionstatechange = () => {
      console.log('>>> ICE连接状态变化:', this.peerConnection.iceConnectionState);
      
      switch (this.peerConnection.iceConnectionState) {
        case 'checking':
          console.log('🔍 ICE正在检查连接...');
          break;
        case 'connected':
          console.log('✓ ICE连接成功！');
          this.logIceDiagnostics('ice-connected');
          // ICE连接成功，通常意味着WebRTC连接即将成功
          break;
        case 'completed':
          console.log('✓ ICE连接完成！');
          this.logIceDiagnostics('ice-completed');
          break;
        case 'failed':
          console.error('✗ ICE连接失败 - 可能是NAT/防火墙问题');
          console.error('建议检查：1) 网络防火墙设置 2) STUN/TURN服务器配置 3) NAT类型');
          this.logIceDiagnostics('ice-failed');
          
          // ICE连接失败时，尝试重新建立连接
          console.log('🔄 ICE连接失败，5秒后尝试重新建立连接...');
          setTimeout(() => {
            if (this.peerConnection && this.peerConnection.iceConnectionState === 'failed') {
              console.log('执行ICE重启...');
              this.restartIce();
            }
          }, 5000);
          
          if (this.callbacks.onError) {
            this.callbacks.onError('ICE连接失败，请检查网络配置');
          }
          break;
        case 'disconnected':
          console.warn('⚠️ ICE连接已断开');
          this.logIceDiagnostics('ice-disconnected');
          // ICE断开可能是临时的，等待一段时间看是否恢复
          setTimeout(() => {
            if (this.peerConnection && this.peerConnection.iceConnectionState === 'disconnected') {
              console.warn('ICE连接持续断开，尝试重新建立连接');
              this.restartIce();
            }
          }, 10000);
          break;
        case 'closed':
          console.log('ICE连接已关闭');
          break;
        default:
          console.log('ICE状态:', this.peerConnection.iceConnectionState);
      }
    };
    
    // 接收远程流
    this.peerConnection.ontrack = (event) => {
      console.log('!!! ✓ 接收到远程流事件触发 !!!');
      console.log('轨道类型:', event.track.kind);
      
      if (event.streams && event.streams.length > 0) {
        const stream = event.streams[0];
        const audioTracks = stream.getAudioTracks();
        const videoTracks = stream.getVideoTracks();
        console.log(`音频轨道: ${audioTracks.length}, 视频轨道: ${videoTracks.length}`);
        
        // 只在第一次收到轨道时设置流，避免重复设置
        if (!this.remoteStream) {
          this.remoteStream = stream;
          
          // 注意：接收端不应该对远程轨道应用约束
          // 视频质量由发送端（设备端）控制
          console.log('远程流已接收，视频质量由设备端控制');
          
          if (this.callbacks.onTrack) {
            this.callbacks.onTrack(this.remoteStream, { audioTracks, videoTracks });
          }
        } else {
          // 如果已经有流了，只是添加了新轨道，更新回调
          console.log('远程流已存在，轨道已添加');
          if (this.callbacks.onTrack) {
            this.callbacks.onTrack(this.remoteStream, { audioTracks, videoTracks });
          }
        }
      }
    };
    
    // DataChannel 接收
    this.peerConnection.ondatachannel = (event) => {
      const channel = event.channel;
      channel.onmessage = (e) => {
        this.handleDataChannelMessage(e.data);
      };
    };
  }
  
  /**
   * 创建 DataChannel
   */
  createDataChannel() {
    const dataChannelInit = {
      ordered: true,
      negotiated: true,
      id: 0
    };
    
    this.dataChannel = this.peerConnection.createDataChannel('control', dataChannelInit);
    
    this.dataChannel.onopen = () => {
      console.log('DataChannel已打开');
    };
    
    this.dataChannel.onmessage = (event) => {
      this.handleDataChannelMessage(event.data);
    };
    
    this.dataChannel.onerror = (error) => {
      console.error('DataChannel错误:', error);
      if (this.callbacks.onError) {
        this.callbacks.onError('DataChannel错误: ' + error.message);
      }
    };
  }
  
  /**
   * 处理 DataChannel 消息
   */
  handleDataChannelMessage(data) {
    try {
      const message = JSON.parse(data);
      console.log('收到DataChannel消息:', message);
      
      if (this.callbacks.onDataChannelMessage) {
        this.callbacks.onDataChannelMessage(message);
      }
    } catch (e) {
      console.log('收到非JSON消息:', data);
    }
  }
  
  /**
   * 发送信令消息
   */
  sendSignaling(data) {
    if (!this.mqttClient) {
      console.error('MQTT未连接');
      return;
    }
    
    const topic = `webrtc/${this.username}/${this.deviceName}`;
    
    console.log('>>> 发送信令:', data.type);
    console.log('>>> 主题:', topic);
    
    this.mqttClient.publish(topic, JSON.stringify(data), { qos: 1 }, (err) => {
      if (err) {
        console.error('发送信令失败:', err);
      } else {
        console.log('✓ 信令发送成功:', data.type);
      }
    });
  }
  
  /**
   * 开始连接
   */
  async start(videoConstraints = null) {
    try {
      this.connectionState = 'connecting';
      
      // 如果提供了视频约束，保存它
      if (videoConstraints) {
        this.videoConstraints = { ...videoConstraints };
      }

      await this.refreshIceServers();
      
      // 创建 PeerConnection
      await this.createPeerConnection();
      
      // 创建 DataChannel
      this.createDataChannel();
      
      // 创建 Offer，配置优化参数
      const offerOptions = {
        offerToReceiveAudio: true,
        offerToReceiveVideo: true,
        // 启用 ICE 重启
        iceRestart: false
      };
      
      const offer = await this.peerConnection.createOffer(offerOptions);
      
      // 修改 SDP 以优化视频质量和延迟
      offer.sdp = this.optimizeSDP(offer.sdp);
      
      await this.peerConnection.setLocalDescription(offer);
      
      // 通过 MQTT 发送 Offer，包含视频约束
      const signalingPayload = {
        type: 'offer',
        deviceName: this.deviceName,
        offer: offer,
        turnConfig: this.buildTurnConfigPayload()
      };

      if (this.videoConstraints) {
        signalingPayload.videoConstraints = this.videoConstraints;
      }

      this.sendSignaling(signalingPayload);

      if (this.videoConstraints) {
        console.log('📤 发送给设备的视频约束:', JSON.stringify(this.videoConstraints, null, 2));
      } else {
        console.log('📤 初始 offer 未携带 videoConstraints，由设备端自行决定推流质量');
      }
      
      
      return true;
    } catch (error) {
      console.error('开始连接失败:', error);
      this.connectionState = 'disconnected';
      if (this.callbacks.onError) {
        this.callbacks.onError('开始连接失败: ' + error.message);
      }
      throw error;
    }
  }

  buildTurnConfigPayload() {
    const turnServers = this.iceServers
      .filter(server => {
        const urls = Array.isArray(server.urls) ? server.urls : [server.urls];
        return urls.some(url => typeof url === 'string' && url.startsWith('turn:'));
      })
      .map(server => ({
        urls: Array.isArray(server.urls) ? server.urls : [server.urls],
        username: server.username,
        credential: server.credential
      }));

    return {
      source: this.turnConfigSource || 'web-offer',
      servers: turnServers
    };
  }
  
  /**
   * 优化 SDP 以提高视频质量和降低延迟
   */
  optimizeSDP(sdp) {
    let optimizedSDP = sdp;
    
    // 设置视频编码参数
    // 1. 大幅提高最大比特率以支持高帧率和高分辨率
    optimizedSDP = optimizedSDP.replace(
      /(m=video.*\r\n)/g,
      '$1b=AS:20000\r\n' // 提高到 20Mbps 以支持高分辨率高帧率
    );
    
    // 2. 添加 TIAS (Transport Independent Application Specific Maximum) 带宽限制
    optimizedSDP = optimizedSDP.replace(
      /(b=AS:20000\r\n)/g,
      '$1b=TIAS:20000000\r\n' // 20 Mbps in bits per second
    );
    
    // 3. 优先使用 H.264 编码（更好的硬件支持和质量）
    const h264Regex = /a=rtpmap:(\d+) H264\/90000/;
    const h264Match = optimizedSDP.match(h264Regex);
    if (h264Match) {
      const h264PayloadType = h264Match[1];
      
      // 设置 H.264 高质量高帧率编码参数
      const h264FmtpRegex = new RegExp(`a=fmtp:${h264PayloadType} (.*)`, 'g');
      if (optimizedSDP.match(h264FmtpRegex)) {
        optimizedSDP = optimizedSDP.replace(
          h264FmtpRegex,
          // 提高 max-mbps 以支持 60fps
          `a=fmtp:${h264PayloadType} level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=640034;max-mbps=972000;max-fs=36864;max-br=20000`
        );
      } else {
        optimizedSDP = optimizedSDP.replace(
          h264Regex,
          `$&\r\na=fmtp:${h264PayloadType} level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=640034;max-mbps=972000;max-fs=36864;max-br=20000`
        );
      }
      
      // 将 H.264 移到编码列表的最前面（提高优先级）
      const mLineRegex = /m=video \d+ [^\r\n]+/;
      const mLineMatch = optimizedSDP.match(mLineRegex);
      if (mLineMatch) {
        const mLine = mLineMatch[0];
        const payloadTypes = mLine.split(' ').slice(3);
        
        // 将 H.264 payload type 移到最前面
        const reorderedTypes = [h264PayloadType, ...payloadTypes.filter(pt => pt !== h264PayloadType)];
        const newMLine = mLine.split(' ').slice(0, 3).join(' ') + ' ' + reorderedTypes.join(' ');
        
        optimizedSDP = optimizedSDP.replace(mLineRegex, newMLine);
      }
    }
    
    // 4. 禁用 RTX（重传）以降低延迟
    optimizedSDP = optimizedSDP.replace(/a=rtpmap:\d+ rtx\/90000\r\n/g, '');
    optimizedSDP = optimizedSDP.replace(/a=fmtp:\d+ apt=\d+\r\n/g, '');
    
    // 5. 禁用 FEC（前向纠错）以降低延迟
    optimizedSDP = optimizedSDP.replace(/a=rtpmap:\d+ (red|ulpfec)\/90000\r\n/g, '');
    
    // 6. 设置音频编码参数
    optimizedSDP = optimizedSDP.replace(
      /(m=audio.*\r\n)/g,
      '$1b=AS:128\r\n' // 设置音频带宽为 128 kbps
    );
    
    // 7. 优先使用 Opus 编码
    const opusRegex = /a=rtpmap:(\d+) opus\/48000\/2/;
    const opusMatch = optimizedSDP.match(opusRegex);
    if (opusMatch) {
      const opusPayloadType = opusMatch[1];
      
      // 设置 Opus 低延迟高质量参数
      const opusFmtpRegex = new RegExp(`a=fmtp:${opusPayloadType} (.*)`, 'g');
      if (optimizedSDP.match(opusFmtpRegex)) {
        optimizedSDP = optimizedSDP.replace(
          opusFmtpRegex,
          `a=fmtp:${opusPayloadType} minptime=10;useinbandfec=1;maxaveragebitrate=128000;stereo=1;sprop-stereo=1`
        );
      } else {
        optimizedSDP = optimizedSDP.replace(
          opusRegex,
          `$&\r\na=fmtp:${opusPayloadType} minptime=10;useinbandfec=1;maxaveragebitrate=128000;stereo=1;sprop-stereo=1`
        );
      }
      
      // 将 Opus 移到音频编码列表的最前面
      const audioMLineRegex = /m=audio \d+ [^\r\n]+/;
      const audioMLineMatch = optimizedSDP.match(audioMLineRegex);
      if (audioMLineMatch) {
        const audioMLine = audioMLineMatch[0];
        const audioPayloadTypes = audioMLine.split(' ').slice(3);
        
        const reorderedAudioTypes = [opusPayloadType, ...audioPayloadTypes.filter(pt => pt !== opusPayloadType)];
        const newAudioMLine = audioMLine.split(' ').slice(0, 3).join(' ') + ' ' + reorderedAudioTypes.join(' ');
        
        optimizedSDP = optimizedSDP.replace(audioMLineRegex, newAudioMLine);
      }
    }
    
    // 8. 添加低延迟属性
    optimizedSDP = optimizedSDP.replace(
      /(a=rtcp-mux\r\n)/g,
      '$1a=rtcp-rsize\r\n' // 启用 RTCP 精简模式
    );
    
    // 9. 设置 RTCP 反馈机制以快速响应网络变化
    if (h264Match) {
      const h264PayloadType = h264Match[1];
      // 确保有 NACK 和 PLI 反馈
      if (!optimizedSDP.includes(`a=rtcp-fb:${h264PayloadType} nack`)) {
        optimizedSDP = optimizedSDP.replace(
          new RegExp(`(a=rtpmap:${h264PayloadType} H264/90000\r\n)`),
          `$1a=rtcp-fb:${h264PayloadType} nack\r\na=rtcp-fb:${h264PayloadType} nack pli\r\na=rtcp-fb:${h264PayloadType} goog-remb\r\n`
        );
      }
    }
    
    console.log('✓ SDP 已优化（高质量高帧率低延迟模式 - 20Mbps, High Profile）');
    console.log('当前视频约束:', this.videoConstraints || '未设置');
    return optimizedSDP;
  }
  
  /**
   * 处理 Answer
   */
  async handleAnswer(answer) {
    // 检查PeerConnection状态，避免重复设置
    if (!this.peerConnection) {
      console.error('PeerConnection不存在，无法处理Answer');
      return;
    }
    
    const currentState = this.peerConnection.signalingState;
    console.log('>>> 处理Answer，当前信令状态:', currentState);
    
    if (currentState === 'stable') {
      console.warn('⚠️ PeerConnection已处于stable状态，可能是重复的Answer或连接已建立');
      // 不直接返回，而是检查连接状态
      if (this.peerConnection.connectionState === 'connected') {
        console.log('✓ 连接已建立，跳过Answer处理');
        return;
      } else {
        console.warn('⚠️ 信令状态为stable但连接未建立，尝试处理Answer');
      }
    }
    
    try {
      await this.peerConnection.setRemoteDescription(new RTCSessionDescription(answer));
      console.log('✓ 远程描述设置成功');
    } catch (error) {
      console.error('✗ 设置远程描述失败:', error);
      
      // 如果设置失败，可能需要重新建立连接
      if (error.name === 'InvalidStateError') {
        console.warn('⚠️ 状态错误，可能需要重新建立连接');
        // 可以在这里触发重新连接逻辑
      }
      
      if (this.callbacks.onError) {
        this.callbacks.onError('设置远程描述失败: ' + error.message);
      }
    }
  }
  
  /**
   * 处理 ICE 候选
   */
  async handleIceCandidate(candidate) {
    this.recordIceCandidate('remote', candidate);
    console.log('>>> 添加远程ICE候选:', this.describeIceCandidate(candidate));
    if (this.peerConnection) {
      await this.peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
      console.log('✓ ICE候选添加成功');
    }
  }
  
  /**
   * 发送 DataChannel 消息
   */
  sendMessage(message) {
    if (!this.dataChannel || this.dataChannel.readyState !== 'open') {
      console.warn('DataChannel未打开');
      return false;
    }
    
    const data = typeof message === 'string' ? message : JSON.stringify(message);
    this.dataChannel.send(data);
    return true;
  }
  
  /**
   * 发送虚拟按键
   */
  sendVirtualKey(key) {
    return this.sendMessage({
      action: 'virtualKey',
      key: key
    });
  }
  
  /**
   * 请求屏幕共享
   */
  requestScreenShare() {
    return this.sendMessage({
      action: 'startScreenShare'
    });
  }
  
  /**
   * 更新视频设置
   */
  updateVideoSettings(settings) {
    // 保存新的视频约束
    this.videoConstraints = { ...settings };
    
    console.log('更新视频设置:', settings);
    
    // 发送给设备端
    return this.sendMessage({
      action: 'updateVideoSettings',
      settings: settings
    });
  }
  
  /**
   * 重新协商连接（用于应用新的视频设置）
   */
  async renegotiate(videoConstraints) {
    if (!this.peerConnection) {
      throw new Error('PeerConnection 未初始化');
    }
    
    console.log('开始重新协商，新的视频约束:', videoConstraints);
    
    // 更新视频约束
    this.videoConstraints = { ...videoConstraints };
    
    try {
      // 创建新的 Offer
      const offerOptions = {
        offerToReceiveAudio: true,
        offerToReceiveVideo: true,
        iceRestart: false
      };
      
      const offer = await this.peerConnection.createOffer(offerOptions);
      
      // 优化 SDP
      offer.sdp = this.optimizeSDP(offer.sdp);
      
      await this.peerConnection.setLocalDescription(offer);
      
      // 发送新的 Offer 和视频约束
      this.sendSignaling({
        type: 'offer',
        deviceName: this.deviceName,
        offer: offer,
        videoConstraints: this.videoConstraints,
        renegotiate: true
      });
      
      console.log('🔄 重新协商 - 发送给设备的视频约束:', JSON.stringify(this.videoConstraints, null, 2));
      console.log('✓ 重新协商 Offer 已发送');
      return true;
    } catch (error) {
      console.error('重新协商失败:', error);
      if (this.callbacks.onError) {
        this.callbacks.onError('重新协商失败: ' + error.message);
      }
      throw error;
    }
  }
  
  /**
   * 强制重置连接
   */
  forceReconnect() {
    console.log('🔄 强制重置WebRTC连接...');
    
    // 清理现有连接
    this.cleanup();
    
    // 重置状态
    this.connectionState = 'disconnected';
    
    console.log('✓ 连接已重置，可以重新建立连接');
    
    // 触发状态变化回调
    if (this.callbacks.onConnectionStateChange) {
      this.callbacks.onConnectionStateChange(this.connectionState);
    }
  }
  
  /**
   * 重启ICE连接
   */
  async restartIce() {
    if (!this.peerConnection) {
      console.error('PeerConnection不存在，无法重启ICE');
      return;
    }
    
    try {
      console.log('🔄 开始ICE重启...');
      
      // 创建新的offer，启用ICE重启
      const offerOptions = {
        offerToReceiveAudio: true,
        offerToReceiveVideo: true,
        iceRestart: true // 关键：启用ICE重启
      };
      
      const offer = await this.peerConnection.createOffer(offerOptions);
      offer.sdp = this.optimizeSDP(offer.sdp);
      
      await this.peerConnection.setLocalDescription(offer);
      
      // 发送ICE重启的offer
      this.sendSignaling({
        type: 'offer',
        deviceName: this.deviceName,
        offer: offer,
        videoConstraints: this.videoConstraints,
        iceRestart: true
      });
      
      console.log('✓ ICE重启offer已发送');
    } catch (error) {
      console.error('ICE重启失败:', error);
    }
  }
  
  /**
   * 停止连接
   */
  stop() {
    this.cleanup();
    this.connectionState = 'disconnected';
  }
  
  /**
   * 清理资源
   */
  cleanup() {
    if (this.relayCheckTimer) {
      clearTimeout(this.relayCheckTimer);
      this.relayCheckTimer = null;
    }

    if (this.dataChannel) {
      this.dataChannel.close();
      this.dataChannel = null;
    }
    
    if (this.peerConnection) {
      this.peerConnection.close();
      this.peerConnection = null;
    }
    
    if (this.remoteStream) {
      this.remoteStream.getTracks().forEach(track => track.stop());
      this.remoteStream = null;
    }
    
    console.log('✓ WebRTC 资源已清理');
  }

  describeIceCandidate(candidate) {
    if (!candidate) {
      return 'null';
    }

    const raw = candidate.candidate || '';
    const candidateType = raw.match(/\btyp\s+([a-zA-Z0-9]+)/)?.[1] || candidate.type || 'unknown';
    const protocol = raw.match(/\b(udp|tcp)\b/i)?.[1]?.toLowerCase() || candidate.protocol || 'unknown';
    const address = candidate.address || raw.split(' ')[4] || 'unknown';
    const port = candidate.port || raw.split(' ')[5] || 'unknown';
    const tcpType = raw.match(/\btcptype\s+([a-zA-Z0-9]+)/)?.[1];
    return `type=${candidateType}, protocol=${protocol}, address=${address}, port=${port}${tcpType ? `, tcpType=${tcpType}` : ''}`;
  }

  async logIceDiagnostics(reason) {
    if (!this.peerConnection) {
      return;
    }

    const now = Date.now();
    if (now - this.lastIceStatsSnapshotAt < 1500) {
      return;
    }
    this.lastIceStatsSnapshotAt = now;

    try {
      const stats = await this.peerConnection.getStats();
      let selectedPair = null;
      const candidates = new Map();

      stats.forEach((report) => {
        if (report.type === 'local-candidate' || report.type === 'remote-candidate') {
          candidates.set(report.id, report);
        }
        if (report.type === 'candidate-pair') {
          const isSelected = report.selected || report.nominated || report.state === 'succeeded';
          if (!selectedPair && isSelected) {
            selectedPair = report;
          }
        }
      });

      if (!selectedPair) {
        console.warn(`[ICE diagnostics:${reason}] 未找到已选中的 candidate pair`);
        return;
      }

      const local = candidates.get(selectedPair.localCandidateId);
      const remote = candidates.get(selectedPair.remoteCandidateId);
      console.log(`[ICE diagnostics:${reason}] pair state=${selectedPair.state}, nominated=${selectedPair.nominated}, writable=${selectedPair.writable}, readable=${selectedPair.readable}, currentRtt=${selectedPair.currentRoundTripTime || 0}`);
      if (local) {
        console.log(`[ICE diagnostics:${reason}] local => type=${local.candidateType}, protocol=${local.protocol}, address=${local.address || local.ip}:${local.port}, networkType=${local.networkType || 'unknown'}`);
      }
      if (remote) {
        console.log(`[ICE diagnostics:${reason}] remote => type=${remote.candidateType}, protocol=${remote.protocol}, address=${remote.address || remote.ip}:${remote.port}`);
      }
      if (!local || !remote) {
        console.log(`[ICE diagnostics:${reason}] pair ids => local=${selectedPair.localCandidateId}, remote=${selectedPair.remoteCandidateId}`);
      }
    } catch (error) {
      console.warn(`[ICE diagnostics:${reason}] getStats失败:`, error);
    }
  }

  createEmptyIceStats() {
    return {
      local: { host: 0, srflx: 0, relay: 0, prflx: 0, unknown: 0 },
      remote: { host: 0, srflx: 0, relay: 0, prflx: 0, unknown: 0 }
    };
  }

  resetIceDebugState() {
    this.iceCandidateStats = this.createEmptyIceStats();
    if (this.relayCheckTimer) {
      clearTimeout(this.relayCheckTimer);
      this.relayCheckTimer = null;
    }
  }

  recordIceCandidate(side, candidate) {
    const raw = candidate?.candidate || '';
    const candidateType = raw.match(/\btyp\s+([a-zA-Z0-9]+)/)?.[1] || candidate?.type || 'unknown';
    const bucket = this.iceCandidateStats[side];
    if (!bucket) {
      return;
    }
    if (Object.prototype.hasOwnProperty.call(bucket, candidateType)) {
      bucket[candidateType] += 1;
    } else {
      bucket.unknown += 1;
    }
    this.logIceCandidateSummary(`${side}-candidate-${candidateType}`);
  }

  logIceCandidateSummary(reason) {
    const local = this.iceCandidateStats.local;
    const remote = this.iceCandidateStats.remote;
    console.log(`[ICE summary:${reason}] local host=${local.host}, srflx=${local.srflx}, relay=${local.relay}, prflx=${local.prflx}, unknown=${local.unknown}; remote host=${remote.host}, srflx=${remote.srflx}, relay=${remote.relay}, prflx=${remote.prflx}, unknown=${remote.unknown}`);
  }

  warnIfRelayMissing(reason) {
    const { local, remote } = this.iceCandidateStats;
    if (local.relay === 0) {
      console.warn(`[ICE summary:${reason}] 本地尚未获得 relay 候选`);
    }
    if (remote.relay === 0) {
      console.warn(`[ICE summary:${reason}] 远端尚未获得 relay 候选`);
    }
  }

  scheduleRelayCheck() {
    if (this.relayCheckTimer) {
      clearTimeout(this.relayCheckTimer);
    }
    this.relayCheckTimer = setTimeout(() => {
      this.logIceCandidateSummary('relay-check-timeout');
      this.warnIfRelayMissing('relay-check-timeout');
      this.relayCheckTimer = null;
    }, 4000);
  }
  
  /**
   * 获取连接状态
   */
  getConnectionState() {
    return this.connectionState;
  }
  
  /**
   * 获取远程流
   */
  getRemoteStream() {
    return this.remoteStream;
  }
  
  /**
   * 检查 DataChannel 是否可用
   */
  isDataChannelOpen() {
    return this.dataChannel && this.dataChannel.readyState === 'open';
  }
}
