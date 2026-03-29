package com.dishtest.screencast

import android.app.Application
import android.content.Intent
import android.os.Build
import android.util.Log
import com.dishtest.screencast.crash.CrashHandler
import com.dishtest.screencast.crash.ProcessGuardService

/**
 * 应用程序类
 * 初始化全局配置和崩溃处理
 */
class ScreencastApplication : Application() {

    companion object {
        private const val TAG = "ScreencastApplication"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Application onCreate")

        // 初始化崩溃处理器
        initCrashHandler()

        // 启动进程守护服务（仅在主进程）
        if (isMainProcess()) {
            startProcessGuardService()
        }
    }

    /**
     * 初始化崩溃处理器
     */
    private fun initCrashHandler() {
        try {
            CrashHandler.getInstance().init(this)
            Log.d(TAG, "CrashHandler initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize CrashHandler", e)
        }
    }

    /**
     * 启动进程守护服务
     */
    private fun startProcessGuardService() {
        try {
            val intent = Intent(this, ProcessGuardService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            Log.d(TAG, "ProcessGuardService started")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start ProcessGuardService", e)
        }
    }

    /**
     * 判断是否为主进程
     */
    private fun isMainProcess(): Boolean {
        val processName = getCurrentProcessName()
        return processName == packageName
    }

    /**
     * 获取当前进程名
     */
    private fun getCurrentProcessName(): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return Application.getProcessName()
        }

        // 兼容旧版本
        try {
            val activityManager = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
            activityManager.runningAppProcesses?.forEach { processInfo ->
                if (processInfo.pid == android.os.Process.myPid()) {
                    return processInfo.processName
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get process name", e)
        }

        return packageName
    }
}
