package com.ruoyi.screencast.control

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.util.Log
import com.google.gson.Gson
import org.json.JSONObject

/**
 * 控制消息处理器
 * 负责解析和处理来自Web端的控制消息
 * 参考scrcpy的消息处理机制
 */
class ControlMessageHandler(
    private val context: Context,
    private val touchInjector: TouchEventInjector,
    private val keyInjector: KeyEventInjector,
    private val feedbackCallback: ((String, JSONObject) -> Unit)? = null
) {
    companion object {
        private const val TAG = "ControlMessageHandler"
    }

    private val gson = Gson()
    private val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

    /**
     * 处理控制消息
     */
    fun handleMessage(messageJson: String): Boolean {
        return try {
            val message = gson.fromJson(messageJson, ControlMessage::class.java)
            handleControlMessage(message)
        } catch (e: Exception) {
            Log.e(TAG, "解析控制消息失败", e)
            false
        }
    }

    /**
     * 处理控制消息对象
     */
    private fun handleControlMessage(message: ControlMessage): Boolean {
        Log.d(TAG, "处理控制消息: ${message.action}")

        return when (message.action) {
            "click" -> handleClick(message)
            "doubleClick" -> handleDoubleClick(message)
            "longPress" -> handleLongPress(message)
            "swipe" -> handleSwipe(message)
            "touchDown" -> handleTouchDown(message)
            "touchMove" -> handleTouchMove(message)
            "touchUp" -> handleTouchUp(message)
            "virtualKey" -> handleVirtualKey(message)
            "volumeUp", "volumeDown" -> handleVolume(message)
            "rotateScreen" -> handleRotateScreen()
            "setClipboard" -> handleSetClipboard(message)
            "readClipboard" -> handleReadClipboard()
            "setQuality" -> handleSetQuality(message)
            "stopCapture" -> handleStopCapture()
            else -> {
                Log.w(TAG, "未知的控制动作: ${message.action}")
                false
            }
        }
    }

    /**
     * 处理点击
     */
    private fun handleClick(message: ControlMessage): Boolean {
        val x = message.x ?: return false
        val y = message.y ?: return false
        val resolution = message.resolution ?: return false

        val success = touchInjector.injectClick(x, y, resolution.width, resolution.height)

        if (success) {
            sendFeedback("click-confirmation", JSONObject().apply {
                put("x", x)
                put("y", y)
            })
        }

        return success
    }

    /**
     * 处理双击
     */
    private fun handleDoubleClick(message: ControlMessage): Boolean {
        val x = message.x ?: return false
        val y = message.y ?: return false
        val resolution = message.resolution ?: return false

        // 执行两次点击，间隔100ms
        val success1 = touchInjector.injectClick(x, y, resolution.width, resolution.height)
        Thread.sleep(100)
        val success2 = touchInjector.injectClick(x, y, resolution.width, resolution.height)

        return success1 && success2
    }

    /**
     * 处理长按
     */
    private fun handleLongPress(message: ControlMessage): Boolean {
        val x = message.x ?: return false
        val y = message.y ?: return false
        val resolution = message.resolution ?: return false
        val duration = message.durationMs ?: 500

        return touchInjector.injectLongPress(x, y, resolution.width, resolution.height, duration)
    }

    /**
     * 处理滑动
     */
    private fun handleSwipe(message: ControlMessage): Boolean {
        val x1 = message.x1 ?: return false
        val y1 = message.y1 ?: return false
        val x2 = message.x2 ?: return false
        val y2 = message.y2 ?: return false
        val resolution = message.resolution ?: return false
        val duration = message.durationMs ?: 300

        val success = touchInjector.injectSwipe(
            x1, y1, x2, y2,
            resolution.width, resolution.height,
            duration
        )

        if (success) {
            sendFeedback("swipe-confirmation", JSONObject().apply {
                put("x1", x1)
                put("y1", y1)
                put("x2", x2)
                put("y2", y2)
            })
        }

        return success
    }

    /**
     * 处理触摸按下
     */
    private fun handleTouchDown(message: ControlMessage): Boolean {
        val x = message.x ?: return false
        val y = message.y ?: return false
        val resolution = message.resolution ?: return false

        return touchInjector.injectTouchDown(x, y, resolution.width, resolution.height)
    }

    /**
     * 处理触摸移动
     */
    private fun handleTouchMove(message: ControlMessage): Boolean {
        val x = message.x ?: return false
        val y = message.y ?: return false
        val resolution = message.resolution ?: return false

        return touchInjector.injectTouchMove(x, y, resolution.width, resolution.height)
    }

    /**
     * 处理触摸释放
     */
    private fun handleTouchUp(message: ControlMessage): Boolean {
        return if (message.x != null && message.y != null && message.resolution != null) {
            touchInjector.injectTouchUp(
                message.x,
                message.y,
                message.resolution.width,
                message.resolution.height
            )
        } else {
            touchInjector.injectTouchUp()
        }
    }

    /**
     * 处理虚拟按键
     */
    private fun handleVirtualKey(message: ControlMessage): Boolean {
        val key = message.key ?: return false
        return keyInjector.injectVirtualKey(key)
    }

    /**
     * 处理音量调节
     */
    private fun handleVolume(message: ControlMessage): Boolean {
        val direction = if (message.action == "volumeUp") "up" else "down"
        val success = keyInjector.injectVolumeKey(direction)

        if (success) {
            sendFeedback("volume-confirmation", JSONObject().apply {
                put("direction", direction)
            })
        }

        return success
    }

    /**
     * 处理屏幕旋转
     */
    private fun handleRotateScreen(): Boolean {
        // 这里需要实现屏幕旋转逻辑
        // 可以通过修改系统设置或发送广播实现
        Log.d(TAG, "屏幕旋转功能待实现")

        sendFeedback("rotation-confirmation", JSONObject())
        return true
    }

    /**
     * 处理设置剪贴板
     */
    private fun handleSetClipboard(message: ControlMessage): Boolean {
        val text = message.text ?: return false

        return try {
            val clip = ClipData.newPlainText("screencast", text)
            clipboardManager.setPrimaryClip(clip)

            sendFeedback("clipboard-write-confirmation", JSONObject().apply {
                put("success", true)
            })

            true
        } catch (e: Exception) {
            Log.e(TAG, "设置剪贴板失败", e)
            false
        }
    }

    /**
     * 处理读取剪贴板
     */
    private fun handleReadClipboard(): Boolean {
        return try {
            val clip = clipboardManager.primaryClip
            val text = if (clip != null && clip.itemCount > 0) {
                clip.getItemAt(0).text?.toString() ?: ""
            } else {
                ""
            }

            sendFeedback("clipboard-content", JSONObject().apply {
                put("text", text)
            })

            true
        } catch (e: Exception) {
            Log.e(TAG, "读取剪贴板失败", e)
            false
        }
    }

    /**
     * 处理设置质量
     */
    private fun handleSetQuality(message: ControlMessage): Boolean {
        val settings = message.settings ?: return false

        Log.d(TAG, "设置质量: ${settings.quality} (${settings.resolution}@${settings.frameRate}fps)")

        // 这里需要通知ScreenCaptureService更新质量
        // 可以通过广播或回调实现

        sendFeedback("quality-change-confirmation", JSONObject().apply {
            put("quality", settings.quality)
            put("resolution", settings.resolution)
            put("frameRate", settings.frameRate)
        })

        return true
    }

    /**
     * 处理停止捕获
     */
    private fun handleStopCapture(): Boolean {
        Log.d(TAG, "停止捕获")
        // 这里需要通知ScreenCaptureService停止捕获
        return true
    }

    /**
     * 发送反馈消息
     */
    private fun sendFeedback(type: String, data: JSONObject) {
        data.put("type", type)
        data.put("timestamp", System.currentTimeMillis())
        feedbackCallback?.invoke(type, data)
    }

    /**
     * 重置状态
     */
    fun reset() {
        touchInjector.reset()
        Log.d(TAG, "控制消息处理器已重置")
    }
}
