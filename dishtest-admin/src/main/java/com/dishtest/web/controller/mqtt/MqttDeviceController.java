package com.dishtest.web.controller.mqtt;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.dishtest.common.annotation.Log;
import com.dishtest.common.core.controller.BaseController;
import com.dishtest.common.core.domain.AjaxResult;
import com.dishtest.common.core.page.TableDataInfo;
import com.dishtest.common.enums.BusinessType;
import com.dishtest.common.utils.SecurityUtils;
import com.dishtest.system.domain.MqttDevice;
import com.dishtest.system.service.IMqttOperationLogService;

/**
 * MQTT设备Controller
 *
 * @author dishtest
 * @date 2025-01-19
 */
@RestController
@RequestMapping("/mqtt/device")
public class MqttDeviceController extends BaseController
{
    @Autowired
    private IMqttOperationLogService operationLogService;

    /**
     * 查询MQTT设备列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:list')")
    @GetMapping("/list")
    public TableDataInfo list(MqttDevice mqttDevice)
    {
        return getDataTable(java.util.Collections.emptyList());
    }

    /**
     * 导出MQTT设备列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:export')")
    @Log(title = "MQTT设备", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public AjaxResult export(MqttDevice mqttDevice)
    {
        return error("该接口已停用：设备管理改为仅读取MQTT保留消息，不再使用数据库导出");
    }

    /**
     * 获取MQTT设备详细信息
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:query')")
    @GetMapping(value = "/{deviceId}")
    public AjaxResult getInfo(@PathVariable("deviceId") Long deviceId)
    {
        return error("该接口已停用：设备管理改为仅读取MQTT保留消息，不再查询数据库");
    }

    /**
     * 新增MQTT设备
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:add')")
    @Log(title = "MQTT设备", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody MqttDevice mqttDevice)
    {
        return error("该接口已停用：设备管理改为仅读取MQTT保留消息，不再入库");
    }

    /**
     * 修改MQTT设备
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:edit')")
    @Log(title = "MQTT设备", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody MqttDevice mqttDevice)
    {
        return error("该接口已停用：设备管理改为仅读取MQTT保留消息，不再入库");
    }

    /**
     * 删除MQTT设备
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:remove')")
    @Log(title = "MQTT设备", businessType = BusinessType.DELETE)
    @DeleteMapping("/{deviceIds}")
    public AjaxResult remove(@PathVariable Long[] deviceIds)
    {
        String username = SecurityUtils.getUsername();
        operationLogService.logOperation(username, "删除设备(停用)", "",
                                        "忽略数据库删除请求: " + Arrays.toString(deviceIds),
                                        "成功", null);
        return error("该接口已停用：设备管理改为仅读取MQTT保留消息，不再删除数据库记录");
    }

    /**
     * 发送命令到设备（已废弃，前端直接通过MQTT发送）
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:command')")
    @Log(title = "设备控制", businessType = BusinessType.OTHER)
    @PostMapping("/command")
    public AjaxResult sendCommand(@RequestBody Map<String, Object> params)
    {
        String username = SecurityUtils.getUsername();
        String action = (String) params.get("action");
        @SuppressWarnings("unchecked")
        List<String> deviceNames = (List<String>) params.get("deviceNames");

        if (deviceNames == null || deviceNames.isEmpty())
        {
            return error("请选择设备");
        }

        // 前端已直接通过MQTT发送命令，此接口仅记录日志
        operationLogService.logOperation(username, "设备控制-" + action,
                                        String.join(",", deviceNames),
                                        "操作: " + action, "成功", null);

        return success("命令已发送");
    }

    /**
     * 获取设备统计信息
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:list')")
    @GetMapping("/statistics")
    public AjaxResult getStatistics()
    {
        Map<String, Object> data = new HashMap<>();
        data.put("totalDevices", 0);
        data.put("onlineDevices", 0);
        data.put("offlineDevices", 0);
        data.put("totalDiamonds", 0);
        return success(data);
    }

    /**
     * 批量保存设备数据（从前端MQTT实时数据）
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:edit')")
    @Log(title = "批量保存设备", businessType = BusinessType.UPDATE)
    @PostMapping("/batchSave")
    public AjaxResult batchSave(@RequestBody List<MqttDevice> devices)
    {
        return error("该接口已停用：设备管理改为仅读取MQTT保留消息，不再入库");
    }
}
