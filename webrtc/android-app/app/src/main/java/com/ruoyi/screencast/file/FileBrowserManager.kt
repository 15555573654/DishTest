package com.dishtest.screencast.file

import android.content.Context
import android.os.Environment
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

/**
 * 文件浏览管理器
 * 负责浏览Android设备的文件系统
 */
class FileBrowserManager(private val context: Context) {
    
    companion object {
        private const val TAG = "FileBrowserManager"
    }
    
    /**
     * 获取目录列表
     */
    fun listDirectory(path: String): JSONObject {
        return try {
            val dir = File(path)
            
            if (!dir.exists()) {
                createErrorResponse("目录不存在: $path")
            } else if (!dir.isDirectory) {
                createErrorResponse("不是目录: $path")
            } else if (!dir.canRead()) {
                createErrorResponse("没有读取权限: $path")
            } else {
                val files = dir.listFiles()?.sortedWith(compareBy(
                    { !it.isDirectory }, // 目录排在前面
                    { it.name.lowercase() } // 按名称排序
                )) ?: emptyList()
                
                val fileList = JSONArray()
                for (file in files) {
                    try {
                        fileList.put(createFileInfo(file))
                    } catch (e: Exception) {
                        Log.w(TAG, "无法读取文件信息: ${file.name}", e)
                    }
                }
                
                JSONObject().apply {
                    put("success", true)
                    put("path", path)
                    put("files", fileList)
                    put("canGoUp", dir.parent != null)
                    put("parentPath", dir.parent ?: "")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "列出目录失败: $path", e)
            createErrorResponse("列出目录失败: ${e.message}")
        }
    }
    
    /**
     * 获取常用目录
     */
    fun getCommonDirectories(): JSONObject {
        return try {
            val dirs = JSONArray()
            
            // 外部存储根目录
            val externalStorage = Environment.getExternalStorageDirectory()
            if (externalStorage.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "内部存储")
                    put("path", externalStorage.absolutePath)
                    put("icon", "phone")
                })
            }
            
            // 下载目录
            val downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (downloadDir.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "下载")
                    put("path", downloadDir.absolutePath)
                    put("icon", "download")
                })
            }
            
            // 文档目录
            val documentsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
            if (documentsDir.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "文档")
                    put("path", documentsDir.absolutePath)
                    put("icon", "document")
                })
            }
            
            // 图片目录
            val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            if (picturesDir.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "图片")
                    put("path", picturesDir.absolutePath)
                    put("icon", "picture")
                })
            }
            
            // DCIM目录
            val dcimDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
            if (dcimDir.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "相机")
                    put("path", dcimDir.absolutePath)
                    put("icon", "camera")
                })
            }
            
            // 音乐目录
            val musicDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
            if (musicDir.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "音乐")
                    put("path", musicDir.absolutePath)
                    put("icon", "music")
                })
            }
            
            // 视频目录
            val moviesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            if (moviesDir.exists()) {
                dirs.put(JSONObject().apply {
                    put("name", "视频")
                    put("path", moviesDir.absolutePath)
                    put("icon", "video")
                })
            }
            
            JSONObject().apply {
                put("success", true)
                put("directories", dirs)
            }
        } catch (e: Exception) {
            Log.e(TAG, "获取常用目录失败", e)
            createErrorResponse("获取常用目录失败: ${e.message}")
        }
    }
    
    /**
     * 创建文件信息对象
     */
    private fun createFileInfo(file: File): JSONObject {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        
        return JSONObject().apply {
            put("name", file.name)
            put("path", file.absolutePath)
            put("isDirectory", file.isDirectory)
            put("size", if (file.isDirectory) 0 else file.length())
            put("lastModified", dateFormat.format(Date(file.lastModified())))
            put("canRead", file.canRead())
            put("canWrite", file.canWrite())
            put("extension", getFileExtension(file.name))
            put("mimeType", getMimeType(file.name))
        }
    }
    
    /**
     * 获取文件扩展名
     */
    private fun getFileExtension(fileName: String): String {
        val lastDot = fileName.lastIndexOf('.')
        return if (lastDot > 0 && lastDot < fileName.length - 1) {
            fileName.substring(lastDot + 1).lowercase()
        } else {
            ""
        }
    }
    
    /**
     * 获取MIME类型
     */
    private fun getMimeType(fileName: String): String {
        val extension = getFileExtension(fileName)
        return when (extension) {
            // 图片
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "gif" -> "image/gif"
            "bmp" -> "image/bmp"
            "webp" -> "image/webp"
            
            // 视频
            "mp4" -> "video/mp4"
            "avi" -> "video/x-msvideo"
            "mkv" -> "video/x-matroska"
            "mov" -> "video/quicktime"
            
            // 音频
            "mp3" -> "audio/mpeg"
            "wav" -> "audio/wav"
            "flac" -> "audio/flac"
            "m4a" -> "audio/mp4"
            
            // 文档
            "pdf" -> "application/pdf"
            "doc", "docx" -> "application/msword"
            "xls", "xlsx" -> "application/vnd.ms-excel"
            "ppt", "pptx" -> "application/vnd.ms-powerpoint"
            "txt" -> "text/plain"
            
            // 压缩文件
            "zip" -> "application/zip"
            "rar" -> "application/x-rar-compressed"
            "7z" -> "application/x-7z-compressed"
            
            // APK
            "apk" -> "application/vnd.android.package-archive"
            
            else -> "application/octet-stream"
        }
    }
    
    /**
     * 创建错误响应
     */
    private fun createErrorResponse(message: String): JSONObject {
        return JSONObject().apply {
            put("success", false)
            put("error", message)
        }
    }
    
    /**
     * 删除文件或目录
     */
    fun deleteFile(path: String): JSONObject {
        return try {
            val file = File(path)
            
            if (!file.exists()) {
                createErrorResponse("文件不存在")
            } else if (!file.canWrite()) {
                createErrorResponse("没有删除权限")
            } else {
                val deleted = if (file.isDirectory) {
                    file.deleteRecursively()
                } else {
                    file.delete()
                }
                
                if (deleted) {
                    JSONObject().apply {
                        put("success", true)
                        put("message", "删除成功")
                    }
                } else {
                    createErrorResponse("删除失败")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "删除文件失败: $path", e)
            createErrorResponse("删除失败: ${e.message}")
        }
    }
    
    /**
     * 创建目录
     */
    fun createDirectory(path: String): JSONObject {
        return try {
            val dir = File(path)
            
            if (dir.exists()) {
                createErrorResponse("目录已存在")
            } else {
                val created = dir.mkdirs()
                
                if (created) {
                    JSONObject().apply {
                        put("success", true)
                        put("message", "创建成功")
                    }
                } else {
                    createErrorResponse("创建失败")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "创建目录失败: $path", e)
            createErrorResponse("创建失败: ${e.message}")
        }
    }
    
    /**
     * 重命名文件或目录
     */
    fun renameFile(oldPath: String, newName: String): JSONObject {
        return try {
            val oldFile = File(oldPath)
            
            if (!oldFile.exists()) {
                createErrorResponse("文件不存在")
            } else if (!oldFile.canWrite()) {
                createErrorResponse("没有重命名权限")
            } else {
                val newFile = File(oldFile.parent, newName)
                
                if (newFile.exists()) {
                    createErrorResponse("目标文件已存在")
                } else {
                    val renamed = oldFile.renameTo(newFile)
                    
                    if (renamed) {
                        JSONObject().apply {
                            put("success", true)
                            put("message", "重命名成功")
                            put("newPath", newFile.absolutePath)
                        }
                    } else {
                        createErrorResponse("重命名失败")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "重命名文件失败: $oldPath -> $newName", e)
            createErrorResponse("重命名失败: ${e.message}")
        }
    }
}
