package com.dishtest.screencast

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.dishtest.screencast.databinding.ActivityMainBinding
import com.dishtest.screencast.service.ScreenCaptureService
import com.dishtest.screencast.webrtc.WebRTCManager
import com.dishtest.screencast.mqtt.MqttManager
import com.dishtest.screencast.apk.ApkInstallManager
import com.dishtest.screencast.file.FileReceiveManager
import com.dishtest.screencast.file.FileBrowserManager
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {
    
    companion object {
        private const val TAG = "MainActivity"
    }
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var mqttManager: MqttManager
    private lateinit var webrtcManager: WebRTCManager
    private lateinit var apkInstallManager: ApkInstallManager
    private lateinit var fileReceiveManager: FileReceiveManager
    private lateinit var fileBrowserManager: FileBrowserManager
    
    private val SCREEN_CAPTURE_REQUEST = 1001
    private val PERMISSION_REQUEST = 1002
    
    // 保存屏幕捕获的 Intent，用于自动启动
    private var pendingScreenCaptureData: Intent? = null
    private var pendingScreenCaptureResultCode: Int = 0
    private var shouldAutoStartCapture = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        Log.d(TAG, "=== MainActivity onCreate ===")
        
        // 检查是否从崩溃恢复
        checkCrashRecovery()
        
        mqttManager = MqttManager(this)
        webrtcManager = WebRTCManager(this)
        apkInstallManager = ApkInstallManager(this)
        fileReceiveManager = FileReceiveManager(this)
        fileBrowserManager = FileBrowserManager(this)
        
        setupListeners()
        checkPermissions()
        
        // 应用启动时就请求屏幕捕获权限
        requestScreenCapturePermissionOnStartup()
        
        // 自动连接MQTT（延迟2秒，等待UI初始化完成）
        binding.root.postDelayed({
            autoConnectMqtt()
        }, 2000)
        
        log("应用启动成功")
    }
    
    private fun setupListeners() {
        binding.btnStartScreen.setOnClickListener {
            if (binding.btnStartScreen.text == "开始投屏") {
                if (pendingScreenCaptureData != null) {
                    // 已有权限，直接启动
                    startScreenCaptureWithPermission()
                } else {
                    // 没有权限，请求权限
                    requestScreenCapture()
                }
            } else {
                // 停止投屏
                log("🛑 停止投屏")
                webrtcManager.pauseStreaming()
                mqttManager.publishDeviceStatus("未运行")
                binding.btnStartScreen.text = "开始投屏"
                binding.tvScreenStatus.text = "状态: 已停止"
                Toast.makeText(this, "投屏已停止", Toast.LENGTH_SHORT).show()
            }
        }
        
        // 添加重置连接按钮的长按事件
        binding.btnStartScreen.setOnLongClickListener {
            if (pendingScreenCaptureData != null) {
                log("🔄 重置WebRTC连接...")
                webrtcManager.resetConnection()
                Toast.makeText(this, "连接已重置，可以重新开始投屏", Toast.LENGTH_SHORT).show()
                true
            } else {
                false
            }
        }
        
        binding.btnEnableAccessibility.setOnClickListener {
            openAccessibilitySettings()
        }
        
        binding.btnClearLog.setOnClickListener {
            binding.tvLog.text = ""
        }
        
        // 长按清空日志按钮查看崩溃日志
        binding.btnClearLog.setOnLongClickListener {
            openCrashLogs()
            true
        }
        
        mqttManager.setStatusCallback { status ->
            runOnUiThread {
                binding.tvMqttStatus.text = "状态: $status"
                
                // 根据连接状态启用/禁用投屏按钮
                if (status == "已连接") {
                    binding.btnStartScreen.isEnabled = true
                } else if (status == "连接失败" || status == "已断开") {
                    binding.btnStartScreen.isEnabled = false
                }
            }
        }
        
        mqttManager.setLogCallback { message ->
            log(message)
        }
        
        webrtcManager.setStatusCallback { status ->
            runOnUiThread {
                binding.tvScreenStatus.text = "状态: $status"
                
                // 根据状态更新按钮文本
                when (status) {
                    "捕获中", "已连接", "正在连接" -> {
                        binding.btnStartScreen.text = "停止投屏"
                    }
                    "未连接", "连接失败", "已断开", "已关闭" -> {
                        binding.btnStartScreen.text = "开始投屏"
                    }
                }
            }
        }
        
        webrtcManager.setLogCallback { message ->
            log(message)
        }
        
        // 设置屏幕捕获请求回调
        webrtcManager.setScreenCaptureRequestCallback {
            runOnUiThread {
                log("📞 收到WebRTC屏幕捕获请求回调")
                log("📋 当前状态: pendingScreenCaptureData=${pendingScreenCaptureData != null}")
                
                if (pendingScreenCaptureData != null) {
                    // 已有权限，直接启动
                    log("收到远程投屏请求，自动启动屏幕捕获")
                    startScreenCaptureWithPermission()
                } else {
                    // 没有权限，请求权限并在获得权限后自动启动
                    log("收到远程投屏请求，但尚未授权，正在请求权限...")
                    shouldAutoStartCapture = true // 标记需要自动启动
                    Toast.makeText(this, "正在请求屏幕录制权限以开始投屏", Toast.LENGTH_SHORT).show()
                    requestScreenCapture()
                }
            }
        }
        
        // 检查无障碍服务状态
        checkAccessibilityService()
    }
    
    private fun checkPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
        )
        
        // 注意：FOREGROUND_SERVICE_MEDIA_PROJECTION 不需要运行时请求
        // 它是在 AndroidManifest.xml 中声明后自动授予的
        
        val needRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (needRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needRequest.toTypedArray(), PERMISSION_REQUEST)
        }
    }
    
    private fun autoConnectMqtt() {
        // 使用固定的服务器配置
        val host = "150.158.128.73"
        val port = 1883
        val username = binding.etUsername.text.toString()
        val password = binding.etPassword.text.toString()
        val deviceName = binding.etDeviceName.text.toString()
        
        if (username.isEmpty() || password.isEmpty() || deviceName.isEmpty()) {
            log("⚠️ 请填写用户名、密码和设备名称")
            Toast.makeText(this, "请填写用户名、密码和设备名称", Toast.LENGTH_SHORT).show()
            return
        }
        
        log("🔄 正在自动连接到服务器...")
        connectMqtt(host, port, username, password, deviceName)
    }
    
    private fun connectMqtt(host: String, port: Int, username: String, password: String, deviceName: String) {
        // 在连接MQTT之前就设置WebRTCManager，确保消息回调已就绪
        webrtcManager.setMqttManager(mqttManager)
        webrtcManager.setDeviceInfo(username, deviceName)
        
        mqttManager.connect(host, port, username, password, deviceName) { success ->
            runOnUiThread {
                if (success) {
                    binding.btnStartScreen.isEnabled = true
                    
                    // 设置APK安装管理器的日志回调
                    apkInstallManager.setLogCallback { message ->
                        log(message)
                    }
                    
                    // 订阅APK传输主题
                    subscribeApkTopic(username, deviceName)
                    
                    // 订阅文件传输主题
                    subscribeFileTopic(username, deviceName)
                    
                    // 订阅文件浏览主题
                    subscribeFileBrowserTopic(username, deviceName)
                    
                    log("✅ MQTT连接成功")
                } else {
                    Toast.makeText(this, "连接失败，请检查网络或账号信息", Toast.LENGTH_LONG).show()
                    log("❌ MQTT连接失败")
                }
            }
        }
    }
    
    private fun disconnectMqtt() {
        mqttManager.disconnect()
        webrtcManager.release()
        stopScreenCaptureService()
        binding.btnStartScreen.isEnabled = false
        log("已断开连接并清理资源")
    }
    
    private fun requestScreenCapture() {
        val mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        startActivityForResult(mediaProjectionManager.createScreenCaptureIntent(), SCREEN_CAPTURE_REQUEST)
    }
    
    private fun requestScreenCapturePermissionOnStartup() {
        // 延迟 2 秒后自动请求屏幕捕获权限
        binding.root.postDelayed({
            log("正在请求屏幕录制权限...")
            Toast.makeText(this, "请授权屏幕录制权限，以便远程投屏", Toast.LENGTH_LONG).show()
            requestScreenCapture()
        }, 2000)
    }
    
    private fun startScreenCaptureWithPermission() {
        if (pendingScreenCaptureData == null) {
            Toast.makeText(this, "No screen capture permission available", Toast.LENGTH_SHORT).show()
            log("Screen capture permission data is missing")
            return
        }

        log("Preparing screen capture session...")

        val hasRetainedCapture = webrtcManager.hasRetainedCaptureSession()
        val hasRunningService = ScreenCaptureService.instance != null
        
        try {
            // 先启动服务并传递权限数据
            val serviceIntent = Intent(this, ScreenCaptureService::class.java)
            serviceIntent.putExtra("resultCode", pendingScreenCaptureResultCode)
            serviceIntent.putExtra("data", pendingScreenCaptureData)

            if (!hasRunningService) {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
                log("ScreenCaptureService started")
            } else {
                // 服务已运行，只需更新权限数据
                startService(serviceIntent)
                log("Reusing existing ScreenCaptureService")
            }

            // WebRTCManager会等待服务就绪，所以这里只需要短暂延迟
            val startDelayMs = if (hasRunningService || hasRetainedCapture) 100L else 500L
            binding.root.postDelayed({
                try {
                    webrtcManager.startCapture(pendingScreenCaptureResultCode, pendingScreenCaptureData!!)
                    mqttManager.publishDeviceStatus("运行中")
                    log("WebRTC capture start requested")
                } catch (e: Exception) {
                    log("WebRTC capture start failed: ${e.message}")
                    Toast.makeText(this, "WebRTC start failed: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }, startDelayMs)
        } catch (e: Exception) {
            log("Failed to prepare screen capture: ${e.message}")
            e.printStackTrace()
            Toast.makeText(this, "启动失败: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    private fun stopScreenCaptureService() {
        try {
            val serviceIntent = Intent(this, ScreenCaptureService::class.java)
            stopService(serviceIntent)
            log("Stopped ScreenCaptureService")
        } catch (e: Exception) {
            log("Failed to stop service: ${e.message}")
        }
    }
    
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
        log("已打开无障碍设置页面")
        
        // 启动一个定时检查，看用户是否启用了服务
        startAccessibilityServiceCheck()
    }
    
    private fun startAccessibilityServiceCheck() {
        val handler = android.os.Handler(mainLooper)
        val checkRunnable = object : Runnable {
            override fun run() {
                if (com.dishtest.screencast.webrtc.AccessibilityHelper.isServiceConnected()) {
                    log("✓ 无障碍服务已启用，设备控制功能现在可用")
                    Toast.makeText(this@MainActivity, "无障碍服务已启用！", Toast.LENGTH_SHORT).show()
                } else {
                    // 每2秒检查一次，最多检查30秒
                    handler.postDelayed(this, 2000)
                }
            }
        }
        
        // 开始检查（延迟1秒，给用户时间操作）
        handler.postDelayed(checkRunnable, 1000)
        
        // 30秒后停止检查
        handler.postDelayed({
            handler.removeCallbacks(checkRunnable)
        }, 30000)
    }
    
    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityManager = getSystemService(android.content.Context.ACCESSIBILITY_SERVICE) as android.view.accessibility.AccessibilityManager
        val enabledServices = android.provider.Settings.Secure.getString(
            contentResolver,
            android.provider.Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        
        val serviceName = "${packageName}/${com.dishtest.screencast.service.AccessibilityControlService::class.java.name}"
        return enabledServices?.contains(serviceName) == true
    }
    
    private fun checkAccessibilityService() {
        // 延迟检查，给应用启动时间
        binding.root.postDelayed({
            val isServiceEnabled = isAccessibilityServiceEnabled()
            val isServiceConnected = com.dishtest.screencast.webrtc.AccessibilityHelper.isServiceConnected()
            
            log("无障碍服务状态检查: 系统启用=$isServiceEnabled, 服务连接=$isServiceConnected")
            
            if (!isServiceEnabled) {
                log("⚠️ 无障碍服务未启用，正在引导用户启用...")
                
                // 显示对话框询问用户是否要启用无障碍服务
                androidx.appcompat.app.AlertDialog.Builder(this)
                    .setTitle("启用无障碍服务")
                    .setMessage("为了使用设备控制功能（返回、主页、任务栏），需要启用无障碍服务。\n\n请在设置页面中找到\"${getString(R.string.app_name)}\"并启用。")
                    .setPositiveButton("去设置") { _, _ ->
                        openAccessibilitySettings()
                    }
                    .setNegativeButton("稍后") { dialog, _ ->
                        dialog.dismiss()
                        log("用户选择稍后启用无障碍服务")
                    }
                    .setCancelable(false)
                    .show()
            } else {
                log("✓ 无障碍服务已启用")
                if (!isServiceConnected) {
                    log("⚠️ 服务已启用但未连接，可能需要重启应用")
                }
            }
        }, 2000) // 2秒后检查，给应用足够的启动时间
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == SCREEN_CAPTURE_REQUEST && resultCode == RESULT_OK && data != null) {
            // 保存屏幕捕获权限
            pendingScreenCaptureData = data
            pendingScreenCaptureResultCode = resultCode
            log("✓ 屏幕录制权限已授权")
            
            // 如果是由远程投屏请求触发的，自动启动
            if (shouldAutoStartCapture) {
                shouldAutoStartCapture = false
                log("自动启动屏幕捕获（远程请求触发）")
                startScreenCaptureWithPermission()
                Toast.makeText(this, "权限已授权，正在启动投屏", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "权限已授权，可以开始使用", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (allGranted) {
                log("✓ 所有权限已授予")
                Toast.makeText(this, "权限已授予", Toast.LENGTH_SHORT).show()
            } else {
                log("⚠️ 部分权限被拒绝")
                Toast.makeText(this, "部分权限被拒绝，功能可能受限", Toast.LENGTH_LONG).show()
                
                // 检查哪些权限被拒绝
                permissions.forEachIndexed { index, permission ->
                    if (grantResults[index] != PackageManager.PERMISSION_GRANTED) {
                        log("❌ 权限被拒绝: $permission")
                    }
                }
            }
        }
    }
    
    private fun log(message: String) {
        runOnUiThread {
            val time = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
            val logText = binding.tvLog.text.toString()
            binding.tvLog.text = "$logText\n[$time] $message"
            
            // 自动滚动到底部 - 支持NestedScrollView
            binding.tvLog.post {
                val parent = binding.tvLog.parent
                when (parent) {
                    is androidx.core.widget.NestedScrollView -> {
                        parent.fullScroll(android.view.View.FOCUS_DOWN)
                    }
                    is android.widget.ScrollView -> {
                        parent.fullScroll(android.view.View.FOCUS_DOWN)
                    }
                }
            }
        }
    }
    
    /**
     * 订阅APK传输主题
     */
    private fun subscribeApkTopic(username: String, deviceName: String) {
        val apkTopic = "apk/$username/$deviceName"
        mqttManager.subscribe(apkTopic) { topic, message ->
            handleApkMessage(message)
        }
        log("✓ 已订阅APK传输主题: $apkTopic")
    }
    
    /**
     * 订阅文件传输主题
     */
    private fun subscribeFileTopic(username: String, deviceName: String) {
        val fileTopic = "file/$username/$deviceName"
        mqttManager.subscribe(fileTopic) { topic, message ->
            handleFileMessage(message)
        }
        log("✓ 已订阅文件传输主题: $fileTopic")
    }
    
    /**
     * 订阅文件浏览主题
     */
    private fun subscribeFileBrowserTopic(username: String, deviceName: String) {
        val fileBrowserTopic = "file-browser/$username/$deviceName/request"
        mqttManager.subscribe(fileBrowserTopic) { topic, message ->
            handleFileBrowserMessage(message)
        }
        log("✓ 已订阅文件浏览主题: $fileBrowserTopic")
    }
    
    /**
     * 处理APK MQTT消息
     */
    private fun handleApkMessage(message: String) {
        try {
            val json = org.json.JSONObject(message)
            val type = json.getString("type")
            
            when (type) {
                "apk-chunk" -> {
                    val apkId = json.getString("apkId")
                    val chunkIndex = json.getInt("chunkIndex")
                    val totalChunks = json.getInt("totalChunks")
                    val fileName = json.getString("fileName")
                    val dataBase64 = json.getString("data")
                    
                    // Base64解码
                    val data = android.util.Base64.decode(dataBase64, android.util.Base64.DEFAULT)
                    
                    // 传递给APK安装管理器
                    apkInstallManager.receiveApkChunk(apkId, chunkIndex, totalChunks, data, fileName)
                }
                "apk-cancel" -> {
                    val apkId = json.getString("apkId")
                    apkInstallManager.cancelApkReceive(apkId)
                }
            }
        } catch (e: Exception) {
            log("❌ 处理APK消息失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    /**
     * 处理文件MQTT消息
     */
    private fun handleFileMessage(message: String) {
        try {
            log("📦 收到文件消息")
            val json = org.json.JSONObject(message)
            val type = json.getString("type")
            log("📦 文件消息类型: $type")
            
            when (type) {
                "file-chunk" -> {
                    val fileId = json.getString("fileId")
                    val chunkIndex = json.getInt("chunkIndex")
                    val totalChunks = json.getInt("totalChunks")
                    val fileName = json.getString("fileName")
                    val targetPath = json.getString("targetPath")
                    val dataBase64 = json.getString("data")
                    
                    log("📦 文件分块: $fileName [$chunkIndex/$totalChunks] -> $targetPath")
                    
                    // 传递给文件接收管理器
                    fileReceiveManager.handleFileChunk(
                        fileId, chunkIndex, totalChunks, fileName, targetPath, dataBase64
                    )
                }
                "file-cancel" -> {
                    val fileId = json.getString("fileId")
                    log("📦 取消文件接收: $fileId")
                    fileReceiveManager.cancelFileReceive(fileId)
                }
            }
        } catch (e: Exception) {
            log("❌ 处理文件消息失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    /**
     * 处理文件浏览MQTT消息
     */
    private fun handleFileBrowserMessage(message: String) {
        try {
            val json = org.json.JSONObject(message)
            val action = json.getString("action")
            val requestId = json.optString("requestId", "")
            
            val response = when (action) {
                "list-directory" -> {
                    val path = json.getString("path")
                    fileBrowserManager.listDirectory(path)
                }
                "get-common-directories" -> {
                    fileBrowserManager.getCommonDirectories()
                }
                "delete-file" -> {
                    val path = json.getString("path")
                    fileBrowserManager.deleteFile(path)
                }
                "create-directory" -> {
                    val path = json.getString("path")
                    fileBrowserManager.createDirectory(path)
                }
                "rename-file" -> {
                    val oldPath = json.getString("oldPath")
                    val newName = json.getString("newName")
                    fileBrowserManager.renameFile(oldPath, newName)
                }
                else -> {
                    org.json.JSONObject().apply {
                        put("success", false)
                        put("error", "未知操作: $action")
                    }
                }
            }
            
            // 添加requestId到响应中
            if (requestId.isNotEmpty()) {
                response.put("requestId", requestId)
            }
            response.put("action", action)
            
            // 发送响应
            sendFileBrowserResponse(response.toString())
            
        } catch (e: Exception) {
            log("❌ 处理文件浏览消息失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    /**
     * 发送文件浏览响应
     */
    private fun sendFileBrowserResponse(response: String) {
        val username = binding.etUsername.text.toString()
        val deviceName = binding.etDeviceName.text.toString()
        val topic = "file-browser/$username/$deviceName/response"
        mqttManager.publish(topic, response)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mqttManager.disconnect()
        webrtcManager.release()
        stopScreenCaptureService()
    }
    
    override fun onConfigurationChanged(newConfig: android.content.res.Configuration) {
        super.onConfigurationChanged(newConfig)
        
        // 处理屏幕旋转
        when (newConfig.orientation) {
            android.content.res.Configuration.ORIENTATION_LANDSCAPE -> {
                log("📱 屏幕已旋转到横屏")
                handleOrientationChange()
            }
            android.content.res.Configuration.ORIENTATION_PORTRAIT -> {
                log("📱 屏幕已旋转到竖屏")
                handleOrientationChange()
            }
        }
    }
    
    private fun handleOrientationChange() {
        // 如果正在投屏，更新分辨率信息
        if (webrtcManager.isCapturing()) {
            log("🔄 检测到屏幕旋转，更新分辨率信息...")
            
            // 延迟一小段时间，确保系统完成旋转
            binding.root.postDelayed({
                webrtcManager.handleOrientationChange()
            }, 500)
        }
    }
    
    /**
     * 检查是否从崩溃恢复
     */
    private fun checkCrashRecovery() {
        val crashed = intent.getBooleanExtra("crashed", false)
        val crashCount = intent.getIntExtra("crash_count", 0)
        val restartedByGuard = intent.getBooleanExtra("restarted_by_guard", false)
        
        if (crashed) {
            log("⚠️ 应用已从崩溃中恢复 (第${crashCount}次)")
            Toast.makeText(this, "应用已从崩溃中恢复", Toast.LENGTH_LONG).show()
        }
        
        if (restartedByGuard) {
            log("🛡️ 应用由守护进程重启")
            Toast.makeText(this, "应用已自动重启", Toast.LENGTH_SHORT).show()
        }
    }
    
    /**
     * 打开崩溃日志查看页面
     */
    private fun openCrashLogs() {
        try {
            val intent = Intent(this, com.dishtest.screencast.crash.CrashLogActivity::class.java)
            startActivity(intent)
        } catch (e: Exception) {
            Toast.makeText(this, "打开崩溃日志失败: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }
}
