package com.ruoyi.screencast.webrtc

import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import com.google.gson.Gson
import com.ruoyi.screencast.mqtt.MqttManager
import org.webrtc.*

class WebRTCManager(private val context: Context) {
    
    private var peerConnection: PeerConnection? = null
    private var videoCapturer: VideoCapturer? = null
    private var videoSource: VideoSource? = null
    private var audioSource: AudioSource? = null
    private var localVideoTrack: VideoTrack? = null
    private var localAudioTrack: AudioTrack? = null
    
    private var mqttManager: MqttManager? = null
    private var username: String = ""
    private var deviceName: String = ""
    
    private var statusCallback: ((String) -> Unit)? = null
    private var logCallback: ((String) -> Unit)? = null
    private var screenCaptureRequestCallback: (() -> Unit)? = null
    
    private var pendingOffer: SessionDescription? = null
    
    private val gson = Gson()
    
    init {
        initializeWebRTC()
    }
    
    private fun initializeWebRTC() {
        val options = PeerConnectionFactory.InitializationOptions.builder(context)
            .setEnableInternalTracer(true)
            .createInitializationOptions()
        PeerConnectionFactory.initialize(options)
    }
    
    fun setMqttManager(manager: MqttManager) {
        mqttManager = manager
        mqttManager?.setMessageCallback { topic, message ->
            handleSignaling(message)
        }
    }
    
    fun setDeviceInfo(user: String, device: String) {
        username = user
        deviceName = device
    }
    
    fun setStatusCallback(callback: (String) -> Unit) {
        statusCallback = callback
    }
    
    fun setLogCallback(callback: (String) -> Unit) {
        logCallback = callback
    }
    
    fun setScreenCaptureRequestCallback(callback: () -> Unit) {
        screenCaptureRequestCallback = callback
    }
    
    fun startCapture(resultCode: Int, data: Intent) {
        try {
            // 检查前台服务是否运行
            val service = com.ruoyi.screencast.service.ScreenCaptureService.instance
            if (service == null) {
                throw RuntimeException("ScreenCaptureService not running - MediaProjection requires foreground service")
            }
            
            // 停止现有捕获，避免重复启动
            if (videoCapturer != null || localVideoTrack != null) {
                logCallback?.invoke("⚠️ 屏幕捕获已在运行，先停止现有捕获")
                stopCapture()
            }
            
            logCallback?.invoke("🎬 开始初始化屏幕捕获...")
            logCallback?.invoke("✅ 前台服务已运行，可以创建MediaProjection")
            
            val factory = createPeerConnectionFactory()
            
            // 获取设备实际屏幕分辨率
            val displayMetrics = context.resources.displayMetrics
            val screenWidth = displayMetrics.widthPixels
            val screenHeight = displayMetrics.heightPixels
            
            logCallback?.invoke("📱 设备分辨率: ${screenWidth}x${screenHeight}")
            
            // 使用Intent创建ScreenCapturer（WebRTC库需要Intent，不是MediaProjection对象）
            logCallback?.invoke("🎥 创建屏幕捕获器...")
            videoCapturer = createScreenCapturer(data)
            
            logCallback?.invoke("📹 创建视频源...")
            videoSource = factory.createVideoSource(false)
            
            logCallback?.invoke("🔗 初始化视频捕获器...")
            videoCapturer?.initialize(SurfaceTextureHelper.create("CaptureThread", null), context, videoSource?.capturerObserver)
            
            // 使用设备实际分辨率，帧率设置为30fps（平衡性能和流畅度）
            logCallback?.invoke("▶️ 启动视频捕获: ${screenWidth}x${screenHeight}@30fps")
            videoCapturer?.startCapture(screenWidth, screenHeight, 30)
            
            logCallback?.invoke("🎞️ 创建视频轨道...")
            localVideoTrack = factory.createVideoTrack("video", videoSource)
            
            logCallback?.invoke("🎵 创建音频源和轨道...")
            audioSource = factory.createAudioSource(MediaConstraints())
            localAudioTrack = factory.createAudioTrack("audio", audioSource)
            
            // 验证轨道创建成功
            if (localVideoTrack != null) {
                logCallback?.invoke("✅ 视频轨道创建成功")
            } else {
                logCallback?.invoke("❌ 视频轨道创建失败")
            }
            
            if (localAudioTrack != null) {
                logCallback?.invoke("✅ 音频轨道创建成功")
            } else {
                logCallback?.invoke("❌ 音频轨道创建失败")
            }
            
            logCallback?.invoke("✅ 视频捕获已启动: ${screenWidth}x${screenHeight}@30fps")
            statusCallback?.invoke("捕获中")
            
            // 如果有待处理的 offer，现在处理它
            pendingOffer?.let { offer ->
                logCallback?.invoke("📥 处理待处理的 offer，开始建立WebRTC连接")
                handleOffer(offer)
                pendingOffer = null
                logCallback?.invoke("✓ 待处理的 offer 已处理完成")
            } ?: run {
                logCallback?.invoke("ℹ️ 没有待处理的 offer，等待Web端发起连接")
            }
            
        } catch (e: Exception) {
            logCallback?.invoke("❌ 启动捕获失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    private fun stopCapture() {
        try {
            logCallback?.invoke("🛑 停止现有屏幕捕获...")
            
            videoCapturer?.stopCapture()
            videoCapturer?.dispose()
            videoCapturer = null
            
            localVideoTrack?.dispose()
            localVideoTrack = null
            
            localAudioTrack?.dispose()
            localAudioTrack = null
            
            videoSource?.dispose()
            videoSource = null
            
            audioSource?.dispose()
            audioSource = null
            
            logCallback?.invoke("✓ 屏幕捕获资源已清理")
        } catch (e: Exception) {
            logCallback?.invoke("⚠️ 清理捕获资源时出错: ${e.message}")
        }
    }
    
    private fun createPeerConnectionFactory(): PeerConnectionFactory {
        return PeerConnectionFactory.builder()
            .setVideoEncoderFactory(DefaultVideoEncoderFactory(null, true, true))
            .setVideoDecoderFactory(DefaultVideoDecoderFactory(null))
            .createPeerConnectionFactory()
    }
    
    private fun createScreenCapturer(mediaProjectionPermissionResultData: Intent): VideoCapturer {
        // 确保在前台服务上下文中创建ScreenCapturer
        logCallback?.invoke("🎥 在前台服务上下文中创建ScreenCapturer")
        
        return ScreenCapturerAndroid(
            mediaProjectionPermissionResultData,
            object : MediaProjection.Callback() {
                override fun onStop() {
                    logCallback?.invoke("MediaProjection已停止")
                }
            }
        )
    }
    
    private fun handleSignaling(message: String) {
        try {
            val jsonObject = gson.fromJson(message, com.google.gson.JsonObject::class.java)
            val type = jsonObject.get("type")?.asString ?: return
            val deviceNameFromMsg = jsonObject.get("deviceName")?.asString ?: return
            
            if (deviceNameFromMsg != deviceName) {
                return
            }
            
            logCallback?.invoke("收到信令: $type")
            
            when (type) {
                "offer" -> {
                    val offerObj = jsonObject.getAsJsonObject("offer")
                    if (offerObj != null) {
                        val sdpType = offerObj.get("type")?.asString
                        val sdp = offerObj.get("sdp")?.asString
                        if (sdpType != null && sdp != null) {
                            val sessionDescType = when (sdpType.lowercase()) {
                                "offer" -> SessionDescription.Type.OFFER
                                "answer" -> SessionDescription.Type.ANSWER
                                "pranswer" -> SessionDescription.Type.PRANSWER
                                else -> SessionDescription.Type.OFFER
                            }
                            val offer = SessionDescription(sessionDescType, sdp)
                            handleOffer(offer)
                        }
                    }
                }
                "ice-candidate" -> {
                    val candidateObj = jsonObject.getAsJsonObject("candidate")
                    if (candidateObj != null) {
                        val sdpMid = candidateObj.get("sdpMid")?.asString
                        val sdpMLineIndex = candidateObj.get("sdpMLineIndex")?.asInt ?: 0
                        val sdp = candidateObj.get("candidate")?.asString
                        if (sdpMid != null && sdp != null) {
                            val candidate = IceCandidate(sdpMid, sdpMLineIndex, sdp)
                            handleIceCandidate(candidate)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            logCallback?.invoke("处理信令失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    private fun handleOffer(offer: SessionDescription) {
        try {
            logCallback?.invoke("开始处理Offer")
            
            // 如果已经有PeerConnection，检查状态决定是否需要重新创建
            if (peerConnection != null) {
                val signalingState = peerConnection?.signalingState()
                val connectionState = peerConnection?.connectionState()
                logCallback?.invoke("当前PeerConnection状态: 信令=$signalingState, 连接=$connectionState")
                
                // 如果信令状态正常且连接状态也正常，跳过重复处理
                if (signalingState == PeerConnection.SignalingState.STABLE && 
                    (connectionState == PeerConnection.PeerConnectionState.CONNECTED || 
                     connectionState == PeerConnection.PeerConnectionState.CONNECTING)) {
                    logCallback?.invoke("⚠️ PeerConnection状态正常，跳过重复的Offer处理")
                    return
                }
                
                // 如果连接失败或断开，清理并重新创建
                if (connectionState == PeerConnection.PeerConnectionState.FAILED ||
                    connectionState == PeerConnection.PeerConnectionState.DISCONNECTED ||
                    connectionState == PeerConnection.PeerConnectionState.CLOSED) {
                    logCallback?.invoke("🔄 连接状态异常($connectionState)，重新建立连接")
                } else {
                    logCallback?.invoke("🔄 信令状态异常($signalingState)，重新建立连接")
                }
                
                peerConnection?.close()
                peerConnection?.dispose()
                peerConnection = null
            }
            
            val factory = createPeerConnectionFactory()
            
            val iceServers = listOf(
                PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer(),
                PeerConnection.IceServer.builder("turn:openrelay.metered.ca:80")
                    .setUsername("openrelayproject")
                    .setPassword("openrelayproject")
                    .createIceServer()
            )
            
            val rtcConfig = PeerConnection.RTCConfiguration(iceServers).apply {
                // 优化网络传输
                tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.DISABLED
                bundlePolicy = PeerConnection.BundlePolicy.MAXBUNDLE
                rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.REQUIRE
                continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY
                // 启用 DSCP 标记以提高 QoS
                enableDscp = true
            }
            
            peerConnection = factory.createPeerConnection(rtcConfig, object : PeerConnection.Observer {
                override fun onIceCandidate(candidate: IceCandidate?) {
                    candidate?.let { sendIceCandidate(it) }
                }
                
                override fun onIceCandidatesRemoved(candidates: Array<out IceCandidate>?) {}
                
                override fun onConnectionChange(newState: PeerConnection.PeerConnectionState?) {
                    logCallback?.invoke("PeerConnection状态变化: $newState")
                    when (newState) {
                        PeerConnection.PeerConnectionState.CONNECTING -> {
                            statusCallback?.invoke("正在连接")
                            logCallback?.invoke("WebRTC正在建立连接...")
                        }
                        PeerConnection.PeerConnectionState.CONNECTED -> {
                            statusCallback?.invoke("已连接")
                            logCallback?.invoke("✓ WebRTC连接成功！")
                        }
                        PeerConnection.PeerConnectionState.FAILED -> {
                            statusCallback?.invoke("连接失败")
                            logCallback?.invoke("✗ WebRTC连接失败")
                        }
                        PeerConnection.PeerConnectionState.DISCONNECTED -> {
                            statusCallback?.invoke("已断开")
                            logCallback?.invoke("⚠️ WebRTC连接已断开")
                        }
                        PeerConnection.PeerConnectionState.CLOSED -> {
                            statusCallback?.invoke("已关闭")
                            logCallback?.invoke("WebRTC连接已关闭")
                        }
                        else -> {
                            logCallback?.invoke("WebRTC状态: $newState")
                        }
                    }
                }
                
                override fun onSignalingChange(state: PeerConnection.SignalingState?) {
                    logCallback?.invoke("信令状态变化: $state")
                }
                
                override fun onIceConnectionChange(state: PeerConnection.IceConnectionState?) {
                    logCallback?.invoke("ICE连接状态变化: $state")
                    when (state) {
                        PeerConnection.IceConnectionState.CONNECTED -> {
                            logCallback?.invoke("✓ ICE连接已建立")
                        }
                        PeerConnection.IceConnectionState.COMPLETED -> {
                            logCallback?.invoke("✓ ICE连接已完成")
                        }
                        PeerConnection.IceConnectionState.FAILED -> {
                            logCallback?.invoke("✗ ICE连接失败")
                        }
                        PeerConnection.IceConnectionState.DISCONNECTED -> {
                            logCallback?.invoke("⚠️ ICE连接已断开")
                        }
                        else -> {}
                    }
                }
                override fun onIceConnectionReceivingChange(receiving: Boolean) {}
                override fun onIceGatheringChange(state: PeerConnection.IceGatheringState?) {}
                override fun onAddStream(stream: MediaStream?) {}
                override fun onRemoveStream(stream: MediaStream?) {}
                override fun onDataChannel(channel: DataChannel?) {
                    setupDataChannel(channel)
                }
                override fun onRenegotiationNeeded() {}
                override fun onAddTrack(receiver: RtpReceiver?, streams: Array<out MediaStream>?) {}
            })
            
            // 检查是否已启动屏幕捕获
            if (localVideoTrack == null) {
                logCallback?.invoke("⚠️ 尚未启动屏幕捕获，保存 offer 并请求权限...")
                statusCallback?.invoke("等待授权")
                // 保存 offer，等待屏幕捕获启动后再处理
                pendingOffer = offer
                // 通知 MainActivity 请求屏幕捕获权限
                screenCaptureRequestCallback?.invoke()
                return
            }
            
            // 确保视频轨道存在才继续
            if (localVideoTrack == null) {
                logCallback?.invoke("✗ 视频轨道不存在，无法建立连接")
                return
            }
            
            logCallback?.invoke("✓ 屏幕捕获已启动，开始建立WebRTC连接")
            
            localVideoTrack?.let { 
                peerConnection?.addTrack(it, listOf("stream"))
                logCallback?.invoke("✓ 已添加视频轨道")
            }
            localAudioTrack?.let { 
                peerConnection?.addTrack(it, listOf("stream"))
                logCallback?.invoke("✓ 已添加音频轨道")
            }
            
            peerConnection?.setRemoteDescription(SimpleSdpObserver(), offer)
            
            // 创建高质量视频约束
            val constraints = MediaConstraints().apply {
                mandatory.add(MediaConstraints.KeyValuePair("OfferToReceiveAudio", "false"))
                mandatory.add(MediaConstraints.KeyValuePair("OfferToReceiveVideo", "false"))
            }
            
            peerConnection?.createAnswer(object : SdpObserver {
                override fun onCreateSuccess(answer: SessionDescription?) {
                    answer?.let {
                        // 优化 SDP 以提高视频质量
                        val optimizedSdp = optimizeSdp(it.description)
                        val optimizedAnswer = SessionDescription(it.type, optimizedSdp)
                        peerConnection?.setLocalDescription(SimpleSdpObserver(), optimizedAnswer)
                        sendAnswer(optimizedAnswer)
                        logCallback?.invoke("✓ Answer已创建并发送")
                    }
                }
                
                override fun onSetSuccess() {}
                override fun onCreateFailure(error: String?) {
                    logCallback?.invoke("创建Answer失败: $error")
                }
                override fun onSetFailure(error: String?) {
                    logCallback?.invoke("设置本地描述失败: $error")
                }
            }, constraints)
            
        } catch (e: Exception) {
            logCallback?.invoke("处理Offer失败: ${e.message}")
        }
    }
    
    private fun handleIceCandidate(candidate: IceCandidate) {
        peerConnection?.addIceCandidate(candidate)
        logCallback?.invoke("已添加ICE候选")
    }
    
    private fun optimizeSdp(sdp: String): String {
        var optimizedSdp = sdp
        
        // 设置更合理的码率（10Mbps）以平衡画质和网络负载
        val maxBitrate = 10000  // 10Mbps
        val minBitrate = 2000   // 2Mbps
        val startBitrate = 5000 // 5Mbps
        
        // 为 VP8/VP9 编码器设置码率参数
        optimizedSdp = optimizedSdp.replace(
            Regex("(a=fmtp:\\d+ .*)"),
            "$1;x-google-max-bitrate=$maxBitrate;x-google-min-bitrate=$minBitrate;x-google-start-bitrate=$startBitrate"
        )
        
        // 添加高质量编码参数
        if (optimizedSdp.contains("VP8")) {
            optimizedSdp = optimizedSdp.replace(
                "a=rtpmap:(\\d+) VP8/90000".toRegex(),
                "a=rtpmap:$1 VP8/90000\r\na=fmtp:$1 x-google-max-bitrate=$maxBitrate;x-google-min-bitrate=$minBitrate;x-google-start-bitrate=$startBitrate"
            )
        }
        
        if (optimizedSdp.contains("VP9")) {
            optimizedSdp = optimizedSdp.replace(
                "a=rtpmap:(\\d+) VP9/90000".toRegex(),
                "a=rtpmap:$1 VP9/90000\r\na=fmtp:$1 x-google-max-bitrate=$maxBitrate;x-google-min-bitrate=$minBitrate;x-google-start-bitrate=$startBitrate;profile-id=0"
            )
        }
        
        // 添加 H264 高质量配置
        if (optimizedSdp.contains("H264")) {
            optimizedSdp = optimizedSdp.replace(
                "a=fmtp:(\\d+) .*profile-level-id=([0-9a-fA-F]+)".toRegex(),
                "a=fmtp:$1 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=$2;x-google-max-bitrate=$maxBitrate;x-google-min-bitrate=$minBitrate;x-google-start-bitrate=$startBitrate"
            )
        }
        
        logCallback?.invoke("SDP已优化: 码率${minBitrate}-${maxBitrate}kbps")
        return optimizedSdp
    }
    
    private fun sendAnswer(answer: SessionDescription?) {
        answer?.let {
            // 创建标准格式的 answer 对象，确保 type 是小写
            val answerMap = mapOf(
                "type" to it.type.canonicalForm().lowercase(),
                "sdp" to it.description
            )
            val message = mapOf(
                "type" to "answer",
                "deviceName" to deviceName,
                "answer" to answerMap,
                "from" to "device"
            )
            val topic = "webrtc/$username/$deviceName"
            mqttManager?.publish(topic, gson.toJson(message))
            logCallback?.invoke("已发送Answer")
        }
    }
    
    private fun sendIceCandidate(candidate: IceCandidate) {
        // 创建标准格式的 candidate 对象
        val candidateMap = mapOf(
            "candidate" to candidate.sdp,
            "sdpMid" to candidate.sdpMid,
            "sdpMLineIndex" to candidate.sdpMLineIndex
        )
        val message = mapOf(
            "type" to "ice-candidate",
            "deviceName" to deviceName,
            "candidate" to candidateMap,
            "from" to "device"
        )
        val topic = "webrtc/$username/$deviceName"
        mqttManager?.publish(topic, gson.toJson(message))
    }
    
    private fun setupDataChannel(channel: DataChannel?) {
        channel?.registerObserver(object : DataChannel.Observer {
            override fun onMessage(buffer: DataChannel.Buffer?) {
                buffer?.let {
                    val data = ByteArray(it.data.remaining())
                    it.data.get(data)
                    val message = String(data)
                    handleControlMessage(message)
                }
            }
            
            override fun onBufferedAmountChange(amount: Long) {}
            override fun onStateChange() {}
        })
    }
    
    private fun handleControlMessage(message: String) {
        try {
            val data = gson.fromJson(message, ControlMessage::class.java)
            logCallback?.invoke("收到控制指令: ${data.action}")
            
            when (data.action) {
                "click" -> performClick(data.x ?: 0f, data.y ?: 0f)
                "swipe" -> performSwipe(data.x1 ?: 0f, data.y1 ?: 0f, data.x2 ?: 0f, data.y2 ?: 0f)
                "back" -> performBack()
                "home" -> performHome()
                "virtualKey" -> performVirtualKey(data.key ?: "")
                "setQuality" -> handleQualityChange(data.settings)
            }
        } catch (e: Exception) {
            logCallback?.invoke("处理控制指令失败: ${e.message}")
        }
    }
    
    private fun handleQualityChange(settings: QualitySettings?) {
        settings?.let { qualitySettings ->
            logCallback?.invoke("收到质量设置: ${qualitySettings.quality} - ${qualitySettings.resolution}@${qualitySettings.frameRate}fps")
            
            try {
                // 解析分辨率
                val resolutionParts = qualitySettings.resolution.split("x")
                if (resolutionParts.size == 2) {
                    val width = resolutionParts[0].toInt()
                    val height = resolutionParts[1].toInt()
                    val frameRate = qualitySettings.frameRate
                    
                    // 停止当前捕获
                    videoCapturer?.stopCapture()
                    
                    // 重新启动捕获，使用新的参数
                    videoCapturer?.startCapture(width, height, frameRate)
                    
                    logCallback?.invoke("✓ 视频质量已调整: ${width}x${height}@${frameRate}fps")
                    statusCallback?.invoke("质量已调整")
                } else {
                    logCallback?.invoke("✗ 分辨率格式错误: ${qualitySettings.resolution}")
                }
            } catch (e: Exception) {
                logCallback?.invoke("✗ 调整视频质量失败: ${e.message}")
            }
        }
    }
    
    private fun performVirtualKey(key: String) {
        when (key) {
            "back" -> performBack()
            "home" -> performHome()
            "menu" -> performMenu()
        }
    }
    
    private fun performMenu() {
        AccessibilityHelper.performMenu()
    }
    
    private fun performClick(x: Float, y: Float) {
        // 通过无障碍服务执行点击
        AccessibilityHelper.performClick(x, y)
    }
    
    private fun performSwipe(x1: Float, y1: Float, x2: Float, y2: Float) {
        AccessibilityHelper.performSwipe(x1, y1, x2, y2)
    }
    
    private fun performBack() {
        AccessibilityHelper.performBack()
    }
    
    private fun performHome() {
        AccessibilityHelper.performHome()
    }
    
    fun resetConnection() {
        try {
            logCallback?.invoke("🔄 重置WebRTC连接...")
            
            // 清理现有连接
            peerConnection?.close()
            peerConnection?.dispose()
            peerConnection = null
            
            // 清理待处理的offer
            pendingOffer = null
            
            logCallback?.invoke("✓ WebRTC连接已重置，可以重新建立连接")
        } catch (e: Exception) {
            logCallback?.invoke("重置连接时出错: ${e.message}")
        }
    }
    
    fun release() {
        try {
            videoCapturer?.stopCapture()
            videoCapturer?.dispose()
            videoCapturer = null
            
            peerConnection?.close()
            peerConnection?.dispose()
            peerConnection = null
            
            localVideoTrack?.dispose()
            localVideoTrack = null
            
            localAudioTrack?.dispose()
            localAudioTrack = null
            
            videoSource?.dispose()
            videoSource = null
            
            audioSource?.dispose()
            audioSource = null
            
            pendingOffer = null
            
            logCallback?.invoke("WebRTC 资源已完全清理")
        } catch (e: Exception) {
            logCallback?.invoke("清理资源时出错: ${e.message}")
        }
    }
    
    private class SimpleSdpObserver : SdpObserver {
        override fun onCreateSuccess(sdp: SessionDescription?) {}
        override fun onSetSuccess() {}
        override fun onCreateFailure(error: String?) {}
        override fun onSetFailure(error: String?) {}
    }
    
    data class ControlMessage(
        val action: String,
        val x: Float? = null,
        val y: Float? = null,
        val x1: Float? = null,
        val y1: Float? = null,
        val x2: Float? = null,
        val y2: Float? = null,
        val key: String? = null,
        val settings: QualitySettings? = null
    )
    
    data class QualitySettings(
        val quality: String,
        val resolution: String,
        val frameRate: Int
    )
}
