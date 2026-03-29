package com.dishtest.screencast.crash

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.ruoyi.screencast.MainActivity
import com.ruoyi.screencast.R
import java.io.File

/**
 * 进程守护服务
 * 在独立进程中运行，监控主进程状态
 */
class ProcessGuardService : Service() {

    companion object {
        private const val TAG = "ProcessGuardService"
        private const val NOTIFICATION_ID = 1002
        private const val CHANNEL_ID = "process_guard_channel"
        private const val CHECK_INTERVAL = 5000L // 检查间隔（毫秒）
        private const val RESTART_DELAY = 2000L // 重启延迟（毫秒）
    }

    private var isRunning = false
    private val handler = Handler(Looper.getMainLooper())
    private var lastCheckTime = 0L
    private var restartAttempts = 0
    private val maxRestartAttempts = 5
    
    private val checkRunnable = object : Runnable {
        override fun run() {
            if (isRunning) {
                checkMainProcess()
                handler.postDelayed(this, CHECK_INTERVAL)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "ProcessGuardService created in process: ${getCurrentProcessName()}")
        createNotificationChannel()
        
        try {
            startForeground(NOTIFICATION_ID, createNotification())
            Log.d(TAG, "ProcessGuardService started as foreground service")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start foreground service", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "ProcessGuardService onStartCommand")
        
        if (!isRunning) {
            isRunning = true
            // 延迟启动检查，给主进程启动时间
            handler.postDelayed(checkRunnable, CHECK_INTERVAL)
            Log.d(TAG, "Started monitoring main process")
        }

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "ProcessGuardService destroyed")
        isRunning = false
        handler.removeCallbacks(checkRunnable)
    }

    /**
     * 检查主进程状态
     */
    private fun checkMainProcess() {
        try {
            val currentTime = System.currentTimeMillis()
            lastCheckTime = currentTime
            
            val isMainProcessRunning = isMainProcessAlive()
            
            if (!isMainProcessRunning) {
                Log.w(TAG, "⚠️ Main process not running, attempting restart (attempt ${restartAttempts + 1}/$maxRestartAttempts)")
                
                if (restartAttempts < maxRestartAttempts) {
                    restartAttempts++
                    handler.postDelayed({
                        restartMainProcess()
                    }, RESTART_DELAY)
                } else {
                    Log.e(TAG, "❌ Max restart attempts reached, stopping guard service")
                    stopSelf()
                }
            } else {
                // 主进程正常运行，重置重启计数
                if (restartAttempts > 0) {
                    Log.d(TAG, "✓ Main process recovered, resetting restart counter")
                    restartAttempts = 0
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking main process", e)
        }
    }

    /**
     * 检查主进程是否存活
     * 使用多种方法检测，提高可靠性
     */
    private fun isMainProcessAlive(): Boolean {
        val mainProcessName = packageName
        
        // 方法1: 检查ActivityManager的运行进程
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val processes = activityManager.runningAppProcesses
            
            if (processes != null) {
                val mainProcess = processes.find { it.processName == mainProcessName }
                if (mainProcess != null) {
                    Log.d(TAG, "✓ Main process found via ActivityManager (pid=${mainProcess.pid})")
                    return true
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to check via ActivityManager: ${e.message}")
        }
        
        // 方法2: 检查进程文件系统（适用于Android 10+）
        try {
            val myUid = android.os.Process.myUid()
            val procDir = File("/proc")
            
            if (procDir.exists() && procDir.isDirectory) {
                procDir.listFiles()?.forEach { pidDir ->
                    if (pidDir.isDirectory && pidDir.name.matches(Regex("\\d+"))) {
                        try {
                            val cmdlineFile = File(pidDir, "cmdline")
                            if (cmdlineFile.exists()) {
                                val cmdline = cmdlineFile.readText().trim('\u0000')
                                
                                // 检查是否是主进程
                                if (cmdline == mainProcessName) {
                                    // 验证UID是否匹配
                                    val statusFile = File(pidDir, "status")
                                    if (statusFile.exists()) {
                                        val status = statusFile.readText()
                                        val uidLine = status.lines().find { it.startsWith("Uid:") }
                                        if (uidLine != null) {
                                            val uid = uidLine.split("\\s+".toRegex())[1].toIntOrNull()
                                            if (uid == myUid) {
                                                Log.d(TAG, "✓ Main process found via /proc (pid=${pidDir.name})")
                                                return true
                                            }
                                        }
                                    }
                                }
                            }
                        } catch (e: Exception) {
                            // 忽略单个进程检查失败
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to check via /proc: ${e.message}")
        }
        
        // 方法3: 检查MainActivity是否在任务栈中
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val tasks = activityManager.getRunningTasks(10)
            
            tasks?.forEach { task ->
                if (task.baseActivity?.packageName == packageName) {
                    Log.d(TAG, "✓ Main process found via running tasks")
                    return true
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to check via running tasks: ${e.message}")
        }
        
        Log.w(TAG, "❌ Main process not found by any method")
        return false
    }

    /**
     * 重启主进程
     */
    private fun restartMainProcess() {
        try {
            Log.d(TAG, "🔄 Attempting to restart main process...")
            
            // 创建启动Intent
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("restarted_by_guard", true)
                putExtra("restart_time", System.currentTimeMillis())
            }
            
            startActivity(intent)
            Log.d(TAG, "✓ Main process restart initiated")
            
            // 发送通知
            showRestartNotification()
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to restart main process", e)
            e.printStackTrace()
        }
    }

    /**
     * 显示重启通知
     */
    private fun showRestartNotification() {
        try {
            val notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("应用已自动重启")
                .setContentText("守护进程检测到应用异常退出并已重启")
                .setSmallIcon(R.drawable.ic_launcher_foreground)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .build()
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.notify(NOTIFICATION_ID + 1, notification)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to show restart notification", e)
        }
    }

    /**
     * 获取当前进程名
     */
    private fun getCurrentProcessName(): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return Application.getProcessName()
        }
        
        try {
            val pid = android.os.Process.myPid()
            val cmdlineFile = File("/proc/$pid/cmdline")
            if (cmdlineFile.exists()) {
                return cmdlineFile.readText().trim('\u0000')
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get process name", e)
        }
        
        return "unknown"
    }

    /**
     * 创建通知渠道
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "进程守护",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "保持应用稳定运行"
                setShowBadge(false)
                setSound(null, null)
                enableVibration(false)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * 创建前台服务通知
     */
    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("应用守护中")
            .setContentText("保护应用稳定运行")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }
}
