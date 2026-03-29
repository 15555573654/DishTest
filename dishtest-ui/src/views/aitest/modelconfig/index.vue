<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="模型名称" prop="modelName">
        <el-input
          v-model="queryParams.modelName"
          placeholder="请输入模型名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="模型类型" prop="modelType">
        <el-input
          v-model="queryParams.modelType"
          placeholder="请输入模型类型"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="正常" value="0" />
          <el-option label="停用" value="1" />
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
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['aitest:modelconfig:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['aitest:modelconfig:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="modelconfigList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="模型ID" align="center" prop="modelId" width="80" />
      <el-table-column label="模型名称" align="center" prop="modelName" show-overflow-tooltip />
      <el-table-column label="模型类型" align="center" prop="modelType" width="120" />
      <el-table-column label="模型版本" align="center" prop="modelVersion" width="150" show-overflow-tooltip />
      <el-table-column label="API地址" align="center" prop="apiUrl" show-overflow-tooltip />
      <el-table-column label="是否默认" align="center" prop="isDefault" width="100">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.isDefault === '1'" type="success">是</el-tag>
          <el-tag v-else type="info">否</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === '0'" type="success">正常</el-tag>
          <el-tag v-else type="danger">停用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="180">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['aitest:modelconfig:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['aitest:modelconfig:remove']"
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

    <!-- 添加或修改AI模型配置对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="模型名称" prop="modelName">
          <el-input v-model="form.modelName" placeholder="请输入模型名称" />
        </el-form-item>
        <el-form-item label="模型类型" prop="modelType">
          <el-input v-model="form.modelType" placeholder="如: openai, deepseek, moonshot 等" />
          <div style="color: #909399; font-size: 12px; margin-top: 5px;">
            支持任何 OpenAI 兼容的 API，可自由输入模型类型标识
          </div>
        </el-form-item>
        <el-form-item label="API地址" prop="apiUrl">
          <el-input v-model="form.apiUrl" placeholder="请输入API地址" />
        </el-form-item>
        <el-form-item label="API密钥" prop="apiKey">
          <el-input v-model="form.apiKey" type="password" placeholder="请输入API密钥(本地模型可不填)" show-password />
        </el-form-item>
        <el-form-item label="模型版本" prop="modelVersion">
          <el-input v-model="form.modelVersion" placeholder="如: gpt-3.5-turbo, claude-3-sonnet等" />
        </el-form-item>
        <el-form-item label="最大Token数" prop="maxTokens">
          <el-input-number v-model="form.maxTokens" :min="1024" :max="32768" :step="1024" style="width: 100%" />
        </el-form-item>
        <el-form-item label="温度参数" prop="temperature">
          <el-row :gutter="10">
            <el-col :span="20">
              <el-slider v-model="form.temperature" :min="0" :max="2" :step="0.1" show-input :precision="2" :disabled="form.supportTemperature === '0'" />
            </el-col>
            <el-col :span="4">
              <el-checkbox v-model="temperatureDisabled" @change="handleTemperatureToggle">禁用</el-checkbox>
            </el-col>
          </el-row>
          <div style="color: #909399; font-size: 12px; margin-top: 5px;">
            温度越高,生成内容越随机;温度越低,生成内容越确定。某些模型不支持此参数,可以禁用。
          </div>
        </el-form-item>
        <el-form-item label="是否默认" prop="isDefault">
          <el-radio-group v-model="form.isDefault">
            <el-radio label="1">是</el-radio>
            <el-radio label="0">否</el-radio>
          </el-radio-group>
          <div style="color: #909399; font-size: 12px; margin-top: 5px;">
            设置为默认后,该模型将在生成测试用例时优先使用
          </div>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="0">正常</el-radio>
            <el-radio label="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="success" icon="el-icon-connection" @click="handleTestConnection" :loading="testLoading">测试连接</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listModelconfig, getModelconfig, delModelconfig, addModelconfig, updateModelconfig, testConnection } from "@/api/aitest/modelconfig";

export default {
  name: "Modelconfig",
  data() {
    return {
      // 遮罩层
      loading: true,
      // 测试连接加载状态
      testLoading: false,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // AI模型配置表格数据
      modelconfigList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 温度参数是否禁用
      temperatureDisabled: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        modelName: null,
        modelType: null,
        isDefault: null,
        status: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        modelName: [
          { required: true, message: "模型名称不能为空", trigger: "blur" }
        ],
        modelType: [
          { required: true, message: "请选择模型类型", trigger: "change" }
        ],
        apiUrl: [
          { required: true, message: "API地址不能为空", trigger: "blur" }
        ]
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询AI模型配置列表 */
    getList() {
      this.loading = true;
      listModelconfig(this.queryParams).then(response => {
        this.modelconfigList = response.rows;
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
        modelId: null,
        modelName: null,
        modelType: null,
        apiUrl: null,
        apiKey: null,
        modelVersion: null,
        maxTokens: 4096,
        temperature: 0.7,
        isDefault: "0",
        status: "0",
        supportTemperature: "1",
        remark: null
      };
      this.temperatureDisabled = false;
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
      this.ids = selection.map(item => item.modelId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加AI模型配置";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const modelId = row.modelId || this.ids
      getModelconfig(modelId).then(response => {
        this.form = response.data;
        // 转换temperature为数字
        if (this.form.temperature) {
          this.form.temperature = parseFloat(this.form.temperature);
        }
        // 设置温度参数禁用状态
        this.temperatureDisabled = this.form.supportTemperature === '0';
        this.open = true;
        this.title = "修改AI模型配置";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.modelId != null) {
            updateModelconfig(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addModelconfig(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const modelIds = row.modelId || this.ids;
      this.$modal.confirm('是否确认删除AI模型配置编号为"' + modelIds + '"的数据项？').then(() => {
        return delModelconfig(modelIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 测试连接 */
    handleTestConnection() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          this.testLoading = true;
          testConnection(this.form).then(response => {
            try {
              const result = JSON.parse(response.msg);
              if (result.success) {
                this.$modal.msgSuccess(result.message);
                // 更新supportTemperature字段
                if (result.supportTemperature !== undefined) {
                  this.form.supportTemperature = result.supportTemperature;
                  this.temperatureDisabled = result.supportTemperature === '0';
                  if (result.supportTemperature === '0') {
                    this.$modal.msgWarning("检测到该模型不支持temperature参数，已自动禁用");
                  }
                }
              } else {
                this.$modal.msgError(result.message);
              }
            } catch (e) {
              this.$modal.msgError("测试失败: " + response.msg);
            }
          }).catch(() => {
            this.$modal.msgError("测试连接失败");
          }).finally(() => {
            this.testLoading = false;
          });
        }
      });
    },
    /** 温度参数禁用切换 */
    handleTemperatureToggle(val) {
      if (val) {
        this.form.supportTemperature = '0';
        this.form.temperature = 0;
      } else {
        this.form.supportTemperature = '1';
        this.form.temperature = 0.7;
      }
    }
  }
};
</script>
