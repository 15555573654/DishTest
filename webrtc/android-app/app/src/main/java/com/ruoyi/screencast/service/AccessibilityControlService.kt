package com.ruoyi.screencast.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import com.ruoyi.screencast.webrtc.AccessibilityHelper

class AccessibilityControlService : AccessibilityService() {
    
    private val TAG = "AccessibilityControlService"
    
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
        val path = Path()
        path.moveTo(x, y)
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 100))
            .build()
        
        return dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "点击手势执行成功")
            }
            
            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "点击手势被取消")
            }
        }, null)
    }
    
    fun performSwipeGesture(x1: Float, y1: Float, x2: Float, y2: Float): Boolean {
        Log.d(TAG, "尝试滑动: ($x1, $y1) -> ($x2, $y2)")
        val path = Path()
        path.moveTo(x1, y1)
        path.lineTo(x2, y2)
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 500))
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
        Log.d(TAG, "无障碍服务已销毁")
        AccessibilityHelper.setService(null)
    }
}
