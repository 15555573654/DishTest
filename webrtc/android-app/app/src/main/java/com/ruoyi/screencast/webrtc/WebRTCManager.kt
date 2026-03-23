package com.ruoyi.screencast.webrtc

import android.content.Context
import android.content.Intent
import android.content.ClipData
import android.content.ClipboardManager
import android.media.projection.MediaProjection
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.content.pm.ActivityInfo
import android.view.Surface
import android.view.WindowManager
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.ruoyi.screencast.mqtt.MqttManager
import com.ruoyi.screencast.service.ScreenCaptureService
import org.webrtc.*
import kotlin.math.hypot
import kotlin.math.roundToInt

class WebRTCManager(private val context: Context) {
    
    private var peerConnection: PeerConnection? = null
    private var videoCapturer: VideoCapturer? = null
    private var videoSource: VideoSource? = null
    private var audioSource: AudioSource? = null
    private var localVideoTrack: VideoTrack? = null
    private var localAudioTrack: AudioTrack? = null
    private var controlDataChannel: DataChannel? = null
    
    private var mqttManager: MqttManager? = null
    private var username: String = ""
    private var deviceName: String = ""
    private var pushedIceServers: List<PeerConnection.IceServer> = emptyList()
    
    private var statusCallback: ((String) -> Unit)? = null
    private var logCallback: ((String) -> Unit)? = null
    private var screenCaptureRequestCallback: (() -> Unit)? = null
    
    private var pendingOffer: SessionDescription? = null
    private var screenCaptureIntent: Intent? = null
    private var surfaceTextureHelper: SurfaceTextureHelper? = null
    private var peerConnectionFactory: PeerConnectionFactory? = null
    private var requestedCaptureConfig = CaptureConfig.unconstrained()
    private var activeCaptureConfig = CaptureConfig.unconstrained()
    private var lastDisplayInfo: DisplayInfo? = null
    private var localIceCandidateStats = mutableMapOf<String, Int>()
    private var remoteIceCandidateStats = mutableMapOf<String, Int>()

    private val gson = Gson()
    
    init {
        initializeWebRTC()
    }
    
    private fun initializeWebRTC() {
        val options = PeerConnectionFactory.InitializationOptions.builder(context)
            .createInitializationOptions()
        PeerConnectionFactory.initialize(options)
    }
    
    fun setMqttManager(manager: MqttManager) {
        mqttManager = manager
        mqttManager?.setMessageCallback { topic, message ->
            when {
                topic.contains("webrtc/") -> handleSignaling(message)
                topic.contains("control/") -> handleControlMessage(message)
                else -> logCallback?.invoke("收到未知主题消息: $topic")
            }
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

    fun hasRetainedCaptureSession(): Boolean {
        return videoCapturer != null && localVideoTrack != null
    }

    fun startCapture(resultCode: Int, data: Intent) {
        try {
            screenCaptureIntent = data
            val service = com.ruoyi.screencast.service.ScreenCaptureService.instance
            if (service == null) {
                throw RuntimeException("ScreenCaptureService not running - MediaProjection requires foreground service")
            }
            val displayInfo = getDisplayInfo()
            lastDisplayInfo = displayInfo
            activeCaptureConfig = requestedCaptureConfig.resolve(displayInfo)
            sendDeviceResolution(displayInfo)
            if (hasRetainedCaptureSession()) {
                logCallback?.invoke("Reusing retained MediaProjection capture session")
                sendVideoResolution(activeCaptureConfig.width, activeCaptureConfig.height, activeCaptureConfig.frameRate)
                statusCallback?.invoke("已启动")
                pendingOffer?.let { offer ->
                    processOfferAsync(offer)
                    pendingOffer = null
                }
                return
            }
            if (videoCapturer != null || localVideoTrack != null) {
                logCallback?.invoke("Cleaning up partial capture state before recreating capture")
                stopCapture()
            }
            logCallback?.invoke("Starting MediaProjection capture")
            val factory = createPeerConnectionFactory()
            resetIceCandidateStats()
            sendVideoResolution(activeCaptureConfig.width, activeCaptureConfig.height, activeCaptureConfig.frameRate)
            videoCapturer = createScreenCapturer(data)
            videoSource = factory.createVideoSource(false)
            if (surfaceTextureHelper == null) {
                surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", null)
            }
            videoCapturer?.initialize(surfaceTextureHelper, context, videoSource?.capturerObserver)
            videoCapturer?.startCapture(activeCaptureConfig.width, activeCaptureConfig.height, activeCaptureConfig.frameRate)
            localVideoTrack = factory.createVideoTrack("video", videoSource)
            if (audioSource == null) {
                audioSource = factory.createAudioSource(MediaConstraints())
            }
            if (localAudioTrack == null) {
                localAudioTrack = factory.createAudioTrack("audio", audioSource)
            }
            logCallback?.invoke("Capture started: ${activeCaptureConfig.width}x${activeCaptureConfig.height}@${activeCaptureConfig.frameRate}fps")
            statusCallback?.invoke("已启动")
            pendingOffer?.let { offer ->
                processOfferAsync(offer)
                pendingOffer = null
            }
        } catch (e: Exception) {
            logCallback?.invoke("Start capture failed: ${e.message}")
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
            logCallback?.invoke("✓ 屏幕捕获资源已清理")
        } catch (e: Exception) {
            logCallback?.invoke("⚠️ 清理捕获资源时出错: ${e.message}")
        }
    }
    
    private fun createPeerConnectionFactory(): PeerConnectionFactory {
        peerConnectionFactory?.let { return it }
        return PeerConnectionFactory.builder()
            .setVideoEncoderFactory(DefaultVideoEncoderFactory(null, true, true))
            .setVideoDecoderFactory(DefaultVideoDecoderFactory(null))
            .createPeerConnectionFactory()
            .also { peerConnectionFactory = it }
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
                    jsonObject.getAsJsonObject("videoConstraints")?.let { constraints ->
                        requestedCaptureConfig = parseCaptureConfig(constraints)
                        logCallback?.invoke("收到前端采集期望: ${requestedCaptureConfig.width}x${requestedCaptureConfig.height}@${requestedCaptureConfig.frameRate}fps")
                    }
                    jsonObject.getAsJsonObject("turnConfig")?.let { turnConfig ->
                        pushedIceServers = parseTurnConfig(turnConfig)
                    }
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
                            processOfferAsync(offer)
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
            
            // 如果已经有PeerConnection，总是重新创建以确保连接的可靠性
            if (peerConnection != null) {
                val signalingState = peerConnection?.signalingState()
                val connectionState = peerConnection?.connectionState()
                logCallback?.invoke("📊 当前PeerConnection状态: 信令=$signalingState, 连接=$connectionState")
                logCallback?.invoke("🔄 为确保连接可靠性，重新创建PeerConnection")
                
                try {
                    peerConnection?.close()
                    peerConnection?.dispose()
                    peerConnection = null
                    logCallback?.invoke("✓ 旧PeerConnection已清理")
                } catch (e: Exception) {
                    logCallback?.invoke("⚠️ 清理旧PeerConnection时出错: ${e.message}")
                }
            } else {
                logCallback?.invoke("🆕 首次创建PeerConnection")
            }
            
            val factory = createPeerConnectionFactory()
            
            val iceServers = pushedIceServers
            if (iceServers.isEmpty()) {
                throw IllegalStateException("未收到 Web 端推送的 TURN 配置")
            }
            
            val rtcConfig = PeerConnection.RTCConfiguration(iceServers).apply {
                // 优化网络传输
                tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.ENABLED
                bundlePolicy = PeerConnection.BundlePolicy.MAXBUNDLE
                rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.REQUIRE
                continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY
                iceCandidatePoolSize = 6
                // 启用 DSCP 标记以提高 QoS
                enableDscp = true
            }
            logCallback?.invoke("ICE服务器配置: ${iceServers.joinToString { it.urls.toString() }}")
            
            peerConnection = factory.createPeerConnection(rtcConfig, object : PeerConnection.Observer {
                override fun onIceCandidate(candidate: IceCandidate?) {
                    candidate?.let {
                        recordIceCandidate(localIceCandidateStats, it)
                        logCallback?.invoke("📤 本地ICE候选: ${describeIceCandidate(it)}")
                        sendIceCandidate(it)
                    }
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
                override fun onIceGatheringChange(state: PeerConnection.IceGatheringState?) {
                    logCallback?.invoke("ICE收集状态变化: $state")
                    if (state == PeerConnection.IceGatheringState.COMPLETE) {
                        logIceCandidateSummary("android-gather-complete")
                        warnIfRelayMissing("android-gather-complete")
                    }
                }
                override fun onAddStream(stream: MediaStream?) {}
                override fun onRemoveStream(stream: MediaStream?) {}
                override fun onDataChannel(channel: DataChannel?) {
                    setupDataChannel(channel)
                }
                override fun onRenegotiationNeeded() {}
                override fun onAddTrack(receiver: RtpReceiver?, streams: Array<out MediaStream>?) {}
            })

            setupControlDataChannel()
            val currentDisplayInfo = getDisplayInfo()
            sendDeviceResolution(currentDisplayInfo)
            if (activeCaptureConfig.width > 0 && activeCaptureConfig.height > 0) {
                sendVideoResolution(
                    activeCaptureConfig.width,
                    activeCaptureConfig.height,
                    activeCaptureConfig.frameRate
                )
            }
            
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

    private fun processOfferAsync(offer: SessionDescription) {
        Thread {
            handleOffer(offer)
        }.start()
    }

    private fun parseTurnConfig(turnConfig: JsonObject): List<PeerConnection.IceServer> {
        val source = turnConfig.get("source")?.asString ?: "unknown"
        val servers = turnConfig.getAsJsonArray("servers") ?: JsonArray()
        val parsedServers = mutableListOf<PeerConnection.IceServer>()

        servers.forEach { element ->
            val server = element?.asJsonObject ?: return@forEach
            val credentialUsername = server.get("username")?.asString.orEmpty()
            val credential = server.get("credential")?.asString.orEmpty()
            val urls = server.getAsJsonArray("urls") ?: JsonArray()
            urls.forEach { urlElement ->
                val url = urlElement?.asString ?: return@forEach
                parsedServers.add(
                    PeerConnection.IceServer.builder(url)
                        .setUsername(credentialUsername)
                        .setPassword(credential)
                        .createIceServer()
                )
            }
        }

        logCallback?.invoke("TURN 配置来源: $source")
        if (parsedServers.isNotEmpty()) {
            logCallback?.invoke("已接收 Web 端推送的 TURN 地址: ${parsedServers.joinToString { server -> server.urls.toString() }}")
        } else {
            logCallback?.invoke("⚠️ Web 端未推送可用的 TURN 地址")
        }

        return parsedServers
    }
    
    private fun handleIceCandidate(candidate: IceCandidate) {
        peerConnection?.addIceCandidate(candidate)
        recordIceCandidate(remoteIceCandidateStats, candidate)
        logCallback?.invoke("📥 已添加远端ICE候选: ${describeIceCandidate(candidate)}")
    }
    
    private fun optimizeSdp(sdp: String): String {
        var optimizedSdp = sdp
        
        val maxBitrate = when {
            activeCaptureConfig.height >= 2160 -> 30000
            activeCaptureConfig.height >= 1440 -> 20000
            activeCaptureConfig.height >= 1080 -> 16000
            activeCaptureConfig.height >= 720 -> 10000
            else -> 6000
        }
        val minBitrate = maxBitrate / 3
        val startBitrate = maxBitrate * 2 / 3
        
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
        controlDataChannel?.unregisterObserver()
        controlDataChannel = channel
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

    private fun setupControlDataChannel() {
        val connection = peerConnection ?: return
        val existingChannel = controlDataChannel
        if (existingChannel != null && existingChannel.state() != DataChannel.State.CLOSED) {
            setupDataChannel(existingChannel)
            return
        }

        val init = DataChannel.Init().apply {
            ordered = true
            negotiated = true
            id = 0
        }

        try {
            val channel = connection.createDataChannel("control", init)
            logCallback?.invoke("Control DataChannel created on Android side")
            setupDataChannel(channel)
        } catch (e: Exception) {
            logCallback?.invoke("Failed to create Android control DataChannel: ${e.message}")
        }
    }
    
    private fun handleControlMessage(message: String) {
        try {
            val data = gson.fromJson(message, ControlMessage::class.java)
            logCallback?.invoke("收到控制指令: ${data.action} - ${data.key ?: "无按键"}")
            
            when (data.action) {
                "virtualKey" -> {
                    val key = data.key ?: return
                    logCallback?.invoke("执行虚拟按键: $key")
                    when (key) {
                        "back" -> {
                            logCallback?.invoke("执行返回操作")
                            performBack()
                        }
                        "home" -> {
                            logCallback?.invoke("执行主页操作")
                            performHome()
                        }
                        "menu" -> {
                            logCallback?.invoke("执行任务栏操作")
                            performMenu()
                        }
                        else -> logCallback?.invoke("未知按键: $key")
                    }
                }
                "click" -> performClick(data.x ?: 0f, data.y ?: 0f)
                "doubleClick" -> performDoubleClick(data.x ?: 0f, data.y ?: 0f)
                "touchDown" -> performTouchDown(data.x ?: 0f, data.y ?: 0f)
                "touchMove" -> performTouchMove(data.x ?: 0f, data.y ?: 0f)
                "touchUp" -> performTouchUp(data.x, data.y)
                "longPress" -> performLongPress(data.x ?: 0f, data.y ?: 0f, data.durationMs ?: 500L)
                "swipe" -> performSwipe(
                    data.x1 ?: 0f,
                    data.y1 ?: 0f,
                    data.x2 ?: 0f,
                    data.y2 ?: 0f,
                    data.durationMs
                )
                "volumeUp" -> adjustVolume("up")
                "volumeDown" -> adjustVolume("down")
                "rotateScreen" -> rotateScreen()
                "setClipboard" -> setClipboardText(data.text)
                "readClipboard" -> sendClipboardContent()
                "installApp" -> installAppFromUrl(data.url)
                "setQuality" -> handleQualityChange(data.settings)
                "refresh-video" -> sendRefreshConfirmation()
                "stopCapture" -> handleStopCaptureRequest()
                else -> logCallback?.invoke("未知控制动作: ${data.action}")
            }
        } catch (e: Exception) {
            logCallback?.invoke("处理控制消息失败: ${e.message}")
        }
    }

    private fun handleStopCaptureRequest() {
        logCallback?.invoke("Received stopCapture request; pausing WebRTC streaming only")
        try {
            peerConnection?.close()
            peerConnection?.dispose()
            peerConnection = null
        } catch (e: Exception) {
            logCallback?.invoke("Failed to close PeerConnection while handling stopCapture: ${e.message}")
        }
        pendingOffer = null
        controlDataChannel?.close()
        controlDataChannel = null
        statusCallback?.invoke("已停止")
        logCallback?.invoke("Streaming paused; MediaProjection session retained")
    }
    
    private fun handleQualityChange(settings: QualitySettings?) {
        settings?.let { qualitySettings ->
            logCallback?.invoke("收到质量设置: ${qualitySettings.quality} - ${qualitySettings.resolution}@${qualitySettings.frameRate}fps")
            
            try {
                val resolutionParts = qualitySettings.resolution.split("x")
                if (resolutionParts.size == 2) {
                    requestedCaptureConfig = CaptureConfig(
                        width = resolutionParts[0].toInt(),
                        height = resolutionParts[1].toInt(),
                        frameRate = qualitySettings.frameRate
                    )
                    applyCaptureConfig(requestedCaptureConfig, qualitySettings.quality)
                } else {
                    logCallback?.invoke("✗ 分辨率格式错误: ${qualitySettings.resolution}")
                }
            } catch (e: Exception) {
                logCallback?.invoke("✗ 调整视频质量失败: ${e.message}")
            }
        }
    }
    
    /** 发送刷新确认消息 */
    private fun sendRefreshConfirmation() {
        val confirmMessage = mapOf(
            "type" to "refresh-confirmation",
            "deviceName" to deviceName,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        val topic = "control/$username/$deviceName/feedback"
        mqttManager?.publish(topic, gson.toJson(confirmMessage))
    }
    
    private fun sendDeviceResolution(displayInfo: DisplayInfo) {
        val resolutionMessage = mapOf(
            "type" to "device-resolution",
            "deviceName" to deviceName,
            "width" to displayInfo.width,
            "height" to displayInfo.height,
            "rotation" to displayInfo.rotationDegrees,
            "densityDpi" to displayInfo.densityDpi,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        val topic = "control/$username/$deviceName/feedback"
        mqttManager?.publish(topic, gson.toJson(resolutionMessage))
        logCallback?.invoke("✓ 已发送设备分辨率信息: ${displayInfo.width}x${displayInfo.height}, rotation=${displayInfo.rotationDegrees}")
    }
    
    private fun sendVideoResolution(width: Int, height: Int, frameRate: Int) {
        val resolutionMessage = mapOf(
            "type" to "video-resolution",
            "deviceName" to deviceName,
            "width" to width,
            "height" to height,
            "frameRate" to frameRate,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        val topic = "control/$username/$deviceName/feedback"
        mqttManager?.publish(topic, gson.toJson(resolutionMessage))
        logCallback?.invoke("✓ 已发送视频传输分辨率信息: ${width}x${height}@${frameRate}fps")
    }
    
    /** 发送质量变更确认消息 */
    private fun sendQualityChangeConfirmation(quality: String, width: Int, height: Int, frameRate: Int) {
        val confirmMessage = mapOf(
            "type" to "quality-change-confirmation",
            "deviceName" to deviceName,
            "quality" to quality,
            "width" to width,
            "height" to height,
            "frameRate" to frameRate,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        val topic = "control/$username/$deviceName/feedback"
        mqttManager?.publish(topic, gson.toJson(confirmMessage))
        logCallback?.invoke("✓ 已发送质量变更确认: $quality (${width}x${height}@${frameRate}fps)")
    }
    
    private fun performVirtualKey(key: String) {
        when (key) {
            "back" -> performBack()
            "home" -> performHome()
            "menu" -> performMenu()
        }
    }
    
    private fun performMenu() {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，请在设置中启用")
            return
        }
        logCallback?.invoke("📱 执行任务栏操作")
        AccessibilityHelper.performMenu()
    }
    
    private fun performClick(x: Float, y: Float) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，无法执行点击操作")
            return
        }
        
        val point = clampToDisplay(x, y)
        logCallback?.invoke("👆 执行点击: (${point.x}, ${point.y})")
        AccessibilityHelper.performClick(point.x, point.y)
        sendClickConfirmation(point.x, point.y, "click")
    }

    private fun performDoubleClick(x: Float, y: Float) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，无法执行双击操作")
            return
        }
        val point = clampToDisplay(x, y)
        logCallback?.invoke("👆 执行双击: (${point.x}, ${point.y})")
        AccessibilityHelper.performDoubleClick(point.x, point.y)
        sendClickConfirmation(point.x, point.y, "doubleClick")
    }

    private fun performTouchDown(x: Float, y: Float) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("Accessibility unavailable for touchDown")
            return
        }
        val point = clampToDisplay(x, y)
        logCallback?.invoke("touchDown: (${point.x}, ${point.y})")
        AccessibilityHelper.performTouchDown(point.x, point.y)
    }

    private fun performTouchUp(x: Float?, y: Float?) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("Accessibility unavailable for touchUp")
            return
        }
        val point = if (x != null && y != null) clampToDisplay(x, y) else null
        logCallback?.invoke("touchUp: (${point?.x}, ${point?.y})")
        AccessibilityHelper.performTouchUp(point?.x, point?.y)
    }

    private fun performTouchMove(x: Float, y: Float) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("Accessibility unavailable for touchMove")
            return
        }
        val point = clampToDisplay(x, y)
        AccessibilityHelper.performTouchMove(point.x, point.y)
    }

    private fun performLongPress(x: Float, y: Float, durationMs: Long) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，无法执行长按操作")
            return
        }
        val point = clampToDisplay(x, y)
        val finalDuration = durationMs.coerceIn(350L, 1200L)
        logCallback?.invoke("👆 执行长按: (${point.x}, ${point.y}), duration=${finalDuration}ms")
        AccessibilityHelper.performLongPress(point.x, point.y, finalDuration)
        sendClickConfirmation(point.x, point.y, "longPress", finalDuration)
    }

    private fun sendClickConfirmation(x: Float, y: Float, action: String, durationMs: Long? = null) {
        val confirmMessage = mutableMapOf<String, Any>(
            "type" to "click-confirmation",
            "action" to action,
            "deviceName" to deviceName,
            "x" to x,
            "y" to y,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        durationMs?.let { confirmMessage["durationMs"] = it }
        val topic = "control/$username/$deviceName/feedback"
        mqttManager?.publish(topic, gson.toJson(confirmMessage))
    }
    
    private fun performSwipe(x1: Float, y1: Float, x2: Float, y2: Float, durationMs: Long?) {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，无法执行滑动操作")
            return
        }

        val start = clampToDisplay(x1, y1)
        val end = clampToDisplay(x2, y2)
        val distance = hypot((end.x - start.x).toDouble(), (end.y - start.y).toDouble())
        val finalDuration = durationMs ?: (120L + distance / 5.5).roundToInt().toLong().coerceIn(140L, 700L)

        logCallback?.invoke("👆 执行滑动: (${start.x}, ${start.y}) -> (${end.x}, ${end.y}), duration=${finalDuration}ms")
        AccessibilityHelper.performSwipe(start.x, start.y, end.x, end.y, finalDuration)
        sendSwipeConfirmation(start.x, start.y, end.x, end.y, finalDuration)
    }
    
    private fun sendSwipeConfirmation(x1: Float, y1: Float, x2: Float, y2: Float, durationMs: Long) {
        val confirmMessage = mapOf(
            "type" to "swipe-confirmation",
            "deviceName" to deviceName,
            "x1" to x1,
            "y1" to y1,
            "x2" to x2,
            "y2" to y2,
            "durationMs" to durationMs,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        val topic = "control/$username/$deviceName/feedback"
        mqttManager?.publish(topic, gson.toJson(confirmMessage))
    }
    
    private fun performBack() {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，请在设置中启用")
            return
        }
        logCallback?.invoke("🔙 执行返回操作")
        AccessibilityHelper.performBack()
    }
    
    private fun performHome() {
        if (!AccessibilityHelper.isServiceConnected()) {
            logCallback?.invoke("❌ 无障碍服务未启用，请在设置中启用")
            return
        }
        logCallback?.invoke("🏠 执行主页操作")
        AccessibilityHelper.performHome()
    }

    private fun adjustVolume(direction: String) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        val adjustDirection = if (direction == "up") AudioManager.ADJUST_RAISE else AudioManager.ADJUST_LOWER
        audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, adjustDirection, AudioManager.FLAG_SHOW_UI)
        sendVolumeConfirmation(direction)
    }

    private fun rotateScreen() {
        val activity = context as? android.app.Activity ?: return
        val orientation = context.resources.configuration.orientation
        activity.requestedOrientation = if (orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE) {
            ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        } else {
            ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        }
        Handler(Looper.getMainLooper()).postDelayed({
            refreshCaptureForDisplayChange("rotate-command")
        }, 450L)
    }

    private fun setClipboardText(text: String?) {
        val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager ?: return
        val content = text ?: ""
        clipboardManager.setPrimaryClip(ClipData.newPlainText("remote-control", content))
        sendClipboardWriteConfirmation()
    }

    private fun sendClipboardContent() {
        val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager ?: return
        val text = clipboardManager.primaryClip?.getItemAt(0)?.coerceToText(context)?.toString().orEmpty()
        val topic = "control/$username/$deviceName/feedback"
        val message = mapOf(
            "type" to "clipboard-content",
            "deviceName" to deviceName,
            "text" to text,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        mqttManager?.publish(topic, gson.toJson(message))
    }

    private fun installAppFromUrl(url: String?) {
        val installUrl = url?.trim().orEmpty()
        if (installUrl.isBlank()) {
            logCallback?.invoke("Install app ignored: empty url")
            return
        }
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(installUrl)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
        sendInstallConfirmation(installUrl)
    }

    private fun sendVolumeConfirmation(direction: String) {
        val topic = "control/$username/$deviceName/feedback"
        val message = mapOf(
            "type" to "volume-confirmation",
            "deviceName" to deviceName,
            "direction" to direction,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        mqttManager?.publish(topic, gson.toJson(message))
    }

    private fun sendRotationConfirmation(rotation: Int? = null, reason: String? = null) {
        val topic = "control/$username/$deviceName/feedback"
        val message = mutableMapOf<String, Any>(
            "type" to "rotation-confirmation",
            "deviceName" to deviceName,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        rotation?.let { message["rotation"] = it }
        reason?.let { message["reason"] = it }
        mqttManager?.publish(topic, gson.toJson(message))
    }

    private fun sendClipboardWriteConfirmation() {
        val topic = "control/$username/$deviceName/feedback"
        val message = mapOf(
            "type" to "clipboard-write-confirmation",
            "deviceName" to deviceName,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        mqttManager?.publish(topic, gson.toJson(message))
    }

    private fun sendInstallConfirmation(url: String) {
        val topic = "control/$username/$deviceName/feedback"
        val message = mapOf(
            "type" to "install-app-confirmation",
            "deviceName" to deviceName,
            "url" to url,
            "timestamp" to System.currentTimeMillis(),
            "from" to "device"
        )
        mqttManager?.publish(topic, gson.toJson(message))
    }

    private fun clampToDisplay(x: Float, y: Float): TouchPoint {
        refreshCaptureForDisplayChange("control-coordinate")
        val displayInfo = getDisplayInfo()
        return TouchPoint(
            x = x.coerceIn(0f, (displayInfo.width - 1).toFloat()),
            y = y.coerceIn(0f, (displayInfo.height - 1).toFloat())
        )
    }

    private fun parseCaptureConfig(constraints: com.google.gson.JsonObject): CaptureConfig {
        val width = constraints.get("width")?.asInt ?: 0
        val height = constraints.get("height")?.asInt ?: 0
        val frameRate = constraints.get("frameRate")?.asInt ?: 0
        return CaptureConfig(width = width, height = height, frameRate = frameRate)
    }

    private fun applyCaptureConfig(config: CaptureConfig, qualityName: String? = null) {
        val displayInfo = getDisplayInfo()
        val resolved = config.resolve(displayInfo)
        videoCapturer?.let { capturer ->
            if (capturer is ScreenCapturerAndroid) {
                capturer.changeCaptureFormat(resolved.width, resolved.height, resolved.frameRate)
                activeCaptureConfig = resolved
                sendDeviceResolution(displayInfo)
                sendVideoResolution(resolved.width, resolved.height, resolved.frameRate)
                sendQualityChangeConfirmation(
                    qualityName ?: "custom",
                    resolved.width,
                    resolved.height,
                    resolved.frameRate
                )
                logCallback?.invoke("✓ 视频质量已调整: ${resolved.width}x${resolved.height}@${resolved.frameRate}fps")
                statusCallback?.invoke("质量已调整")
            }
        } ?: logCallback?.invoke("⚠️ 视频捕获器不可用，无法调整质量")
    }

    private fun getDisplayInfo(): DisplayInfo {
        val metrics = context.resources.displayMetrics
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        var width = metrics.widthPixels
        var height = metrics.heightPixels

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = windowManager.currentWindowMetrics.bounds
            width = bounds.width()
            height = bounds.height()
        }

        val rotation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            context.display?.rotation ?: Surface.ROTATION_0
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.rotation
        }

        return DisplayInfo(
            width = width,
            height = height,
            densityDpi = metrics.densityDpi,
            rotationDegrees = when (rotation) {
                Surface.ROTATION_90 -> 90
                Surface.ROTATION_180 -> 180
                Surface.ROTATION_270 -> 270
                else -> 0
            }
        )
    }

    private fun refreshCaptureForDisplayChange(reason: String) {
        val displayInfo = getDisplayInfo()
        val previous = lastDisplayInfo
        val changed = previous == null ||
            previous.width != displayInfo.width ||
            previous.height != displayInfo.height ||
            previous.rotationDegrees != displayInfo.rotationDegrees
        if (!changed) {
            return
        }

        lastDisplayInfo = displayInfo
        sendDeviceResolution(displayInfo)
        sendRotationConfirmation(displayInfo.rotationDegrees, reason)

        val resolved = requestedCaptureConfig.resolve(displayInfo)
        val needsFormatUpdate = resolved.width != activeCaptureConfig.width ||
            resolved.height != activeCaptureConfig.height ||
            resolved.frameRate != activeCaptureConfig.frameRate
        if (!needsFormatUpdate) {
            return
        }

        activeCaptureConfig = resolved
        (videoCapturer as? ScreenCapturerAndroid)?.let { capturer ->
            try {
                capturer.changeCaptureFormat(resolved.width, resolved.height, resolved.frameRate)
                sendVideoResolution(resolved.width, resolved.height, resolved.frameRate)
                logCallback?.invoke("↻ 屏幕方向变化，已更新投屏参数: ${resolved.width}x${resolved.height}@${resolved.frameRate}fps")
            } catch (e: Exception) {
                logCallback?.invoke("⚠️ 方向变化后更新投屏参数失败: ${e.message}")
            }
        }
    }

    private fun describeIceCandidate(candidate: IceCandidate): String {
        val candidateString = candidate.sdp
        val parts = candidateString.split(" ")
        val address = parts.getOrNull(4) ?: "unknown"
        val port = parts.getOrNull(5) ?: "unknown"
        val protocol = parts.getOrNull(2)?.lowercase() ?: "unknown"
        val type = Regex(""" typ ([a-zA-Z0-9]+)""").find(candidateString)?.groupValues?.getOrNull(1) ?: "unknown"
        val tcpType = Regex(""" tcptype ([a-zA-Z0-9]+)""").find(candidateString)?.groupValues?.getOrNull(1)
        return buildString {
            append("type=").append(type)
            append(", protocol=").append(protocol)
            append(", address=").append(address)
            append(", port=").append(port)
            candidate.sdpMid?.let { append(", mid=").append(it) }
            append(", mLine=").append(candidate.sdpMLineIndex)
            tcpType?.let { append(", tcpType=").append(it) }
        }
    }

    private fun resetIceCandidateStats() {
        localIceCandidateStats = mutableMapOf(
            "host" to 0,
            "srflx" to 0,
            "relay" to 0,
            "prflx" to 0,
            "unknown" to 0
        )
        remoteIceCandidateStats = mutableMapOf(
            "host" to 0,
            "srflx" to 0,
            "relay" to 0,
            "prflx" to 0,
            "unknown" to 0
        )
    }

    private fun recordIceCandidate(stats: MutableMap<String, Int>, candidate: IceCandidate) {
        val type = Regex(""" typ ([a-zA-Z0-9]+)""").find(candidate.sdp)?.groupValues?.getOrNull(1) ?: "unknown"
        stats[type] = (stats[type] ?: 0) + 1
        logIceCandidateSummary("candidate-$type")
    }

    private fun logIceCandidateSummary(reason: String) {
        val localSummary = "host=${localIceCandidateStats["host"]}, srflx=${localIceCandidateStats["srflx"]}, relay=${localIceCandidateStats["relay"]}, prflx=${localIceCandidateStats["prflx"]}, unknown=${localIceCandidateStats["unknown"]}"
        val remoteSummary = "host=${remoteIceCandidateStats["host"]}, srflx=${remoteIceCandidateStats["srflx"]}, relay=${remoteIceCandidateStats["relay"]}, prflx=${remoteIceCandidateStats["prflx"]}, unknown=${remoteIceCandidateStats["unknown"]}"
        logCallback?.invoke("[ICE统计:$reason] local {$localSummary}; remote {$remoteSummary}")
    }

    private fun warnIfRelayMissing(reason: String) {
        if ((localIceCandidateStats["relay"] ?: 0) == 0) {
            logCallback?.invoke("[ICE统计:$reason] 本地尚未获得 relay 候选")
        }
        if ((remoteIceCandidateStats["relay"] ?: 0) == 0) {
            logCallback?.invoke("[ICE统计:$reason] 远端尚未获得 relay 候选")
        }
    }
    
    fun resetConnection() {
        try {
            logCallback?.invoke("🔄 重置WebRTC连接...")
            
            // 清理现有连接
            peerConnection?.close()
            peerConnection?.dispose()
            peerConnection = null
            controlDataChannel?.close()
            controlDataChannel = null
            
            // 清理待处理的offer
            pendingOffer = null
            
            logCallback?.invoke("✓ WebRTC连接已重置，可以重新建立连接")
        } catch (e: Exception) {
            logCallback?.invoke("重置连接时出错: ${e.message}")
        }
    }
    
    fun pauseStreaming() {
        try {
            peerConnection?.close()
            peerConnection?.dispose()
            peerConnection = null

            controlDataChannel?.close()
            controlDataChannel = null
            pendingOffer = null


            statusCallback?.invoke("已停止")
            logCallback?.invoke("Screen casting paused; MediaProjection session kept alive")
        } catch (e: Exception) {
            logCallback?.invoke("Pause streaming failed: ${e.message}")
        }
    }

    fun release() {
        try {
            videoCapturer?.stopCapture()
            videoCapturer?.dispose()
            videoCapturer = null
            controlDataChannel?.close()
            controlDataChannel = null
            
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
            surfaceTextureHelper?.dispose()
            surfaceTextureHelper = null
            
            pendingOffer = null
            screenCaptureIntent = null
            
            logCallback?.invoke("WebRTC 资源已完全清理")
        } catch (e: Exception) {
            logCallback?.invoke("清理资源时出错: ${e.message}")
        }
    }

    private fun stopScreenCaptureService() {
        try {
            ScreenCaptureService.instance?.stopSelf()
            context.stopService(Intent(context, ScreenCaptureService::class.java))
            logCallback?.invoke("✓ 已请求停止前台录屏服务")
        } catch (e: Exception) {
            logCallback?.invoke("⚠️ 停止录屏服务失败: ${e.message}")
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
        val durationMs: Long? = null,
        val key: String? = null,
        val settings: QualitySettings? = null,
        val text: String? = null,
        val url: String? = null
    )
    
    data class QualitySettings(
        val quality: String,
        val resolution: String,
        val frameRate: Int
    )

    data class CaptureConfig(
        val width: Int = 0,
        val height: Int = 0,
        val frameRate: Int = 0
    ) {
        fun resolve(displayInfo: DisplayInfo): CaptureConfig {
            val safeFrameRate = if (frameRate > 0) frameRate else 60
            val displayLongSide = maxOf(displayInfo.width, displayInfo.height)
            val displayShortSide = minOf(displayInfo.width, displayInfo.height)
            val requestedLongSide = maxOf(width, height).takeIf { it > 0 } ?: displayLongSide
            val aspectRatio = displayShortSide.toDouble() / displayLongSide.toDouble()
            val resolvedShortSide = ((requestedLongSide * aspectRatio) / 2.0).roundToInt() * 2
            return if (displayInfo.height >= displayInfo.width) {
                CaptureConfig(
                    width = resolvedShortSide.coerceAtLeast(2),
                    height = requestedLongSide,
                    frameRate = safeFrameRate
                )
            } else {
                CaptureConfig(
                    width = requestedLongSide,
                    height = resolvedShortSide.coerceAtLeast(2),
                    frameRate = safeFrameRate
                )
            }
        }

        companion object {
            fun unconstrained(): CaptureConfig = CaptureConfig()
        }
    }

    data class DisplayInfo(
        val width: Int,
        val height: Int,
        val densityDpi: Int,
        val rotationDegrees: Int
    )

    data class TouchPoint(
        val x: Float,
        val y: Float
    )
}
