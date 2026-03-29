package com.dishtest.system.service.impl;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson2.JSON;
import com.dishtest.system.domain.MqttTaskConfig;
import com.dishtest.system.mapper.MqttTaskConfigMapper;
import com.dishtest.system.service.IDeviceManagerService;
import com.dishtest.system.service.IMqttTaskConfigService;

/**
 * MQTT任务配置服务实现
 *
 * @author ruoyi
 * @date 2025-01-19
 */
@Service
public class MqttTaskConfigServiceImpl implements IMqttTaskConfigService
{
    private static final Logger log = LoggerFactory.getLogger(MqttTaskConfigServiceImpl.class);

    @Autowired
    private MqttTaskConfigMapper mqttTaskConfigMapper;

    @Autowired
    private IDeviceManagerService deviceManagerService;

    @Override
    public MqttTaskConfig selectMqttTaskConfigByConfigId(Long configId)
    {
        return mqttTaskConfigMapper.selectMqttTaskConfigByConfigId(configId);
    }

    @Override
    public List<MqttTaskConfig> selectMqttTaskConfigList(MqttTaskConfig mqttTaskConfig)
    {
        return mqttTaskConfigMapper.selectMqttTaskConfigList(mqttTaskConfig);
    }

    @Override
    public int insertMqttTaskConfig(MqttTaskConfig mqttTaskConfig)
    {
        // 验证JSON格式
        if (!validateJsonFormat(mqttTaskConfig.getConfigContent()))
        {
            throw new RuntimeException("配置内容不是有效的JSON格式");
        }
        return mqttTaskConfigMapper.insertMqttTaskConfig(mqttTaskConfig);
    }

    @Override
    public int updateMqttTaskConfig(MqttTaskConfig mqttTaskConfig)
    {
        // 验证JSON格式
        if (!validateJsonFormat(mqttTaskConfig.getConfigContent()))
        {
            throw new RuntimeException("配置内容不是有效的JSON格式");
        }
        return mqttTaskConfigMapper.updateMqttTaskConfig(mqttTaskConfig);
    }

    @Override
    public int deleteMqttTaskConfigByConfigIds(Long[] configIds)
    {
        return mqttTaskConfigMapper.deleteMqttTaskConfigByConfigIds(configIds);
    }

    @Override
    public int deleteMqttTaskConfigByConfigId(Long configId)
    {
        return mqttTaskConfigMapper.deleteMqttTaskConfigByConfigId(configId);
    }

    @Override
    public boolean validateJsonFormat(String content)
    {
        try
        {
            JSON.parse(content);
            return true;
        }
        catch (Exception e)
        {
            log.error("JSON格式验证失败: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public boolean sendConfigToDevices(Long configId, List<String> deviceNames, String username)
    {
        try
        {
            // 查询配置
            MqttTaskConfig config = mqttTaskConfigMapper.selectMqttTaskConfigByConfigId(configId);
            if (config == null)
            {
                log.error("配置不存在: configId={}", configId);
                return false;
            }

            // 前端已直接通过MQTT发送配置，此方法仅记录日志
            log.info("任务配置已通过前端发送到设备: deviceNames={}, configName={}", deviceNames, config.getConfigName());

            return true;
        }
        catch (Exception e)
        {
            log.error("发送配置到设备失败", e);
            return false;
        }
    }
}
