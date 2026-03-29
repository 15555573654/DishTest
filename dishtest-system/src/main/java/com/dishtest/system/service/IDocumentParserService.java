package com.dishtest.system.service;

import org.springframework.web.multipart.MultipartFile;

/**
 * 文档解析服务接口
 * 
 * @author dishtest
 */
public interface IDocumentParserService 
{
    /**
     * 解析文档文件，提取文本内容
     * 
     * @param file 上传的文档文件
     * @return 文档文本内容
     * @throws Exception 解析异常
     */
    String parseDocument(MultipartFile file) throws Exception;

    /**
     * 判断文件类型是否支持
     * 
     * @param fileName 文件名
     * @return 是否支持
     */
    boolean isSupportedFileType(String fileName);
}
