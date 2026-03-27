package com.ruoyi.screencast.crash

import android.app.ActivityManager
import android.content.Context
import android.util.Log
import java.io.File

/**
 * 守护服务调试工具
 */
object GuardServiceDebugger {
    private const val TAG = "GuardServiceDebugger"

    /**
     * 检查守护服务状态
     */
    fun checkGuardServiceStatus(context: Context): String {
        val sb = StringBuilder()
        sb.appendLine("=== 守护服务状态检查 ===")
        
        // 1. 检查进程
        val processes = getRunningProcesses(context)
        sb.appendLine("\n1. 运行中的进程:")
        processes.forEach { (name, pid) ->
            sb.appendLine("  - $name (pid=$pid)")
            Log.d(TAG, "Process: $name (pid=$pid)")
        }
        
        val guardProcessName = "${context.packageName}:guard"
        val hasGuardProcess = processes.containsKey(guardProcessName)
        sb.appendLine("\n守护进程状态: ${if (hasGuardProcess) "✓ 运行中" else "✗ 未运行"}")
        Log.d(TAG, "Guard process status: ${if (hasGuardProcess) "RUNNING" else "NOT RUNNING"}")
        
        // 2. 检查服务
        val services = getRunningServices(context)
        sb.appendLine("\n2. 运行中的服务:")
        services.forEach { serviceName ->
            sb.appendLine("  - $serviceName")
            Log.d(TAG, "Service: $serviceName")
        }
        
        val guardServiceName = "com.ruoyi.screencast.crash.ProcessGuardService"
        val hasGuardService = services.any { it.contains("ProcessGuardService") }
        sb.appendLine("\n守护服务状态: ${if (hasGuardService) "✓ 运行中" else "✗ 未运行"}")
        Log.d(TAG, "Guard service status: ${if (hasGuardService) "RUNNING" else "NOT RUNNING"}")
        
        // 3. 检查/proc文件系统
        sb.appendLine("\n3. /proc文件系统检查:")
        val procInfo = checkProcFileSystem(context)
        sb.appendLine(procInfo)
        
        return sb.toString()
    }

    /**
     * 获取运行中的进程
     */
    private fun getRunningProcesses(context: Context): Map<String, Int> {
        val processes = mutableMapOf<String, Int>()
        
        try {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.runningAppProcesses?.forEach { processInfo ->
                if (processInfo.processName.contains(context.packageName)) {
                    processes[processInfo.processName] = processInfo.pid
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get running processes", e)
        }
        
        return processes
    }

    /**
     * 获取运行中的服务
     */
    private fun getRunningServices(context: Context): List<String> {
        val services = mutableListOf<String>()
        
        try {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            @Suppress("DEPRECATION")
            activityManager.getRunningServices(100)?.forEach { serviceInfo ->
                if (serviceInfo.service.packageName == context.packageName) {
                    services.add(serviceInfo.service.className)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get running services", e)
        }
        
        return services
    }

    /**
     * 检查/proc文件系统
     */
    private fun checkProcFileSystem(context: Context): String {
        val sb = StringBuilder()
        val myUid = android.os.Process.myUid()
        val packageName = context.packageName
        
        try {
            val procDir = File("/proc")
            if (!procDir.exists()) {
                sb.appendLine("  /proc目录不存在")
                return sb.toString()
            }
            
            var foundCount = 0
            procDir.listFiles()?.forEach { pidDir ->
                if (pidDir.isDirectory && pidDir.name.matches(Regex("\\d+"))) {
                    try {
                        val cmdlineFile = File(pidDir, "cmdline")
                        if (cmdlineFile.exists()) {
                            val cmdline = cmdlineFile.readText().trim('\u0000')
                            
                            if (cmdline.startsWith(packageName)) {
                                // 验证UID
                                val statusFile = File(pidDir, "status")
                                if (statusFile.exists()) {
                                    val status = statusFile.readText()
                                    val uidLine = status.lines().find { it.startsWith("Uid:") }
                                    if (uidLine != null) {
                                        val uid = uidLine.split("\\s+".toRegex())[1].toIntOrNull()
                                        if (uid == myUid) {
                                            sb.appendLine("  - $cmdline (pid=${pidDir.name})")
                                            Log.d(TAG, "Found process via /proc: $cmdline (pid=${pidDir.name})")
                                            foundCount++
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
            
            if (foundCount == 0) {
                sb.appendLine("  未找到相关进程")
            }
            
        } catch (e: Exception) {
            sb.appendLine("  检查失败: ${e.message}")
            Log.e(TAG, "Failed to check /proc", e)
        }
        
        return sb.toString()
    }

    /**
     * 打印详细日志
     */
    fun printDetailedLogs(context: Context) {
        Log.d(TAG, "========================================")
        Log.d(TAG, "守护服务详细状态")
        Log.d(TAG, "========================================")
        
        val status = checkGuardServiceStatus(context)
        status.lines().forEach { line ->
            Log.d(TAG, line)
        }
        
        Log.d(TAG, "========================================")
    }
}
