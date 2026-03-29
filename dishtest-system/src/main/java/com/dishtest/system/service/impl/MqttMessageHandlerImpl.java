package com.dishtest.system.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.dishtest.system.service.IMqttMessageHandler;

/**
 * MQTT消息处理器实现
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
@Service
public class MqttMessageHandlerImpl implements IMqttMessageHandler
{
    private static final Logger log = LoggerFactory.getLogger(MqttMessageHandlerImpl.class);

    @Override
    public void handleMessage(String topic, String payload)
    {
        try
        {
            log.info("开始处理消息: topic={}", topic);
            
            // 解析JSON消息
            JSONObject msgData = JSON.parseObject(payload);
            String deviceName = msgData.getString("deviceName");
            
            log.info("解析消息: deviceName={}", deviceName);

            // 提取用户名
            String username = extractUsername(topic);
            log.info("提取用户名: username={}", username);

            // 处理状态更新消息
            if (topic.contains("/status/") || topic.startsWith("status/"))
            {
                log.info("处理状态消息");
                handleStatusMessage(deviceName, username, msgData);
            }
            // 处理响应消息
            else if (topic.contains("/response/") || topic.startsWith("response/"))
            {
                log.info("处理响应消息");
                handleResponseMessage(deviceName, username, msgData);
            }
            // 处理配置消息
            else if (topic.contains("/config/") || topic.startsWith("config/"))
            {
                log.info("处理配置消息");
                handleConfigMessage(deviceName, username, msgData);
            }
            else
            {
                log.warn("未知的消息类型: topic={}", topic);
            }
        }
        catch (Exception e)
        {
            log.error("处理MQTT消息失败: topic={}, payload={}", topic, payload, e);
        }
    }

    /**
     * 处理状态消息
     */
    private void handleStatusMessage(String deviceName, String username, JSONObject msgData)
    {
        String status = msgData.getString("status");
        if (status != null && !status.isEmpty())
        {
            // 转换状态
            if ("offline".equals(status))
            {
                status = "离线";
            }
            else if ("online".equals(status))
            {
                status = "在线";
            }

            log.info("状态消息(仅透传不入库): deviceName={}, username={}, status={}", deviceName, username, status);
        }
    }

    /**
     * 处理响应消息
     */
    private void handleResponseMessage(String deviceName, String username, JSONObject msgData)
    {
        String response = msgData.getString("response");

        if ("停止".equals(response))
        {
            log.info("响应消息(仅透传不入库): deviceName={}, username={}, scriptStatus=未运行", deviceName, username);
        }
        else if ("运行中".equals(response))
        {
            log.info("响应消息(仅透传不入库): deviceName={}, username={}, scriptStatus=运行中", deviceName, username);
        }
        else if ("暂停".equals(response))
        {
            log.info("响应消息(仅透传不入库): deviceName={}, username={}, scriptStatus=暂停", deviceName, username);
        }
    }

    /**
     * 处理配置消息
     */
    private void handleConfigMessage(String deviceName, String username, JSONObject msgData)
    {
        log.info("处理配置消息: deviceName={}, username={}, msgData={}", deviceName, username, msgData);
        
        // 仅记录收到的配置消息，不做设备入库更新
        log.info("配置消息(仅透传不入库): deviceName={}, username={}", deviceName, username);
        
        String msgAction = msgData.getString("type");
        String msgContent = msgData.getString("msg");

        if ("post".equals(msgAction) && msgContent != null && !msgContent.isEmpty())
        {
            // 处理数据更新
            handleDataUpdate(deviceName, username, msgContent);
        }
    }

    /**
     * 处理数据更新
     */
    private void handleDataUpdate(String deviceName, String username, String msgContent)
    {
        try
        {
            JSONObject gameData = JSON.parseObject(msgContent);
            log.info("配置数据(仅透传不入库): deviceName={}, username={}, keys={}", deviceName, username, gameData.keySet());
        }
        catch (Exception e)
        {
            log.error("解析游戏数据失败: deviceName={}", deviceName, e);
        }
    }

    /**
     * 从主题中提取用户名
     */
    private String extractUsername(String topic)
    {
        // 主题格式: response/{username}/{deviceName} 或 status/{username}/{deviceName}
        String[] parts = topic.split("/");
        if (parts.length >= 2)
        {
            return parts[1];
        }
        return "";
    }
}
