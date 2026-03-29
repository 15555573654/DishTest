package com.dishtest.system.mapper;

import java.util.List;

import com.dishtest.system.domain.MqttTaskConfig;

/**
 * MQTT任务配置Mapper接口
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public interface MqttTaskConfigMapper 
{
    /**
     * 查询MQTT任务配置
     * 
     * @param configId 配置ID
     * @return MQTT任务配置
     */
    public MqttTaskConfig selectMqttTaskConfigByConfigId(Long configId);

    /**
     * 查询MQTT任务配置列表
     * 
     * @param mqttTaskConfig MQTT任务配置
     * @return MQTT任务配置集合
     */
    public List<MqttTaskConfig> selectMqttTaskConfigList(MqttTaskConfig mqttTaskConfig);

    /**
     * 新增MQTT任务配置
     * 
     * @param mqttTaskConfig MQTT任务配置
     * @return 结果
     */
    public int insertMqttTaskConfig(MqttTaskConfig mqttTaskConfig);

    /**
     * 修改MQTT任务配置
     * 
     * @param mqttTaskConfig MQTT任务配置
     * @return 结果
     */
    public int updateMqttTaskConfig(MqttTaskConfig mqttTaskConfig);

    /**
     * 删除MQTT任务配置
     * 
     * @param configId 配置ID
     * @return 结果
     */
    public int deleteMqttTaskConfigByConfigId(Long configId);

    /**
     * 批量删除MQTT任务配置
     * 
     * @param configIds 需要删除的数据ID
     * @return 结果
     */
    public int deleteMqttTaskConfigByConfigIds(Long[] configIds);
}
