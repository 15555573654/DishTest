package com.dishtest.system.service;

import java.util.List;
import com.dishtest.system.domain.AiPromptConfig;

/**
 * AI提示词配置Service接口
 * 
 * @author dishtest
 * @date 2026-02-16
 */
public interface IAiPromptConfigService 
{
    /**
     * 查询AI提示词配置
     * 
     * @param configId 配置ID
     * @return AI提示词配置
     */
    public AiPromptConfig selectAiPromptConfigByConfigId(Long configId);

    /**
     * 查询AI提示词配置列表
     * 
     * @param aiPromptConfig AI提示词配置
     * @return AI提示词配置集合
     */
    public List<AiPromptConfig> selectAiPromptConfigList(AiPromptConfig aiPromptConfig);

    /**
     * 获取默认提示词
     * 
     * @param aiModel AI模型
     * @return 提示词内容
     */
    public String getDefaultPromptContent(String aiModel);

    /**
     * 新增AI提示词配置
     * 
     * @param aiPromptConfig AI提示词配置
     * @return 结果
     */
    public int insertAiPromptConfig(AiPromptConfig aiPromptConfig);

    /**
     * 修改AI提示词配置
     * 
     * @param aiPromptConfig AI提示词配置
     * @return 结果
     */
    public int updateAiPromptConfig(AiPromptConfig aiPromptConfig);

    /**
     * 批量删除AI提示词配置
     * 
     * @param configIds 需要删除的配置ID
     * @return 结果
     */
    public int deleteAiPromptConfigByConfigIds(Long[] configIds);

    /**
     * 删除AI提示词配置信息
     * 
     * @param configId 配置ID
     * @return 结果
     */
    public int deleteAiPromptConfigByConfigId(Long configId);
}
