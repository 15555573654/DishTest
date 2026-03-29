package com.dishtest.system.service;

import java.util.List;
import com.dishtest.system.domain.TestCase;

/**
 * 测试用例Service接口
 * 
 * @author ruoyi
 */
public interface ITestCaseService 
{
    /**
     * 查询测试用例
     * 
     * @param caseId 测试用例主键
     * @return 测试用例
     */
    public TestCase selectTestCaseByCaseId(Long caseId);

    /**
     * 查询测试用例列表
     * 
     * @param testCase 测试用例
     * @return 测试用例集合
     */
    public List<TestCase> selectTestCaseList(TestCase testCase);

    /**
     * 新增测试用例
     * 
     * @param testCase 测试用例
     * @return 结果
     */
    public int insertTestCase(TestCase testCase);

    /**
     * 修改测试用例
     * 
     * @param testCase 测试用例
     * @return 结果
     */
    public int updateTestCase(TestCase testCase);

    /**
     * 批量删除测试用例
     * 
     * @param caseIds 需要删除的测试用例主键集合
     * @return 结果
     */
    public int deleteTestCaseByCaseIds(Long[] caseIds);

    /**
     * 删除测试用例信息
     * 
     * @param caseId 测试用例主键
     * @return 结果
     */
    public int deleteTestCaseByCaseId(Long caseId);

    /**
     * 生成测试用例（调用AI）
     * 
     * @param caseId 测试用例ID
     * @return 结果
     */
    public void generateTestCase(Long caseId);
}
