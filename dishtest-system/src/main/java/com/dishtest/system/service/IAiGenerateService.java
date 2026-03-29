package com.dishtest.system.service;

import com.dishtest.system.domain.AiModelConfig;

/**
 * AI生成服务接口
 * 
 * @author dishtest
 */
public interface IAiGenerateService 
{
    /**
     * 根据文档生成测试用例（使用内置模型类型）
     * 
     * @param documentContent 文档内容
     * @param aiModel AI模型类型 (openai/claude/qwen/local)
     * @return 生成的测试用例内容(Markdown格式)
     * @throws Exception 生成异常
     */
    String generateTestCase(String documentContent, String aiModel) throws Exception;

    /**
     * 根据文档生成测试用例（使用自定义模型配置）
     * 
     * @param documentContent 文档内容
     * @param modelConfig 自定义AI模型配置（来自 ai_model_config 表）
     * @return 生成的测试用例内容(Markdown格式)
     * @throws Exception 生成异常
     */
    String generateTestCase(String documentContent, AiModelConfig modelConfig) throws Exception;
}
