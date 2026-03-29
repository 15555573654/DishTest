package com.dishtest.system.service.impl;

import java.util.List;
import com.dishtest.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dishtest.system.mapper.AiPromptConfigMapper;
import com.dishtest.system.domain.AiPromptConfig;
import com.dishtest.system.service.IAiPromptConfigService;

/**
 * AI提示词配置Service业务层处理
 * 
 * @author dishtest
 * @date 2026-02-16
 */
@Service
public class AiPromptConfigServiceImpl implements IAiPromptConfigService 
{
    @Autowired
    private AiPromptConfigMapper aiPromptConfigMapper;

    /**
     * 查询AI提示词配置
     * 
     * @param configId 配置ID
     * @return AI提示词配置
     */
    @Override
    public AiPromptConfig selectAiPromptConfigByConfigId(Long configId)
    {
        return aiPromptConfigMapper.selectAiPromptConfigByConfigId(configId);
    }

    /**
     * 查询AI提示词配置列表
     * 
     * @param aiPromptConfig AI提示词配置
     * @return AI提示词配置
     */
    @Override
    public List<AiPromptConfig> selectAiPromptConfigList(AiPromptConfig aiPromptConfig)
    {
        return aiPromptConfigMapper.selectAiPromptConfigList(aiPromptConfig);
    }

    /**
     * 获取默认提示词
     * 
     * @param aiModel AI模型
     * @return 提示词内容
     */
    @Override
    public String getDefaultPromptContent(String aiModel)
    {
        AiPromptConfig config = aiPromptConfigMapper.selectDefaultPromptConfig(aiModel);
        if (config != null)
        {
            return config.getPromptContent();
        }
        
        // 如果没有找到默认配置,返回系统默认提示词
        return getSystemDefaultPrompt();
    }

    /**
     * 新增AI提示词配置
     * 
     * @param aiPromptConfig AI提示词配置
     * @return 结果
     */
    @Override
    public int insertAiPromptConfig(AiPromptConfig aiPromptConfig)
    {
        aiPromptConfig.setCreateTime(DateUtils.getNowDate());
        
        // 如果设置为默认,取消其他默认配置
        if ("1".equals(aiPromptConfig.getIsDefault()))
        {
            aiPromptConfigMapper.cancelOtherDefault(aiPromptConfig.getAiModel());
        }
        
        return aiPromptConfigMapper.insertAiPromptConfig(aiPromptConfig);
    }

    /**
     * 修改AI提示词配置
     * 
     * @param aiPromptConfig AI提示词配置
     * @return 结果
     */
    @Override
    public int updateAiPromptConfig(AiPromptConfig aiPromptConfig)
    {
        aiPromptConfig.setUpdateTime(DateUtils.getNowDate());
        
        // 如果设置为默认,取消其他默认配置
        if ("1".equals(aiPromptConfig.getIsDefault()))
        {
            aiPromptConfigMapper.cancelOtherDefault(aiPromptConfig.getAiModel());
        }
        
        return aiPromptConfigMapper.updateAiPromptConfig(aiPromptConfig);
    }

    /**
     * 批量删除AI提示词配置
     * 
     * @param configIds 需要删除的配置ID
     * @return 结果
     */
    @Override
    public int deleteAiPromptConfigByConfigIds(Long[] configIds)
    {
        return aiPromptConfigMapper.deleteAiPromptConfigByConfigIds(configIds);
    }

    /**
     * 删除AI提示词配置信息
     * 
     * @param configId 配置ID
     * @return 结果
     */
    @Override
    public int deleteAiPromptConfigByConfigId(Long configId)
    {
        return aiPromptConfigMapper.deleteAiPromptConfigByConfigId(configId);
    }

    /**
     * 获取系统默认提示词
     */
    private String getSystemDefaultPrompt()
    {
        return "你是一个专业的测试工程师，请根据需求文档生成详细的测试用例。\n\n" +
            "请按照以下格式生成测试用例:\n\n" +
            "# 测试用例\n\n" +
            "## 1. 功能测试用例\n\n" +
            "### 测试用例1: [用例名称]\n" +
            "- **用例ID**: TC001\n" +
            "- **测试目标**: [描述测试目标]\n" +
            "- **前置条件**: [列出前置条件]\n" +
            "- **测试步骤**:\n" +
            "  1. [步骤1]\n" +
            "  2. [步骤2]\n" +
            "- **预期结果**: [描述预期结果]\n" +
            "- **优先级**: 高/中/低\n\n" +
            "## 2. 边界值测试用例\n\n" +
            "## 3. 异常测试用例\n\n" +
            "要求:\n" +
            "1. 测试用例要全面覆盖需求文档中的所有功能点\n" +
            "2. 包含正常场景和异常场景\n" +
            "3. 考虑边界值和特殊情况\n" +
            "4. 使用Markdown格式输出";
    }
}
