package com.dishtest.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.scheduling.annotation.Async;
import com.dishtest.common.utils.DateUtils;
import com.dishtest.system.mapper.TestCaseMapper;
import com.dishtest.system.domain.TestCase;
import com.dishtest.system.domain.AiModelConfig;
import com.dishtest.system.service.ITestCaseService;
import com.dishtest.system.service.IAiGenerateService;
import com.dishtest.system.service.IAiModelConfigService;
import com.dishtest.system.service.IDocumentParserService;

/**
 * 测试用例Service业务层处理
 * 
 * @author dishtest
 */
@Service
public class TestCaseServiceImpl implements ITestCaseService 
{
    @Autowired
    private TestCaseMapper testCaseMapper;

    @Autowired
    private IAiGenerateService aiGenerateService;

    @Autowired
    private IAiModelConfigService aiModelConfigService;

    @Autowired
    private IDocumentParserService documentParserService;

    /**
     * 查询测试用例
     * 
     * @param caseId 测试用例主键
     * @return 测试用例
     */
    @Override
    public TestCase selectTestCaseByCaseId(Long caseId)
    {
        return testCaseMapper.selectTestCaseByCaseId(caseId);
    }

    /**
     * 查询测试用例列表
     * 
     * @param testCase 测试用例
     * @return 测试用例
     */
    @Override
    public List<TestCase> selectTestCaseList(TestCase testCase)
    {
        return testCaseMapper.selectTestCaseList(testCase);
    }

    /**
     * 新增测试用例
     * 
     * @param testCase 测试用例
     * @return 结果
     */
    @Override
    public int insertTestCase(TestCase testCase)
    {
        testCase.setCreateTime(DateUtils.getNowDate());
        return testCaseMapper.insertTestCase(testCase);
    }

    /**
     * 修改测试用例
     * 
     * @param testCase 测试用例
     * @return 结果
     */
    @Override
    public int updateTestCase(TestCase testCase)
    {
        testCase.setUpdateTime(DateUtils.getNowDate());
        return testCaseMapper.updateTestCase(testCase);
    }

    /**
     * 批量删除测试用例
     * 
     * @param caseIds 需要删除的测试用例主键
     * @return 结果
     */
    @Override
    public int deleteTestCaseByCaseIds(Long[] caseIds)
    {
        return testCaseMapper.deleteTestCaseByCaseIds(caseIds);
    }

    /**
     * 删除测试用例信息
     * 
     * @param caseId 测试用例主键
     * @return 结果
     */
    @Override
    public int deleteTestCaseByCaseId(Long caseId)
    {
        return testCaseMapper.deleteTestCaseByCaseId(caseId);
    }

    /**
     * 异步生成测试用例
     * 
     * @param caseId 测试用例ID
     */
    @Async
    @Override
    public void generateTestCase(Long caseId)
    {
        TestCase testCase = testCaseMapper.selectTestCaseByCaseId(caseId);
        if (testCase == null)
        {
            return;
        }

        // 更新状态为生成中
        testCase.setStatus("1");
        testCaseMapper.updateTestCase(testCase);

        long startTime = System.currentTimeMillis();
        
        try
        {
            // 获取文档内容
            String documentContent = testCase.getInputDoc();
            if (documentContent == null || documentContent.isEmpty())
            {
                throw new Exception("文档内容为空");
            }

            String generatedContent;
            String usedModelName = null;
            Long modelConfigId = testCase.getModelConfigId();
            
            if (modelConfigId != null) {
                // 使用指定的模型配置
                AiModelConfig modelConfig = aiModelConfigService.selectAiModelConfigByModelId(modelConfigId);
                if (modelConfig != null && "0".equals(modelConfig.getStatus())) {
                    generatedContent = aiGenerateService.generateTestCase(documentContent, modelConfig);
                    usedModelName = modelConfig.getModelName();
                } else {
                    throw new RuntimeException("模型配置不存在或已禁用");
                }
            } else {
                // 未指定模型配置，使用 ai_model 字段查找默认配置
                String aiModel = testCase.getAiModel();
                if (aiModel == null || aiModel.isEmpty()) {
                    aiModel = "openai";
                }
                
                // 从数据库获取该类型的默认模型配置
                AiModelConfig defaultConfig = aiModelConfigService.getDefaultModelConfig(aiModel);
                if (defaultConfig != null && "0".equals(defaultConfig.getStatus())) {
                    generatedContent = aiGenerateService.generateTestCase(documentContent, defaultConfig);
                    usedModelName = defaultConfig.getModelName();
                } else {
                    throw new RuntimeException("未找到可用的模型配置，请在模型配置中添加 [" + aiModel + "] 类型的默认配置");
                }
            }
            
            long endTime = System.currentTimeMillis();
            int generateTime = (int) ((endTime - startTime) / 1000);
            
            // 更新测试用例
            testCase.setCaseContent(generatedContent);
            testCase.setStatus("2");
            testCase.setGenerateTime(generateTime);
            testCase.setErrorMsg(null);
            // 记录使用的模型名称（直接设置，不判断）
            testCase.setAiModel(usedModelName);
            testCaseMapper.updateTestCase(testCase);
        }
        catch (Exception e)
        {
            // 生成失败
            testCase.setStatus("3");
            testCase.setErrorMsg(e.getMessage());
            testCaseMapper.updateTestCase(testCase);
        }
    }
}
