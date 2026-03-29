package com.dishtest.web.controller.aitest;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.dishtest.common.annotation.Log;
import com.dishtest.common.core.controller.BaseController;
import com.dishtest.common.core.domain.AjaxResult;
import com.dishtest.common.enums.BusinessType;
import com.dishtest.system.domain.AiModelConfig;
import com.dishtest.system.service.IAiModelConfigService;
import com.dishtest.common.utils.poi.ExcelUtil;
import com.dishtest.common.core.page.TableDataInfo;

/**
 * AI模型配置Controller
 * 
 * @author dishtest
 * @date 2026-02-16
 */
@RestController
@RequestMapping("/aitest/modelconfig")
public class AiModelConfigController extends BaseController
{
    @Autowired
    private IAiModelConfigService aiModelConfigService;

    /**
     * 查询AI模型配置列表
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:list')")
    @GetMapping("/list")
    public TableDataInfo list(AiModelConfig aiModelConfig)
    {
        startPage();
        List<AiModelConfig> list = aiModelConfigService.selectAiModelConfigList(aiModelConfig);
        return getDataTable(list);
    }

    /**
     * 导出AI模型配置列表
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:export')")
    @Log(title = "AI模型配置", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, AiModelConfig aiModelConfig)
    {
        List<AiModelConfig> list = aiModelConfigService.selectAiModelConfigList(aiModelConfig);
        ExcelUtil<AiModelConfig> util = new ExcelUtil<AiModelConfig>(AiModelConfig.class);
        util.exportExcel(response, list, "AI模型配置数据");
    }

    /**
     * 获取AI模型配置详细信息
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:query')")
    @GetMapping(value = "/{modelId}")
    public AjaxResult getInfo(@PathVariable("modelId") Long modelId)
    {
        return success(aiModelConfigService.selectAiModelConfigByModelId(modelId));
    }

    /**
     * 新增AI模型配置
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:add')")
    @Log(title = "AI模型配置", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody AiModelConfig aiModelConfig)
    {
        return toAjax(aiModelConfigService.insertAiModelConfig(aiModelConfig));
    }

    /**
     * 修改AI模型配置
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:edit')")
    @Log(title = "AI模型配置", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody AiModelConfig aiModelConfig)
    {
        return toAjax(aiModelConfigService.updateAiModelConfig(aiModelConfig));
    }

    /**
     * 删除AI模型配置
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:remove')")
    @Log(title = "AI模型配置", businessType = BusinessType.DELETE)
	@DeleteMapping("/{modelIds}")
    public AjaxResult remove(@PathVariable Long[] modelIds)
    {
        return toAjax(aiModelConfigService.deleteAiModelConfigByModelIds(modelIds));
    }

    /**
     * 测试模型连接
     */
    @PreAuthorize("@ss.hasPermi('aitest:modelconfig:edit')")
    @Log(title = "测试模型连接", businessType = BusinessType.OTHER)
    @PostMapping("/testConnection")
    public AjaxResult testConnection(@RequestBody AiModelConfig aiModelConfig)
    {
        String result = aiModelConfigService.testConnection(aiModelConfig);
        return AjaxResult.success(result);
    }
}
