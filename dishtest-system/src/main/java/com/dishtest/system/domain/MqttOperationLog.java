package com.dishtest.system.domain;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.dishtest.common.annotation.Excel;
import com.dishtest.common.core.domain.BaseEntity;

/**
 * MQTT操作日志对象 mqtt_operation_log
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
public class MqttOperationLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 日志ID */
    @Excel(name = "日志ID")
    private Long logId;

    /** 操作用户 */
    @Excel(name = "操作用户")
    private String username;

    /** 操作类型 */
    @Excel(name = "操作类型")
    private String operationType;

    /** 设备名称列表 */
    @Excel(name = "设备名称")
    private String deviceNames;

    /** 操作内容 */
    @Excel(name = "操作内容")
    private String operationContent;

    /** 操作结果(成功/失败) */
    @Excel(name = "操作结果")
    private String result;

    /** 错误信息 */
    @Excel(name = "错误信息")
    private String errorMessage;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "创建时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    public void setLogId(Long logId) 
    {
        this.logId = logId;
    }

    public Long getLogId() 
    {
        return logId;
    }

    public void setUsername(String username) 
    {
        this.username = username;
    }

    public String getUsername() 
    {
        return username;
    }

    public void setOperationType(String operationType) 
    {
        this.operationType = operationType;
    }

    public String getOperationType() 
    {
        return operationType;
    }

    public void setDeviceNames(String deviceNames) 
    {
        this.deviceNames = deviceNames;
    }

    public String getDeviceNames() 
    {
        return deviceNames;
    }

    public void setOperationContent(String operationContent) 
    {
        this.operationContent = operationContent;
    }

    public String getOperationContent() 
    {
        return operationContent;
    }

    public void setResult(String result) 
    {
        this.result = result;
    }

    public String getResult() 
    {
        return result;
    }

    public void setErrorMessage(String errorMessage) 
    {
        this.errorMessage = errorMessage;
    }

    public String getErrorMessage() 
    {
        return errorMessage;
    }

    public void setCreateTime(Date createTime) 
    {
        this.createTime = createTime;
    }

    public Date getCreateTime() 
    {
        return createTime;
    }

    @Override
    public String toString() {
        return "MqttOperationLog{" +
                "logId=" + logId +
                ", username='" + username + '\'' +
                ", operationType='" + operationType + '\'' +
                ", deviceNames='" + deviceNames + '\'' +
                ", operationContent='" + operationContent + '\'' +
                ", result='" + result + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                ", createTime=" + createTime +
                '}';
    }
}
