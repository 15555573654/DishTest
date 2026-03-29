package com.dishtest.system.domain;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.dishtest.common.annotation.Excel;

/**
 * MQTT连接配置对象 mqtt_connection_config
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public class MqttConnectionConfig
{
    private static final long serialVersionUID = 1L;

    /** 配置ID */
    private Long configId;

    /** 用户名 */
    @Excel(name = "用户名")
    private String username;

    /** MQTT服务器地址 */
    @Excel(name = "MQTT服务器地址")
    private String mqttHost;

    /** MQTT服务器端口 */
    @Excel(name = "MQTT服务器端口")
    private Integer mqttPort;

    /** MQTT用户名 */
    @Excel(name = "MQTT用户名")
    private String mqttUsername;

    /** MQTT密码(加密) */
    private String mqttPassword;

    /** 是否启用(0否 1是) */
    @Excel(name = "是否启用", readConverterExp = "0=否,1=是")
    private Integer enabled;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date updateTime;

    public void setConfigId(Long configId) 
    {
        this.configId = configId;
    }

    public Long getConfigId() 
    {
        return configId;
    }

    public void setUsername(String username) 
    {
        this.username = username;
    }

    public String getUsername() 
    {
        return username;
    }

    public void setMqttHost(String mqttHost) 
    {
        this.mqttHost = mqttHost;
    }

    public String getMqttHost() 
    {
        return mqttHost;
    }

    public void setMqttPort(Integer mqttPort) 
    {
        this.mqttPort = mqttPort;
    }

    public Integer getMqttPort() 
    {
        return mqttPort;
    }

    public void setMqttUsername(String mqttUsername) 
    {
        this.mqttUsername = mqttUsername;
    }

    public String getMqttUsername() 
    {
        return mqttUsername;
    }

    public void setMqttPassword(String mqttPassword) 
    {
        this.mqttPassword = mqttPassword;
    }

    public String getMqttPassword() 
    {
        return mqttPassword;
    }

    public void setEnabled(Integer enabled) 
    {
        this.enabled = enabled;
    }

    public Integer getEnabled() 
    {
        return enabled;
    }

    public void setCreateTime(Date createTime) 
    {
        this.createTime = createTime;
    }

    public Date getCreateTime() 
    {
        return createTime;
    }

    public void setUpdateTime(Date updateTime) 
    {
        this.updateTime = updateTime;
    }

    public Date getUpdateTime() 
    {
        return updateTime;
    }

    @Override
    public String toString() {
        return "MqttConnectionConfig{" +
                "configId=" + configId +
                ", username='" + username + '\'' +
                ", mqttHost='" + mqttHost + '\'' +
                ", mqttPort=" + mqttPort +
                ", mqttUsername='" + mqttUsername + '\'' +
                ", enabled=" + enabled +
                ", createTime=" + createTime +
                ", updateTime=" + updateTime +
                '}';
    }
}
