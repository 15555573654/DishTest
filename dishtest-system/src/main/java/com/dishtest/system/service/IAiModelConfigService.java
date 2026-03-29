package com.dishtest.system.service;

import java.util.List;
import com.dishtest.system.domain.AiModelConfig;

/**
 * AI模型配置Service接口
 * 
 * @author ruoyi
 * @date 2026-02-16
 */
public interface IAiModelConfigService 
{
    /**
     * 查询AI模型配置
     * 
     * @param modelId 模型ID
     * @return AI模型配置
     */
    public AiModelConfig selectAiModelConfigByModelId(Long modelId);

    /**
     * 查询AI模型配置列表
     * 
     * @param aiModelConfig AI模型配置
     * @return AI模型配置集合
     */
    public List<AiModelConfig> selectAiModelConfigList(AiModelConfig aiModelConfig);

    /**
     * 获取默认模型配置
     * 
     * @param modelType 模型类型
     * @return AI模型配置
     */
    public AiModelConfig getDefaultModelConfig(String modelType);

    /**
     * 新增AI模型配置
     * 
     * @param aiModelConfig AI模型配置
     * @return 结果
     */
    public int insertAiModelConfig(AiModelConfig aiModelConfig);

    /**
     * 修改AI模型配置
     * 
     * @param aiModelConfig AI模型配置
     * @return 结果
     */
    public int updateAiModelConfig(AiModelConfig aiModelConfig);

    /**
     * 批量删除AI模型配置
     * 
     * @param modelIds 需要删除的模型ID
     * @return 结果
     */
    public int deleteAiModelConfigByModelIds(Long[] modelIds);

    /**
     * 删除AI模型配置信息
     * 
     * @param modelId 模型ID
     * @return 结果
     */
    public int deleteAiModelConfigByModelId(Long modelId);

    /**
     * 测试模型连接
     * 
     * @param aiModelConfig AI模型配置
     * @return 测试结果（包含是否支持temperature等信息）
     */
    public String testConnection(AiModelConfig aiModelConfig);
}
