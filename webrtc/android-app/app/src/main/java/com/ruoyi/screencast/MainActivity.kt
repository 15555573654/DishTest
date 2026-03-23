package com.ruoyi.screencast

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ruoyi.screencast.databinding.ActivityMainBinding
import com.ruoyi.screencast.service.ScreenCaptureService
import com.ruoyi.screencast.webrtc.WebRTCManager
import com.ruoyi.screencast.mqtt.MqttManager
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var mqttManager: MqttManager
    private lateinit var webrtcManager: WebRTCManager
    
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
        
        mqttManager = MqttManager(this)
        webrtcManager = WebRTCManager(this)
        
        setupListeners()
        checkPermissions()
        
        // 应用启动时就请求屏幕捕获权限
        requestScreenCapturePermissionOnStartup()
        
        log("应用启动成功")
    }
    
    private fun setupListeners() {
        binding.btnConnect.setOnClickListener {
            connectMqtt()
        }
        
        binding.btnDisconnect.setOnClickListener {
            disconnectMqtt()
        }
        
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
        
        mqttManager.setStatusCallback { status ->
            runOnUiThread {
                binding.tvMqttStatus.text = "状态: $status"
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
        val permissions = arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO
        )
        
        val needRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (needRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needRequest.toTypedArray(), PERMISSION_REQUEST)
        }
    }
    
    private fun connectMqtt() {
        val host = binding.etMqttHost.text.toString()
        val port = binding.etMqttPort.text.toString()
        val username = binding.etUsername.text.toString()
        val password = binding.etPassword.text.toString()
        val deviceName = binding.etDeviceName.text.toString()
        
        if (host.isEmpty() || port.isEmpty() || username.isEmpty() || password.isEmpty() || deviceName.isEmpty()) {
            Toast.makeText(this, "请填写完整信息", Toast.LENGTH_SHORT).show()
            return
        }
        
        mqttManager.connect(host, port.toInt(), username, password, deviceName) { success ->
            runOnUiThread {
                if (success) {
                    binding.btnConnect.isEnabled = false
                    binding.btnDisconnect.isEnabled = true
                    binding.btnStartScreen.isEnabled = true
                    
                    webrtcManager.setMqttManager(mqttManager)
                    webrtcManager.setDeviceInfo(username, deviceName)
                } else {
                    Toast.makeText(this, "连接失败", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    
    private fun disconnectMqtt() {
        mqttManager.disconnect()
        webrtcManager.release()
        stopScreenCaptureService()
        binding.btnConnect.isEnabled = true
        binding.btnDisconnect.isEnabled = false
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
        val serviceIntent = Intent(this, ScreenCaptureService::class.java)
        serviceIntent.putExtra("resultCode", pendingScreenCaptureResultCode)
        serviceIntent.putExtra("data", pendingScreenCaptureData)

        try {
            if (!hasRunningService) {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
                log("ScreenCaptureService started")
            } else {
                log("Reusing existing ScreenCaptureService")
            }

            val startDelayMs = if (hasRunningService || hasRetainedCapture) 200L else 1500L
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
            Toast.makeText(this, "Failed to prepare screen capture: ${e.message}", Toast.LENGTH_LONG).show()
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
                if (com.ruoyi.screencast.webrtc.AccessibilityHelper.isServiceConnected()) {
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
        
        val serviceName = "${packageName}/${com.ruoyi.screencast.service.AccessibilityControlService::class.java.name}"
        return enabledServices?.contains(serviceName) == true
    }
    
    private fun checkAccessibilityService() {
        // 延迟检查，给应用启动时间
        binding.root.postDelayed({
            val isServiceEnabled = isAccessibilityServiceEnabled()
            val isServiceConnected = com.ruoyi.screencast.webrtc.AccessibilityHelper.isServiceConnected()
            
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
    
    override fun onDestroy() {
        super.onDestroy()
        mqttManager.disconnect()
        webrtcManager.release()
        stopScreenCaptureService()
    }
}
