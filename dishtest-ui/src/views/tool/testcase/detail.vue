<template>
  <div class="testcase-detail-page">
    <div class="detail-header">
      <h2>{{ viewForm.caseTitle }}</h2>
      <div class="header-actions">
        <el-radio-group v-model="viewMode" size="small" @change="handleViewModeChange">
          <el-radio-button label="markdown">Markdown</el-radio-button>
          <el-radio-button label="table">表格</el-radio-button>
          <el-radio-button label="mindmap">思维导图</el-radio-button>
        </el-radio-group>
        <el-button size="small" type="primary" icon="el-icon-download" @click="handleExportCsv" style="margin-left: 10px;">导出CSV</el-button>
        <el-button size="small" type="success" icon="el-icon-download" @click="handleExportXMind">导出XMind</el-button>
      </div>
    </div>
    <div class="detail-body" v-loading="loading">
      <div v-if="viewMode === 'markdown'" class="markdown-body" v-html="renderMarkdown(viewForm.caseContent)"></div>
      <div v-if="viewMode === 'table'" class="table-view">
        <el-table :data="parsedTableData" border style="width: 100%">
          <el-table-column type="index" label="#" width="50"></el-table-column>
          <el-table-column prop="module" label="功能模块" width="140"></el-table-column>
          <el-table-column prop="testPoint" label="测试点" width="180"></el-table-column>
          <el-table-column prop="verifyPoint" label="验证点" width="180"></el-table-column>
          <el-table-column prop="scenario" label="场景描述" min-width="200">
            <template slot-scope="scope"><div class="cell-wrap">{{ scope.row.scenario }}</div></template>
          </el-table-column>
          <el-table-column prop="expected" label="预期结果" min-width="200">
            <template slot-scope="scope"><div class="cell-wrap">{{ scope.row.expected }}</div></template>
          </el-table-column>
        </el-table>
      </div>
      <div v-if="viewMode === 'mindmap'" id="mindmap-container" class="mindmap-fullscreen"></div>
      <div v-if="!loading && !viewForm.caseId" class="empty-content">
        <el-empty description="测试用例不存在或加载失败"></el-empty>
      </div>
    </div>
  </div>
</template>

<!-- SCRIPT_PLACEHOLDER -->

<script>
import { getTestCase, exportCsv, exportXMind } from "@/api/tool/testcase";
import testcaseMixin from "./mixin";

export default {
  name: "TestCaseDetail",
  mixins: [testcaseMixin],
  data() {
    return { loading: true, viewForm: {}, viewMode: 'markdown' };
  },
  created() {
    const mode = this.$route.query.mode;
    if (mode) this.viewMode = mode;
    this.loadData(this.$route.params.caseId);
  },
  methods: {
    loadData(caseId) {
      this.loading = true;
      getTestCase(caseId).then(response => {
        this.viewForm = response.data || {};
        this.parseContentToTable(this.viewForm.caseContent);
        this.loading = false;
        if (this.viewMode === 'mindmap') {
          this.$nextTick(() => { this.renderMindMap('mindmap-container', this.viewForm.caseContent, this.viewForm.caseTitle); });
        }
      }).catch(() => { this.loading = false; });
    },
    handleViewModeChange() {
      if (this.viewMode === 'mindmap') {
        this.$nextTick(() => { this.renderMindMap('mindmap-container', this.viewForm.caseContent, this.viewForm.caseTitle); });
      }
    },
    handleExportCsv() {
      exportCsv(this.viewForm.caseId).then(res => { this.downloadFile(res, this.viewForm.caseTitle + '.csv', 'text/csv'); });
    },
    handleExportXMind() {
      exportXMind(this.viewForm.caseId).then(res => { this.downloadFile(res, this.viewForm.caseTitle + '.xmind', 'application/octet-stream'); });
    }
  }
};
</script>

<style scoped>
.testcase-detail-page { padding: 20px; background: #fff; min-height: 100vh; }
.detail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #e4e7ed; }
.detail-header h2 { margin: 0; font-size: 18px; }
.detail-body { min-height: calc(100vh - 120px); }
.markdown-body { padding: 15px; line-height: 1.8; }
.mindmap-fullscreen { width: 100%; height: calc(100vh - 160px); border: 1px solid #e4e7ed; border-radius: 4px; }
.cell-wrap { white-space: pre-wrap; word-break: break-word; line-height: 1.5; }
</style>
