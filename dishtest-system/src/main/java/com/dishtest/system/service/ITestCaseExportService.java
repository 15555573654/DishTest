package com.dishtest.system.service;

/**
 * 测试用例导出服务接口
 * 
 * @author ruoyi
 */
public interface ITestCaseExportService 
{
    /**
     * 导出为CSV格式
     * 
     * @param caseContent 测试用例内容(Markdown格式)
     * @return CSV内容
     */
    String exportToCsv(String caseContent);

    /**
     * 导出为XMind格式
     * 
     * @param caseTitle 用例标题
     * @param caseContent 测试用例内容(Markdown格式)
     * @return XMind文件字节数组
     * @throws Exception 导出异常
     */
    byte[] exportToXMind(String caseTitle, String caseContent) throws Exception;
}
