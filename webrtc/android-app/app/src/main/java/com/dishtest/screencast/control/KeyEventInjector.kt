package com.dishtest.screencast.control

import android.os.SystemClock
import android.util.Log
import android.view.KeyEvent
import java.io.IOException

/**
 * 按键事件注入器
 * 负责将按键事件注入到Android系统
 * 参考scrcpy的按键事件注入实现
 */
class KeyEventInjector {
    companion object {
        private const val TAG = "KeyEventInjector"

        // Android按键码
        const val KEYCODE_BACK = KeyEvent.KEYCODE_BACK
        const val KEYCODE_HOME = KeyEvent.KEYCODE_HOME
        const val KEYCODE_MENU = KeyEvent.KEYCODE_MENU
        const val KEYCODE_VOLUME_UP = KeyEvent.KEYCODE_VOLUME_UP
        const val KEYCODE_VOLUME_DOWN = KeyEvent.KEYCODE_VOLUME_DOWN
        const val KEYCODE_POWER = KeyEvent.KEYCODE_POWER
    }

    /**
     * 注入按键事件
     */
    fun injectKey(keyCode: Int): Boolean {
        Log.d(TAG, "注入按键: $keyCode")

        return try {
            val downTime = SystemClock.uptimeMillis()

            // DOWN事件
            injectKeyEvent(KeyEvent.ACTION_DOWN, keyCode, downTime)

            // UP事件（延迟50ms模拟真实按键）
            Thread.sleep(50)
            val upTime = SystemClock.uptimeMillis()
            injectKeyEvent(KeyEvent.ACTION_UP, keyCode, upTime)

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入按键事件失败", e)
            false
        }
    }

    /**
     * 注入虚拟按键
     */
    fun injectVirtualKey(key: String): Boolean {
        val keyCode = when (key.lowercase()) {
            "back" -> KEYCODE_BACK
            "home" -> KEYCODE_HOME
            "menu", "task" -> KEYCODE_MENU
            else -> {
                Log.w(TAG, "未知的虚拟按键: $key")
                return false
            }
        }

        return injectKey(keyCode)
    }

    /**
     * 注入音量按键
     */
    fun injectVolumeKey(direction: String): Boolean {
        val keyCode = when (direction.lowercase()) {
            "up" -> KEYCODE_VOLUME_UP
            "down" -> KEYCODE_VOLUME_DOWN
            else -> {
                Log.w(TAG, "未知的音量方向: $direction")
                return false
            }
        }

        return injectKey(keyCode)
    }

    /**
     * 注入电源按键
     */
    fun injectPowerKey(): Boolean {
        return injectKey(KEYCODE_POWER)
    }

    /**
     * 注入KeyEvent
     */
    private fun injectKeyEvent(action: Int, keyCode: Int, eventTime: Long) {
        val event = KeyEvent(
            eventTime,
            eventTime,
            action,
            keyCode,
            0,
            0,
            -1,
            0,
            0,
            0
        )

        try {
            // 使用反射调用InputManager.injectInputEvent
            val inputManagerClass = Class.forName("android.hardware.input.InputManager")
            val instanceMethod = inputManagerClass.getDeclaredMethod("getInstance")
            val inputManager = instanceMethod.invoke(null)

            val injectInputEventMethod = inputManagerClass.getMethod(
                "injectInputEvent",
                android.view.InputEvent::class.java,
                Int::class.javaPrimitiveType
            )

            // MODE_ASYNC = 0
            injectInputEventMethod.invoke(inputManager, event, 0)
        } catch (e: Exception) {
            Log.e(TAG, "注入按键事件失败", e)
            throw IOException("Failed to inject key event", e)
        }
    }
}
