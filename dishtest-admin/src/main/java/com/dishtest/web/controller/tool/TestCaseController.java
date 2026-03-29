package com.dishtest.web.controller.tool;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.dishtest.common.annotation.Log;
import com.dishtest.common.core.controller.BaseController;
import com.dishtest.common.core.domain.AjaxResult;
import com.dishtest.common.enums.BusinessType;
import com.dishtest.common.utils.file.FileUploadUtils;
import com.dishtest.common.utils.file.FileUtils;
import com.dishtest.common.config.RuoYiConfig;
import com.dishtest.system.domain.TestCase;
import com.dishtest.system.service.ITestCaseService;
import com.dishtest.system.service.IDocumentParserService;
import com.dishtest.system.service.ITestCaseExportService;
import com.dishtest.common.utils.poi.ExcelUtil;
import com.dishtest.common.core.page.TableDataInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.OutputStream;

/**
 * 测试用例Controller
 * 
 * @author ruoyi
 */
@RestController
@RequestMapping("/tool/testcase")
public class TestCaseController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(TestCaseController.class);

    @Autowired
    private ITestCaseService testCaseService;

    @Autowired
    private IDocumentParserService documentParserService;

    @Autowired
    private ITestCaseExportService testCaseExportService;

    /**
     * 查询测试用例列表
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:list')")
    @GetMapping("/list")
    public TableDataInfo list(TestCase testCase)
    {
        startPage();
        List<TestCase> list = testCaseService.selectTestCaseList(testCase);
        return getDataTable(list);
    }

    /**
     * 导出测试用例列表
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:export')")
    @Log(title = "测试用例", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, TestCase testCase)
    {
        List<TestCase> list = testCaseService.selectTestCaseList(testCase);
        ExcelUtil<TestCase> util = new ExcelUtil<TestCase>(TestCase.class);
        util.exportExcel(response, list, "测试用例数据");
    }

    /**
     * 获取测试用例详细信息
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:query')")
    @GetMapping(value = "/{caseId}")
    public AjaxResult getInfo(@PathVariable("caseId") Long caseId)
    {
        return success(testCaseService.selectTestCaseByCaseId(caseId));
    }

    /**
     * 上传文档并创建测试用例
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:add')")
    @Log(title = "上传测试用例文档", businessType = BusinessType.INSERT)
    @PostMapping("/upload")
    public AjaxResult upload(@RequestParam("file") MultipartFile file,
                            @RequestParam("caseTitle") String caseTitle,
                            @RequestParam(value = "modelConfigId", required = false) Long modelConfigId,
                            @RequestParam(value = "promptConfigId", required = false) Long promptConfigId,
                            @RequestParam(value = "remark", required = false) String remark)
    {
        try
        {
            // 检查文件类型
            String fileName = file.getOriginalFilename();
            if (!documentParserService.isSupportedFileType(fileName))
            {
                return error("不支持的文件格式，仅支持: txt, md, doc, docx, pdf, xlsx, xls, csv");
            }

            // 上传文件
            String filePath = FileUploadUtils.upload(RuoYiConfig.getUploadPath(), file);
            
            // 解析文档内容
            String documentContent = documentParserService.parseDocument(file);
            
            // 创建测试用例
            TestCase testCase = new TestCase();
            testCase.setCaseTitle(caseTitle);
            testCase.setInputDoc(documentContent);
            testCase.setFileName(fileName);
            testCase.setFilePath(filePath);
            testCase.setFileType(getFileExtension(fileName));
            testCase.setModelConfigId(modelConfigId);
            testCase.setPromptConfigId(promptConfigId);
            testCase.setStatus("0");
            testCase.setRemark(remark);
            
            return toAjax(testCaseService.insertTestCase(testCase));
        }
        catch (Exception e)
        {
            log.error("文件上传失败", e);
            return error("文件上传失败: " + e.getMessage());
        }
    }

    /**
     * 新增测试用例（文本方式）
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:add')")
    @Log(title = "测试用例", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody TestCase testCase)
    {
        testCase.setStatus("0");
        return toAjax(testCaseService.insertTestCase(testCase));
    }

    /**
     * 修改测试用例
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:edit')")
    @Log(title = "测试用例", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody TestCase testCase)
    {
        return toAjax(testCaseService.updateTestCase(testCase));
    }

    /**
     * 删除测试用例
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:remove')")
    @Log(title = "测试用例", businessType = BusinessType.DELETE)
	@DeleteMapping("/{caseIds}")
    public AjaxResult remove(@PathVariable Long[] caseIds)
    {
        return toAjax(testCaseService.deleteTestCaseByCaseIds(caseIds));
    }

    /**
     * 生成测试用例
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:generate')")
    @Log(title = "生成测试用例", businessType = BusinessType.UPDATE)
    @PostMapping("/generate/{caseId}")
    public AjaxResult generate(@PathVariable Long caseId)
    {
        TestCase testCase = testCaseService.selectTestCaseByCaseId(caseId);
        if (testCase == null)
        {
            return error("测试用例不存在");
        }
        
        if ("1".equals(testCase.getStatus()))
        {
            return error("测试用例正在生成中，请稍后");
        }
        
        // 异步生成测试用例
        testCaseService.generateTestCase(caseId);
        
        return success("测试用例生成任务已提交，请稍后刷新查看结果");
    }

    /**
     * 导出测试用例为CSV
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:export')")
    @Log(title = "导出测试用例CSV", businessType = BusinessType.EXPORT)
    @GetMapping("/exportCsv/{caseId}")
    public void exportCsv(@PathVariable Long caseId, HttpServletResponse response)
    {
        try
        {
            TestCase testCase = testCaseService.selectTestCaseByCaseId(caseId);
            if (testCase == null || testCase.getCaseContent() == null)
            {
                return;
            }

            String csvContent = testCaseExportService.exportToCsv(testCase.getCaseContent());
            
            // 检查csvContent是否为空或只有表头
            if (csvContent == null || csvContent.trim().isEmpty() || csvContent.split("\n").length <= 1)
            {
                log.warn("CSV内容为空，用例ID: {}", caseId);
            }
            
            response.setContentType("text/csv; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Content-Disposition", 
                "attachment; filename=" + java.net.URLEncoder.encode(testCase.getCaseTitle() + ".csv", "UTF-8"));
            
            // BOM已在exportToCsv中添加，不需要重复添加
            response.getWriter().write(csvContent);
            response.getWriter().flush();
        }
        catch (Exception e)
        {
            log.error("导出CSV失败", e);
        }
    }

    /**
     * 导出测试用例为XMind
     */
    @PreAuthorize("@ss.hasPermi('tool:testcase:export')")
    @Log(title = "导出测试用例XMind", businessType = BusinessType.EXPORT)
    @GetMapping("/exportXMind/{caseId}")
    public void exportXMind(@PathVariable Long caseId, HttpServletResponse response)
    {
        try
        {
            TestCase testCase = testCaseService.selectTestCaseByCaseId(caseId);
            if (testCase == null || testCase.getCaseContent() == null)
            {
                return;
            }

            byte[] xmindData = testCaseExportService.exportToXMind(
                testCase.getCaseTitle(), testCase.getCaseContent());
            
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", 
                "attachment; filename=" + java.net.URLEncoder.encode(testCase.getCaseTitle() + ".xmind", "UTF-8"));
            
            response.getOutputStream().write(xmindData);
            response.getOutputStream().flush();
        }
        catch (Exception e)
        {
            log.error("导出XMind失败", e);
        }
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
