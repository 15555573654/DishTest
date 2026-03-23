package com.ruoyi.system.service.impl;

import java.util.Collections;
import java.util.List;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.system.domain.MqttDevice;
import com.ruoyi.system.domain.vo.MqttDeviceStatistics;
import com.ruoyi.system.service.IDeviceManagerService;

/**
 * 设备管理服务实现（数据库链路已停用）
 */
@Service
public class DeviceManagerServiceImpl implements IDeviceManagerService
{
    @Override
    public MqttDevice registerDevice(String deviceName, String username)
    {
        return null;
    }

    @Override
    public void updateDeviceStatus(String deviceName, String username, String status)
    {
        // 已停用：设备状态改为由MQTT保留消息驱动
    }

    @Override
    public void updateScriptStatus(String deviceName, String username, String scriptStatus)
    {
        // 已停用：脚本状态改为由MQTT保留消息驱动
    }

    @Override
    public void updateGameData(String deviceName, String username, JSONObject gameData)
    {
        // 已停用：游戏数据不再入库
    }

    @Override
    public List<MqttDevice> selectMqttDeviceList(MqttDevice mqttDevice)
    {
        return Collections.emptyList();
    }

    @Override
    public MqttDevice selectMqttDeviceByDeviceId(Long deviceId)
    {
        return null;
    }

    @Override
    public MqttDevice selectMqttDeviceByName(String deviceName)
    {
        return null;
    }

    @Override
    public int insertMqttDevice(MqttDevice mqttDevice)
    {
        return 0;
    }

    @Override
    public int updateMqttDevice(MqttDevice mqttDevice)
    {
        return 0;
    }

    @Override
    public int deleteMqttDeviceByDeviceIds(Long[] deviceIds)
    {
        return 0;
    }

    @Override
    public int deleteMqttDeviceByDeviceId(Long deviceId)
    {
        return 0;
    }

    @Override
    public MqttDeviceStatistics getStatistics(String username)
    {
        return new MqttDeviceStatistics(0, 0, 0, 0L);
    }
}
