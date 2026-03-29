<template>
  <el-dialog
    title="文件浏览器"
    :visible.sync="visible"
    width="800px"
    :modal="false"
    @close="handleClose"
    @open="handleOpen"
  >
    <div class="file-browser-container">
      <!-- 快捷目录 -->
      <div class="quick-access">
        <el-button
          v-for="dir in commonDirectories"
          :key="dir.path"
          size="small"
          @click="navigateTo(dir.path)"
          :icon="getIconClass(dir.icon)"
        >
          {{ dir.name }}
        </el-button>
      </div>

      <!-- 路径导航 -->
      <div class="path-navigation">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item
            v-for="(segment, index) in pathSegments"
            :key="index"
            @click.native="navigateToSegment(index)"
            style="cursor: pointer;"
          >
            {{ segment.name }}
          </el-breadcrumb-item>
        </el-breadcrumb>
        <el-button
          size="small"
          icon="el-icon-refresh"
          @click="refreshCurrentDirectory"
          style="margin-left: 10px;"
        >刷新</el-button>
      </div>

      <!-- 文件列表 -->
      <div class="file-list" v-loading="loading">
        <el-table
          :data="files"
          style="width: 100%"
          @row-dblclick="handleRowDoubleClick"
          height="400"
        >
          <el-table-column label="名称" min-width="200">
            <template slot-scope="scope">
              <i :class="getFileIcon(scope.row)" style="margin-right: 5px;"></i>
              <span>{{ scope.row.name }}</span>
            </template>
          </el-table-column>
          <el-table-column label="大小" width="100">
            <template slot-scope="scope">
              {{ scope.row.isDirectory ? '-' : formatFileSize(scope.row.size) }}
            </template>
          </el-table-column>
          <el-table-column label="修改时间" width="160">
            <template slot-scope="scope">
              {{ scope.row.lastModified }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150">
            <template slot-scope="scope">
              <el-button
                v-if="!scope.row.isDirectory"
                size="mini"
                type="text"
                @click="downloadFile(scope.row)"
              >下载</el-button>
              <el-button
                size="mini"
                type="text"
                @click="renameFile(scope.row)"
              >重命名</el-button>
              <el-button
                size="mini"
                type="text"
                style="color: #F56C6C;"
                @click="deleteFile(scope.row)"
              >删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <el-button size="small" icon="el-icon-folder-add" @click="showCreateDirectoryDialog">新建文件夹</el-button>
        <el-button size="small" icon="el-icon-upload" @click="showUploadDialog">上传文件</el-button>
      </div>
    </div>

    <!-- 新建文件夹对话框 -->
    <el-dialog
      title="新建文件夹"
      :visible.sync="createDirDialogVisible"
      width="400px"
      append-to-body
    >
      <el-input v-model="newDirectoryName" placeholder="请输入文件夹名称"></el-input>
      <span slot="footer">
        <el-button @click="createDirDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="createDirectory">确定</el-button>
      </span>
    </el-dialog>

    <!-- 重命名对话框 -->
    <el-dialog
      title="重命名"
      :visible.sync="renameDialogVisible"
      width="400px"
      append-to-body
    >
      <el-input v-model="newFileName" placeholder="请输入新名称"></el-input>
      <span slot="footer">
        <el-button @click="renameDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmRename">确定</el-button>
      </span>
    </el-dialog>
  </el-dialog>
</template>

<script>
export default {
  name: 'FileBrowserDialog',
  props: {
    value: {
      type: Boolean,
      default: false
    },
    deviceName: {
      type: String,
      required: true
    },
    username: {
      type: String,
      required: true
    },
    mqttClient: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      visible: this.value,
      loading: false,
      currentPath: '/sdcard',
      files: [],
      commonDirectories: [],
      createDirDialogVisible: false,
      newDirectoryName: '',
      renameDialogVisible: false,
      newFileName: '',
      renamingFile: null,
      pendingRequests: new Map()
    };
  },
  computed: {
    pathSegments() {
      if (!this.currentPath) return [];
      const parts = this.currentPath.split('/').filter(p => p);
      const segments = [{ name: '根目录', path: '/' }];
      let currentPath = '';
      for (const part of parts) {
        currentPath += '/' + part;
        segments.push({ name: part, path: currentPath });
      }
      return segments;
    }
  },
  watch: {
    value(val) {
      this.visible = val;
    },
    visible(val) {
      this.$emit('input', val);
    }
  },
  methods: {
    handleOpen() {
      this.loadCommonDirectories();
      this.loadDirectory(this.currentPath);
      this.setupMqttListener();
    },

    handleClose() {
      this.removeMqttListener();
    },

    setupMqttListener() {
      if (!this.mqttClient) return;
      
      const topic = `file-browser/${this.username}/${this.deviceName}/response`;
      this.mqttClient.subscribe(topic, { qos: 1 });
      this.mqttClient.on('message', this.handleMqttMessage);
    },

    removeMqttListener() {
      if (!this.mqttClient) return;
      
      const topic = `file-browser/${this.username}/${this.deviceName}/response`;
      this.mqttClient.unsubscribe(topic);
      this.mqttClient.removeListener('message', this.handleMqttMessage);
    },

    handleMqttMessage(topic, message) {
      const responseTopic = `file-browser/${this.username}/${this.deviceName}/response`;
      if (topic !== responseTopic) return;

      try {
        const data = JSON.parse(message.toString());
        const requestId = data.requestId;
        
        if (requestId && this.pendingRequests.has(requestId)) {
          const resolve = this.pendingRequests.get(requestId);
          this.pendingRequests.delete(requestId);
          resolve(data);
        }
      } catch (e) {
        console.error('解析文件浏览响应失败:', e);
      }
    },

    sendRequest(action, params = {}) {
      return new Promise((resolve, reject) => {
        if (!this.mqttClient) {
          reject(new Error('MQTT未连接'));
          return;
        }

        const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const message = {
          action,
          requestId,
          ...params
        };

        const topic = `file-browser/${this.username}/${this.deviceName}/request`;
        this.mqttClient.publish(topic, JSON.stringify(message), { qos: 1 }, (err) => {
          if (err) {
            reject(err);
          } else {
            this.pendingRequests.set(requestId, resolve);
            // 10秒超时
            setTimeout(() => {
              if (this.pendingRequests.has(requestId)) {
                this.pendingRequests.delete(requestId);
                reject(new Error('请求超时'));
              }
            }, 10000);
          }
        });
      });
    },

    async loadCommonDirectories() {
      try {
        const response = await this.sendRequest('get-common-directories');
        if (response.success) {
          this.commonDirectories = response.directories;
        }
      } catch (e) {
        console.error('加载常用目录失败:', e);
      }
    },

    async loadDirectory(path) {
      this.loading = true;
      try {
        const response = await this.sendRequest('list-directory', { path });
        if (response.success) {
          this.currentPath = response.path;
          this.files = response.files;
        } else {
          this.$message.error(response.error || '加载目录失败');
        }
      } catch (e) {
        this.$message.error('加载目录失败: ' + e.message);
      } finally {
        this.loading = false;
      }
    },

    navigateTo(path) {
      this.loadDirectory(path);
    },

    navigateToSegment(index) {
      const segment = this.pathSegments[index];
      this.navigateTo(segment.path);
    },

    refreshCurrentDirectory() {
      this.loadDirectory(this.currentPath);
    },

    handleRowDoubleClick(row) {
      if (row.isDirectory) {
        this.navigateTo(row.path);
      }
    },

    getFileIcon(file) {
      if (file.isDirectory) {
        return 'el-icon-folder';
      }
      
      const ext = file.extension.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(ext)) {
        return 'el-icon-picture';
      } else if (['mp4', 'avi', 'mkv', 'mov'].includes(ext)) {
        return 'el-icon-video-camera';
      } else if (['mp3', 'wav', 'flac', 'm4a'].includes(ext)) {
        return 'el-icon-headset';
      } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].includes(ext)) {
        return 'el-icon-document';
      } else if (['zip', 'rar', '7z'].includes(ext)) {
        return 'el-icon-folder-opened';
      } else if (ext === 'apk') {
        return 'el-icon-mobile-phone';
      }
      return 'el-icon-document';
    },

    getIconClass(icon) {
      const iconMap = {
        phone: 'el-icon-mobile-phone',
        download: 'el-icon-download',
        document: 'el-icon-document',
        picture: 'el-icon-picture',
        camera: 'el-icon-camera',
        music: 'el-icon-headset',
        video: 'el-icon-video-camera'
      };
      return iconMap[icon] || 'el-icon-folder';
    },

    formatFileSize(bytes) {
      if (bytes === 0) return '0 B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    },

    showCreateDirectoryDialog() {
      this.newDirectoryName = '';
      this.createDirDialogVisible = true;
    },

    async createDirectory() {
      if (!this.newDirectoryName) {
        this.$message.warning('请输入文件夹名称');
        return;
      }

      const newPath = this.currentPath + '/' + this.newDirectoryName;
      try {
        const response = await this.sendRequest('create-directory', { path: newPath });
        if (response.success) {
          this.$message.success('创建成功');
          this.createDirDialogVisible = false;
          this.refreshCurrentDirectory();
        } else {
          this.$message.error(response.error || '创建失败');
        }
      } catch (e) {
        this.$message.error('创建失败: ' + e.message);
      }
    },

    renameFile(file) {
      this.renamingFile = file;
      this.newFileName = file.name;
      this.renameDialogVisible = true;
    },

    async confirmRename() {
      if (!this.newFileName) {
        this.$message.warning('请输入新名称');
        return;
      }

      try {
        const response = await this.sendRequest('rename-file', {
          oldPath: this.renamingFile.path,
          newName: this.newFileName
        });
        if (response.success) {
          this.$message.success('重命名成功');
          this.renameDialogVisible = false;
          this.refreshCurrentDirectory();
        } else {
          this.$message.error(response.error || '重命名失败');
        }
      } catch (e) {
        this.$message.error('重命名失败: ' + e.message);
      }
    },

    deleteFile(file) {
      this.$confirm(`确定要删除 ${file.name} 吗？`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          const response = await this.sendRequest('delete-file', { path: file.path });
          if (response.success) {
            this.$message.success('删除成功');
            this.refreshCurrentDirectory();
          } else {
            this.$message.error(response.error || '删除失败');
          }
        } catch (e) {
          this.$message.error('删除失败: ' + e.message);
        }
      }).catch(() => {});
    },

    downloadFile(file) {
      this.$message.info('文件下载功能开发中...');
      // TODO: 实现文件下载功能
    },

    showUploadDialog() {
      console.log('FileBrowserDialog: showUploadDialog called, currentPath:', this.currentPath);
      this.$emit('open-upload', this.currentPath);
      // 不要立即关闭文件浏览器，让用户可以看到上传对话框
      // this.visible = false;
    }
  }
};
</script>

<style scoped>
.file-browser-container {
  padding: 10px 0;
}

.quick-access {
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e4e7ed;
}

.quick-access .el-button {
  margin-right: 10px;
  margin-bottom: 5px;
}

.path-navigation {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.file-list {
  margin-bottom: 15px;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

::v-deep .el-dialog {
  background-color: #fff;
}

::v-deep .el-dialog__header {
  background-color: #fff;
  border-bottom: 1px solid #e4e7ed;
}

::v-deep .el-dialog__body {
  background-color: #fff;
}

::v-deep .el-breadcrumb__item:hover {
  color: #409EFF;
}
</style>
