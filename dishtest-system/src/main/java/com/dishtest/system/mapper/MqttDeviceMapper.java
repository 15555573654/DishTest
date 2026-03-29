package com.dishtest.system.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.dishtest.system.domain.MqttDevice;

/**
 * MQTT设备Mapper接口
 * 
 * @author dishtest
 * @date 2025-01-19
 */
public interface MqttDeviceMapper 
{
    /**
     * 查询MQTT设备
     * 
     * @param deviceId 设备ID
     * @return MQTT设备
     */
    public MqttDevice selectMqttDeviceByDeviceId(Long deviceId);

    /**
     * 根据设备名称和用户名查询设备
     * 
     * @param deviceName 设备名称
     * @param username 用户名
     * @return MQTT设备
     */
    public MqttDevice selectMqttDeviceByNameAndUsername(@Param("deviceName") String deviceName, @Param("username") String username);

    /**
     * 查询MQTT设备列表
     * 
     * @param mqttDevice MQTT设备
     * @return MQTT设备集合
     */
    public List<MqttDevice> selectMqttDeviceList(MqttDevice mqttDevice);

    /**
     * 新增MQTT设备
     * 
     * @param mqttDevice MQTT设备
     * @return 结果
     */
    public int insertMqttDevice(MqttDevice mqttDevice);

    /**
     * 修改MQTT设备
     * 
     * @param mqttDevice MQTT设备
     * @return 结果
     */
    public int updateMqttDevice(MqttDevice mqttDevice);

    /**
     * 删除MQTT设备
     * 
     * @param deviceId 设备ID
     * @return 结果
     */
    public int deleteMqttDeviceByDeviceId(Long deviceId);

    /**
     * 批量删除MQTT设备
     * 
     * @param deviceIds 需要删除的数据ID
     * @return 结果
     */
    public int deleteMqttDeviceByDeviceIds(Long[] deviceIds);

    /**
     * 统计在线设备数量
     * 
     * @param username 用户名
     * @return 在线设备数量
     */
    public int countOnlineDevices(@Param("username") String username);

    /**
     * 统计钻石总数
     * 
     * @param username 用户名
     * @return 钻石总数
     */
    public Long sumDiamonds(@Param("username") String username);
}
