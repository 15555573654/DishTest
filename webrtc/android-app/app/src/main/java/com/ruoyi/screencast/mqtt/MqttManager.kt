package com.dishtest.screencast.mqtt

import android.content.Context
import org.eclipse.paho.client.mqttv3.*
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence

class MqttManager(private val context: Context) {
    
    private var mqttClient: MqttClient? = null
    private var statusCallback: ((String) -> Unit)? = null
    private var logCallback: ((String) -> Unit)? = null
    private var messageCallback: ((String, String) -> Unit)? = null
    
    private var username: String = ""
    private var deviceName: String = ""
    
    fun setStatusCallback(callback: (String) -> Unit) {
        statusCallback = callback
    }
    
    fun setLogCallback(callback: (String) -> Unit) {
        logCallback = callback
    }
    
    fun setMessageCallback(callback: (String, String) -> Unit) {
        messageCallback = callback
    }
    
    fun connect(host: String, port: Int, user: String, pass: String, device: String, callback: (Boolean) -> Unit) {
        username = user
        deviceName = device
        
        try {
            val broker = "tcp://$host:$port"
            val clientId = "android_${System.currentTimeMillis()}"
            
            logCallback?.invoke("正在连接MQTT: $broker")
            statusCallback?.invoke("连接中...")
            
            mqttClient = MqttClient(broker, clientId, MemoryPersistence())
            
            val options = MqttConnectOptions().apply {
                userName = user
                password = pass.toCharArray()
                isCleanSession = true
                connectionTimeout = 10
                keepAliveInterval = 60
                val willTopic = "status/$user/$device"
                val willPayload = """{"deviceName":"$device","status":"offline","scriptStatus":"未运行"}"""
                setWill(willTopic, willPayload.toByteArray(), 1, true)
            }
            
            mqttClient?.setCallback(object : MqttCallback {
                override fun connectionLost(cause: Throwable?) {
                    logCallback?.invoke("MQTT连接丢失: ${cause?.message}")
                    statusCallback?.invoke("连接丢失")
                }
                
                override fun messageArrived(topic: String?, message: MqttMessage?) {
                    val msg = message?.toString() ?: return
                    logCallback?.invoke("📨 MQTT消息到达: topic=$topic, 长度=${msg.length}")
                    
                    // 添加消息内容的简要信息（避免日志过长）
                    try {
                        val jsonObject = com.google.gson.Gson().fromJson(msg, com.google.gson.JsonObject::class.java)
                        val type = jsonObject.get("type")?.asString
                        val deviceName = jsonObject.get("deviceName")?.asString
                        logCallback?.invoke("📋 消息解析: type=$type, deviceName=$deviceName")
                    } catch (e: Exception) {
                        logCallback?.invoke("📋 消息解析失败: ${e.message}")
                    }
                    
                    messageCallback?.invoke(topic ?: "", msg)
                }
                
                override fun deliveryComplete(token: IMqttDeliveryToken?) {
                }
            })
            
            mqttClient?.connect(options)
            
            // 订阅WebRTC信令主题
            val webrtcTopic = "webrtc/$username/$deviceName"
            mqttClient?.subscribe(webrtcTopic, 1)
            
            // 订阅控制主题
            val controlTopic = "control/$username/$deviceName"
            mqttClient?.subscribe(controlTopic, 1)
            
            logCallback?.invoke("MQTT连接成功")
            logCallback?.invoke("已订阅主题: $webrtcTopic")
            logCallback?.invoke("已订阅主题: $controlTopic")
            statusCallback?.invoke("已连接")
            publishDeviceStatus("未运行")
            callback(true)
            
        } catch (e: Exception) {
            logCallback?.invoke("MQTT连接失败: ${e.message}")
            statusCallback?.invoke("连接失败")
            callback(false)
        }
    }
    
    fun disconnect() {
        try {
            publishOfflineStatus()
            mqttClient?.disconnect()
            mqttClient?.close()
            mqttClient = null
            logCallback?.invoke("MQTT已断开")
            statusCallback?.invoke("未连接")
        } catch (e: Exception) {
            logCallback?.invoke("断开失败: ${e.message}")
        }
    }
    
    fun publish(topic: String, message: String, retained: Boolean = false) {
        try {
            val mqttMessage = MqttMessage(message.toByteArray())
            mqttMessage.qos = 1
            mqttMessage.isRetained = retained
            mqttClient?.publish(topic, mqttMessage)
        } catch (e: Exception) {
            logCallback?.invoke("发送消息失败: ${e.message}")
        }
    }

    fun publishDeviceStatus(scriptStatus: String) {
        if (!isConnected()) return
        val topic = "status/$username/$deviceName"
        val payload = """{"deviceName":"$deviceName","status":"online","scriptStatus":"$scriptStatus"}"""
        publish(topic, payload, true)
        logCallback?.invoke("已发布保留状态: scriptStatus=$scriptStatus, status=online")
    }

    private fun publishOfflineStatus() {
        if (!isConnected()) return
        val topic = "status/$username/$deviceName"
        val payload = """{"deviceName":"$deviceName","status":"offline","scriptStatus":"未运行"}"""
        publish(topic, payload, true)
        logCallback?.invoke("已发布保留状态: scriptStatus=未运行, status=offline")
    }
    
    fun isConnected(): Boolean {
        return mqttClient?.isConnected ?: false
    }
    
    /**
     * 订阅额外的主题
     */
    fun subscribe(topic: String, callback: (String, String) -> Unit) {
        try {
            mqttClient?.subscribe(topic, 1) { t, msg ->
                callback(t, msg.toString())
            }
            logCallback?.invoke("✓ 已订阅主题: $topic")
        } catch (e: Exception) {
            logCallback?.invoke("❌ 订阅主题失败: ${e.message}")
        }
    }
    
    fun getDeviceName(): String = deviceName
    fun getUsername(): String = username
}
