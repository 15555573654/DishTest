package com.dishtest.system.domain.vo;

/**
 * MQTT设备统计信息
 * 
 * @author ruoyi
 * @date 2025-01-19
 */
public class MqttDeviceStatistics
{
    /** 设备总数 */
    private Integer totalDevices;

    /** 在线设备数 */
    private Integer onlineDevices;

    /** 离线设备数 */
    private Integer offlineDevices;

    /** 钻石总数 */
    private Long totalDiamonds;

    public MqttDeviceStatistics()
    {
    }

    public MqttDeviceStatistics(Integer totalDevices, Integer onlineDevices, Integer offlineDevices, Long totalDiamonds)
    {
        this.totalDevices = totalDevices;
        this.onlineDevices = onlineDevices;
        this.offlineDevices = offlineDevices;
        this.totalDiamonds = totalDiamonds;
    }

    public Integer getTotalDevices()
    {
        return totalDevices;
    }

    public void setTotalDevices(Integer totalDevices)
    {
        this.totalDevices = totalDevices;
    }

    public Integer getOnlineDevices()
    {
        return onlineDevices;
    }

    public void setOnlineDevices(Integer onlineDevices)
    {
        this.onlineDevices = onlineDevices;
    }

    public Integer getOfflineDevices()
    {
        return offlineDevices;
    }

    public void setOfflineDevices(Integer offlineDevices)
    {
        this.offlineDevices = offlineDevices;
    }

    public Long getTotalDiamonds()
    {
        return totalDiamonds;
    }

    public void setTotalDiamonds(Long totalDiamonds)
    {
        this.totalDiamonds = totalDiamonds;
    }

    @Override
    public String toString()
    {
        return "MqttDeviceStatistics{" +
                "totalDevices=" + totalDevices +
                ", onlineDevices=" + onlineDevices +
                ", offlineDevices=" + offlineDevices +
                ", totalDiamonds=" + totalDiamonds +
                '}';
    }
}
