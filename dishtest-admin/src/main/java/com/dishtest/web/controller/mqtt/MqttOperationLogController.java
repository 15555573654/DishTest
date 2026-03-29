package com.dishtest.web.controller.mqtt;

import java.util.List;
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
import com.dishtest.system.domain.MqttOperationLog;
import com.dishtest.system.service.IMqttOperationLogService;

/**
 * MQTT操作日志Controller
 * 
 * @author dishtest
 * @date 2025-01-19
 */
@RestController
@RequestMapping("/mqtt/log")
public class MqttOperationLogController extends BaseController
{
    @Autowired
    private IMqttOperationLogService mqttOperationLogService;

    /**
     * 查询MQTT操作日志列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:log:list')")
    @GetMapping("/list")
    public TableDataInfo list(MqttOperationLog mqttOperationLog)
    {
        startPage();
        mqttOperationLog.setUsername(SecurityUtils.getUsername());
        List<MqttOperationLog> list = mqttOperationLogService.selectMqttOperationLogList(mqttOperationLog);
        return getDataTable(list);
    }

    /**
     * 导出MQTT操作日志列表
     */
    @PreAuthorize("@ss.hasPermi('mqtt:log:export')")
    @Log(title = "MQTT操作日志", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, MqttOperationLog mqttOperationLog)
    {
        mqttOperationLog.setUsername(SecurityUtils.getUsername());
        List<MqttOperationLog> list = mqttOperationLogService.selectMqttOperationLogList(mqttOperationLog);
        ExcelUtil<MqttOperationLog> util = new ExcelUtil<MqttOperationLog>(MqttOperationLog.class);
        util.exportExcel(response, list, "MQTT操作日志数据");
    }

    /**
     * 获取MQTT操作日志详细信息
     */
    @PreAuthorize("@ss.hasPermi('mqtt:log:query')")
    @GetMapping(value = "/{logId}")
    public AjaxResult getInfo(@PathVariable("logId") Long logId)
    {
        return success(mqttOperationLogService.selectMqttOperationLogByLogId(logId));
    }

    /**
     * 删除MQTT操作日志
     */
    @PreAuthorize("@ss.hasPermi('mqtt:log:remove')")
    @Log(title = "MQTT操作日志", businessType = BusinessType.DELETE)
    @DeleteMapping("/{logIds}")
    public AjaxResult remove(@PathVariable Long[] logIds)
    {
        return toAjax(mqttOperationLogService.deleteMqttOperationLogByLogIds(logIds));
    }

    /**
     * 清空MQTT操作日志
     */
    @PreAuthorize("@ss.hasPermi('mqtt:log:remove')")
    @Log(title = "MQTT操作日志", businessType = BusinessType.CLEAN)
    @DeleteMapping("/clean")
    public AjaxResult clean()
    {
        mqttOperationLogService.cleanMqttOperationLog();
        return success();
    }
}
