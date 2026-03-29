package com.dishtest.system.domain;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.dishtest.common.annotation.Excel;
import com.dishtest.common.core.domain.BaseEntity;

/**
 * 测试用例对象 test_case
 * 
 * @author dishtest
 */
public class TestCase extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 测试用例ID */
    private Long caseId;

    /** 用例标题 */
    private String caseTitle;

    /** 输入文档内容 */
    private String inputDoc;

    /** 文档文件名 */
    private String fileName;

    /** 文档文件路径 */
    private String filePath;

    /** 文档文件类型 */
    private String fileType;

    /** 生成的测试用例内容(Markdown格式) */
    private String caseContent;

    /** 生成状态（0待生成 1生成中 2已完成 3失败） */
    private String status;

    /** AI模型 */
    @Excel(name = "AI模型")
    private String aiModel;

    /** 提示词配置ID */
    private Long promptConfigId;

    /** 模型配置ID */
    private Long modelConfigId;

    /** 生成耗时(秒) */
    private Integer generateTime;

    /** 错误信息 */
    private String errorMsg;

    public Long getCaseId()
    {
        return caseId;
    }

    public void setCaseId(Long caseId)
    {
        this.caseId = caseId;
    }

    @NotBlank(message = "用例标题不能为空")
    @Size(min = 0, max = 200, message = "用例标题不能超过200个字符")
    public String getCaseTitle()
    {
        return caseTitle;
    }

    public void setCaseTitle(String caseTitle)
    {
        this.caseTitle = caseTitle;
    }

    @NotBlank(message = "输入文档不能为空")
    public String getInputDoc()
    {
        return inputDoc;
    }

    public void setInputDoc(String inputDoc)
    {
        this.inputDoc = inputDoc;
    }

    public String getCaseContent()
    {
        return caseContent;
    }

    public void setCaseContent(String caseContent)
    {
        this.caseContent = caseContent;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getAiModel() 
    {
        return aiModel;
    }

    public void setAiModel(String aiModel) 
    {
        this.aiModel = aiModel;
    }

    public Long getPromptConfigId() 
    {
        return promptConfigId;
    }

    public void setPromptConfigId(Long promptConfigId) 
    {
        this.promptConfigId = promptConfigId;
    }

    public Long getModelConfigId() 
    {
        return modelConfigId;
    }

    public void setModelConfigId(Long modelConfigId) 
    {
        this.modelConfigId = modelConfigId;
    }

    public Integer getGenerateTime()
    {
        return generateTime;
    }

    public void setGenerateTime(Integer generateTime)
    {
        this.generateTime = generateTime;
    }

    public String getErrorMsg()
    {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg)
    {
        this.errorMsg = errorMsg;
    }

    public String getFileName()
    {
        return fileName;
    }

    public void setFileName(String fileName)
    {
        this.fileName = fileName;
    }

    public String getFilePath()
    {
        return filePath;
    }

    public void setFilePath(String filePath)
    {
        this.filePath = filePath;
    }

    public String getFileType()
    {
        return fileType;
    }

    public void setFileType(String fileType)
    {
        this.fileType = fileType;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("caseId", getCaseId())
            .append("caseTitle", getCaseTitle())
            .append("inputDoc", getInputDoc())
            .append("fileName", getFileName())
            .append("filePath", getFilePath())
            .append("fileType", getFileType())
            .append("caseContent", getCaseContent())
            .append("status", getStatus())
            .append("aiModel", getAiModel())
            .append("promptConfigId", getPromptConfigId())
            .append("modelConfigId", getModelConfigId())
            .append("generateTime", getGenerateTime())
            .append("errorMsg", getErrorMsg())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
