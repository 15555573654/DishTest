package com.dishtest.system.domain;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.dishtest.common.annotation.Excel;
import com.dishtest.common.core.domain.BaseEntity;

/**
 * MQTT设备对象 mqtt_device
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public class MqttDevice extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 设备ID */
    private Long deviceId;

    /** 设备名称 */
    @Excel(name = "设备名称")
    private String deviceName;

    /** 所属用户 */
    @Excel(name = "所属用户")
    private String username;

    /** 设备状态(在线/离线) */
    @Excel(name = "设备状态")
    private String deviceStatus;

    /** 脚本状态(运行中/未运行/暂停) */
    @Excel(name = "脚本状态")
    private String scriptStatus;

    /** 等级 */
    @Excel(name = "等级")
    private String level;

    /** 区服 */
    @Excel(name = "区服")
    private String server;

    /** 钻石数量 */
    @Excel(name = "钻石数量")
    private String diamonds;

    /** 任务配置名称 */
    @Excel(name = "任务配置")
    private String taskConfig;

    /** 最后在线时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "最后在线时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date lastOnline;

    public void setDeviceId(Long deviceId) 
    {
        this.deviceId = deviceId;
    }

    public Long getDeviceId() 
    {
        return deviceId;
    }

    public void setDeviceName(String deviceName) 
    {
        this.deviceName = deviceName;
    }

    public String getDeviceName() 
    {
        return deviceName;
    }

    public void setUsername(String username) 
    {
        this.username = username;
    }

    public String getUsername() 
    {
        return username;
    }

    public void setDeviceStatus(String deviceStatus) 
    {
        this.deviceStatus = deviceStatus;
    }

    public String getDeviceStatus() 
    {
        return deviceStatus;
    }

    public void setScriptStatus(String scriptStatus) 
    {
        this.scriptStatus = scriptStatus;
    }

    public String getScriptStatus() 
    {
        return scriptStatus;
    }

    public void setLevel(String level) 
    {
        this.level = level;
    }

    public String getLevel() 
    {
        return level;
    }

    public void setServer(String server) 
    {
        this.server = server;
    }

    public String getServer() 
    {
        return server;
    }

    public void setDiamonds(String diamonds) 
    {
        this.diamonds = diamonds;
    }

    public String getDiamonds() 
    {
        return diamonds;
    }

    public void setTaskConfig(String taskConfig) 
    {
        this.taskConfig = taskConfig;
    }

    public String getTaskConfig() 
    {
        return taskConfig;
    }

    public void setLastOnline(Date lastOnline) 
    {
        this.lastOnline = lastOnline;
    }

    public Date getLastOnline() 
    {
        return lastOnline;
    }

    @Override
    public String toString() {
        return "MqttDevice{" +
                "deviceId=" + deviceId +
                ", deviceName='" + deviceName + '\'' +
                ", username='" + username + '\'' +
                ", deviceStatus='" + deviceStatus + '\'' +
                ", scriptStatus='" + scriptStatus + '\'' +
                ", level='" + level + '\'' +
                ", server='" + server + '\'' +
                ", diamonds='" + diamonds + '\'' +
                ", taskConfig='" + taskConfig + '\'' +
                ", lastOnline=" + lastOnline +
                '}';
    }
}
