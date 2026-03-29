package com.dishtest.system.mapper;

import java.util.List;
import com.dishtest.system.domain.AiModelConfig;

/**
 * AI模型配置Mapper接口
 * 
 * @author ruoyi
 * @date 2026-02-16
 */
public interface AiModelConfigMapper 
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
     * 查询默认模型配置
     * 
     * @param modelType 模型类型
     * @return AI模型配置
     */
    public AiModelConfig selectDefaultModelConfig(String modelType);

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
     * 删除AI模型配置
     * 
     * @param modelId 模型ID
     * @return 结果
     */
    public int deleteAiModelConfigByModelId(Long modelId);

    /**
     * 批量删除AI模型配置
     * 
     * @param modelIds 需要删除的数据ID
     * @return 结果
     */
    public int deleteAiModelConfigByModelIds(Long[] modelIds);

    /**
     * 取消其他默认配置
     * 
     * @param modelType 模型类型
     * @return 结果
     */
    public int cancelOtherDefault(String modelType);
}
