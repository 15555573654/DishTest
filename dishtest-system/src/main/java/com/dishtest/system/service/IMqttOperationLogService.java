package com.dishtest.system.service;

import java.util.List;

import com.dishtest.system.domain.MqttOperationLog;

/**
 * MQTT操作日志服务接口
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public interface IMqttOperationLogService
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
     * 批量删除MQTT操作日志
     * 
     * @param logIds 需要删除的MQTT操作日志ID
     * @return 结果
     */
    public int deleteMqttOperationLogByLogIds(Long[] logIds);

    /**
     * 删除MQTT操作日志信息
     * 
     * @param logId 日志ID
     * @return 结果
     */
    public int deleteMqttOperationLogByLogId(Long logId);

    /**
     * 清空操作日志
     * 
     * @return 结果
     */
    public int cleanMqttOperationLog();

    /**
     * 记录操作日志
     * 
     * @param username 用户名
     * @param operationType 操作类型
     * @param deviceNames 设备名称列表
     * @param operationContent 操作内容
     * @param result 操作结果
     * @param errorMessage 错误信息
     */
    public void logOperation(String username, String operationType, String deviceNames, 
                            String operationContent, String result, String errorMessage);
}
