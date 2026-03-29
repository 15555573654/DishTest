package com.dishtest.system.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.dishtest.common.annotation.Excel;
import com.dishtest.common.core.domain.BaseEntity;

/**
 * AI提示词配置对象 ai_prompt_config
 * 
 * @author dishtest
 * @date 2026-02-16
 */
public class AiPromptConfig extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 配置ID */
    private Long configId;

    /** 配置名称 */
    @Excel(name = "配置名称")
    private String configName;

    /** 提示词内容 */
    @Excel(name = "提示词内容")
    private String promptContent;

    /** 适用的AI模型 */
    @Excel(name = "适用的AI模型")
    private String aiModel;

    /** 是否默认 */
    @Excel(name = "是否默认")
    private String isDefault;

    /** 状态 */
    @Excel(name = "状态")
    private String status;

    public void setConfigId(Long configId) 
    {
        this.configId = configId;
    }

    public Long getConfigId() 
    {
        return configId;
    }

    public void setConfigName(String configName) 
    {
        this.configName = configName;
    }

    public String getConfigName() 
    {
        return configName;
    }

    public void setPromptContent(String promptContent) 
    {
        this.promptContent = promptContent;
    }

    public String getPromptContent() 
    {
        return promptContent;
    }

    public void setAiModel(String aiModel) 
    {
        this.aiModel = aiModel;
    }

    public String getAiModel() 
    {
        return aiModel;
    }

    public void setIsDefault(String isDefault) 
    {
        this.isDefault = isDefault;
    }

    public String getIsDefault() 
    {
        return isDefault;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("configId", getConfigId())
            .append("configName", getConfigName())
            .append("promptContent", getPromptContent())
            .append("aiModel", getAiModel())
            .append("isDefault", getIsDefault())
            .append("status", getStatus())
            .append("remark", getRemark())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}
