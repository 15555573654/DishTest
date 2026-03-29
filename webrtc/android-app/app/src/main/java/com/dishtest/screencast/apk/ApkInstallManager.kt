package com.dishtest.screencast.apk

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream

class ApkInstallManager(private val context: Context) {
    
    companion object {
        private const val TAG = "ApkInstallManager"
        private const val APK_DIR = "apk_downloads"
    }
    
    private var logCallback: ((String) -> Unit)? = null
    private val apkChunks = mutableMapOf<String, MutableList<ByteArray>>()
    private val apkMetadata = mutableMapOf<String, ApkMetadata>()
    
    fun setLogCallback(callback: (String) -> Unit) {
        logCallback = callback
    }
    
    /**
     * 接收APK分块数据
     */
    fun receiveApkChunk(apkId: String, chunkIndex: Int, totalChunks: Int, data: ByteArray, fileName: String) {
        try {
            // 初始化元数据
            if (!apkMetadata.containsKey(apkId)) {
                apkMetadata[apkId] = ApkMetadata(fileName, totalChunks)
                apkChunks[apkId] = MutableList(totalChunks) { ByteArray(0) }
                log("开始接收APK: $fileName (共 $totalChunks 块)")
            }
            
            // 保存分块
            apkChunks[apkId]?.set(chunkIndex, data)
            
            val receivedChunks = apkChunks[apkId]?.count { it.isNotEmpty() } ?: 0
            val progress = (receivedChunks * 100) / totalChunks
            log("接收进度: $receivedChunks/$totalChunks ($progress%)")
            
            // 检查是否接收完成
            if (receivedChunks == totalChunks) {
                log("✓ APK接收完成，开始组装...")
                assembleAndInstallApk(apkId)
            }
            
        } catch (e: Exception) {
            log("❌ 接收APK分块失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    /**
     * 组装并安装APK
     */
    private fun assembleAndInstallApk(apkId: String) {
        try {
            val metadata = apkMetadata[apkId] ?: throw Exception("APK元数据不存在")
            val chunks = apkChunks[apkId] ?: throw Exception("APK分块数据不存在")
            
            // 创建APK目录
            val apkDir = File(context.getExternalFilesDir(null), APK_DIR)
            if (!apkDir.exists()) {
                apkDir.mkdirs()
            }
            
            // 组装APK文件
            val apkFile = File(apkDir, metadata.fileName)
            FileOutputStream(apkFile).use { output ->
                chunks.forEach { chunk ->
                    output.write(chunk)
                }
            }
            
            log("✓ APK组装完成: ${apkFile.absolutePath}")
            log("文件大小: ${apkFile.length() / 1024} KB")
            
            // 清理内存中的数据
            apkChunks.remove(apkId)
            apkMetadata.remove(apkId)
            
            // 安装APK
            installApk(apkFile)
            
        } catch (e: Exception) {
            log("❌ 组装APK失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    /**
     * 安装APK
     */
    private fun installApk(apkFile: File) {
        try {
            log("开始安装APK...")
            
            val intent = Intent(Intent.ACTION_VIEW)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Android 7.0及以上使用FileProvider
                val apkUri = FileProvider.getUriForFile(
                    context,
                    "${context.packageName}.fileprovider",
                    apkFile
                )
                intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            } else {
                // Android 7.0以下直接使用文件URI
                intent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive")
            }
            
            context.startActivity(intent)
            log("✓ 已打开安装界面")
            
        } catch (e: Exception) {
            log("❌ 安装APK失败: ${e.message}")
            e.printStackTrace()
        }
    }
    
    /**
     * 取消APK接收
     */
    fun cancelApkReceive(apkId: String) {
        apkChunks.remove(apkId)
        apkMetadata.remove(apkId)
        log("已取消APK接收: $apkId")
    }
    
    /**
     * 清理旧的APK文件
     */
    fun cleanOldApkFiles() {
        try {
            val apkDir = File(context.getExternalFilesDir(null), APK_DIR)
            if (apkDir.exists()) {
                apkDir.listFiles()?.forEach { file ->
                    if (file.isFile && file.extension == "apk") {
                        file.delete()
                        log("已删除旧APK: ${file.name}")
                    }
                }
            }
        } catch (e: Exception) {
            log("清理APK文件失败: ${e.message}")
        }
    }
    
    private fun log(message: String) {
        Log.d(TAG, message)
        logCallback?.invoke(message)
    }
    
    data class ApkMetadata(
        val fileName: String,
        val totalChunks: Int
    )
}
