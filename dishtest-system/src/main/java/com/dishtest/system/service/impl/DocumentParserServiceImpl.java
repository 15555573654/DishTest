package com.dishtest.system.service.impl;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.dishtest.system.service.IDocumentParserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 文档解析服务实现
 * 
 * @author dishtest
 */
@Service
public class DocumentParserServiceImpl implements IDocumentParserService 
{
    private static final Logger log = LoggerFactory.getLogger(DocumentParserServiceImpl.class);

    /**
     * 解析文档文件
     */
    @Override
    public String parseDocument(MultipartFile file) throws Exception
    {
        String fileName = file.getOriginalFilename();
        if (fileName == null || fileName.isEmpty())
        {
            throw new Exception("文件名为空");
        }

        String fileExtension = getFileExtension(fileName).toLowerCase();
        
        switch (fileExtension)
        {
            case "txt":
            case "md":
                return parseTxtFile(file);
            case "doc":
            case "docx":
                return parseWordFile(file);
            case "pdf":
                return parsePdfFile(file);
            case "xlsx":
            case "xls":
                return parseExcelFile(file);
            case "csv":
                return parseCsvFile(file);
            default:
                throw new Exception("不支持的文件格式: " + fileExtension);
        }
    }

    /**
     * 判断文件类型是否支持
     */
    @Override
    public boolean isSupportedFileType(String fileName)
    {
        if (fileName == null || fileName.isEmpty())
        {
            return false;
        }
        
        String extension = getFileExtension(fileName).toLowerCase();
        return extension.equals("txt") || extension.equals("md") || 
               extension.equals("doc") || extension.equals("docx") || 
               extension.equals("pdf") || extension.equals("xlsx") || 
               extension.equals("xls") || extension.equals("csv");
    }

    /**
     * 解析TXT/MD文件
     */
    private String parseTxtFile(MultipartFile file) throws Exception
    {
        StringBuilder content = new StringBuilder();
        try (InputStream is = file.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8")))
        {
            String line;
            while ((line = reader.readLine()) != null)
            {
                content.append(line).append("\n");
            }
        }
        return content.toString();
    }

    /**
     * 解析Word文件
     */
    private String parseWordFile(MultipartFile file) throws Exception
    {
        StringBuilder content = new StringBuilder();
        try (InputStream is = file.getInputStream();
             XWPFDocument document = new XWPFDocument(is))
        {
            for (XWPFParagraph paragraph : document.getParagraphs())
            {
                content.append(paragraph.getText()).append("\n");
            }
        }
        return content.toString();
    }

    /**
     * 解析PDF文件
     */
    private String parsePdfFile(MultipartFile file) throws Exception
    {
        try (InputStream is = file.getInputStream();
             PDDocument document = PDDocument.load(is))
        {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }

    /**
     * 解析Excel文件
     */
    private String parseExcelFile(MultipartFile file) throws Exception
    {
        StringBuilder content = new StringBuilder();
        try (InputStream is = file.getInputStream();
             org.apache.poi.ss.usermodel.Workbook workbook = org.apache.poi.ss.usermodel.WorkbookFactory.create(is))
        {
            for (int i = 0; i < workbook.getNumberOfSheets(); i++)
            {
                org.apache.poi.ss.usermodel.Sheet sheet = workbook.getSheetAt(i);
                content.append("Sheet: ").append(sheet.getSheetName()).append("\n\n");
                
                for (org.apache.poi.ss.usermodel.Row row : sheet)
                {
                    for (org.apache.poi.ss.usermodel.Cell cell : row)
                    {
                        switch (cell.getCellType())
                        {
                            case STRING:
                                content.append(cell.getStringCellValue());
                                break;
                            case NUMERIC:
                                if (org.apache.poi.ss.usermodel.DateUtil.isCellDateFormatted(cell))
                                {
                                    content.append(cell.getDateCellValue());
                                }
                                else
                                {
                                    content.append(cell.getNumericCellValue());
                                }
                                break;
                            case BOOLEAN:
                                content.append(cell.getBooleanCellValue());
                                break;
                            case FORMULA:
                                content.append(cell.getCellFormula());
                                break;
                            default:
                                break;
                        }
                        content.append("\t");
                    }
                    content.append("\n");
                }
                content.append("\n");
            }
        }
        return content.toString();
    }

    /**
     * 解析CSV文件
     */
    private String parseCsvFile(MultipartFile file) throws Exception
    {
        StringBuilder content = new StringBuilder();
        try (InputStream is = file.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8")))
        {
            String line;
            while ((line = reader.readLine()) != null)
            {
                content.append(line).append("\n");
            }
        }
        return content.toString();
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String fileName)
    {
        int lastIndexOf = fileName.lastIndexOf(".");
        if (lastIndexOf == -1)
        {
            return "";
        }
        return fileName.substring(lastIndexOf + 1);
    }
}
