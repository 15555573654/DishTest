package com.dishtest.system.service.impl;

import java.util.List;
import com.dishtest.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.dishtest.system.mapper.AiModelConfigMapper;
import com.dishtest.system.domain.AiModelConfig;
import com.dishtest.system.service.IAiModelConfigService;

/**
 * AI模型配置Service业务层处理
 * 
 * @author dishtest
 * @date 2026-02-16
 */
@Service
public class AiModelConfigServiceImpl implements IAiModelConfigService 
{
    @Autowired
    private AiModelConfigMapper aiModelConfigMapper;

    /**
     * 查询AI模型配置
     * 
     * @param modelId 模型ID
     * @return AI模型配置
     */
    @Override
    public AiModelConfig selectAiModelConfigByModelId(Long modelId)
    {
        return aiModelConfigMapper.selectAiModelConfigByModelId(modelId);
    }

    /**
     * 查询AI模型配置列表
     * 
     * @param aiModelConfig AI模型配置
     * @return AI模型配置
     */
    @Override
    public List<AiModelConfig> selectAiModelConfigList(AiModelConfig aiModelConfig)
    {
        return aiModelConfigMapper.selectAiModelConfigList(aiModelConfig);
    }

    /**
     * 获取默认模型配置
     * 
     * @param modelType 模型类型
     * @return AI模型配置
     */
    @Override
    public AiModelConfig getDefaultModelConfig(String modelType)
    {
        return aiModelConfigMapper.selectDefaultModelConfig(modelType);
    }

    /**
     * 新增AI模型配置
     * 
     * @param aiModelConfig AI模型配置
     * @return 结果
     */
    @Override
    public int insertAiModelConfig(AiModelConfig aiModelConfig)
    {
        aiModelConfig.setCreateTime(DateUtils.getNowDate());
        
        // 如果设置为默认,取消其他默认配置
        if ("1".equals(aiModelConfig.getIsDefault()))
        {
            aiModelConfigMapper.cancelOtherDefault(aiModelConfig.getModelType());
        }
        
        return aiModelConfigMapper.insertAiModelConfig(aiModelConfig);
    }

    /**
     * 修改AI模型配置
     * 
     * @param aiModelConfig AI模型配置
     * @return 结果
     */
    @Override
    public int updateAiModelConfig(AiModelConfig aiModelConfig)
    {
        aiModelConfig.setUpdateTime(DateUtils.getNowDate());
        
        // 如果设置为默认,取消其他默认配置
        if ("1".equals(aiModelConfig.getIsDefault()))
        {
            aiModelConfigMapper.cancelOtherDefault(aiModelConfig.getModelType());
        }
        
        return aiModelConfigMapper.updateAiModelConfig(aiModelConfig);
    }

    /**
     * 批量删除AI模型配置
     * 
     * @param modelIds 需要删除的模型ID
     * @return 结果
     */
    @Override
    public int deleteAiModelConfigByModelIds(Long[] modelIds)
    {
        return aiModelConfigMapper.deleteAiModelConfigByModelIds(modelIds);
    }

    /**
     * 删除AI模型配置信息
     * 
     * @param modelId 模型ID
     * @return 结果
     */
    @Override
    public int deleteAiModelConfigByModelId(Long modelId)
    {
        return aiModelConfigMapper.deleteAiModelConfigByModelId(modelId);
    }

    /**
     * 测试模型连接
     * 
     * @param aiModelConfig AI模型配置
     * @return 测试结果
     */
    @Override
    public String testConnection(AiModelConfig aiModelConfig)
    {
        try
        {
            String apiUrl = aiModelConfig.getApiUrl();
            String apiKey = aiModelConfig.getApiKey();
            String model = aiModelConfig.getModelVersion() != null && !aiModelConfig.getModelVersion().isEmpty()
                    ? aiModelConfig.getModelVersion() : aiModelConfig.getModelName();
            
            if (apiUrl == null || apiUrl.isEmpty())
            {
                return "{\"success\":false,\"message\":\"API地址未配置\"}";
            }
            if (model == null || model.isEmpty())
            {
                return "{\"success\":false,\"message\":\"模型名称/版本未配置\"}";
            }

            org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.setContentType(org.springframework.http.MediaType.APPLICATION_JSON);
            if (apiKey != null && !apiKey.isEmpty())
            {
                headers.setBearerAuth(apiKey);
            }

            // 构建测试请求 - 使用标准 OpenAI 格式（messages）
            com.alibaba.fastjson2.JSONObject requestBody = new com.alibaba.fastjson2.JSONObject();
            requestBody.put("model", model);
            com.alibaba.fastjson2.JSONArray messages = new com.alibaba.fastjson2.JSONArray();
            com.alibaba.fastjson2.JSONObject testMsg = new com.alibaba.fastjson2.JSONObject();
            testMsg.put("role", "user");
            testMsg.put("content", "hi");
            messages.add(testMsg);
            requestBody.put("messages", messages);
            requestBody.put("max_tokens", 10);

            // 第一次测试：标准格式，不带temperature
            org.springframework.http.HttpEntity<String> request = new org.springframework.http.HttpEntity<>(requestBody.toJSONString(), headers);
            
            try
            {
                org.springframework.http.ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, request, String.class);
                
                if (response.getStatusCode().is2xxSuccessful())
                {
                    // 第二次测试：带temperature
                    requestBody.put("temperature", 0.7);
                    org.springframework.http.HttpEntity<String> request2 = new org.springframework.http.HttpEntity<>(requestBody.toJSONString(), headers);
                    
                    try
                    {
                        org.springframework.http.ResponseEntity<String> response2 = restTemplate.postForEntity(apiUrl, request2, String.class);
                        if (response2.getStatusCode().is2xxSuccessful())
                        {
                            return "{\"success\":true,\"message\":\"连接成功\",\"supportTemperature\":\"1\"}";
                        }
                    }
                    catch (Exception e)
                    {
                        String errorMsg = e.getMessage();
                        if (errorMsg != null && (errorMsg.contains("temperature") || errorMsg.contains("Unsupported parameter")))
                        {
                            return "{\"success\":true,\"message\":\"连接成功(不支持temperature参数)\",\"supportTemperature\":\"0\"}";
                        }
                    }
                    
                    return "{\"success\":true,\"message\":\"连接成功\",\"supportTemperature\":\"1\"}";
                }
                else
                {
                    return "{\"success\":false,\"message\":\"连接失败: " + response.getStatusCode() + "\"}";
                }
            }
            catch (Exception e)
            {
                String errorMsg = e.getMessage();
                if (errorMsg != null && errorMsg.length() > 200)
                {
                    errorMsg = errorMsg.substring(0, 200) + "...";
                }
                return "{\"success\":false,\"message\":\"连接失败: " + errorMsg + "\"}";
            }
        }
        catch (Exception e)
        {
            return "{\"success\":false,\"message\":\"测试异常: " + e.getMessage() + "\"}";
        }
    }
}
