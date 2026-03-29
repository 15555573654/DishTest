package com.dishtest.screencast.control

import android.graphics.Point
import android.os.SystemClock
import android.util.Log
import android.view.InputDevice
import android.view.MotionEvent
import java.io.IOException

/**
 * 触摸事件注入器
 * 负责将触摸事件注入到Android系统
 * 参考scrcpy的触摸事件注入实现
 */
class TouchEventInjector(private val coordinateMapper: CoordinateMapper) {
    companion object {
        private const val TAG = "TouchEventInjector"
    }

    // 当前触摸状态
    private var lastTouchDown: Point? = null
    private var lastTouchDownTime: Long = 0

    /**
     * 注入点击事件
     */
    fun injectClick(x: Int, y: Int, sourceWidth: Int, sourceHeight: Int): Boolean {
        val devicePoint = coordinateMapper.mapToDevice(x, y, sourceWidth, sourceHeight)
        if (devicePoint == null) {
            Log.w(TAG, "坐标映射失败")
            return false
        }

        Log.d(TAG, "注入点击: (${devicePoint.x}, ${devicePoint.y})")

        return try {
            val downTime = SystemClock.uptimeMillis()
            
            // DOWN事件
            injectMotionEvent(
                MotionEvent.ACTION_DOWN,
                downTime,
                downTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            // UP事件（延迟50ms模拟真实点击）
            Thread.sleep(50)
            val upTime = SystemClock.uptimeMillis()
            injectMotionEvent(
                MotionEvent.ACTION_UP,
                downTime,
                upTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入点击事件失败", e)
            false
        }
    }

    /**
     * 注入滑动事件
     */
    fun injectSwipe(
        x1: Int, y1: Int,
        x2: Int, y2: Int,
        sourceWidth: Int, sourceHeight: Int,
        durationMs: Long = 300
    ): Boolean {
        val startPoint = coordinateMapper.mapToDevice(x1, y1, sourceWidth, sourceHeight)
        val endPoint = coordinateMapper.mapToDevice(x2, y2, sourceWidth, sourceHeight)

        if (startPoint == null || endPoint == null) {
            Log.w(TAG, "坐标映射失败")
            return false
        }

        Log.d(TAG, "注入滑动: (${startPoint.x}, ${startPoint.y}) -> (${endPoint.x}, ${endPoint.y}), 时长: ${durationMs}ms")

        return try {
            val downTime = SystemClock.uptimeMillis()
            val steps = (durationMs / 16).toInt().coerceAtLeast(10) // 约60fps

            // DOWN事件
            injectMotionEvent(
                MotionEvent.ACTION_DOWN,
                downTime,
                downTime,
                startPoint.x.toFloat(),
                startPoint.y.toFloat()
            )

            // MOVE事件
            for (i in 1 until steps) {
                val progress = i.toFloat() / steps
                val currentX = startPoint.x + (endPoint.x - startPoint.x) * progress
                val currentY = startPoint.y + (endPoint.y - startPoint.y) * progress
                val eventTime = downTime + (durationMs * progress).toLong()

                injectMotionEvent(
                    MotionEvent.ACTION_MOVE,
                    downTime,
                    eventTime,
                    currentX,
                    currentY
                )

                Thread.sleep(16) // 约60fps
            }

            // UP事件
            val upTime = downTime + durationMs
            injectMotionEvent(
                MotionEvent.ACTION_UP,
                downTime,
                upTime,
                endPoint.x.toFloat(),
                endPoint.y.toFloat()
            )

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入滑动事件失败", e)
            false
        }
    }

    /**
     * 注入长按事件
     */
    fun injectLongPress(
        x: Int, y: Int,
        sourceWidth: Int, sourceHeight: Int,
        durationMs: Long = 500
    ): Boolean {
        val devicePoint = coordinateMapper.mapToDevice(x, y, sourceWidth, sourceHeight)
        if (devicePoint == null) {
            Log.w(TAG, "坐标映射失败")
            return false
        }

        Log.d(TAG, "注入长按: (${devicePoint.x}, ${devicePoint.y}), 时长: ${durationMs}ms")

        return try {
            val downTime = SystemClock.uptimeMillis()

            // DOWN事件
            injectMotionEvent(
                MotionEvent.ACTION_DOWN,
                downTime,
                downTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            // 保持按下状态
            Thread.sleep(durationMs)

            // UP事件
            val upTime = SystemClock.uptimeMillis()
            injectMotionEvent(
                MotionEvent.ACTION_UP,
                downTime,
                upTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入长按事件失败", e)
            false
        }
    }

    /**
     * 注入触摸按下事件
     */
    fun injectTouchDown(x: Int, y: Int, sourceWidth: Int, sourceHeight: Int): Boolean {
        val devicePoint = coordinateMapper.mapToDevice(x, y, sourceWidth, sourceHeight)
        if (devicePoint == null) {
            Log.w(TAG, "坐标映射失败")
            return false
        }

        Log.d(TAG, "注入触摸按下: (${devicePoint.x}, ${devicePoint.y})")

        return try {
            val downTime = SystemClock.uptimeMillis()
            lastTouchDown = devicePoint
            lastTouchDownTime = downTime

            injectMotionEvent(
                MotionEvent.ACTION_DOWN,
                downTime,
                downTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入触摸按下事件失败", e)
            false
        }
    }

    /**
     * 注入触摸移动事件
     */
    fun injectTouchMove(x: Int, y: Int, sourceWidth: Int, sourceHeight: Int): Boolean {
        if (lastTouchDown == null) {
            Log.w(TAG, "没有触摸按下事件，无法移动")
            return false
        }

        val devicePoint = coordinateMapper.mapToDevice(x, y, sourceWidth, sourceHeight)
        if (devicePoint == null) {
            Log.w(TAG, "坐标映射失败")
            return false
        }

        return try {
            val eventTime = SystemClock.uptimeMillis()

            injectMotionEvent(
                MotionEvent.ACTION_MOVE,
                lastTouchDownTime,
                eventTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入触摸移动事件失败", e)
            false
        }
    }

    /**
     * 注入触摸释放事件
     */
    fun injectTouchUp(x: Int? = null, y: Int? = null, sourceWidth: Int = 0, sourceHeight: Int = 0): Boolean {
        val devicePoint = if (x != null && y != null && sourceWidth > 0 && sourceHeight > 0) {
            coordinateMapper.mapToDevice(x, y, sourceWidth, sourceHeight)
        } else {
            lastTouchDown
        }

        if (devicePoint == null) {
            Log.w(TAG, "没有有效的触摸位置")
            return false
        }

        Log.d(TAG, "注入触摸释放: (${devicePoint.x}, ${devicePoint.y})")

        return try {
            val upTime = SystemClock.uptimeMillis()

            injectMotionEvent(
                MotionEvent.ACTION_UP,
                lastTouchDownTime,
                upTime,
                devicePoint.x.toFloat(),
                devicePoint.y.toFloat()
            )

            // 清除状态
            lastTouchDown = null
            lastTouchDownTime = 0

            true
        } catch (e: Exception) {
            Log.e(TAG, "注入触摸释放事件失败", e)
            false
        }
    }

    /**
     * 注入MotionEvent
     */
    private fun injectMotionEvent(
        action: Int,
        downTime: Long,
        eventTime: Long,
        x: Float,
        y: Float
    ) {
        val event = MotionEvent.obtain(
            downTime,
            eventTime,
            action,
            x,
            y,
            0
        )

        event.source = InputDevice.SOURCE_TOUCHSCREEN

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
            Log.e(TAG, "注入事件失败", e)
            throw IOException("Failed to inject event", e)
        } finally {
            event.recycle()
        }
    }

    /**
     * 重置状态
     */
    fun reset() {
        lastTouchDown = null
        lastTouchDownTime = 0
        Log.d(TAG, "触摸事件注入器已重置")
    }
}
