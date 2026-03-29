package com.dishtest.system.service;

import java.util.List;

import com.dishtest.system.domain.MqttTaskConfig;

/**
 * MQTT任务配置服务接口
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public interface IMqttTaskConfigService
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
     * 批量删除MQTT任务配置
     * 
     * @param configIds 需要删除的MQTT任务配置ID
     * @return 结果
     */
    public int deleteMqttTaskConfigByConfigIds(Long[] configIds);

    /**
     * 删除MQTT任务配置信息
     * 
     * @param configId 配置ID
     * @return 结果
     */
    public int deleteMqttTaskConfigByConfigId(Long configId);

    /**
     * 验证JSON格式
     * 
     * @param content JSON内容
     * @return 是否有效
     */
    public boolean validateJsonFormat(String content);

    /**
     * 发送配置到设备
     * 
     * @param configId 配置ID
     * @param deviceNames 设备名称列表
     * @param username 用户名
     * @return 结果
     */
    public boolean sendConfigToDevices(Long configId, List<String> deviceNames, String username);
}
