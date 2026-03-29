package com.dishtest.system.service;

import java.util.List;
import java.util.Map;
import java.util.function.Consumer;

/**
 * 批量生成服务接口
 * 参考auto_test的30并发批量生成实现
 * 
 * @author dishtest
 */
public interface IBatchGenerateService {
    
    /**
     * 批量生成测试用例
     * 支持并发生成，实时进度回调
     * 
     * @param caseId 测试用例ID
     * @param targetCount 目标生成数量
     * @param progressCallback 进度回调函数，接收进度信息Map
     * @return 生成的测试用例列表
     */
    List<Map<String, Object>> batchGenerate(
        Long caseId,
        int targetCount,
        Consumer<Map<String, Object>> progressCallback
    );
    
    /**
     * 取消批量生成任务
     * 
     * @param caseId 测试用例ID
     * @return 是否成功取消
     */
    boolean cancelBatchGenerate(Long caseId);
    
    /**
     * 获取批量生成进度
     * 
     * @param caseId 测试用例ID
     * @return 进度信息Map，包含generatedCount、totalCount、progressPercent等
     */
    Map<String, Object> getBatchGenerateProgress(Long caseId);
    
    /**
     * 检查是否正在批量生成
     * 
     * @param caseId 测试用例ID
     * @return 是否正在生成
     */
    boolean isBatchGenerating(Long caseId);
}
