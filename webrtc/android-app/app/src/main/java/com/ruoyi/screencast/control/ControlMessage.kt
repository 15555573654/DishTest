package com.dishtest.screencast.control

/**
 * 控制消息数据类
 */
data class ControlMessage(
    val action: String,
    val x: Int? = null,
    val y: Int? = null,
    val x1: Int? = null,
    val y1: Int? = null,
    val x2: Int? = null,
    val y2: Int? = null,
    val resolution: Resolution? = null,
    val durationMs: Long? = null,
    val key: String? = null,
    val direction: String? = null,
    val text: String? = null,
    val settings: QualitySettings? = null,
    val deviceName: String? = null,
    val from: String? = null
)

/**
 * 分辨率数据类
 */
data class Resolution(
    val width: Int,
    val height: Int
)

/**
 * 质量设置数据类
 */
data class QualitySettings(
    val quality: String,
    val resolution: String,
    val frameRate: Int
)
