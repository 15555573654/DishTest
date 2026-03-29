package com.dishtest.web.controller.mqtt;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.dishtest.common.annotation.Log;
import com.dishtest.common.core.controller.BaseController;
import com.dishtest.common.core.domain.AjaxResult;
import com.dishtest.common.core.page.TableDataInfo;
import com.dishtest.common.enums.BusinessType;
import com.dishtest.common.utils.SecurityUtils;
import com.dishtest.common.utils.poi.ExcelUtil;
import com.dishtest.system.domain.MqttTaskConfig;
import com.dishtest.system.service.IMqttTaskConfigService;
import com.dishtest.system.service.IMqttOperationLogService;

/**
 * MQTT任务配置Controller
 * 
 * @author dishtest
 * @date 2025-01-19
 */
@RestController
@RequestMapping("/mqtt/config")
public class MqttTaskConfigController extends BaseController
{
    @Autowired
    private IMqttTaskConfigService mqttTaskConfigService;

    @Autowired
    private IMqttOperationLogService operationLogService;

    /**
     * 查询MQTT任务配置列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:list')")
    @GetMapping("/list")
    public TableDataInfo list(MqttTaskConfig mqttTaskConfig)
    {
        startPage();
        mqttTaskConfig.setUsername(SecurityUtils.getUsername());
        List<MqttTaskConfig> list = mqttTaskConfigService.selectMqttTaskConfigList(mqttTaskConfig);
        return getDataTable(list);
    }

    /**
     * 导出MQTT任务配置列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:export')")
    @Log(title = "MQTT任务配置", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, MqttTaskConfig mqttTaskConfig)
    {
        mqttTaskConfig.setUsername(SecurityUtils.getUsername());
        List<MqttTaskConfig> list = mqttTaskConfigService.selectMqttTaskConfigList(mqttTaskConfig);
        ExcelUtil<MqttTaskConfig> util = new ExcelUtil<MqttTaskConfig>(MqttTaskConfig.class);
        util.exportExcel(response, list, "MQTT任务配置数据");
    }

    /**
     * 获取MQTT任务配置详细信息
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:query')")
    @GetMapping(value = "/{configId}")
    public AjaxResult getInfo(@PathVariable("configId") Long configId)
    {
        return success(mqttTaskConfigService.selectMqttTaskConfigByConfigId(configId));
    }

    /**
     * 新增MQTT任务配置
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:add')")
    @Log(title = "MQTT任务配置", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody MqttTaskConfig mqttTaskConfig)
    {
        mqttTaskConfig.setUsername(SecurityUtils.getUsername());
        mqttTaskConfig.setCreateBy(SecurityUtils.getUsername());
        
        // 验证JSON格式
        if (!mqttTaskConfigService.validateJsonFormat(mqttTaskConfig.getConfigContent()))
        {
            return error("配置内容不是有效的JSON格式");
        }
        
        return toAjax(mqttTaskConfigService.insertMqttTaskConfig(mqttTaskConfig));
    }

    /**
     * 修改MQTT任务配置
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:edit')")
    @Log(title = "MQTT任务配置", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody MqttTaskConfig mqttTaskConfig)
    {
        mqttTaskConfig.setUpdateBy(SecurityUtils.getUsername());
        
        // 验证JSON格式
        if (!mqttTaskConfigService.validateJsonFormat(mqttTaskConfig.getConfigContent()))
        {
            return error("配置内容不是有效的JSON格式");
        }
        
        return toAjax(mqttTaskConfigService.updateMqttTaskConfig(mqttTaskConfig));
    }

    /**
     * 删除MQTT任务配置
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:remove')")
    @Log(title = "MQTT任务配置", businessType = BusinessType.DELETE)
    @DeleteMapping("/{configIds}")
    public AjaxResult remove(@PathVariable Long[] configIds)
    {
        return toAjax(mqttTaskConfigService.deleteMqttTaskConfigByConfigIds(configIds));
    }

    /**
     * 发送配置到设备
     */
    @PreAuthorize("@ss.hasPermi('mqtt:config:send')")
    @Log(title = "下发任务配置", businessType = BusinessType.OTHER)
    @PostMapping("/send")
    public AjaxResult sendConfig(@RequestBody Map<String, Object> params)
    {
        String username = SecurityUtils.getUsername();
        Long configId = Long.valueOf(params.get("configId").toString());
        @SuppressWarnings("unchecked")
        List<String> deviceNames = (List<String>) params.get("deviceNames");

        if (deviceNames == null || deviceNames.isEmpty())
        {
            return error("请选择设备");
        }

        boolean success = mqttTaskConfigService.sendConfigToDevices(configId, deviceNames, username);

        // 记录操作日志
        MqttTaskConfig config = mqttTaskConfigService.selectMqttTaskConfigByConfigId(configId);
        String configName = config != null ? config.getConfigName() : "未知配置";
        operationLogService.logOperation(username, "下发任务配置", 
                                        String.join(",", deviceNames), 
                                        "配置: " + configName, 
                                        success ? "成功" : "失败", null);

        if (success)
        {
            return success("配置发送成功");
        }
        else
        {
            return error("配置发送失败");
        }
    }

    /**
     * 验证JSON格式
     */
    @PostMapping("/validateJson")
    public AjaxResult validateJson(@RequestBody Map<String, String> params)
    {
        String content = params.get("content");
        boolean valid = mqttTaskConfigService.validateJsonFormat(content);
        
        if (valid)
        {
            return success("JSON格式正确");
        }
        else
        {
            return error("JSON格式错误");
        }
    }
}
