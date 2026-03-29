package com.dishtest.system.service.impl;

import java.io.ByteArrayOutputStream;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import com.dishtest.system.service.ITestCaseExportService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 测试用例导出服务实现
 * 
 * @author ruoyi
 */
@Service
public class TestCaseExportServiceImpl implements ITestCaseExportService 
{
    private static final Logger log = LoggerFactory.getLogger(TestCaseExportServiceImpl.class);

    /**
     * 导出为CSV格式 - 与前端表格视图保持一致
     */
    @Override
    public String exportToCsv(String caseContent) 
    {
        if (caseContent == null || caseContent.isEmpty()) 
        {
            return "";
        }

        StringBuilder csv = new StringBuilder();
        // CSV表头 - 添加BOM以支持Excel正确显示中文
        csv.append("\uFEFF");
        csv.append("功能模块,测试点,验证点,场景,预期结果\n");

        // 使用与前端相同的解析逻辑
        List<TestCaseRow> rows = parseContentToTable(caseContent);
        
        for (TestCaseRow row : rows) 
        {
            csv.append(formatCsvLine(
                row.module, 
                row.testPoint, 
                row.verifyPoint, 
                row.scenario, 
                row.expected
            ));
        }

        return csv.toString();
    }
    
    /**
     * 解析内容为表格数据 - 与前端parseContentToTable逻辑一致
     */
    private List<TestCaseRow> parseContentToTable(String content) 
    {
        List<TestCaseRow> data = new ArrayList<>();
        
        // 方法1: 尝试解析标准 Markdown 格式
        data = parseStandardMarkdown(content);
        if (!data.isEmpty()) 
        {
            log.debug("使用标准Markdown格式解析，共{}条", data.size());
            return data;
        }
        
        // 方法2: 尝试解析 Markdown 表格格式
        data = parseMarkdownTable(content);
        if (!data.isEmpty()) 
        {
            log.debug("使用Markdown表格格式解析，共{}条", data.size());
            return data;
        }
        
        // 方法3: 尝试解析列表格式
        data = parseListFormat(content);
        if (!data.isEmpty()) 
        {
            log.debug("使用列表格式解析，共{}条", data.size());
            return data;
        }
        
        log.warn("无法解析测试用例内容");
        return data;
    }
    
    /**
     * 解析标准 Markdown 层级格式
     */
    private List<TestCaseRow> parseStandardMarkdown(String content) 
    {
        List<TestCaseRow> data = new ArrayList<>();
        String[] lines = content.split("\n");
        String module = "", testPoint = "", verifyPoint = "", scenario = "";
        
        for (String line : lines) 
        {
            String trimmed = line.trim();
            if (trimmed.isEmpty()) continue;
            
            if (trimmed.startsWith("## ") && !trimmed.startsWith("### ")) 
            {
                module = trimmed.substring(3).trim();
            } 
            else if (trimmed.startsWith("### ")) 
            {
                testPoint = trimmed.substring(4).trim();
            } 
            else if (trimmed.startsWith("#### ")) 
            {
                verifyPoint = trimmed.substring(5).trim();
            } 
            else if (trimmed.startsWith("##### ")) 
            {
                scenario = trimmed.substring(6).trim();
            } 
            else if (trimmed.startsWith("###### ")) 
            {
                String text = trimmed.substring(7).trim();
                String expected = text.replaceFirst("^预期结果[：:]\\s*", "").trim();
                data.add(new TestCaseRow(module, testPoint, verifyPoint, scenario, expected));
            }
        }
        
        return data;
    }
    
    /**
     * 解析 Markdown 表格格式
     */
    private List<TestCaseRow> parseMarkdownTable(String content) 
    {
        List<TestCaseRow> data = new ArrayList<>();
        String[] lines = content.split("\n");
        boolean inTable = false;
        
        for (String line : lines) 
        {
            String trimmed = line.trim();
            if (trimmed.isEmpty()) continue;
            
            if (trimmed.startsWith("|") && trimmed.endsWith("|")) 
            {
                String[] cells = trimmed.split("\\|");
                List<String> cleanCells = new ArrayList<>();
                for (String cell : cells) 
                {
                    String clean = cell.trim();
                    if (!clean.isEmpty()) 
                    {
                        cleanCells.add(clean);
                    }
                }
                
                // 跳过分隔行
                if (!cleanCells.isEmpty() && cleanCells.get(0).matches("^[-:]+$")) 
                {
                    inTable = true;
                    continue;
                }
                
                if (inTable && cleanCells.size() >= 4) 
                {
                    data.add(new TestCaseRow(
                        cleanCells.get(0),
                        cleanCells.get(1),
                        cleanCells.get(2),
                        cleanCells.get(3),
                        cleanCells.size() > 4 ? cleanCells.get(4) : ""
                    ));
                }
            }
        }
        
        return data;
    }
    
    /**
     * 解析列表格式 - 与前端parseListFormat逻辑一致
     */
    private List<TestCaseRow> parseListFormat(String content) 
    {
        List<TestCaseRow> data = new ArrayList<>();
        String[] lines = content.split("\n");
        
        String currentModule = "";
        String currentTestPoint = "";
        String currentVerifyPoint = "";
        String currentScenario = "";
        String currentScenarioDesc = "";
        String currentExpected = "";
        
        for (String line : lines) 
        {
            String trimmed = line.trim();
            if (trimmed.isEmpty()) continue;
            
            // 检测是否是新的测试点/验证点（较短的标题行，不包含冒号）
            if (!trimmed.contains("：") && !trimmed.contains(":") &&
                !trimmed.startsWith("场景") &&
                trimmed.length() < 100 &&
                !trimmed.contains("。")) 
            {
                // 保存之前的场景
                if (!currentScenario.isEmpty() && !currentExpected.isEmpty()) 
                {
                    String fullScenario = currentScenario;
                    if (!currentScenarioDesc.isEmpty()) 
                    {
                        fullScenario += "；" + currentScenarioDesc;
                    }
                    data.add(new TestCaseRow(currentModule, currentTestPoint, currentVerifyPoint, 
                        fullScenario, currentExpected));
                    currentScenario = "";
                    currentScenarioDesc = "";
                    currentExpected = "";
                }
                
                // 判断是测试点还是验证点
                if (currentTestPoint.isEmpty()) 
                {
                    currentTestPoint = trimmed;
                } 
                else 
                {
                    currentVerifyPoint = trimmed;
                }
                continue;
            }
            
            // 匹配场景编号
            Pattern scenarioPattern = Pattern.compile("^场景\\s*(\\d+)[：:]\\s*(.*)$");
            Matcher scenarioMatcher = scenarioPattern.matcher(trimmed);
            if (scenarioMatcher.matches()) 
            {
                // 保存之前的场景
                if (!currentScenario.isEmpty() && !currentExpected.isEmpty()) 
                {
                    String fullScenario = currentScenario;
                    if (!currentScenarioDesc.isEmpty()) 
                    {
                        fullScenario += "；" + currentScenarioDesc;
                    }
                    data.add(new TestCaseRow(currentModule, currentTestPoint, currentVerifyPoint, 
                        fullScenario, currentExpected));
                }
                
                // 开始新场景
                currentScenario = scenarioMatcher.group(2).trim();
                currentScenarioDesc = "";
                currentExpected = "";
                continue;
            }
            
            // 匹配场景描述
            Pattern descPattern = Pattern.compile("^场景描述[：:]\\s*(.*)$");
            Matcher descMatcher = descPattern.matcher(trimmed);
            if (descMatcher.matches()) 
            {
                currentScenarioDesc = descMatcher.group(1).trim();
                continue;
            }
            
            // 匹配预期结果
            Pattern expectedPattern = Pattern.compile("^预期结果[：:]\\s*(.*)$");
            Matcher expectedMatcher = expectedPattern.matcher(trimmed);
            if (expectedMatcher.matches()) 
            {
                currentExpected = expectedMatcher.group(1).trim();
                
                // 如果有完整的场景信息，立即保存
                if (!currentScenario.isEmpty()) 
                {
                    String fullScenario = currentScenario;
                    if (!currentScenarioDesc.isEmpty()) 
                    {
                        fullScenario += "；" + currentScenarioDesc;
                    }
                    data.add(new TestCaseRow(currentModule, currentTestPoint, currentVerifyPoint, 
                        fullScenario, currentExpected));
                    
                    // 重置场景相关变量
                    currentScenario = "";
                    currentScenarioDesc = "";
                    currentExpected = "";
                }
                continue;
            }
            
            // 处理长文本（可能是场景描述或预期结果的延续）
            if (trimmed.length() > 50 || trimmed.contains("。")) 
            {
                if (!currentScenarioDesc.isEmpty() && currentExpected.isEmpty()) 
                {
                    currentScenarioDesc += trimmed;
                } 
                else if (!currentExpected.isEmpty()) 
                {
                    currentExpected += trimmed;
                } 
                else if (!currentScenario.isEmpty() && currentScenarioDesc.isEmpty()) 
                {
                    currentScenarioDesc = trimmed;
                }
            }
        }
        
        // 保存最后一个场景
        if (!currentScenario.isEmpty() && !currentExpected.isEmpty()) 
        {
            String fullScenario = currentScenario;
            if (!currentScenarioDesc.isEmpty()) 
            {
                fullScenario += "；" + currentScenarioDesc;
            }
            data.add(new TestCaseRow(currentModule, currentTestPoint, currentVerifyPoint, 
                fullScenario, currentExpected));
        }
        
        return data;
    }
    
    /**
     * 测试用例行数据类
     */
    private static class TestCaseRow 
    {
        String module;
        String testPoint;
        String verifyPoint;
        String scenario;
        String expected;
        
        TestCaseRow(String module, String testPoint, String verifyPoint, String scenario, String expected) 
        {
            this.module = module != null ? module : "";
            this.testPoint = testPoint != null ? testPoint : "";
            this.verifyPoint = verifyPoint != null ? verifyPoint : "";
            this.scenario = scenario != null ? scenario : "";
            this.expected = expected != null ? expected : "";
        }
    }

    /**
     * 导出为XMind格式
     */
    @Override
    public byte[] exportToXMind(String caseTitle, String caseContent) throws Exception 
    {
        // 创建XML文档
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.newDocument();

        // 创建根元素
        Element xmapContent = doc.createElement("xmap-content");
        xmapContent.setAttribute("xmlns", "urn:xmind:xmap:xmlns:content:2.0");
        xmapContent.setAttribute("xmlns:fo", "http://www.w3.org/1999/XSL/Format");
        xmapContent.setAttribute("xmlns:svg", "http://www.w3.org/2000/svg");
        xmapContent.setAttribute("xmlns:xhtml", "http://www.w3.org/1999/xhtml");
        xmapContent.setAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink");
        xmapContent.setAttribute("version", "2.0");
        doc.appendChild(xmapContent);

        // 创建sheet
        Element sheet = doc.createElement("sheet");
        sheet.setAttribute("id", "sheet1");
        sheet.setAttribute("timestamp", String.valueOf(System.currentTimeMillis()));
        xmapContent.appendChild(sheet);

        // 创建根主题
        Element rootTopic = doc.createElement("topic");
        rootTopic.setAttribute("id", "root");
        rootTopic.setAttribute("structure-class", "org.xmind.ui.map.unbalanced");
        sheet.appendChild(rootTopic);

        Element rootTitle = doc.createElement("title");
        rootTitle.setTextContent(caseTitle);
        rootTopic.appendChild(rootTitle);

        // 解析Markdown并创建子主题
        Element children = doc.createElement("children");
        Element topics = doc.createElement("topics");
        topics.setAttribute("type", "attached");
        children.appendChild(topics);
        rootTopic.appendChild(children);

        parseMindMapFromMarkdown(doc, topics, caseContent);

        // 转换为字符串
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transformer = transformerFactory.newTransformer();
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
        
        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(doc), new StreamResult(writer));
        String xmlContent = writer.toString();

        // 创建XMind文件(ZIP格式)
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ZipOutputStream zos = new ZipOutputStream(baos);

        // 添加content.xml
        ZipEntry contentEntry = new ZipEntry("content.xml");
        zos.putNextEntry(contentEntry);
        zos.write(xmlContent.getBytes("UTF-8"));
        zos.closeEntry();

        // 添加META-INF/manifest.xml
        ZipEntry manifestEntry = new ZipEntry("META-INF/manifest.xml");
        zos.putNextEntry(manifestEntry);
        String manifest = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                         "<manifest xmlns=\"urn:xmind:xmap:xmlns:manifest:1.0\">\n" +
                         "  <file-entry full-path=\"content.xml\" media-type=\"text/xml\"/>\n" +
                         "</manifest>";
        zos.write(manifest.getBytes("UTF-8"));
        zos.closeEntry();

        zos.close();
        return baos.toByteArray();
    }

    /**
     * 解析Markdown到XMind结构 - 与前端parseMindMapFromMarkdown逻辑一致
     */
    private void parseMindMapFromMarkdown(Document doc, Element parent, String content) 
    {
        String[] lines = content.split("\n");
        int topicId = 1;
        
        // 上下文状态
        Element moduleNode = null;
        Element testPointNode = null;
        Element verifyPointNode = null;
        Element scenarioNode = null;
        
        for (String line : lines) 
        {
            String trimmed = line.trim();
            if (trimmed.isEmpty()) continue;
            
            // 忽略 # 一级标题（已经有根标题 caseTitle）
            if (trimmed.startsWith("# ") && !trimmed.startsWith("## ")) 
            {
                continue;
            }
            
            // 标准 Markdown 标题
            if (trimmed.startsWith("## ") && !trimmed.startsWith("### ")) 
            {
                moduleNode = createTopic(doc, "n" + topicId++, trimmed.substring(3).trim());
                parent.appendChild(moduleNode);
                testPointNode = verifyPointNode = scenarioNode = null;
                continue;
            } 
            else if (trimmed.startsWith("### ") && moduleNode != null) 
            {
                Element children = getOrCreateChildren(doc, moduleNode);
                testPointNode = createTopic(doc, "n" + topicId++, trimmed.substring(4).trim());
                children.appendChild(testPointNode);
                verifyPointNode = scenarioNode = null;
                continue;
            } 
            else if (trimmed.startsWith("#### ") && testPointNode != null) 
            {
                Element children = getOrCreateChildren(doc, testPointNode);
                verifyPointNode = createTopic(doc, "n" + topicId++, trimmed.substring(5).trim());
                children.appendChild(verifyPointNode);
                scenarioNode = null;
                continue;
            } 
            else if (trimmed.startsWith("##### ")) 
            {
                Element targetParent = verifyPointNode != null ? verifyPointNode : testPointNode;
                if (targetParent != null) 
                {
                    Element children = getOrCreateChildren(doc, targetParent);
                    scenarioNode = createTopic(doc, "n" + topicId++, trimmed.substring(6).trim());
                    children.appendChild(scenarioNode);
                }
                continue;
            } 
            else if (trimmed.startsWith("###### ")) 
            {
                Element targetParent = scenarioNode != null ? scenarioNode : 
                                      (verifyPointNode != null ? verifyPointNode : testPointNode);
                if (targetParent != null) 
                {
                    Element children = getOrCreateChildren(doc, targetParent);
                    Element topic = createTopic(doc, "n" + topicId++, trimmed.substring(7).trim());
                    children.appendChild(topic);
                }
                continue;
            }
            
            // 匹配功能模块
            Pattern modulePattern = Pattern.compile("^(?:功能模块|模块)[：:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
            Matcher moduleMatcher = modulePattern.matcher(trimmed);
            if (moduleMatcher.matches()) 
            {
                moduleNode = createTopic(doc, "n" + topicId++, moduleMatcher.group(1).trim());
                parent.appendChild(moduleNode);
                testPointNode = verifyPointNode = scenarioNode = null;
                continue;
            }
            
            // 匹配测试点
            Pattern testPointPattern = Pattern.compile("^(?:测试点|测试项)[：:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
            Matcher testPointMatcher = testPointPattern.matcher(trimmed);
            if (testPointMatcher.matches() && moduleNode != null) 
            {
                Element children = getOrCreateChildren(doc, moduleNode);
                testPointNode = createTopic(doc, "n" + topicId++, testPointMatcher.group(1).trim());
                children.appendChild(testPointNode);
                verifyPointNode = scenarioNode = null;
                continue;
            }
            
            // 匹配验证点
            Pattern verifyPointPattern = Pattern.compile("^(?:验证点|检查点)[：:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
            Matcher verifyPointMatcher = verifyPointPattern.matcher(trimmed);
            if (verifyPointMatcher.matches() && testPointNode != null) 
            {
                Element children = getOrCreateChildren(doc, testPointNode);
                verifyPointNode = createTopic(doc, "n" + topicId++, verifyPointMatcher.group(1).trim());
                children.appendChild(verifyPointNode);
                scenarioNode = null;
                continue;
            }
            
            // 匹配场景编号
            Pattern scenarioNumPattern = Pattern.compile("^场景\\s*(\\d+)[：:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
            Matcher scenarioNumMatcher = scenarioNumPattern.matcher(trimmed);
            if (scenarioNumMatcher.matches()) 
            {
                Element targetParent = verifyPointNode != null ? verifyPointNode : 
                                      (testPointNode != null ? testPointNode : moduleNode);
                if (targetParent != null) 
                {
                    Element children = getOrCreateChildren(doc, targetParent);
                    scenarioNode = createTopic(doc, "n" + topicId++, scenarioNumMatcher.group(2).trim());
                    children.appendChild(scenarioNode);
                }
                continue;
            }
            
            // 匹配场景描述
            Pattern scenarioDescPattern = Pattern.compile("^(?:场景描述|描述)[：:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
            Matcher scenarioDescMatcher = scenarioDescPattern.matcher(trimmed);
            if (scenarioDescMatcher.matches() && scenarioNode != null) 
            {
                Element children = getOrCreateChildren(doc, scenarioNode);
                Element topic = createTopic(doc, "n" + topicId++, "描述：" + scenarioDescMatcher.group(1).trim());
                children.appendChild(topic);
                continue;
            }
            
            // 匹配预期结果
            Pattern expectedPattern = Pattern.compile("^(?:预期结果|期望结果)[：:]\\s*(.+)$", Pattern.CASE_INSENSITIVE);
            Matcher expectedMatcher = expectedPattern.matcher(trimmed);
            if (expectedMatcher.matches() && scenarioNode != null) 
            {
                Element children = getOrCreateChildren(doc, scenarioNode);
                Element topic = createTopic(doc, "n" + topicId++, "预期：" + expectedMatcher.group(1).trim());
                children.appendChild(topic);
                continue;
            }
            
            // 列表项
            if (trimmed.startsWith("-") || trimmed.startsWith("*") || trimmed.matches("^\\d+\\..*")) 
            {
                String text = trimmed.replaceFirst("^[-*\\d.]+\\s*", "").trim();
                Element targetParent = scenarioNode != null ? scenarioNode : 
                                      (verifyPointNode != null ? verifyPointNode : 
                                      (testPointNode != null ? testPointNode : moduleNode));
                if (targetParent != null) 
                {
                    Element children = getOrCreateChildren(doc, targetParent);
                    Element topic = createTopic(doc, "n" + topicId++, text);
                    children.appendChild(topic);
                }
                continue;
            }
            
            // 未匹配的行，如果较短且不包含句号，可能是标题
            if (trimmed.length() < 80 && !trimmed.contains("。") && !trimmed.contains(".")) 
            {
                Element targetParent = testPointNode != null ? testPointNode : moduleNode;
                if (targetParent != null && verifyPointNode == null) 
                {
                    Element children = getOrCreateChildren(doc, targetParent);
                    verifyPointNode = createTopic(doc, "n" + topicId++, trimmed);
                    children.appendChild(verifyPointNode);
                    scenarioNode = null;
                }
            }
        }
    }

    /**
     * 创建主题节点
     */
    private Element createTopic(Document doc, String id, String title) 
    {
        Element topic = doc.createElement("topic");
        topic.setAttribute("id", id);
        
        Element titleElement = doc.createElement("title");
        titleElement.setTextContent(title);
        topic.appendChild(titleElement);
        
        return topic;
    }

    /**
     * 获取或创建children节点
     */
    private Element getOrCreateChildren(Document doc, Element parent) 
    {
        Element children = (Element) parent.getElementsByTagName("children").item(0);
        if (children == null) 
        {
            children = doc.createElement("children");
            Element topics = doc.createElement("topics");
            topics.setAttribute("type", "attached");
            children.appendChild(topics);
            parent.appendChild(children);
            return topics;
        }
        return (Element) children.getElementsByTagName("topics").item(0);
    }

    /**
     * 格式化CSV行
     */
    private String formatCsvLine(String... values) 
    {
        StringBuilder line = new StringBuilder();
        for (int i = 0; i < values.length; i++) 
        {
            if (i > 0) line.append(",");
            line.append("\"").append(escapeCsv(values[i])).append("\"");
        }
        line.append("\n");
        return line.toString();
    }

    /**
     * 转义CSV特殊字符
     */
    private String escapeCsv(String value) 
    {
        if (value == null) return "";
        return value.replace("\"", "\"\"").replace("\n", " ").replace("\r", "");
    }

    /**
     * 提取值
     */
    private String extractValue(String line) 
    {
        // 支持中英文冒号
        int colonIndex = line.indexOf(":");
        if (colonIndex == -1) 
        {
            colonIndex = line.indexOf("：");
        }
        
        if (colonIndex > 0 && colonIndex < line.length() - 1) 
        {
            String value = line.substring(colonIndex + 1).trim();
            // 移除可能的markdown加粗标记
            value = value.replaceAll("\\*\\*", "");
            return value;
        }
        return "";
    }
}
