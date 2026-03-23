package com.ruoyi.web.controller.mqtt;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

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

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.domain.MqttDevice;
import com.ruoyi.system.domain.vo.MqttDeviceStatistics;
import com.ruoyi.system.service.IDeviceManagerService;
import com.ruoyi.system.service.IMqttOperationLogService;

/**
 * MQTT设备Controller
 *
 * @author ruoyi
 * @date 2025-01-19
 */
@RestController
@RequestMapping("/mqtt/device")
public class MqttDeviceController extends BaseController
{
    @Autowired
    private IDeviceManagerService deviceManagerService;

    @Autowired
    private IMqttOperationLogService operationLogService;

    /**
     * 查询MQTT设备列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:list')")
    @GetMapping("/list")
    public TableDataInfo list(MqttDevice mqttDevice)
    {
        startPage();
        // 不按用户名过滤，显示所有设备
        // mqttDevice.setUsername(SecurityUtils.getUsername());
        List<MqttDevice> list = deviceManagerService.selectMqttDeviceList(mqttDevice);
        return getDataTable(list);
    }

    /**
     * 导出MQTT设备列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:export')")
    @Log(title = "MQTT设备", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, MqttDevice mqttDevice)
    {
        // 不按用户名过滤，导出所有设备
        // mqttDevice.setUsername(SecurityUtils.getUsername());
        List<MqttDevice> list = deviceManagerService.selectMqttDeviceList(mqttDevice);
        ExcelUtil<MqttDevice> util = new ExcelUtil<>(MqttDevice.class);
        util.exportExcel(response, list, "MQTT设备数据");
    }

    /**
     * 获取MQTT设备详细信息
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:query')")
    @GetMapping(value = "/{deviceId}")
    public AjaxResult getInfo(@PathVariable("deviceId") Long deviceId)
    {
        return success(deviceManagerService.selectMqttDeviceByDeviceId(deviceId));
    }

    /**
     * 新增MQTT设备
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:add')")
    @Log(title = "MQTT设备", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody MqttDevice mqttDevice)
    {
        mqttDevice.setUsername(SecurityUtils.getUsername());
        mqttDevice.setCreateBy(SecurityUtils.getUsername());
        return toAjax(deviceManagerService.insertMqttDevice(mqttDevice));
    }

    /**
     * 修改MQTT设备
     */
    @PreAuthorize("@ss.hasPermi('mqtt:device:edit')")
    @Log(title = "MQTT设备", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody MqttDevice mqttDevice)
    {
        mqttDevice.setUpdateBy(SecurityUtils.getUsername());
        return toAjax(deviceManagerService.updateMqttDevice(mqttDevice));
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

        // 获取设备名称列表
        StringBuilder deviceNames = new StringBuilder();
        for (Long deviceId : deviceIds)
        {
            MqttDevice device = deviceManagerService.selectMqttDeviceByDeviceId(deviceId);
            if (device != null)
            {
                deviceNames.append(device.getDeviceName()).append(",");
            }
        }

        int result = deviceManagerService.deleteMqttDeviceByDeviceIds(deviceIds);

        // 记录操作日志
        operationLogService.logOperation(username, "删除设备", deviceNames.toString(),
                                        "删除设备ID: " + Arrays.toString(deviceIds),
                                        result > 0 ? "成功" : "失败", null);

        return toAjax(result);
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
        // 不按用户名过滤，统计所有设备
        MqttDeviceStatistics statistics = deviceManagerService.getStatistics(null);
        return success(statistics);
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
