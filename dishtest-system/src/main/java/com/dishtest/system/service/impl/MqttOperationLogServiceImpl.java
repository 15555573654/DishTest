package com.dishtest.system.service.impl;

import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.dishtest.system.domain.MqttOperationLog;
import com.dishtest.system.mapper.MqttOperationLogMapper;
import com.dishtest.system.service.IMqttOperationLogService;

/**
 * MQTT操作日志服务实现
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
@Service
public class MqttOperationLogServiceImpl implements IMqttOperationLogService
{
    @Autowired
    private MqttOperationLogMapper mqttOperationLogMapper;

    @Override
    public MqttOperationLog selectMqttOperationLogByLogId(Long logId)
    {
        return mqttOperationLogMapper.selectMqttOperationLogByLogId(logId);
    }

    @Override
    public List<MqttOperationLog> selectMqttOperationLogList(MqttOperationLog mqttOperationLog)
    {
        return mqttOperationLogMapper.selectMqttOperationLogList(mqttOperationLog);
    }

    @Override
    public int insertMqttOperationLog(MqttOperationLog mqttOperationLog)
    {
        mqttOperationLog.setCreateTime(new Date());
        return mqttOperationLogMapper.insertMqttOperationLog(mqttOperationLog);
    }

    @Override
    public int deleteMqttOperationLogByLogIds(Long[] logIds)
    {
        return mqttOperationLogMapper.deleteMqttOperationLogByLogIds(logIds);
    }

    @Override
    public int deleteMqttOperationLogByLogId(Long logId)
    {
        return mqttOperationLogMapper.deleteMqttOperationLogByLogId(logId);
    }

    @Override
    public int cleanMqttOperationLog()
    {
        return mqttOperationLogMapper.cleanMqttOperationLog();
    }

    @Override
    public void logOperation(String username, String operationType, String deviceNames, 
                            String operationContent, String result, String errorMessage)
    {
        MqttOperationLog log = new MqttOperationLog();
        log.setUsername(username);
        log.setOperationType(operationType);
        log.setDeviceNames(deviceNames);
        log.setOperationContent(operationContent);
        log.setResult(result);
        log.setErrorMessage(errorMessage);
        
        insertMqttOperationLog(log);
    }
}
