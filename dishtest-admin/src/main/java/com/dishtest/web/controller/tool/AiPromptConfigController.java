package com.dishtest.web.controller.tool;

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
import com.dishtest.system.domain.AiPromptConfig;
import com.dishtest.system.service.IAiPromptConfigService;
import com.dishtest.common.utils.poi.ExcelUtil;
import com.dishtest.common.core.page.TableDataInfo;

/**
 * AI提示词配置Controller
 * 
 * @author ruoyi
 * @date 2026-02-16
 */
@RestController
@RequestMapping("/aitest/promptconfig")
public class AiPromptConfigController extends BaseController
{
    @Autowired
    private IAiPromptConfigService aiPromptConfigService;

    /**
     * 查询AI提示词配置列表
     */
    @PreAuthorize("@ss.hasPermi('aitest:promptconfig:list')")
    @GetMapping("/list")
    public TableDataInfo list(AiPromptConfig aiPromptConfig)
    {
        startPage();
        List<AiPromptConfig> list = aiPromptConfigService.selectAiPromptConfigList(aiPromptConfig);
        return getDataTable(list);
    }

    /**
     * 导出AI提示词配置列表
     */
    @PreAuthorize("@ss.hasPermi('aitest:promptconfig:export')")
    @Log(title = "AI提示词配置", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, AiPromptConfig aiPromptConfig)
    {
        List<AiPromptConfig> list = aiPromptConfigService.selectAiPromptConfigList(aiPromptConfig);
        ExcelUtil<AiPromptConfig> util = new ExcelUtil<AiPromptConfig>(AiPromptConfig.class);
        util.exportExcel(response, list, "AI提示词配置数据");
    }

    /**
     * 获取AI提示词配置详细信息
     */
    @PreAuthorize("@ss.hasPermi('aitest:promptconfig:query')")
    @GetMapping(value = "/{configId}")
    public AjaxResult getInfo(@PathVariable("configId") Long configId)
    {
        return success(aiPromptConfigService.selectAiPromptConfigByConfigId(configId));
    }

    /**
     * 新增AI提示词配置
     */
    @PreAuthorize("@ss.hasPermi('aitest:promptconfig:add')")
    @Log(title = "AI提示词配置", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody AiPromptConfig aiPromptConfig)
    {
        return toAjax(aiPromptConfigService.insertAiPromptConfig(aiPromptConfig));
    }

    /**
     * 修改AI提示词配置
     */
    @PreAuthorize("@ss.hasPermi('aitest:promptconfig:edit')")
    @Log(title = "AI提示词配置", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody AiPromptConfig aiPromptConfig)
    {
        return toAjax(aiPromptConfigService.updateAiPromptConfig(aiPromptConfig));
    }

    /**
     * 删除AI提示词配置
     */
    @PreAuthorize("@ss.hasPermi('aitest:promptconfig:remove')")
    @Log(title = "AI提示词配置", businessType = BusinessType.DELETE)
	@DeleteMapping("/{configIds}")
    public AjaxResult remove(@PathVariable Long[] configIds)
    {
        return toAjax(aiPromptConfigService.deleteAiPromptConfigByConfigIds(configIds));
    }
}
