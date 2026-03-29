package com.dishtest.system.mapper;

import java.util.List;
import com.dishtest.system.domain.AiPromptConfig;

/**
 * AI提示词配置Mapper接口
 * 
 * @author dishtest
 * @date 2026-02-16
 */
public interface AiPromptConfigMapper 
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
     * 查询默认提示词配置
     * 
     * @param aiModel AI模型
     * @return AI提示词配置
     */
    public AiPromptConfig selectDefaultPromptConfig(String aiModel);

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
     * 删除AI提示词配置
     * 
     * @param configId 配置ID
     * @return 结果
     */
    public int deleteAiPromptConfigByConfigId(Long configId);

    /**
     * 批量删除AI提示词配置
     * 
     * @param configIds 需要删除的数据ID
     * @return 结果
     */
    public int deleteAiPromptConfigByConfigIds(Long[] configIds);

    /**
     * 取消其他默认配置
     * 
     * @param aiModel AI模型
     * @return 结果
     */
    public int cancelOtherDefault(String aiModel);
}
