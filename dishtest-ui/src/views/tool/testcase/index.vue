<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="用例标题" prop="caseTitle">
        <el-input
          v-model="queryParams.caseTitle"
          placeholder="请输入用例标题"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="生成状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择生成状态" clearable>
          <el-option label="待生成" value="0" />
          <el-option label="生成中" value="1" />
          <el-option label="已完成" value="2" />
          <el-option label="失败" value="3" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-upload"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['tool:testcase:add']"
        >上传文档</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['tool:testcase:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="testCaseList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="用例ID" align="center" prop="caseId" width="80" />
      <el-table-column label="用例标题" align="center" prop="caseTitle" :show-overflow-tooltip="true" />
      <el-table-column label="文档文件" align="center" prop="fileName" :show-overflow-tooltip="true" width="180" />
      <el-table-column label="生成状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === '0'" type="info">待生成</el-tag>
          <el-tag v-else-if="scope.row.status === '1'" type="warning">生成中</el-tag>
          <el-tag v-else-if="scope.row.status === '2'" type="success">已完成</el-tag>
          <el-tag v-else-if="scope.row.status === '3'" type="danger">失败</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="AI模型" align="center" prop="modelConfigId" width="120">
        <template slot-scope="scope">
          <span v-if="scope.row.modelConfigId">配置ID: {{ scope.row.modelConfigId }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="生成耗时" align="center" prop="generateTime" width="100">
        <template slot-scope="scope">
          <span v-if="scope.row.generateTime">{{ scope.row.generateTime }}秒</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="280">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleView(scope.row)"
            v-hasPermi="['tool:testcase:query']"
          >查看</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleEdit(scope.row)"
            v-hasPermi="['tool:testcase:edit']"
          >编辑</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-refresh"
            @click="handleGenerate(scope.row)"
            v-hasPermi="['tool:testcase:generate']"
            :disabled="scope.row.status === '1'"
          >生成</el-button>
          <el-dropdown @command="(command) => handleExport(command, scope.row)" v-hasPermi="['tool:testcase:export']">
            <el-button size="mini" type="text">
              导出<i class="el-icon-arrow-down el-icon--right"></i>
            </el-button>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item command="csv" :disabled="scope.row.status !== '2'">CSV格式</el-dropdown-item>
              <el-dropdown-item command="xmind" :disabled="scope.row.status !== '2'">XMind格式</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['tool:testcase:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 上传文档对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="600px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="用例标题" prop="caseTitle">
          <el-input v-model="form.caseTitle" placeholder="请输入用例标题" />
        </el-form-item>
        <el-form-item label="上传文档" prop="file" v-if="!form.caseId">
          <el-upload
            ref="upload"
            :limit="1"
            accept=".txt,.md,.doc,.docx,.pdf,.xlsx,.xls,.csv"
            :action="uploadUrl"
            :headers="uploadHeaders"
            :file-list="fileList"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
            :before-upload="beforeUpload"
            :auto-upload="false">
            <el-button slot="trigger" size="small" type="primary">选取文件</el-button>
            <div slot="tip" class="el-upload__tip">支持格式: txt, md, doc, docx, pdf, xlsx, xls, csv，文件大小不超过10MB</div>
          </el-upload>
        </el-form-item>
        <el-form-item label="当前文档" v-if="form.caseId && form.fileName">
          <el-tag>{{ form.fileName }}</el-tag>
        </el-form-item>
        <el-form-item label="模型配置" prop="modelConfigId">
          <el-select v-model="form.modelConfigId" placeholder="请选择模型配置(可选)" @change="handleModelChange" clearable>
            <el-option
              v-for="model in modelConfigList"
              :key="model.modelId"
              :label="model.modelName"
              :value="model.modelId">
              <span>{{ model.modelName }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">{{ model.modelType }}</span>
            </el-option>
          </el-select>
          <div style="color: #909399; font-size: 12px; margin-top: 5px;">
            不选择则使用默认模型配置
          </div>
        </el-form-item>
        <el-form-item label="提示词配置" prop="promptConfigId">
          <el-select v-model="form.promptConfigId" placeholder="请选择提示词配置" clearable>
            <el-option
              v-for="prompt in filteredPromptList"
              :key="prompt.configId"
              :label="prompt.configName"
              :value="prompt.configId">
            </el-option>
          </el-select>
          <div style="color: #909399; font-size: 12px; margin-top: 5px;">
            不选择则使用默认提示词配置
          </div>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 查看测试用例对话框 -->
    <el-dialog title="测试用例详情" :visible.sync="viewOpen" width="80%" append-to-body>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="用例标题">{{ viewForm.caseTitle }}</el-descriptions-item>
        <el-descriptions-item label="生成状态">
          <el-tag v-if="viewForm.status === '0'" type="info">待生成</el-tag>
          <el-tag v-else-if="viewForm.status === '1'" type="warning">生成中</el-tag>
          <el-tag v-else-if="viewForm.status === '2'" type="success">已完成</el-tag>
          <el-tag v-else-if="viewForm.status === '3'" type="danger">失败</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="文档文件">{{ viewForm.fileName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="AI模型">
          <span v-if="viewForm.aiModel === 'openai'">OpenAI</span>
          <span v-else-if="viewForm.aiModel === 'claude'">Claude</span>
          <span v-else-if="viewForm.aiModel === 'qwen'">通义千问</span>
          <span v-else-if="viewForm.aiModel === 'local'">本地模型</span>
          <span v-else>{{ viewForm.aiModel }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="生成耗时">
          <span v-if="viewForm.generateTime">{{ viewForm.generateTime }}秒</span>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ parseTime(viewForm.createTime) }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">输入文档</el-divider>
      <div class="doc-content">{{ viewForm.inputDoc }}</div>

      <el-divider content-position="left">生成的测试用例</el-divider>
      <div v-if="viewForm.status === '2'">
        <div style="margin-bottom: 10px;">
          <el-radio-group v-model="viewMode" size="small" @change="handleViewModeChange">
            <el-radio-button label="markdown">Markdown</el-radio-button>
            <el-radio-button label="table">表格</el-radio-button>
            <el-radio-button label="mindmap">思维导图</el-radio-button>
          </el-radio-group>
          <el-button size="small" type="primary" icon="el-icon-download" @click="exportToCsv(viewForm)" style="margin-left: 10px;">导出CSV</el-button>
          <el-button size="small" type="success" icon="el-icon-download" @click="exportToXMind(viewForm)">导出XMind</el-button>
        </div>

        <!-- Markdown视图 -->
        <div v-if="viewMode === 'markdown'" class="markdown-body" v-html="renderMarkdown(viewForm.caseContent)"></div>

        <!-- 表格视图 -->
        <div v-if="viewMode === 'table'">
          <el-table :data="parsedTableData" border style="width: 100%">
            <el-table-column type="index" label="#" width="50"></el-table-column>
            <el-table-column prop="module" label="功能模块" width="140"></el-table-column>
            <el-table-column prop="testPoint" label="测试点" width="180"></el-table-column>
            <el-table-column prop="verifyPoint" label="验证点" width="180"></el-table-column>
            <el-table-column prop="scenario" label="场景描述" min-width="200">
              <template slot-scope="scope">
                <div class="cell-wrap">{{ scope.row.scenario }}</div>
              </template>
            </el-table-column>
            <el-table-column prop="expected" label="预期结果" min-width="200">
              <template slot-scope="scope">
                <div class="cell-wrap">{{ scope.row.expected }}</div>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 思维导图视图 -->
        <div v-if="viewMode === 'mindmap'" id="mindmap-container" style="width: 100%; height: 600px; border: 1px solid #ddd;"></div>
      </div>
      <div v-else-if="viewForm.status === '3'" class="error-msg">
        <el-alert title="生成失败" type="error" :description="viewForm.errorMsg" :closable="false" />
      </div>
      <div v-else class="empty-content">
        <el-empty description="暂无测试用例内容"></el-empty>
      </div>

      <div slot="footer" class="dialog-footer">
        <el-button @click="viewOpen = false">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listTestCase, getTestCase, delTestCase, uploadTestCase, updateTestCase, generateTestCase, exportCsv, exportXMind } from "@/api/tool/testcase";
import { listModelconfig } from "@/api/aitest/modelconfig";
import { listPromptconfig } from "@/api/aitest/promptconfig";
import { getToken } from "@/utils/auth";
import { marked } from 'marked';
import testcaseMixin from "./mixin";

export default {
  mixins: [testcaseMixin],
  name: "TestCase",
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 测试用例表格数据
      testCaseList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 是否显示查看弹出层
      viewOpen: false,
      // 查看模式 (markdown/table/mindmap)
      viewMode: 'markdown',
      // 表格数据
      parsedTableData: [],
      // 思维导图实例
      mindMapInstance: null,
      // 模型配置列表
      modelConfigList: [],
      // 提示词配置列表
      promptConfigList: [],
      // 上传文件列表
      fileList: [],
      // 上传地址
      uploadUrl: process.env.VUE_APP_BASE_API + "/tool/testcase/upload",
      // 上传请求头
      uploadHeaders: { Authorization: "Bearer " + getToken() },
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        caseTitle: null,
        status: null,
        aiModel: null
      },
      // 表单参数
      form: {
        aiModel: null,
        promptConfigId: null,
        modelConfigId: null
      },
      // 查看表单参数
      viewForm: {},
      // 表单校验
      rules: {
        caseTitle: [
          { required: true, message: "用例标题不能为空", trigger: "blur" }
        ]
      }
    };
  },
  computed: {
    // 根据选择的模型过滤提示词配置
    filteredPromptList() {
      if (!this.form.modelConfigId || !this.modelConfigList.length) {
        return this.promptConfigList;
      }

      // 找到选中的模型配置
      const selectedModel = this.modelConfigList.find(m => m.modelId === this.form.modelConfigId);
      if (!selectedModel) {
        return this.promptConfigList;
      }

      // 过滤出匹配的提示词配置(模型类型匹配或通用配置)
      return this.promptConfigList.filter(p =>
        !p.aiModel || p.aiModel === selectedModel.modelType
      );
    }
  },
  created() {
    this.getList();
    this.loadModelConfigs();
    this.loadPromptConfigs();
  },
  methods: {
    /** 加载模型配置列表 */
    loadModelConfigs() {
      listModelconfig({ status: '0' }).then(response => {
        this.modelConfigList = response.rows || [];
        // 如果有默认配置且表单中没有选择,自动选中默认配置
        if (!this.form.modelConfigId && this.modelConfigList.length > 0) {
          const defaultConfig = this.modelConfigList.find(c => c.isDefault === '1');
          if (defaultConfig) {
            this.form.modelConfigId = defaultConfig.modelId;
          } else if (this.modelConfigList.length > 0) {
            // 如果没有默认配置,选择第一个
            this.form.modelConfigId = this.modelConfigList[0].modelId;
          }
        }
      });
    },
    /** 加载提示词配置列表 */
    loadPromptConfigs() {
      listPromptconfig({ status: '0' }).then(response => {
        this.promptConfigList = response.rows || [];
      });
    },
    /** AI模型变更时,筛选对应的配置 */
    handleModelChange() {
      // 清空提示词选择,让用户重新选择匹配的提示词
      this.form.promptConfigId = null;
    },
    /** 查询测试用例列表 */
    getList() {
      this.loading = true;
      listTestCase(this.queryParams).then(response => {
        this.testCaseList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        caseId: null,
        caseTitle: null,
        modelConfigId: null,
        promptConfigId: null,
        remark: null
      };
      this.fileList = [];
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.caseId)
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "上传测试文档";
      // 弹窗打开后应用默认模型配置，使选择生效
      this.$nextTick(() => {
        if (this.modelConfigList.length > 0 && !this.form.modelConfigId) {
          const defaultConfig = this.modelConfigList.find(c => c.isDefault === '1') || this.modelConfigList[0];
          this.form.modelConfigId = defaultConfig.modelId;
        }
      });
    },
    /** 编辑按钮操作 */
    handleEdit(row) {
      const caseId = row.caseId;
      getTestCase(caseId).then(response => {
        this.form = {
          caseId: response.data.caseId,
          caseTitle: response.data.caseTitle,
          fileName: response.data.fileName,
          modelConfigId: response.data.modelConfigId,
          promptConfigId: response.data.promptConfigId,
          remark: response.data.remark
        };
        this.open = true;
        this.title = "编辑测试用例配置";
      });
    },
    /** 查看按钮操作 */
    handleView(row) {
      this.loading = true;
      const caseId = row.caseId;
      getTestCase(caseId).then(response => {
        this.viewForm = response.data;
        this.viewMode = 'markdown';
        this.parseContentToTable(response.data.caseContent);
        this.viewOpen = true;
        this.loading = false;
      });
    },
    /** 切换视图模式 */
    handleViewModeChange() {
      if (this.viewMode === 'mindmap') {
        this.$nextTick(() => {
          this.renderMindMap();
        });
      }
    },
    /** 生成按钮操作 */
    handleGenerate(row) {
      this.$modal.confirm('是否确认生成测试用例"' + row.caseTitle + '"？').then(() => {
        return generateTestCase(row.caseId);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("生成任务已提交，请稍后刷新查看结果");
      }).catch(() => {});
    },
    /** 文件上传前校验 */
    beforeUpload(file) {
      const isLt10M = file.size / 1024 / 1024 < 10;
      if (!isLt10M) {
        this.$modal.msgError('上传文件大小不能超过 10MB!');
        return false;
      }
      return true;
    },
    /** 文件上传成功 */
    handleUploadSuccess(response, file, fileList) {
      if (response.code === 200) {
        this.$modal.msgSuccess("上传成功");
        this.open = false;
        this.getList();
      } else {
        this.$modal.msgError(response.msg);
      }
    },
    /** 文件上传失败 */
    handleUploadError(err, file, fileList) {
      this.$modal.msgError("上传失败: " + err);
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          // 如果有caseId,说明是编辑模式
          if (this.form.caseId) {
            updateTestCase(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            // 新增模式:上传文件
            const uploadFiles = this.$refs.upload.uploadFiles;
            if (uploadFiles.length === 0) {
              this.$modal.msgError("请选择要上传的文档");
              return;
            }

            const formData = new FormData();
            formData.append('file', uploadFiles[0].raw);
            formData.append('caseTitle', this.form.caseTitle);
            if (this.form.modelConfigId) {
              formData.append('modelConfigId', this.form.modelConfigId);
            }
            if (this.form.promptConfigId) {
              formData.append('promptConfigId', this.form.promptConfigId);
            }
            if (this.form.remark) {
              formData.append('remark', this.form.remark);
            }

            uploadTestCase(formData).then(response => {
              this.$modal.msgSuccess("上传成功");
              this.open = false;
              this.reset();
              this.getList();
            }).catch(error => {
              this.$modal.msgError("上传失败");
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const caseIds = row.caseId || this.ids;
      this.$modal.confirm('是否确认删除测试用例编号为"' + caseIds + '"的数据项？').then(() => {
        return delTestCase(caseIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport(command, row) {
      if (row.status !== '2') {
        this.$modal.msgWarning("请先生成测试用例");
        return;
      }

      if (command === 'csv') {
        this.exportToCsv(row);
      } else if (command === 'xmind') {
        this.exportToXMind(row);
      }
    },
    /** 导出为CSV */
    exportToCsv(row) {
      this.$modal.confirm('是否确认导出测试用例"' + row.caseTitle + '"为CSV格式？').then(() => {
        return exportCsv(row.caseId);
      }).then(response => {
        this.downloadFile(response, row.caseTitle + '.csv', 'text/csv');
        this.$modal.msgSuccess("导出成功");
      }).catch(() => {});
    },
    /** 导出为XMind */
    exportToXMind(row) {
      this.$modal.confirm('是否确认导出测试用例"' + row.caseTitle + '"为XMind格式？').then(() => {
        return exportXMind(row.caseId);
      }).then(response => {
        this.downloadFile(response, row.caseTitle + '.xmind', 'application/octet-stream');
        this.$modal.msgSuccess("导出成功");
      }).catch(() => {});
    },
    /** 下载文件 */
    downloadFile(data, filename, mimeType) {
      const blob = new Blob([data], { type: mimeType });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      link.click();
      window.URL.revokeObjectURL(url);
    },
    /** 渲染Markdown */
    /** 渲染思维导图 */
    renderMindMap() {
      // 使用 mixin 中的 renderMindMap 方法
      // 传入容器ID、内容和标题
      const containerId = 'mindmap-container';
      const content = this.viewForm.caseContent;
      const title = this.viewForm.caseTitle;

      // 调用 mixin 中的方法（需要通过 this 访问）
      if (typeof jsMind === 'undefined') {
        this.$modal.msgError("思维导图库加载失败,请刷新页面重试");
        return;
      }

      if (!content) return;

      const container = document.getElementById(containerId);
      if (!container) return;
      container.innerHTML = '';

      try {
        const jm = new jsMind({
          container: containerId,
          theme: 'primary',
          editable: false,
          mode: 'full'
        });
        const mindData = this.parseContentToMindMap(content, title);
        console.log('思维导图数据:', mindData);
        jm.show(mindData);
        this.mindMapInstance = jm;
        console.log('思维导图渲染成功');
      } catch (error) {
        console.error('思维导图渲染失败:', error);
        this.$modal.msgError("思维导图渲染失败: " + error.message);
      }
    },
    /** 提取值 */
    extractValue(line) {
      const colonIndex = line.indexOf(':');
      const colonIndex2 = line.indexOf('：');
      const index = colonIndex > 0 ? colonIndex : colonIndex2;
      if (index > 0 && index < line.length - 1) {
        return line.substring(index + 1).trim();
      }
      return '';
    }
  }
};
</script>

<style scoped>
.doc-content {
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
  white-space: pre-wrap;
  word-wrap: break-word;
  max-height: 300px;
  overflow-y: auto;
}

.markdown-body {
  padding: 15px;
  background-color: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  max-height: 500px;
  overflow-y: auto;
}

.cell-wrap {
  white-space: pre-wrap;
  word-break: break-word;
  line-height: 1.5;
}

.error-msg {
  margin: 15px 0;
}

.empty-content {
  padding: 30px 0;
}

.custom-tree-node {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 14px;
  padding-right: 8px;
}

#mindmap-container {
  width: 100%;
  height: 600px;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  overflow: auto;
}
</style>
