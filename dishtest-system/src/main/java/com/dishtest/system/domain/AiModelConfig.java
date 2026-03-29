package com.dishtest.system.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.dishtest.common.annotation.Excel;
import com.dishtest.common.core.domain.BaseEntity;

/**
 * AI模型配置对象 ai_model_config
 * 
 * @author ruoyi
 * @date 2026-02-16
 */
public class AiModelConfig extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 模型ID */
    private Long modelId;

    /** 模型名称 */
    @Excel(name = "模型名称")
    private String modelName;

    /** 模型类型 */
    @Excel(name = "模型类型")
    private String modelType;

    /** API地址 */
    @Excel(name = "API地址")
    private String apiUrl;

    /** API密钥 */
    private String apiKey;

    /** 模型版本 */
    @Excel(name = "模型版本")
    private String modelVersion;

    /** 最大token数 */
    @Excel(name = "最大token数")
    private Integer maxTokens;

    /** 温度参数 */
    @Excel(name = "温度参数")
    private BigDecimal temperature;

    /** 是否默认 */
    @Excel(name = "是否默认")
    private String isDefault;

    /** 状态 */
    @Excel(name = "状态")
    private String status;

    /** 是否支持温度参数 */
    @Excel(name = "是否支持温度参数")
    private String supportTemperature;

    public void setModelId(Long modelId) 
    {
        this.modelId = modelId;
    }

    public Long getModelId() 
    {
        return modelId;
    }

    public void setModelName(String modelName) 
    {
        this.modelName = modelName;
    }

    public String getModelName() 
    {
        return modelName;
    }

    public void setModelType(String modelType) 
    {
        this.modelType = modelType;
    }

    public String getModelType() 
    {
        return modelType;
    }

    public void setApiUrl(String apiUrl) 
    {
        this.apiUrl = apiUrl;
    }

    public String getApiUrl() 
    {
        return apiUrl;
    }

    public void setApiKey(String apiKey) 
    {
        this.apiKey = apiKey;
    }

    public String getApiKey() 
    {
        return apiKey;
    }

    public void setModelVersion(String modelVersion) 
    {
        this.modelVersion = modelVersion;
    }

    public String getModelVersion() 
    {
        return modelVersion;
    }

    public void setMaxTokens(Integer maxTokens) 
    {
        this.maxTokens = maxTokens;
    }

    public Integer getMaxTokens() 
    {
        return maxTokens;
    }

    public void setTemperature(BigDecimal temperature) 
    {
        this.temperature = temperature;
    }

    public BigDecimal getTemperature() 
    {
        return temperature;
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

    public void setSupportTemperature(String supportTemperature) 
    {
        this.supportTemperature = supportTemperature;
    }

    public String getSupportTemperature() 
    {
        return supportTemperature;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("modelId", getModelId())
            .append("modelName", getModelName())
            .append("modelType", getModelType())
            .append("apiUrl", getApiUrl())
            .append("apiKey", getApiKey())
            .append("modelVersion", getModelVersion())
            .append("maxTokens", getMaxTokens())
            .append("temperature", getTemperature())
            .append("isDefault", getIsDefault())
            .append("status", getStatus())
            .append("supportTemperature", getSupportTemperature())
            .append("remark", getRemark())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}
