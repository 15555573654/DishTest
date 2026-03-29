package com.dishtest.screencast.control

import android.graphics.Point
import android.util.Log

/**
 * 坐标映射器
 * 负责将Web端坐标映射到Android设备坐标
 * 参考scrcpy的坐标转换逻辑
 */
class CoordinateMapper {
    companion object {
        private const val TAG = "CoordinateMapper"
    }

    // 设备真实分辨率
    private var deviceWidth: Int = 0
    private var deviceHeight: Int = 0

    // 视频传输分辨率
    private var videoWidth: Int = 0
    private var videoHeight: Int = 0

    // 设备旋转角度
    private var rotation: Int = 0

    /**
     * 设置设备分辨率
     */
    fun setDeviceResolution(width: Int, height: Int, rotation: Int = 0) {
        this.deviceWidth = width
        this.deviceHeight = height
        this.rotation = rotation
        Log.d(TAG, "设备分辨率: ${width}x${height}, 旋转: ${rotation}°")
    }

    /**
     * 设置视频传输分辨率
     */
    fun setVideoResolution(width: Int, height: Int) {
        this.videoWidth = width
        this.videoHeight = height
        Log.d(TAG, "视频分辨率: ${width}x${height}")
    }

    /**
     * 将Web端坐标映射到设备坐标
     * @param x Web端X坐标
     * @param y Web端Y坐标
     * @param sourceWidth 源分辨率宽度
     * @param sourceHeight 源分辨率高度
     * @return 设备坐标，如果映射失败返回null
     */
    fun mapToDevice(x: Int, y: Int, sourceWidth: Int, sourceHeight: Int): Point? {
        // 验证输入
        if (deviceWidth <= 0 || deviceHeight <= 0) {
            Log.w(TAG, "设备分辨率未设置")
            return null
        }

        if (sourceWidth <= 0 || sourceHeight <= 0) {
            Log.w(TAG, "源分辨率无效: ${sourceWidth}x${sourceHeight}")
            return null
        }

        // 计算缩放比例
        val scaleX = deviceWidth.toFloat() / sourceWidth
        val scaleY = deviceHeight.toFloat() / sourceHeight

        // 映射坐标
        var deviceX = (x * scaleX).toInt()
        var deviceY = (y * scaleY).toInt()

        // 应用旋转
        if (rotation != 0) {
            val rotated = applyRotation(deviceX, deviceY)
            deviceX = rotated.x
            deviceY = rotated.y
        }

        // 确保坐标在有效范围内
        deviceX = deviceX.coerceIn(0, deviceWidth - 1)
        deviceY = deviceY.coerceIn(0, deviceHeight - 1)

        return Point(deviceX, deviceY)
    }

    /**
     * 应用旋转变换
     */
    private fun applyRotation(x: Int, y: Int): Point {
        return when (rotation) {
            90 -> Point(y, deviceWidth - x)
            180 -> Point(deviceWidth - x, deviceHeight - y)
            270 -> Point(deviceHeight - y, x)
            else -> Point(x, y)
        }
    }

    /**
     * 获取当前设备分辨率
     */
    fun getDeviceResolution(): Pair<Int, Int> {
        return Pair(deviceWidth, deviceHeight)
    }

    /**
     * 获取当前视频分辨率
     */
    fun getVideoResolution(): Pair<Int, Int> {
        return Pair(videoWidth, videoHeight)
    }

    /**
     * 重置所有配置
     */
    fun reset() {
        deviceWidth = 0
        deviceHeight = 0
        videoWidth = 0
        videoHeight = 0
        rotation = 0
        Log.d(TAG, "坐标映射器已重置")
    }
}
