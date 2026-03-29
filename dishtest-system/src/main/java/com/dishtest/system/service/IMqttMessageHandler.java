package com.dishtest.system.service;

/**
 * MQTT消息处理器接口
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
public interface IMqttMessageHandler
{
    /**
     * 处理MQTT消息
     * 
     * @param topic 主题
     * @param payload 消息内容
     */
    void handleMessage(String topic, String payload);
}
