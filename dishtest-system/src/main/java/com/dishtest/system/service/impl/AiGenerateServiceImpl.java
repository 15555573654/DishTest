package com.dishtest.system.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.dishtest.system.domain.AiModelConfig;
import com.dishtest.system.service.IAiGenerateService;
import com.dishtest.system.service.IAiPromptConfigService;
import com.dishtest.system.service.IAiModelConfigService;

import java.math.BigDecimal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * AI生成服务实现 - 支持多种AI平台
 * 
 * @author ruoyi
 */
@Service
public class AiGenerateServiceImpl implements IAiGenerateService 
{
    private static final Logger log = LoggerFactory.getLogger(AiGenerateServiceImpl.class);

    @Autowired
    private IAiPromptConfigService aiPromptConfigService;

    @Autowired
    private IAiModelConfigService aiModelConfigService;

    @Override
    public String generateTestCase(String documentContent, String aiModel) throws Exception
    {
        if (aiModel == null || aiModel.isEmpty())
        {
            aiModel = "openai";
        }

        // 从数据库获取对应类型的默认模型配置
        AiModelConfig modelConfig = aiModelConfigService.getDefaultModelConfig(aiModel);
        
        if (modelConfig == null)
        {
            throw new Exception("未找到模型类型 [" + aiModel + "] 的默认配置，请先在模型配置中添加并设置为默认");
        }
        
        if (!"0".equals(modelConfig.getStatus()))
        {
            throw new Exception("模型配置已停用，请先启用");
        }
        
        // 使用统一的自定义配置方法
        return generateWithCustomConfig(documentContent, modelConfig);
    }

    @Override
    public String generateTestCase(String documentContent, AiModelConfig modelConfig) throws Exception
    {
        if (modelConfig == null)
        {
            throw new Exception("自定义模型配置不能为空");
        }
        return generateWithCustomConfig(documentContent, modelConfig);
    }

    /**
     * 使用自定义模型配置生成（OpenAI 兼容接口，适用于 Coze、自定义代理等）
     */
    private String generateWithCustomConfig(String documentContent, AiModelConfig config) throws Exception
    {
        String apiUrl = config.getApiUrl();
        String apiKey = config.getApiKey();
        String model = config.getModelVersion() != null && !config.getModelVersion().isEmpty()
                ? config.getModelVersion() : config.getModelName();
        if (apiUrl == null || apiUrl.isEmpty())
        {
            throw new Exception("自定义模型 API 地址未配置");
        }
        if (model == null || model.isEmpty())
        {
            throw new Exception("自定义模型名称/版本未配置");
        }

        String modelType = config.getModelType() != null ? config.getModelType() : "openai";
        String systemPrompt = aiPromptConfigService.getDefaultPromptContent(modelType);

        BigDecimal temp = config.getTemperature();
        double temperature = (temp != null) ? temp.doubleValue() : 0.7;

        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (apiKey != null && !apiKey.isEmpty())
        {
            headers.setBearerAuth(apiKey);
        }

        JSONObject requestBody = new JSONObject();
        requestBody.put("model", model);
        JSONArray messages = new JSONArray();
        JSONObject systemMsg = new JSONObject();
        systemMsg.put("role", "system");
        systemMsg.put("content", systemPrompt);
        messages.add(systemMsg);
        JSONObject userMsg = new JSONObject();
        userMsg.put("role", "user");
        userMsg.put("content", "需求文档:\n" + documentContent);
        messages.add(userMsg);
        requestBody.put("messages", messages);
        
        // 尝试添加 temperature 参数（如果配置了且大于0）
        boolean useTemperature = (temp != null && temp.doubleValue() > 0);
        if (useTemperature)
        {
            requestBody.put("temperature", temperature);
        }
        
        if (config.getMaxTokens() != null && config.getMaxTokens() > 0)
        {
            requestBody.put("max_tokens", config.getMaxTokens());
        }

        HttpEntity<String> request = new HttpEntity<>(requestBody.toJSONString(), headers);
        log.info("使用自定义模型配置生成测试用例: {} @ {}", config.getModelName(), apiUrl);
        
        try
        {
            ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, request, String.class);
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null)
            {
                JSONObject responseBody = JSON.parseObject(response.getBody());
                JSONArray choices = responseBody.getJSONArray("choices");
                if (choices != null && !choices.isEmpty())
                {
                    JSONObject choice = choices.getJSONObject(0);
                    JSONObject message = choice.getJSONObject("message");
                    return message != null ? message.getString("content") : "";
                }
                throw new Exception("自定义模型返回数据格式错误");
            }
            throw new Exception("自定义模型 API 调用失败: " + (response.getBody() != null ? response.getBody() : response.getStatusCode()));
        }
        catch (Exception e)
        {
            String errorMsg = e.getMessage();
            // 如果错误是因为 temperature 参数，尝试不带 temperature 重试
            if (useTemperature && errorMsg != null && 
                (errorMsg.contains("temperature") || errorMsg.contains("Unsupported parameter")))
            {
                log.warn("模型不支持 temperature 参数，尝试不带 temperature 重试: {}", config.getModelName());
                requestBody.remove("temperature");
                HttpEntity<String> retryRequest = new HttpEntity<>(requestBody.toJSONString(), headers);
                ResponseEntity<String> response = restTemplate.postForEntity(apiUrl, retryRequest, String.class);
                
                if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null)
                {
                    JSONObject responseBody = JSON.parseObject(response.getBody());
                    JSONArray choices = responseBody.getJSONArray("choices");
                    if (choices != null && !choices.isEmpty())
                    {
                        JSONObject choice = choices.getJSONObject(0);
                        JSONObject message = choice.getJSONObject("message");
                        return message != null ? message.getString("content") : "";
                    }
                    throw new Exception("自定义模型返回数据格式错误");
                }
                throw new Exception("自定义模型 API 调用失败: " + (response.getBody() != null ? response.getBody() : response.getStatusCode()));
            }
            throw e;
        }
    }
}
