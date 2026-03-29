package com.dishtest.system.mapper;

import java.util.List;

import com.dishtest.system.domain.MqttOperationLog;

/**
 * MQTT操作日志Mapper接口
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public interface MqttOperationLogMapper 
{
    /**
     * 查询MQTT操作日志
     * 
     * @param logId 日志ID
     * @return MQTT操作日志
     */
    public MqttOperationLog selectMqttOperationLogByLogId(Long logId);

    /**
     * 查询MQTT操作日志列表
     * 
     * @param mqttOperationLog MQTT操作日志
     * @return MQTT操作日志集合
     */
    public List<MqttOperationLog> selectMqttOperationLogList(MqttOperationLog mqttOperationLog);

    /**
     * 新增MQTT操作日志
     * 
     * @param mqttOperationLog MQTT操作日志
     * @return 结果
     */
    public int insertMqttOperationLog(MqttOperationLog mqttOperationLog);

    /**
     * 修改MQTT操作日志
     * 
     * @param mqttOperationLog MQTT操作日志
     * @return 结果
     */
    public int updateMqttOperationLog(MqttOperationLog mqttOperationLog);

    /**
     * 删除MQTT操作日志
     * 
     * @param logId 日志ID
     * @return 结果
     */
    public int deleteMqttOperationLogByLogId(Long logId);

    /**
     * 批量删除MQTT操作日志
     * 
     * @param logIds 需要删除的数据ID
     * @return 结果
     */
    public int deleteMqttOperationLogByLogIds(Long[] logIds);

    /**
     * 清空操作日志
     * 
     * @return 结果
     */
    public int cleanMqttOperationLog();
}
