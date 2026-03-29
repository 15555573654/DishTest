package com.dishtest.screencast.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.dishtest.screencast.webrtc.AccessibilityHelper

class AccessibilityControlService : AccessibilityService() {
    
    private val TAG = "AccessibilityControlService"
    private val mainHandler = Handler(Looper.getMainLooper())
    private var activeTouchStroke: GestureDescription.StrokeDescription? = null
    private var activeTouchX: Float? = null
    private var activeTouchY: Float? = null
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "无障碍服务已连接")
        AccessibilityHelper.setService(this)
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // 可以在这里处理无障碍事件，目前不需要
    }
    
    override fun onInterrupt() {
        Log.d(TAG, "无障碍服务被中断")
    }
    
    fun performClickAt(x: Float, y: Float): Boolean {
        Log.d(TAG, "尝试点击位置: ($x, $y)")
        return dispatchTapGesture(x, y, 80L, "点击")
    }

    fun performDoubleClickAt(x: Float, y: Float): Boolean {
        Log.d(TAG, "尝试双击位置: ($x, $y)")
        val firstTap = dispatchTapGesture(x, y, 60L, "双击-第一次")
        mainHandler.postDelayed({
            dispatchTapGesture(x, y, 60L, "双击-第二次")
        }, 90L)
        return firstTap
    }

    fun performLongPressAt(x: Float, y: Float, durationMs: Long): Boolean {
        Log.d(TAG, "尝试长按位置: ($x, $y), duration=${durationMs}ms")
        return dispatchTapGesture(x, y, durationMs.coerceIn(350L, 1200L), "长按")
    }

    fun performTouchDown(x: Float, y: Float): Boolean {
        releaseHeldTouch()

        val path = Path()
        path.moveTo(x, y)
        val stroke = GestureDescription.StrokeDescription(path, 0, 60_000L, true)
        val gesture = GestureDescription.Builder()
            .addStroke(stroke)
            .build()

        val dispatched = dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "touchDown completed at ($x, $y)")
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "touchDown cancelled at ($x, $y)")
                activeTouchStroke = null
                activeTouchX = null
                activeTouchY = null
            }
        }, null)

        if (dispatched) {
            activeTouchStroke = stroke
            activeTouchX = x
            activeTouchY = y
        }

        return dispatched
    }

    fun performTouchMove(x: Float, y: Float): Boolean {
        val stroke = activeTouchStroke ?: return performTouchDown(x, y)
        val startX = activeTouchX ?: x
        val startY = activeTouchY ?: y

        val path = Path()
        path.moveTo(startX, startY)
        path.lineTo(x, y)
        val continuedStroke = stroke.continueStroke(path, 0, 16L, true)
        val gesture = GestureDescription.Builder()
            .addStroke(continuedStroke)
            .build()

        val dispatched = dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "touchMove completed to ($x, $y)")
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "touchMove cancelled to ($x, $y)")
                activeTouchStroke = null
                activeTouchX = null
                activeTouchY = null
            }
        }, null)

        if (dispatched) {
            activeTouchStroke = continuedStroke
            activeTouchX = x
            activeTouchY = y
        }

        return dispatched
    }

    fun releaseHeldTouch(x: Float? = null, y: Float? = null): Boolean {
        val stroke = activeTouchStroke ?: return false
        val releaseX = x ?: activeTouchX ?: return false
        val releaseY = y ?: activeTouchY ?: return false

        val path = Path()
        path.moveTo(releaseX, releaseY)
        val gesture = GestureDescription.Builder()
            .addStroke(stroke.continueStroke(path, 0, 1L, false))
            .build()

        val dispatched = dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "touchUp completed at ($releaseX, $releaseY)")
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "touchUp cancelled at ($releaseX, $releaseY)")
            }
        }, null)

        activeTouchStroke = null
        activeTouchX = null
        activeTouchY = null
        return dispatched
    }

    private fun dispatchTapGesture(x: Float, y: Float, durationMs: Long, label: String): Boolean {
        val path = Path()
        path.moveTo(x, y)
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, durationMs))
            .build()
        
        return dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "${label}手势执行成功")
            }
            
            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "${label}手势被取消")
            }
        }, null)
    }
    
    fun performSwipeGesture(x1: Float, y1: Float, x2: Float, y2: Float, durationMs: Long): Boolean {
        Log.d(TAG, "尝试滑动: ($x1, $y1) -> ($x2, $y2), duration=${durationMs}ms")
        val path = Path()
        path.moveTo(x1, y1)
        path.lineTo(x2, y2)
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, durationMs.coerceIn(120L, 1200L)))
            .build()
        
        return dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "滑动手势执行成功")
            }
            
            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "滑动手势被取消")
            }
        }, null)
    }
    
    fun performBackAction(): Boolean {
        Log.d(TAG, "尝试执行返回操作")
        val result = performGlobalAction(GLOBAL_ACTION_BACK)
        Log.d(TAG, "返回操作结果: $result")
        return result
    }
    
    fun performHomeAction(): Boolean {
        Log.d(TAG, "尝试执行主页操作")
        val result = performGlobalAction(GLOBAL_ACTION_HOME)
        Log.d(TAG, "主页操作结果: $result")
        return result
    }
    
    fun performMenuAction(): Boolean {
        Log.d(TAG, "尝试执行任务栏操作")
        val result = performGlobalAction(GLOBAL_ACTION_RECENTS)
        Log.d(TAG, "任务栏操作结果: $result")
        return result
    }
    
    override fun onDestroy() {
        super.onDestroy()
        releaseHeldTouch()
        Log.d(TAG, "无障碍服务已销毁")
        AccessibilityHelper.setService(null)
    }
}
