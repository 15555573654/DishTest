/**
 * WebRTC统计监控器
 * 负责收集和分析WebRTC连接的统计信息
 * 参考scrcpy的性能监控机制
 */

export default class StatsMonitor {
  constructor(peerConnection, options = {}) {
    this.peerConnection = peerConnection;
    
    // 配置参数
    this.config = {
      updateInterval: options.updateInterval || 1000,  // 更新间隔（毫秒）
      enableLogging: options.enableLogging || false    // 是否启用日志
    };

    // 统计数据
    this.stats = {
      bitrate: 0,           // 比特率（kbps）
      fps: 0,               // 帧率
      resolution: '',       // 分辨率
      packetLoss: 0,        // 丢包率（%）
      jitter: 0,            // 抖动（ms）
      rtt: 0,               // 往返时间（ms）
      bytesReceived: 0,     // 接收字节数
      packetsReceived: 0,   // 接收包数
      packetsLost: 0,       // 丢失包数
      framesDecoded: 0,     // 解码帧数
      framesDropped: 0,     // 丢弃帧数
      timestamp: 0          // 时间戳
    };

    // 上次统计数据（用于计算增量）
    this.lastStats = {
      bytesReceived: 0,
      timestamp: 0,
      framesDecoded: 0
    };

    // 监控定时器
    this.monitorInterval = null;

    // 回调函数
    this.onStatsUpdate = null;
    this.onQualityChange = null;

    // 质量评估阈值
    this.qualityThresholds = {
      rtt: {
        excellent: 50,
        good: 100,
        fair: 200
      },
      fps: {
        excellent: 55,
        good: 45,
        fair: 30
      },
      packetLoss: {
        excellent: 1,
        good: 3,
        fair: 5
      }
    };

    // 调试标志
    this.debugStatsLogged = false;
  }

  /**
   * 开始监控
   */
  start() {
    if (this.monitorInterval) {
      console.warn('[StatsMonitor] 监控已在运行');
      return;
    }

    console.log('[StatsMonitor] 开始监控');
    this.monitorInterval = setInterval(() => {
      this.collectStats();
    }, this.config.updateInterval);
  }

  /**
   * 停止监控
   */
  stop() {
    if (this.monitorInterval) {
      clearInterval(this.monitorInterval);
      this.monitorInterval = null;
      console.log('[StatsMonitor] 停止监控');
    }
  }

  /**
   * 收集统计信息
   */
  async collectStats() {
    if (!this.peerConnection) {
      console.warn('[StatsMonitor] PeerConnection不存在');
      return;
    }

    try {
      const stats = await this.peerConnection.getStats();
      
      // 调试：输出所有报告类型（仅首次）
      if (!this.debugStatsLogged && this.config.enableLogging) {
        const reportTypes = new Set();
        stats.forEach(report => {
          reportTypes.add(report.type);
        });
        console.log('[StatsMonitor] 可用的统计报告类型:', Array.from(reportTypes));
        this.debugStatsLogged = true;
      }

      // 解析统计数据
      this.parseStats(stats);

      // 触发更新回调
      if (this.onStatsUpdate) {
        this.onStatsUpdate(this.stats);
      }

      // 质量评估
      this.assessQuality();

    } catch (err) {
      console.error('[StatsMonitor] 获取统计信息失败:', err);
    }
  }

  /**
   * 解析统计数据
   */
  parseStats(stats) {
    stats.forEach(report => {
      // 视频入站统计
      if (report.type === 'inbound-rtp' && report.kind === 'video') {
        this.parseInboundRtp(report);
      }

      // 远端入站统计（RTT）
      if (report.type === 'remote-inbound-rtp' && report.kind === 'video') {
        this.parseRemoteInboundRtp(report);
      }

      // 候选对统计（RTT备用）
      if (report.type === 'candidate-pair' && report.state === 'succeeded') {
        this.parseCandidatePair(report);
      }
    });
  }

  /**
   * 解析入站RTP统计
   */
  parseInboundRtp(report) {
    const now = report.timestamp;

    // 计算比特率
    if (this.lastStats.timestamp > 0 && now > this.lastStats.timestamp) {
      const timeDiff = (now - this.lastStats.timestamp) / 1000; // 转换为秒
      const bytesDiff = report.bytesReceived - this.lastStats.bytesReceived;
      
      if (timeDiff > 0 && bytesDiff >= 0) {
        this.stats.bitrate = Math.round((bytesDiff * 8) / timeDiff / 1000); // kbps
      }
    }

    // 计算帧率
    if (report.framesPerSecond !== undefined && report.framesPerSecond > 0) {
      this.stats.fps = Math.round(report.framesPerSecond);
    } else if (report.framesDecoded !== undefined && this.lastStats.timestamp > 0) {
      // 备用方案：通过解码帧数增量计算
      const timeDiff = (now - this.lastStats.timestamp) / 1000;
      const framesDiff = report.framesDecoded - this.lastStats.framesDecoded;
      
      if (timeDiff > 0 && framesDiff >= 0) {
        this.stats.fps = Math.round(framesDiff / timeDiff);
      }
    }

    // 分辨率
    if (report.frameWidth && report.frameHeight) {
      this.stats.resolution = `${report.frameWidth}x${report.frameHeight}`;
    }

    // 丢包率
    if (report.packetsLost !== undefined && report.packetsReceived !== undefined) {
      const totalPackets = report.packetsLost + report.packetsReceived;
      if (totalPackets > 0) {
        this.stats.packetLoss = parseFloat(((report.packetsLost / totalPackets) * 100).toFixed(2));
      }
      this.stats.packetsLost = report.packetsLost;
      this.stats.packetsReceived = report.packetsReceived;
    }

    // 抖动
    if (report.jitter !== undefined) {
      this.stats.jitter = Math.round(report.jitter * 1000); // 转换为毫秒
    }

    // 解码帧数和丢弃帧数
    if (report.framesDecoded !== undefined) {
      this.stats.framesDecoded = report.framesDecoded;
    }
    if (report.framesDropped !== undefined) {
      this.stats.framesDropped = report.framesDropped;
    }

    // 更新上次统计数据
    this.lastStats.bytesReceived = report.bytesReceived;
    this.lastStats.timestamp = now;
    this.lastStats.framesDecoded = report.framesDecoded || 0;
    
    this.stats.bytesReceived = report.bytesReceived;
    this.stats.timestamp = now;
  }

  /**
   * 解析远端入站RTP统计
   */
  parseRemoteInboundRtp(report) {
    // RTT（往返时间）
    if (report.roundTripTime !== undefined && report.roundTripTime > 0) {
      this.stats.rtt = Math.round(report.roundTripTime * 1000); // 转换为毫秒
      
      if (this.config.enableLogging) {
        console.log('[StatsMonitor] 从 remote-inbound-rtp 获取 RTT:', this.stats.rtt, 'ms');
      }
    }
  }

  /**
   * 解析候选对统计
   */
  parseCandidatePair(report) {
    // RTT备用方案
    if (this.stats.rtt === 0 && report.currentRoundTripTime !== undefined && report.currentRoundTripTime > 0) {
      const newRtt = Math.round(report.currentRoundTripTime * 1000);
      
      // 只有当RTT变化超过5ms时才更新，避免频繁小幅波动
      if (Math.abs(newRtt - this.stats.rtt) > 5 || this.stats.rtt === 0) {
        this.stats.rtt = newRtt;
        
        if (this.config.enableLogging) {
          console.log('[StatsMonitor] 从 candidate-pair 更新 RTT:', this.stats.rtt, 'ms');
        }
      }
    }
  }

  /**
   * 评估连接质量
   */
  assessQuality() {
    const quality = {
      overall: 'unknown',
      rtt: this.getRttQuality(),
      fps: this.getFpsQuality(),
      packetLoss: this.getPacketLossQuality()
    };

    // 综合评估
    const qualities = [quality.rtt, quality.fps, quality.packetLoss];
    const poorCount = qualities.filter(q => q === 'poor').length;
    const fairCount = qualities.filter(q => q === 'fair').length;

    if (poorCount >= 2) {
      quality.overall = 'poor';
    } else if (poorCount >= 1 || fairCount >= 2) {
      quality.overall = 'fair';
    } else if (qualities.every(q => q === 'excellent')) {
      quality.overall = 'excellent';
    } else {
      quality.overall = 'good';
    }

    // 触发质量变化回调
    if (this.onQualityChange && quality.overall !== this.lastQuality) {
      this.onQualityChange(quality);
      this.lastQuality = quality.overall;
    }

    return quality;
  }

  /**
   * 获取RTT质量等级
   */
  getRttQuality() {
    const rtt = this.stats.rtt;
    if (rtt === 0) return 'unknown';
    if (rtt < this.qualityThresholds.rtt.excellent) return 'excellent';
    if (rtt < this.qualityThresholds.rtt.good) return 'good';
    if (rtt < this.qualityThresholds.rtt.fair) return 'fair';
    return 'poor';
  }

  /**
   * 获取FPS质量等级
   */
  getFpsQuality() {
    const fps = this.stats.fps;
    if (fps === 0) return 'unknown';
    if (fps >= this.qualityThresholds.fps.excellent) return 'excellent';
    if (fps >= this.qualityThresholds.fps.good) return 'good';
    if (fps >= this.qualityThresholds.fps.fair) return 'fair';
    return 'poor';
  }

  /**
   * 获取丢包率质量等级
   */
  getPacketLossQuality() {
    const packetLoss = this.stats.packetLoss;
    if (packetLoss === 0) return 'excellent';
    if (packetLoss < this.qualityThresholds.packetLoss.excellent) return 'excellent';
    if (packetLoss < this.qualityThresholds.packetLoss.good) return 'good';
    if (packetLoss < this.qualityThresholds.packetLoss.fair) return 'fair';
    return 'poor';
  }

  /**
   * 获取当前统计数据
   */
  getStats() {
    return { ...this.stats };
  }

  /**
   * 获取质量评估
   */
  getQuality() {
    return this.assessQuality();
  }

  /**
   * 设置统计更新回调
   */
  setOnStatsUpdate(callback) {
    this.onStatsUpdate = callback;
  }

  /**
   * 设置质量变化回调
   */
  setOnQualityChange(callback) {
    this.onQualityChange = callback;
  }

  /**
   * 重置统计数据
   */
  reset() {
    this.stats = {
      bitrate: 0,
      fps: 0,
      resolution: '',
      packetLoss: 0,
      jitter: 0,
      rtt: 0,
      bytesReceived: 0,
      packetsReceived: 0,
      packetsLost: 0,
      framesDecoded: 0,
      framesDropped: 0,
      timestamp: 0
    };

    this.lastStats = {
      bytesReceived: 0,
      timestamp: 0,
      framesDecoded: 0
    };

    this.debugStatsLogged = false;
    console.log('[StatsMonitor] 统计数据已重置');
  }

  /**
   * 获取性能报告
   */
  getPerformanceReport() {
    const quality = this.assessQuality();
    
    return {
      timestamp: Date.now(),
      stats: this.getStats(),
      quality: quality,
      recommendations: this.getRecommendations(quality)
    };
  }

  /**
   * 获取优化建议
   */
  getRecommendations(quality) {
    const recommendations = [];

    if (quality.rtt === 'poor') {
      recommendations.push({
        type: 'network',
        severity: 'high',
        message: '网络延迟过高，建议检查网络连接或降低视频质量'
      });
    }

    if (quality.fps === 'poor') {
      recommendations.push({
        type: 'performance',
        severity: 'high',
        message: '帧率过低，建议降低分辨率或关闭其他应用'
      });
    }

    if (quality.packetLoss === 'poor') {
      recommendations.push({
        type: 'network',
        severity: 'high',
        message: '丢包率过高，建议检查网络稳定性'
      });
    }

    if (this.stats.framesDropped > 0 && this.stats.framesDecoded > 0) {
      const dropRate = (this.stats.framesDropped / this.stats.framesDecoded) * 100;
      if (dropRate > 5) {
        recommendations.push({
          type: 'performance',
          severity: 'medium',
          message: `丢帧率${dropRate.toFixed(1)}%，建议降低视频质量`
        });
      }
    }

    return recommendations;
  }
}
