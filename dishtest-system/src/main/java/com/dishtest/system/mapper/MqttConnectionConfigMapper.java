package com.dishtest.system.mapper;

import java.util.List;

import com.dishtest.system.domain.MqttConnectionConfig;

/**
 * MQTT连接配置Mapper接口
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
public interface MqttConnectionConfigMapper 
{
    /**
     * 查询MQTT连接配置
     * 
     * @param configId 配置ID
     * @return MQTT连接配置
     */
    public MqttConnectionConfig selectMqttConnectionConfigByConfigId(Long configId);

    /**
     * 根据用户名查询MQTT连接配置
     * 
     * @param username 用户名
     * @return MQTT连接配置
     */
    public MqttConnectionConfig selectMqttConnectionConfigByUsername(String username);

    /**
     * 查询MQTT连接配置列表
     * 
     * @param mqttConnectionConfig MQTT连接配置
     * @return MQTT连接配置集合
     */
    public List<MqttConnectionConfig> selectMqttConnectionConfigList(MqttConnectionConfig mqttConnectionConfig);

    /**
     * 新增MQTT连接配置
     * 
     * @param mqttConnectionConfig MQTT连接配置
     * @return 结果
     */
    public int insertMqttConnectionConfig(MqttConnectionConfig mqttConnectionConfig);

    /**
     * 修改MQTT连接配置
     * 
     * @param mqttConnectionConfig MQTT连接配置
     * @return 结果
     */
    public int updateMqttConnectionConfig(MqttConnectionConfig mqttConnectionConfig);

    /**
     * 删除MQTT连接配置
     * 
     * @param configId 配置ID
     * @return 结果
     */
    public int deleteMqttConnectionConfigByConfigId(Long configId);

    /**
     * 批量删除MQTT连接配置
     * 
     * @param configIds 需要删除的数据ID
     * @return 结果
     */
    public int deleteMqttConnectionConfigByConfigIds(Long[] configIds);
}
