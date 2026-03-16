package com.ruoyi.screencast.service

import android.app.*
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import com.ruoyi.screencast.MainActivity
import com.ruoyi.screencast.R

class ScreenCaptureService : Service() {
    
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "screencast_channel"
    
    private var mediaProjection: MediaProjection? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var currentResultCode: Int = -1
    private var currentData: Intent? = null
    
    companion object {
        var instance: ScreenCaptureService? = null
            private set
    }
    
    override fun onCreate() {
        super.onCreate()
        instance = this
        mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        createNotificationChannel()
        
        // Android 14+ 需要指定前台服务类型
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                createNotification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            )
        } else {
            startForeground(NOTIFICATION_ID, createNotification())
        }
        
        android.util.Log.d("ScreenCaptureService", "ScreenCaptureService created and foreground started")
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            val resultCode = it.getIntExtra("resultCode", -1)
            val data = it.getParcelableExtra<Intent>("data")
            
            if (resultCode != -1 && data != null) {
                // 检查是否是新的权限数据
                if (currentResultCode != resultCode || currentData != data) {
                    // 停止旧的MediaProjection
                    stopMediaProjection()
                    
                    // 保存新的权限数据
                    currentResultCode = resultCode
                    currentData = data
                    
                    android.util.Log.d("ScreenCaptureService", "New MediaProjection permission received")
                } else {
                    android.util.Log.d("ScreenCaptureService", "Same MediaProjection permission, reusing")
                }
            }
        }
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopMediaProjection()
        instance = null
        android.util.Log.d("ScreenCaptureService", "ScreenCaptureService destroyed")
    }
    
    private fun stopMediaProjection() {
        mediaProjection?.stop()
        mediaProjection = null
        android.util.Log.d("ScreenCaptureService", "MediaProjection stopped")
    }
    
    fun createMediaProjection(): MediaProjection? {
        if (currentResultCode == -1 || currentData == null) {
            android.util.Log.e("ScreenCaptureService", "No valid MediaProjection permission data")
            return null
        }
        
        // 每次都创建新的MediaProjection实例，避免重用
        stopMediaProjection()
        
        try {
            mediaProjection = mediaProjectionManager?.getMediaProjection(currentResultCode, currentData!!)
            android.util.Log.d("ScreenCaptureService", "New MediaProjection created successfully")
            return mediaProjection
        } catch (e: Exception) {
            android.util.Log.e("ScreenCaptureService", "Failed to create MediaProjection: ${e.message}")
            return null
        }
    }
    
    fun getMediaProjection(): MediaProjection? {
        return mediaProjection
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                getString(R.string.notification_channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.notification_channel_desc)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.notification_title))
            .setContentText(getString(R.string.notification_text))
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(pendingIntent)
            .build()
    }
}
