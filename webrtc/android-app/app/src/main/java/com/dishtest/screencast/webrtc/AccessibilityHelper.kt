package com.dishtest.screencast.webrtc

import android.util.Log
import com.dishtest.screencast.service.AccessibilityControlService

object AccessibilityHelper {
    
    private var service: AccessibilityControlService? = null
    private const val TAG = "AccessibilityHelper"
    
    fun setService(accessibilityService: AccessibilityControlService?) {
        service = accessibilityService
        Log.d(TAG, "AccessibilityService ${if (accessibilityService != null) "已连接" else "已断开"}")
    }
    
    fun performClick(x: Float, y: Float) {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行点击操作")
            return
        }
        Log.d(TAG, "执行点击操作: ($x, $y)")
        service?.performClickAt(x, y)
    }

    fun performDoubleClick(x: Float, y: Float) {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行双击操作")
            return
        }
        Log.d(TAG, "执行双击操作: ($x, $y)")
        service?.performDoubleClickAt(x, y)
    }

    fun performTouchDown(x: Float, y: Float) {
        if (service == null) {
            Log.w(TAG, "AccessibilityService unavailable for touchDown")
            return
        }
        Log.d(TAG, "touchDown at: ($x, $y)")
        service?.performTouchDown(x, y)
    }

    fun performTouchUp(x: Float? = null, y: Float? = null) {
        if (service == null) {
            Log.w(TAG, "AccessibilityService unavailable for touchUp")
            return
        }
        Log.d(TAG, "touchUp at: ($x, $y)")
        service?.releaseHeldTouch(x, y)
    }

    fun performTouchMove(x: Float, y: Float) {
        if (service == null) {
            Log.w(TAG, "AccessibilityService unavailable for touchMove")
            return
        }
        Log.d(TAG, "touchMove at: ($x, $y)")
        service?.performTouchMove(x, y)
    }

    fun performLongPress(x: Float, y: Float, durationMs: Long) {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行长按操作")
            return
        }
        Log.d(TAG, "执行长按操作: ($x, $y), duration=${durationMs}ms")
        service?.performLongPressAt(x, y, durationMs)
    }
    
    fun performSwipe(x1: Float, y1: Float, x2: Float, y2: Float, durationMs: Long) {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行滑动操作")
            return
        }
        Log.d(TAG, "执行滑动操作: ($x1, $y1) -> ($x2, $y2), duration=${durationMs}ms")
        service?.performSwipeGesture(x1, y1, x2, y2, durationMs)
    }
    
    fun performBack() {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行返回操作")
            return
        }
        Log.d(TAG, "执行返回操作")
        val result = service?.performBackAction()
        Log.d(TAG, "返回操作结果: $result")
    }
    
    fun performHome() {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行主页操作")
            return
        }
        Log.d(TAG, "执行主页操作")
        val result = service?.performHomeAction()
        Log.d(TAG, "主页操作结果: $result")
    }
    
    fun performMenu() {
        if (service == null) {
            Log.w(TAG, "无障碍服务未启用，无法执行任务栏操作")
            return
        }
        Log.d(TAG, "执行任务栏操作")
        val result = service?.performMenuAction()
        Log.d(TAG, "任务栏操作结果: $result")
    }
    
    fun isServiceConnected(): Boolean {
        return service != null
    }
}
