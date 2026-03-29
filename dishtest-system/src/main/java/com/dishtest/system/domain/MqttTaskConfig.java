package com.dishtest.system.domain;

import com.dishtest.common.annotation.Excel;
import com.dishtest.common.core.domain.BaseEntity;

/**
 * MQTT任务配置对象 mqtt_task_config
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public class MqttTaskConfig extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 配置ID */
    private Long configId;

    /** 配置名称 */
    @Excel(name = "配置名称")
    private String configName;

    /** 配置内容(JSON格式) */
    @Excel(name = "配置内容")
    private String configContent;

    /** 所属用户 */
    @Excel(name = "所属用户")
    private String username;

    public void setConfigId(Long configId) 
    {
        this.configId = configId;
    }

    public Long getConfigId() 
    {
        return configId;
    }

    public void setConfigName(String configName) 
    {
        this.configName = configName;
    }

    public String getConfigName() 
    {
        return configName;
    }

    public void setConfigContent(String configContent) 
    {
        this.configContent = configContent;
    }

    public String getConfigContent() 
    {
        return configContent;
    }

    public void setUsername(String username) 
    {
        this.username = username;
    }

    public String getUsername() 
    {
        return username;
    }

    @Override
    public String toString() {
        return "MqttTaskConfig{" +
                "configId=" + configId +
                ", configName='" + configName + '\'' +
                ", configContent='" + configContent + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
