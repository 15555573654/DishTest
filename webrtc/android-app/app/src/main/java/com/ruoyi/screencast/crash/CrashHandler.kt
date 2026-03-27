package com.ruoyi.screencast.crash

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.util.Log
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.*
import kotlin.system.exitProcess

/**
 * 全局异常捕获处理器
 * 防止应用因未捕获异常而闪退
 */
class CrashHandler private constructor() : Thread.UncaughtExceptionHandler {

    companion object {
        private const val TAG = "CrashHandler"
        private const val CRASH_LOG_DIR = "crash_logs"
        private const val MAX_CRASH_RESTART = 3 // 最大连续崩溃重启次数
        private const val CRASH_RESTART_INTERVAL = 60000L // 崩溃重启间隔时间（毫秒）

        @Volatile
        private var instance: CrashHandler? = null

        fun getInstance(): CrashHandler {
            return instance ?: synchronized(this) {
                instance ?: CrashHandler().also { instance = it }
            }
        }
    }

    private var context: Context? = null
    private var defaultHandler: Thread.UncaughtExceptionHandler? = null
    private var crashCount = 0
    private var lastCrashTime = 0L

    /**
     * 初始化崩溃处理器
     */
    fun init(context: Context) {
        this.context = context.applicationContext
        defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler(this)
        Log.d(TAG, "CrashHandler initialized")
    }

    override fun uncaughtException(thread: Thread, throwable: Throwable) {
        Log.e(TAG, "Uncaught exception in thread: ${thread.name}", throwable)

        try {
            // 保存崩溃日志
            saveCrashLog(throwable)

            // 检查是否需要重启应用
            if (shouldRestartApp()) {
                restartApp()
            } else {
                // 超过重启次数限制，记录日志并退出
                Log.e(TAG, "Too many crashes, app will exit")
                handleCrashExit(throwable)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling crash", e)
            handleCrashExit(throwable)
        }
    }

    /**
     * 保存崩溃日志到文件
     */
    private fun saveCrashLog(throwable: Throwable) {
        try {
            val context = this.context ?: return
            val logDir = File(context.getExternalFilesDir(null), CRASH_LOG_DIR)
            if (!logDir.exists()) {
                logDir.mkdirs()
            }

            val timestamp = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.getDefault()).format(Date())
            val logFile = File(logDir, "crash_$timestamp.log")

            val writer = PrintWriter(logFile)
            writer.use {
                // 写入设备信息
                it.println("=== Device Info ===")
                it.println("Brand: ${Build.BRAND}")
                it.println("Model: ${Build.MODEL}")
                it.println("Android Version: ${Build.VERSION.RELEASE}")
                it.println("SDK: ${Build.VERSION.SDK_INT}")
                it.println("Time: $timestamp")
                it.println()

                // 写入异常信息
                it.println("=== Exception Info ===")
                val sw = StringWriter()
                throwable.printStackTrace(PrintWriter(sw))
                it.println(sw.toString())
            }

            Log.d(TAG, "Crash log saved: ${logFile.absolutePath}")

            // 清理旧日志（保留最近10个）
            cleanOldLogs(logDir)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save crash log", e)
        }
    }

    /**
     * 清理旧的崩溃日志
     */
    private fun cleanOldLogs(logDir: File) {
        try {
            val logFiles = logDir.listFiles()?.sortedByDescending { it.lastModified() } ?: return
            if (logFiles.size > 10) {
                logFiles.drop(10).forEach { it.delete() }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to clean old logs", e)
        }
    }

    /**
     * 判断是否应该重启应用
     */
    private fun shouldRestartApp(): Boolean {
        val currentTime = System.currentTimeMillis()

        // 如果距离上次崩溃超过间隔时间，重置计数
        if (currentTime - lastCrashTime > CRASH_RESTART_INTERVAL) {
            crashCount = 0
        }

        lastCrashTime = currentTime
        crashCount++

        return crashCount <= MAX_CRASH_RESTART
    }

    /**
     * 重启应用
     */
    private fun restartApp() {
        try {
            val context = this.context ?: return
            Log.d(TAG, "Restarting app (crash count: $crashCount)")

            // 获取启动Intent
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            intent?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                putExtra("crashed", true)
                putExtra("crash_count", crashCount)
            }

            // 延迟重启，给系统时间清理资源
            Thread.sleep(1000)

            context.startActivity(intent)
            Process.killProcess(Process.myPid())
            exitProcess(0)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to restart app", e)
            handleCrashExit(e)
        }
    }

    /**
     * 处理崩溃退出
     */
    private fun handleCrashExit(throwable: Throwable) {
        // 调用系统默认处理器
        defaultHandler?.uncaughtException(Thread.currentThread(), throwable)

        // 强制退出
        Process.killProcess(Process.myPid())
        exitProcess(1)
    }

    /**
     * 获取崩溃日志目录
     */
    fun getCrashLogDir(): File? {
        return context?.let { File(it.getExternalFilesDir(null), CRASH_LOG_DIR) }
    }
}
