package com.ruoyi.system.service.impl;

import java.util.Date;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.MqttDevice;
import com.ruoyi.system.domain.vo.MqttDeviceStatistics;
import com.ruoyi.system.mapper.MqttDeviceMapper;
import com.ruoyi.system.service.IDeviceManagerService;

/**
 * 设备管理服务实现
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
@Service
public class DeviceManagerServiceImpl implements IDeviceManagerService
{
    private static final Logger log = LoggerFactory.getLogger(DeviceManagerServiceImpl.class);

    @Autowired
    private MqttDeviceMapper mqttDeviceMapper;

    @Override
    @Transactional
    public MqttDevice registerDevice(String deviceName, String username)
    {
        // 查询设备是否已存在
        MqttDevice device = mqttDeviceMapper.selectMqttDeviceByNameAndUsername(deviceName, username);

        if (device == null)
        {
            // 创建新设备
            device = new MqttDevice();
            device.setDeviceName(deviceName);
            device.setUsername(username);
            device.setDeviceStatus("离线");
            device.setScriptStatus("未运行");
            device.setLastOnline(new Date());

            mqttDeviceMapper.insertMqttDevice(device);
            log.info("注册新设备: deviceName={}, username={}", deviceName, username);
        }

        return device;
    }

    @Override
    @Transactional
    public void updateDeviceStatus(String deviceName, String username, String status)
    {
        MqttDevice device = mqttDeviceMapper.selectMqttDeviceByNameAndUsername(deviceName, username);

        if (device == null)
        {
            // 设备不存在，创建新设备并直接设置为目标状态
            device = new MqttDevice();
            device.setDeviceName(deviceName);
            device.setUsername(username);
            device.setDeviceStatus(status);
            device.setScriptStatus("未运行");
            device.setLastOnline(new Date());
            mqttDeviceMapper.insertMqttDevice(device);
            log.info("注册新设备并设置状态: deviceName={}, username={}, status={}", deviceName, username, status);
            return;
        }

        if (!status.equals(device.getDeviceStatus()))
        {
            device.setDeviceStatus(status);
            if ("在线".equals(status))
            {
                device.setLastOnline(new Date());
            }
            mqttDeviceMapper.updateMqttDevice(device);
            log.info("更新设备状态: deviceName={}, status={}", deviceName, status);
        }
    }

    @Override
    @Transactional
    public void updateScriptStatus(String deviceName, String username, String scriptStatus)
    {
        MqttDevice device = mqttDeviceMapper.selectMqttDeviceByNameAndUsername(deviceName, username);

        if (device == null)
        {
            // 设备不存在时，先注册为在线状态（因为能收到消息说明在线）
            device = new MqttDevice();
            device.setDeviceName(deviceName);
            device.setUsername(username);
            device.setDeviceStatus("在线");
            device.setScriptStatus(scriptStatus);
            device.setLastOnline(new Date());
            mqttDeviceMapper.insertMqttDevice(device);
            log.info("注册新设备并设置脚本状态: deviceName={}, username={}, scriptStatus={}", deviceName, username, scriptStatus);
            return;
        }

        if (!scriptStatus.equals(device.getScriptStatus()))
        {
            device.setScriptStatus(scriptStatus);
            mqttDeviceMapper.updateMqttDevice(device);
            log.info("更新脚本状态: deviceName={}, scriptStatus={}", deviceName, scriptStatus);
        }
    }

    @Override
    @Transactional
    public void updateGameData(String deviceName, String username, JSONObject gameData)
    {
        MqttDevice device = mqttDeviceMapper.selectMqttDeviceByNameAndUsername(deviceName, username);

        if (device == null)
        {
            // 设备不存在时，先注册为在线状态（因为能收到消息说明在线）
            device = new MqttDevice();
            device.setDeviceName(deviceName);
            device.setUsername(username);
            device.setDeviceStatus("在线");
            device.setScriptStatus("未运行");
            device.setLastOnline(new Date());
            mqttDeviceMapper.insertMqttDevice(device);
            log.info("注册新设备: deviceName={}, username={}", deviceName, username);
            // 重新查询以获取生成的ID
            device = mqttDeviceMapper.selectMqttDeviceByNameAndUsername(deviceName, username);
        }

        boolean updated = false;

        // 更新等级
        if (gameData.containsKey("等级") && gameData.get("等级") != null)
        {
            String level = gameData.get("等级").toString();
            if (StringUtils.isNotEmpty(level) && !level.equals(device.getLevel()))
            {
                device.setLevel(level);
                updated = true;
            }
        }

        // 更新区服
        if (gameData.containsKey("区服") && gameData.get("区服") != null)
        {
            String server = gameData.get("区服").toString();
            if (StringUtils.isNotEmpty(server) && !server.equals(device.getServer()))
            {
                device.setServer(server);
                updated = true;
            }
        }

        // 更新钻石
        if (gameData.containsKey("钻石") && gameData.get("钻石") != null)
        {
            String diamonds = gameData.get("钻石").toString();
            if (StringUtils.isNotEmpty(diamonds) && !diamonds.equals(device.getDiamonds()))
            {
                device.setDiamonds(diamonds);
                updated = true;
            }
        }

        // 更新运行状态
        if (gameData.containsKey("运行状态") && gameData.get("运行状态") != null)
        {
            String scriptStatus = gameData.get("运行状态").toString();
            if (StringUtils.isNotEmpty(scriptStatus) && !scriptStatus.equals(device.getScriptStatus()))
            {
                device.setScriptStatus(scriptStatus);
                updated = true;
                log.info("从游戏数据更新脚本状态: deviceName={}, oldStatus={}, newStatus={}", 
                    deviceName, device.getScriptStatus(), scriptStatus);
            }
        }
        else
        {
            log.debug("游戏数据中没有运行状态字段: deviceName={}, gameData={}", deviceName, gameData);
        }

        if (updated)
        {
            mqttDeviceMapper.updateMqttDevice(device);
            log.info("更新游戏数据: deviceName={}, gameData={}", deviceName, gameData);
        }
    }

    @Override
    public List<MqttDevice> selectMqttDeviceList(MqttDevice mqttDevice)
    {
        List<MqttDevice> devices = mqttDeviceMapper.selectMqttDeviceList(mqttDevice);
        
        // 动态计算设备状态和脚本状态
        long currentTime = System.currentTimeMillis();
        long heartbeatTimeout = 15000; // 15秒超时
        
        for (MqttDevice device : devices)
        {
            // 如果超过心跳超时时间，设置为离线
            if (device.getLastOnline() != null)
            {
                long timeSinceLastOnline = currentTime - device.getLastOnline().getTime();
                
                if (timeSinceLastOnline > heartbeatTimeout)
                {
                    device.setDeviceStatus("离线");
                    device.setScriptStatus("未运行");
                }
            }
        }
        
        return devices;
    }

    @Override
    public MqttDevice selectMqttDeviceByDeviceId(Long deviceId)
    {
        MqttDevice device = mqttDeviceMapper.selectMqttDeviceByDeviceId(deviceId);

        // 动态计算设备状态
        if (device != null && device.getLastOnline() != null)
        {
            long currentTime = System.currentTimeMillis();
            long heartbeatTimeout = 15000; // 15秒超时
            long timeSinceLastOnline = currentTime - device.getLastOnline().getTime();

            if (timeSinceLastOnline > heartbeatTimeout)
            {
                device.setDeviceStatus("离线");
                device.setScriptStatus("未运行");
            }
        }

        return device;
    }

    @Override
    public MqttDevice selectMqttDeviceByName(String deviceName)
    {
        MqttDevice query = new MqttDevice();
        query.setDeviceName(deviceName);
        List<MqttDevice> devices = mqttDeviceMapper.selectMqttDeviceList(query);

        if (devices != null && !devices.isEmpty())
        {
            return devices.get(0);
        }

        return null;
    }

    @Override
    public int insertMqttDevice(MqttDevice mqttDevice)
    {
        return mqttDeviceMapper.insertMqttDevice(mqttDevice);
    }

    @Override
    public int updateMqttDevice(MqttDevice mqttDevice)
    {
        return mqttDeviceMapper.updateMqttDevice(mqttDevice);
    }

    @Override
    public int deleteMqttDeviceByDeviceIds(Long[] deviceIds)
    {
        return mqttDeviceMapper.deleteMqttDeviceByDeviceIds(deviceIds);
    }

    @Override
    public int deleteMqttDeviceByDeviceId(Long deviceId)
    {
        return mqttDeviceMapper.deleteMqttDeviceByDeviceId(deviceId);
    }

    @Override
    public MqttDeviceStatistics getStatistics(String username)
    {
        MqttDevice query = new MqttDevice();
        if (username != null && !username.isEmpty())
        {
            query.setUsername(username);
        }
        List<MqttDevice> devices = mqttDeviceMapper.selectMqttDeviceList(query);

        int totalDevices = devices.size();
        int onlineDevices = 0;
        long totalDiamonds = 0L;
        
        // 动态计算在线设备数和钻石总数
        long currentTime = System.currentTimeMillis();
        long heartbeatTimeout = 15000; // 15秒超时
        
        for (MqttDevice device : devices)
        {
            boolean isOnline = false;
            
            // 判断设备是否在线
            if (device.getLastOnline() != null)
            {
                long timeSinceLastOnline = currentTime - device.getLastOnline().getTime();
                isOnline = timeSinceLastOnline <= heartbeatTimeout;
            }
            
            if (isOnline)
            {
                onlineDevices++;
            }
            
            // 累计钻石数（只统计数字）
            if (device.getDiamonds() != null && device.getDiamonds().matches("^[0-9]+$"))
            {
                try
                {
                    totalDiamonds += Long.parseLong(device.getDiamonds());
                }
                catch (NumberFormatException e)
                {
                    // 忽略无法解析的钻石数
                }
            }
        }
        
        int offlineDevices = totalDevices - onlineDevices;

        return new MqttDeviceStatistics(totalDevices, onlineDevices, offlineDevices, totalDiamonds);
    }
}
