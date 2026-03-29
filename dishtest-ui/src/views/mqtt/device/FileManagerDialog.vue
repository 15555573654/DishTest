<template>
  <el-dialog
    :visible.sync="visible"
    width="520px"
    :modal="false"
    :show-close="false"
    custom-class="file-manager-dialog"
    @close="handleClose"
  >
    <div class="dialog-wrapper">
      <!-- 自定义标题栏 -->
      <div class="dialog-header" @mousedown="startDrag">
        <div class="header-left">
          <i class="el-icon-folder-opened header-icon"></i>
          <span class="header-title">文件管理</span>
        </div>
        <div class="header-right">
          <i class="el-icon-close close-btn" @click.stop="handleClose"></i>
        </div>
      </div>

      <div class="file-manager-container">
      <!-- 功能选择 -->
      <div class="function-selector">
        <div class="function-tabs">
          <div 
            class="tab-item" 
            :class="{ active: selectedFunction === 'upload' }"
            @click="selectedFunction = 'upload'"
          >
            <i class="el-icon-upload"></i>
            <span>上传文件</span>
          </div>
          <div 
            class="tab-item" 
            :class="{ active: selectedFunction === 'apk' }"
            @click="selectedFunction = 'apk'"
          >
            <i class="el-icon-mobile-phone"></i>
            <span>安装APK</span>
          </div>
        </div>
      </div>

      <!-- 上传文件界面 -->
      <div v-if="selectedFunction === 'upload'" class="upload-section">
        <el-upload
          ref="uploadFile"
          action="#"
          :auto-upload="false"
          :on-change="handleFileChange"
          :file-list="fileList"
          :limit="1"
          drag
        >
          <i class="el-icon-upload"></i>
          <div class="el-upload__text">将文件拖到此处，或<em>点击选择</em></div>
          <div class="el-upload__tip" slot="tip">支持任意文件类型，最大100MB</div>
        </el-upload>

        <!-- 文件信息 -->
        <div v-if="selectedFile" class="file-info">
          <p><strong>文件名:</strong> {{ selectedFile.name }}</p>
          <p><strong>大小:</strong> {{ formatFileSize(selectedFile.size) }}</p>
          <p><strong>类型:</strong> {{ selectedFile.type || '未知' }}</p>
        </div>

        <!-- 目标路径选择 -->
        <div v-if="selectedFile" class="path-selector">
          <el-form label-width="80px">
            <el-form-item label="保存路径">
              <el-select v-model="targetPath" placeholder="选择保存位置">
                <el-option label="下载目录 (/sdcard/Download/)" value="/sdcard/Download/"></el-option>
                <el-option label="文档目录 (/sdcard/Documents/)" value="/sdcard/Documents/"></el-option>
                <el-option label="图片目录 (/sdcard/Pictures/)" value="/sdcard/Pictures/"></el-option>
                <el-option label="DCIM目录 (/sdcard/DCIM/)" value="/sdcard/DCIM/"></el-option>
                <el-option label="自定义路径" value="custom"></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="自定义路径" v-if="targetPath === 'custom'">
              <el-input v-model="customPath" placeholder="例如: /sdcard/MyFolder/"></el-input>
            </el-form-item>
          </el-form>
        </div>
      </div>

      <!-- 安装APK界面 -->
      <div v-if="selectedFunction === 'apk'" class="apk-section">
        <el-upload
          ref="uploadApk"
          action="#"
          :auto-upload="false"
          :on-change="handleApkChange"
          :file-list="apkFileList"
          :limit="1"
          accept=".apk"
          drag
        >
          <i class="el-icon-upload"></i>
          <div class="el-upload__text">将APK文件拖到此处，或<em>点击选择</em></div>
          <div class="el-upload__tip" slot="tip">只能上传APK文件，最大100MB</div>
        </el-upload>

        <!-- APK文件信息 -->
        <div v-if="selectedApk" class="file-info">
          <p><strong>文件名:</strong> {{ selectedApk.name }}</p>
          <p><strong>大小:</strong> {{ formatFileSize(selectedApk.size) }}</p>
        </div>
      </div>

      <!-- 传输进度 -->
      <div v-if="isTransferring" class="transfer-progress">
        <el-progress 
          :percentage="transferProgress"
          :status="transferProgress === 100 ? 'success' : undefined"
        ></el-progress>
        <p class="progress-text">{{ progressText }}</p>
      </div>
    </div>
    </div>

    <span slot="footer" class="dialog-footer">
      <el-button @click="handleClose" :disabled="isTransferring">取消</el-button>
      <el-button 
        type="primary" 
        @click="handleSubmit" 
        :disabled="!canSubmit || isTransferring"
        :loading="isTransferring"
      >
        {{ submitButtonText }}
      </el-button>
    </span>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: 'FileManagerDialog',
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
    },
    defaultPath: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      visible: this.value,
      selectedFunction: 'upload', // 'upload' 或 'apk'
      
      // 文件上传相关
      selectedFile: null,
      fileList: [],
      targetPath: '/sdcard/Download/',
      customPath: '',
      
      // APK安装相关
      selectedApk: null,
      apkFileList: [],
      
      // 传输状态
      isTransferring: false,
      transferProgress: 0,
      progressText: '',
      chunkSize: 50 * 1024, // 50KB per chunk
      fileId: '',
      
      // 拖动相关
      isDragging: false,
      dragStartX: 0,
      dragStartY: 0,
      dialogLeft: 0,
      dialogTop: 0
    };
  },
  computed: {
    canSubmit() {
      if (this.selectedFunction === 'upload') {
        return !!this.selectedFile;
      } else {
        return !!this.selectedApk;
      }
    },
    submitButtonText() {
      if (this.isTransferring) {
        return '传输中...';
      }
      return this.selectedFunction === 'upload' ? '开始上传' : '开始安装';
    }
  },
  watch: {
    value(val) {
      this.visible = val;
      if (val && this.defaultPath) {
        this.targetPath = 'custom';
        this.customPath = this.defaultPath;
      }
      if (val) {
        this.$nextTick(() => {
          this.centerDialog();
        });
      }
    },
    visible(val) {
      this.$emit('input', val);
      if (!val) {
        this.resetState();
      }
    },
    selectedFunction() {
      // 切换功能时清空选择
      this.selectedFile = null;
      this.fileList = [];
      this.selectedApk = null;
      this.apkFileList = [];
    }
  },
  mounted() {
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('mouseup', this.handleMouseUp);
  },
  beforeDestroy() {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);
  },
  methods: {
    handleFileChange(file) {
      this.selectedFile = file.raw;
      this.fileList = [file];
    },

    handleApkChange(file) {
      this.selectedApk = file.raw;
      this.apkFileList = [file];
    },

    formatFileSize(bytes) {
      if (bytes === 0) return '0 B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    },

    async handleSubmit() {
      if (this.selectedFunction === 'upload') {
        await this.handleUpload();
      } else {
        await this.handleInstall();
      }
    },

    async handleUpload() {
      if (!this.selectedFile) {
        this.$message.warning('请先选择文件');
        return;
      }

      if (!this.mqttClient) {
        this.$message.error('MQTT未连接');
        return;
      }

      const maxSize = 100 * 1024 * 1024;
      if (this.selectedFile.size > maxSize) {
        this.$message.error('文件大小不能超过100MB');
        return;
      }

      const finalPath = this.targetPath === 'custom' ? this.customPath : this.targetPath;
      if (!finalPath) {
        this.$message.warning('请选择或输入保存路径');
        return;
      }

      try {
        this.isTransferring = true;
        this.transferProgress = 0;
        this.fileId = `file_${Date.now()}`;

        await this.sendFile(finalPath);

        this.$message.success('文件传输完成');
        this.isTransferring = false;
        this.transferProgress = 0;
        
        setTimeout(() => {
          this.visible = false;
        }, 500);
      } catch (error) {
        console.error('文件传输失败:', error);
        this.$message.error('文件传输失败: ' + error.message);
        this.isTransferring = false;
      }
    },

    async handleInstall() {
      if (!this.selectedApk) {
        this.$message.warning('请先选择APK文件');
        return;
      }

      if (!this.mqttClient) {
        this.$message.error('MQTT未连接');
        return;
      }

      try {
        this.isTransferring = true;
        this.transferProgress = 0;
        this.fileId = `apk_${Date.now()}`;

        await this.sendApk();

        this.$message.success('APK传输完成，设备正在安装...');
        this.isTransferring = false;
        this.transferProgress = 0;
        
        setTimeout(() => {
          this.visible = false;
        }, 500);
      } catch (error) {
        console.error('APK传输失败:', error);
        this.$message.error('APK传输失败: ' + error.message);
        this.isTransferring = false;
      }
    },

    async sendFile(targetPath) {
      const file = this.selectedFile;
      const totalSize = file.size;
      const totalChunks = Math.ceil(totalSize / this.chunkSize);

      console.log(`📤 开始传输文件: ${file.name}, 目标: ${targetPath}`);

      const arrayBuffer = await this.readFileAsArrayBuffer(file);
      const uint8Array = new Uint8Array(arrayBuffer);

      for (let i = 0; i < totalChunks; i++) {
        const start = i * this.chunkSize;
        const end = Math.min(start + this.chunkSize, totalSize);
        const chunk = uint8Array.slice(start, end);
        const base64Data = this.arrayBufferToBase64(chunk);

        const message = {
          type: 'file-chunk',
          fileId: this.fileId,
          chunkIndex: i,
          totalChunks: totalChunks,
          fileName: file.name,
          targetPath: targetPath,
          data: base64Data
        };

        const topic = `file/${this.username}/${this.deviceName}`;
        await this.publishMqttMessage(topic, JSON.stringify(message));

        this.transferProgress = Math.round(((i + 1) / totalChunks) * 100);
        this.progressText = `正在传输: ${i + 1}/${totalChunks} (${this.formatFileSize(end)}/${this.formatFileSize(totalSize)})`;

        await this.sleep(50);
      }

      console.log('📤 文件传输完成');
    },

    async sendApk() {
      const file = this.selectedApk;
      const totalSize = file.size;
      const totalChunks = Math.ceil(totalSize / this.chunkSize);

      console.log(`📤 开始传输APK: ${file.name}`);

      const arrayBuffer = await this.readFileAsArrayBuffer(file);
      const uint8Array = new Uint8Array(arrayBuffer);

      for (let i = 0; i < totalChunks; i++) {
        const start = i * this.chunkSize;
        const end = Math.min(start + this.chunkSize, totalSize);
        const chunk = uint8Array.slice(start, end);
        const base64Data = this.arrayBufferToBase64(chunk);

        const message = {
          type: 'apk-chunk',
          apkId: this.fileId,
          chunkIndex: i,
          totalChunks: totalChunks,
          fileName: file.name,
          data: base64Data
        };

        const topic = `apk/${this.username}/${this.deviceName}`;
        await this.publishMqttMessage(topic, JSON.stringify(message));

        this.transferProgress = Math.round(((i + 1) / totalChunks) * 100);
        this.progressText = `正在传输: ${i + 1}/${totalChunks} (${this.formatFileSize(end)}/${this.formatFileSize(totalSize)})`;

        await this.sleep(50);
      }

      console.log('📤 APK传输完成');
    },

    readFileAsArrayBuffer(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.onerror = reject;
        reader.readAsArrayBuffer(file);
      });
    },

    arrayBufferToBase64(buffer) {
      let binary = '';
      const bytes = new Uint8Array(buffer);
      const len = bytes.byteLength;
      for (let i = 0; i < len; i++) {
        binary += String.fromCharCode(bytes[i]);
      }
      return window.btoa(binary);
    },

    publishMqttMessage(topic, message) {
      return new Promise((resolve, reject) => {
        this.mqttClient.publish(topic, message, { qos: 1 }, (err) => {
          if (err) {
            reject(err);
          } else {
            resolve();
          }
        });
      });
    },

    sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    },

    handleClose() {
      if (this.isTransferring) {
        this.$confirm('正在传输文件，确定要取消吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          this.cancelTransfer();
          this.visible = false;
        }).catch(() => {});
      } else {
        this.visible = false;
      }
    },

    cancelTransfer() {
      if (this.fileId && this.mqttClient) {
        const type = this.selectedFunction === 'upload' ? 'file-cancel' : 'apk-cancel';
        const idKey = this.selectedFunction === 'upload' ? 'fileId' : 'apkId';
        const message = {
          type: type,
          [idKey]: this.fileId
        };
        const topic = this.selectedFunction === 'upload' 
          ? `file/${this.username}/${this.deviceName}`
          : `apk/${this.username}/${this.deviceName}`;
        this.mqttClient.publish(topic, JSON.stringify(message), { qos: 1 });
      }
      this.resetState();
    },

    resetState() {
      this.isTransferring = false;
      this.transferProgress = 0;
      this.selectedFile = null;
      this.fileList = [];
      this.selectedApk = null;
      this.apkFileList = [];
      this.targetPath = '/sdcard/Download/';
      this.customPath = '';
      this.selectedFunction = 'upload';
    },

    /** 居中对话框 */
    centerDialog() {
      this.$nextTick(() => {
        const dialog = document.querySelector('.file-manager-dialog');
        if (!dialog) return;

        const rect = dialog.getBoundingClientRect();
        const left = Math.max(16, Math.round((window.innerWidth - rect.width) / 2));
        const top = Math.max(24, Math.round((window.innerHeight - rect.height) / 2));

        dialog.style.left = left + 'px';
        dialog.style.top = top + 'px';
        dialog.style.margin = '0';

        this.dialogLeft = left;
        this.dialogTop = top;
      });
    },

    /** 开始拖动 */
    startDrag(e) {
      const dialog = document.querySelector('.file-manager-dialog');
      if (dialog) {
        const rect = dialog.getBoundingClientRect();
        
        // 如果弹窗还没有设置绝对定位，先固定在当前位置
        if (!dialog.style.left || dialog.style.left === '') {
          dialog.style.left = rect.left + 'px';
          dialog.style.top = rect.top + 'px';
          dialog.style.margin = '0';
        }
        
        // 记录当前位置作为拖动起点
        this.dialogLeft = parseFloat(dialog.style.left) || rect.left;
        this.dialogTop = parseFloat(dialog.style.top) || rect.top;
      }

      this.isDragging = true;
      this.dragStartX = e.clientX;
      this.dragStartY = e.clientY;

      e.preventDefault();
    },

    /** 鼠标移动 */
    handleMouseMove(e) {
      if (!this.isDragging) return;

      const deltaX = e.clientX - this.dragStartX;
      const deltaY = e.clientY - this.dragStartY;

      const dialog = document.querySelector('.file-manager-dialog');
      if (dialog) {
        dialog.style.left = (this.dialogLeft + deltaX) + 'px';
        dialog.style.top = (this.dialogTop + deltaY) + 'px';
        dialog.style.margin = '0';
      }
    },

    /** 鼠标释放 */
    handleMouseUp() {
      this.isDragging = false;
    }
  }
};
</script>

<style scoped>
/* 对话框整体样式 */
::v-deep .file-manager-dialog {
  border-radius: 0;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.3);
}

::v-deep .file-manager-dialog .el-dialog__header {
  display: none;
}

::v-deep .file-manager-dialog .el-dialog__body {
  padding: 0;
  background-color: #f5f7fa;
}

::v-deep .file-manager-dialog .el-dialog__footer {
  padding: 12px 20px;
  background-color: #fff;
  border-top: 1px solid #dcdfe6;
}

/* 对话框包装器 */
.dialog-wrapper {
  display: flex;
  flex-direction: column;
  background-color: #f5f7fa;
}

/* 自定义标题栏 */
.dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  color: #fff;
  background: #000;
  cursor: move;
  user-select: none;
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-icon {
  font-size: 18px;
  color: #fff;
}

.header-title {
  font-size: 14px;
  font-weight: 500;
  color: #fff;
}

.header-right {
  display: flex;
  align-items: center;
}

.close-btn {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  padding: 4px;
  transition: all 0.2s;
}

.close-btn:hover {
  color: #fff;
}

/* 容器样式 */
.file-manager-container {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: 400px;
}

/* 功能选择标签页 */
.function-selector {
  margin-bottom: 20px;
}

.function-tabs {
  display: flex;
  gap: 8px;
  background-color: #fff;
  padding: 6px;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.tab-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 16px;
  border-radius: 2px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 13px;
  font-weight: 500;
  color: #606266;
  background-color: transparent;
}

.tab-item i {
  font-size: 14px;
}

.tab-item:hover {
  background-color: #f5f7fa;
  color: #303133;
}

.tab-item.active {
  background: #000;
  color: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.15);
}

.upload-section,
.apk-section {
  margin-top: 0;
}

.file-info {
  margin-top: 16px;
  padding: 12px;
  background-color: #fff;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
}

.file-info p {
  margin: 6px 0;
  color: #606266;
  font-size: 13px;
  display: flex;
  align-items: center;
}

.file-info p strong {
  min-width: 70px;
  color: #303133;
  font-weight: 500;
}

.path-selector {
  margin-top: 16px;
  padding: 12px;
  background-color: #fff;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
}

.transfer-progress {
  margin-top: 16px;
  padding: 16px;
  background-color: #fff;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
}

.progress-text {
  margin-top: 10px;
  text-align: center;
  color: #606266;
  font-size: 13px;
  font-weight: 500;
}

/* 上传区域样式 */
::v-deep .el-upload {
  width: 100%;
  text-align: center;
}

::v-deep .el-upload-dragger {
  width: 100%;
  height: 160px;
  background: #fafafa;
  border: 2px dashed #d9d9d9;
  border-radius: 4px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

::v-deep .el-upload-dragger:hover {
  border-color: #000;
  background: #f5f5f5;
}

::v-deep .el-upload-dragger .el-icon-upload {
  margin: 0 0 12px;
  font-size: 48px;
  color: #909399;
  transition: all 0.2s;
}

::v-deep .el-upload-dragger:hover .el-icon-upload {
  color: #000;
}

::v-deep .el-upload__text {
  color: #606266;
  font-size: 13px;
  text-align: center;
  line-height: 1.6;
  margin-top: 6px;
}

::v-deep .el-upload__text em {
  color: #000;
  font-style: normal;
  font-weight: 500;
}

::v-deep .el-upload__tip {
  color: #909399;
  font-size: 12px;
  text-align: center;
  margin-top: 6px;
  line-height: 1.4;
}

/* 表单样式优化 */
::v-deep .el-form-item__label {
  color: #303133;
  font-weight: 500;
  font-size: 13px;
}

::v-deep .el-select,
::v-deep .el-input {
  width: 100%;
}

::v-deep .el-select .el-input__inner,
::v-deep .el-input__inner {
  border-radius: 4px;
  border-color: #dcdfe6;
  transition: all 0.2s;
  font-size: 13px;
}

::v-deep .el-select .el-input__inner:focus,
::v-deep .el-input__inner:focus {
  border-color: #000;
}

/* 进度条样式 */
::v-deep .el-progress__text {
  font-weight: 500;
  color: #303133;
  font-size: 13px;
}

::v-deep .el-progress-bar__outer {
  background-color: #e4e7ed;
  border-radius: 2px;
}

::v-deep .el-progress-bar__inner {
  background: #000;
  border-radius: 2px;
}

/* 按钮样式 */
::v-deep .el-button {
  border-radius: 4px;
  font-weight: 500;
  transition: all 0.2s;
  font-size: 13px;
  padding: 9px 15px;
}

::v-deep .el-button--primary {
  background: #000;
  border-color: #000;
}

::v-deep .el-button--primary:hover {
  background: #333;
  border-color: #333;
}

::v-deep .el-button--primary:active {
  background: #000;
  border-color: #000;
}

::v-deep .el-button--default {
  border-color: #dcdfe6;
  color: #606266;
}

::v-deep .el-button--default:hover {
  border-color: #c0c4cc;
  color: #303133;
  background-color: #f5f7fa;
}
</style>
