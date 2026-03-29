package com.dishtest.screencast.file

import android.content.Context
import android.os.Environment
import android.util.Base64
import android.util.Log
import java.io.File
import java.io.FileOutputStream

/**
 * 文件接收管理器
 * 负责接收通过MQTT传输的文件分块，组装并保存到指定位置
 */
class FileReceiveManager(private val context: Context) {
    
    companion object {
        private const val TAG = "FileReceiveManager"
    }
    
    // 存储正在接收的文件信息
    private val receivingFiles = mutableMapOf<String, FileReceiveInfo>()
    
    /**
     * 处理文件分块
     */
    fun handleFileChunk(
        fileId: String,
        chunkIndex: Int,
        totalChunks: Int,
        fileName: String,
        targetPath: String,
        data: String
    ) {
        try {
            Log.d(TAG, "接收文件分块: fileId=$fileId, chunk=$chunkIndex/$totalChunks, fileName=$fileName, targetPath=$targetPath")
            
            // 获取或创建文件接收信息
            val fileInfo = receivingFiles.getOrPut(fileId) {
                Log.d(TAG, "创建新的文件接收信息: $fileName -> $targetPath")
                FileReceiveInfo(
                    fileId = fileId,
                    fileName = fileName,
                    targetPath = targetPath,
                    totalChunks = totalChunks,
                    chunks = mutableMapOf()
                )
            }
            
            // 解码Base64数据
            val chunkData = Base64.decode(data, Base64.DEFAULT)
            fileInfo.chunks[chunkIndex] = chunkData
            
            Log.d(TAG, "已接收 ${fileInfo.chunks.size}/$totalChunks 个分块, 分块大小: ${chunkData.size} bytes")
            
            // 检查是否接收完所有分块
            if (fileInfo.chunks.size == totalChunks) {
                Log.d(TAG, "所有分块接收完成，开始组装文件")
                assembleAndSaveFile(fileInfo)
                receivingFiles.remove(fileId)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "处理文件分块失败", e)
            e.printStackTrace()
            receivingFiles.remove(fileId)
        }
    }
    
    /**
     * 组装并保存文件
     */
    private fun assembleAndSaveFile(fileInfo: FileReceiveInfo) {
        try {
            Log.d(TAG, "开始组装文件: ${fileInfo.fileName}")
            
            // 确保目标目录存在
            val targetDir = File(fileInfo.targetPath)
            if (!targetDir.exists()) {
                targetDir.mkdirs()
            }
            
            // 创建目标文件
            val targetFile = File(targetDir, fileInfo.fileName)
            
            // 如果文件已存在，添加序号
            val finalFile = if (targetFile.exists()) {
                getUniqueFile(targetDir, fileInfo.fileName)
            } else {
                targetFile
            }
            
            // 按顺序写入所有分块
            FileOutputStream(finalFile).use { fos ->
                for (i in 0 until fileInfo.totalChunks) {
                    val chunk = fileInfo.chunks[i]
                    if (chunk != null) {
                        fos.write(chunk)
                    } else {
                        throw Exception("缺少分块 $i")
                    }
                }
            }
            
            Log.d(TAG, "文件保存成功: ${finalFile.absolutePath}")
            
            // 通知媒体扫描器（如果是媒体文件）
            notifyMediaScanner(finalFile)
            
        } catch (e: Exception) {
            Log.e(TAG, "组装文件失败", e)
            throw e
        }
    }
    
    /**
     * 获取唯一的文件名（如果文件已存在，添加序号）
     */
    private fun getUniqueFile(dir: File, fileName: String): File {
        val nameWithoutExt = fileName.substringBeforeLast(".")
        val ext = if (fileName.contains(".")) {
            "." + fileName.substringAfterLast(".")
        } else {
            ""
        }
        
        var counter = 1
        var file = File(dir, fileName)
        
        while (file.exists()) {
            file = File(dir, "${nameWithoutExt}_${counter}${ext}")
            counter++
        }
        
        return file
    }
    
    /**
     * 通知媒体扫描器
     */
    private fun notifyMediaScanner(file: File) {
        try {
            val intent = android.content.Intent(android.content.Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            intent.data = android.net.Uri.fromFile(file)
            context.sendBroadcast(intent)
        } catch (e: Exception) {
            Log.w(TAG, "通知媒体扫描器失败", e)
        }
    }
    
    /**
     * 取消文件接收
     */
    fun cancelFileReceive(fileId: String) {
        receivingFiles.remove(fileId)
        Log.d(TAG, "取消文件接收: $fileId")
    }
    
    /**
     * 清理所有未完成的文件接收
     */
    fun cleanup() {
        receivingFiles.clear()
        Log.d(TAG, "清理文件接收管理器")
    }
    
    /**
     * 文件接收信息
     */
    private data class FileReceiveInfo(
        val fileId: String,
        val fileName: String,
        val targetPath: String,
        val totalChunks: Int,
        val chunks: MutableMap<Int, ByteArray>
    )
}
