package com.dishtest.system.service;

import java.util.List;
import java.util.Map;

/**
 * RAG检索服务接口
 * 参考auto_test的混合RAG架构实现
 * 
 * @author dishtest
 */
public interface IRagService {
    
    /**
     * 检索相关文档
     * 使用混合检索策略：语义搜索(60%) + BM25(40%)
     * 
     * @param query 查询文本
     * @param topK 返回结果数量
     * @return 相关文档列表，包含content、score、method等字段
     */
    List<Map<String, Object>> retrieveDocuments(String query, int topK);
    
    /**
     * 添加文档到向量库
     * 同时添加到ChromaDB(语义搜索)和Lucene(BM25搜索)
     * 
     * @param caseId 测试用例ID
     * @param content 文档内容
     */
    void addDocument(Long caseId, String content);
    
    /**
     * 删除文档
     * 从ChromaDB和Lucene索引中删除
     * 
     * @param caseId 测试用例ID
     */
    void deleteDocument(Long caseId);
    
    /**
     * 批量添加文档
     * 
     * @param documents 文档列表，Map包含caseId和content
     */
    void batchAddDocuments(List<Map<String, Object>> documents);
    
    /**
     * 清空所有文档
     */
    void clearAllDocuments();
    
    /**
     * 获取文档总数
     * 
     * @return 文档总数
     */
    int getDocumentCount();
}
