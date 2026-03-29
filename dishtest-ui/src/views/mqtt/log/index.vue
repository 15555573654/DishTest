<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="操作类型" prop="operationType">
        <el-select v-model="queryParams.operationType" placeholder="操作类型" clearable style="width: 240px">
          <el-option label="启动设备" value="启动设备" />
          <el-option label="停止设备" value="停止设备" />
          <el-option label="暂停设备" value="暂停设备" />
          <el-option label="恢复设备" value="恢复设备" />
          <el-option label="更新脚本" value="更新脚本" />
          <el-option label="下发配置" value="下发配置" />
          <el-option label="删除设备" value="删除设备" />
        </el-select>
      </el-form-item>
      <el-form-item label="操作人员" prop="username">
        <el-input
          v-model="queryParams.username"
          placeholder="请输入操作人员"
          clearable
          style="width: 240px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="操作结果" prop="result">
        <el-select v-model="queryParams.result" placeholder="操作结果" clearable style="width: 240px">
          <el-option label="成功" value="成功" />
          <el-option label="失败" value="失败" />
        </el-select>
      </el-form-item>
      <el-form-item label="操作时间">
        <el-date-picker
          v-model="dateRange"
          style="width: 240px"
          value-format="yyyy-MM-dd HH:mm:ss"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          :default-time="['00:00:00', '23:59:59']"
        ></el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['mqtt:log:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          @click="handleClean"
          v-hasPermi="['mqtt:log:remove']"
        >清空</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table ref="tables" v-loading="loading" :data="logList" @selection-change="handleSelectionChange" :default-sort="defaultSort" @sort-change="handleSortChange">
      <el-table-column type="selection" width="50" align="center" />
      <el-table-column label="日志编号" align="center" prop="logId" width="80" />
      <el-table-column label="操作类型" align="center" prop="operationType" width="100" />
      <el-table-column label="操作人员" align="center" prop="username" width="120" />
      <el-table-column label="设备名称" align="center" prop="deviceNames" :show-overflow-tooltip="true">
        <template slot-scope="scope">
          <el-tag v-for="(device, index) in parseDeviceNames(scope.row.deviceNames)" :key="index" size="mini" style="margin: 2px">
            {{ device }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作结果" align="center" prop="result" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.result === '成功' ? 'success' : 'danger'">
            {{ scope.row.result }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作时间" align="center" prop="createTime" width="160" sortable="custom" :sort-orders="['descending', 'ascending']">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="100">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleView(scope.row)"
            v-hasPermi="['mqtt:log:query']"
          >详细</el-button>
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

    <!-- 操作日志详细 -->
    <el-dialog title="MQTT操作日志详细" :visible.sync="open" width="700px" append-to-body>
      <el-form ref="form" :model="form" label-width="100px" size="mini">
        <el-row>
          <el-col :span="12">
            <el-form-item label="日志编号：">{{ form.logId }}</el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="操作类型：">{{ form.operationType }}</el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="操作人员：">{{ form.username }}</el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="操作结果：">
              <el-tag :type="form.result === '成功' ? 'success' : 'danger'">
                {{ form.result }}
              </el-tag>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="设备名称：">
              <el-tag v-for="(device, index) in parseDeviceNames(form.deviceNames)" :key="index" size="small" style="margin: 2px">
                {{ device }}
              </el-tag>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="操作时间：">{{ parseTime(form.createTime) }}</el-form-item>
          </el-col>
          <el-col :span="24" v-if="form.errorMessage">
            <el-form-item label="错误信息：">
              <el-alert :title="form.errorMessage" type="error" :closable="false" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="open = false">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listLog, delLog, cleanLog } from "@/api/mqtt/log";

export default {
  name: "MqttLog",
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
      // 日志表格数据
      logList: [],
      // 是否显示弹出层
      open: false,
      // 日期范围
      dateRange: [],
      // 默认排序
      defaultSort: { prop: "createTime", order: "descending" },
      // 表单参数
      form: {},
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        operationType: null,
        username: null,
        result: null
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询日志列表 */
    getList() {
      this.loading = true;
      listLog(this.addDateRange(this.queryParams, this.dateRange)).then(response => {
        this.logList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 解析设备名称 */
    parseDeviceNames(deviceNames) {
      if (!deviceNames) return [];
      return deviceNames.split(',').filter(name => name.trim());
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.dateRange = [];
      this.resetForm("queryForm");
      this.queryParams.pageNum = 1;
      this.$refs.tables.sort(this.defaultSort.prop, this.defaultSort.order);
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.logId);
      this.multiple = !selection.length;
    },
    /** 排序触发事件 */
    handleSortChange(column) {
      this.queryParams.orderByColumn = column.prop;
      this.queryParams.isAsc = column.order;
      this.getList();
    },
    /** 详细按钮操作 */
    handleView(row) {
      this.open = true;
      this.form = row;
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const logIds = row.logId || this.ids;
      this.$modal.confirm('是否确认删除选中的日志？').then(() => {
        return delLog(logIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 清空按钮操作 */
    handleClean() {
      this.$modal.confirm('是否确认清空所有MQTT操作日志？').then(() => {
        return cleanLog();
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("清空成功");
      }).catch(() => {});
    }
  }
};
</script>
