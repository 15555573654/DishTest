<template>
  <el-dialog
    title="上传文件"
    :visible.sync="visible"
    width="500px"
    :modal="false"
    @close="handleClose"
  >
    <div class="file-upload-container">
      <!-- 文件选择 -->
      <el-upload
        ref="upload"
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

      <!-- 传输进度 -->
      <div v-if="isTransferring" class="transfer-progress">
        <el-progress 
          :percentage="transferProgress"
          :status="transferProgress === 100 ? 'success' : undefined"
        ></el-progress>
        <p class="progress-text">{{ progressText }}</p>
      </div>
    </div>

    <span slot="footer" class="dialog-footer">
      <el-button @click="handleClose" :disabled="isTransferring">取消</el-button>
      <el-button 
        type="primary" 
        @click="handleUpload" 
        :disabled="!selectedFile || isTransferring"
        :loading="isTransferring"
      >
        {{ isTransferring ? '传输中...' : '开始上传' }}
      </el-button>
    </span>
  </el-dialog>
</template>

<script>
export default {
  name: 'FileUploadDialog',
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
      selectedFile: null,
      fileList: [],
      isTransferring: false,
      transferProgress: 0,
      progressText: '',
      chunkSize: 50 * 1024, // 50KB per chunk
      fileId: '',
      targetPath: '/sdcard/Download/',
      customPath: ''
    };
  },
  watch: {
    value(val) {
      this.visible = val;
      if (val && this.defaultPath) {
        // 对话框打开时设置默认路径
        this.targetPath = 'custom';
        this.customPath = this.defaultPath;
      }
    },
    visible(val) {
      this.$emit('input', val);
      if (!val) {
        // 对话框关闭时重置状态
        this.resetState();
      }
    }
  },
  methods: {
    handleFileChange(file) {
      this.selectedFile = file.raw;
      this.fileList = [file];
    },

    formatFileSize(bytes) {
      if (bytes === 0) return '0 B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
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

      // 验证文件大小
      const maxSize = 100 * 1024 * 1024; // 100MB
      if (this.selectedFile.size > maxSize) {
        this.$message.error('文件大小不能超过100MB');
        return;
      }

      // 获取最终保存路径
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
        
        // 传输完成后重置状态并关闭对话框
        this.isTransferring = false;
        this.transferProgress = 0;
        
        // 延迟关闭对话框
        setTimeout(() => {
          this.visible = false;
        }, 500);
      } catch (error) {
        console.error('文件传输失败:', error);
        this.$message.error('文件传输失败: ' + error.message);
        this.isTransferring = false;
      }
    },

    async sendFile(targetPath) {
      const file = this.selectedFile;
      const totalSize = file.size;
      const totalChunks = Math.ceil(totalSize / this.chunkSize);

      console.log(`📤 开始传输文件: ${file.name}`);
      console.log(`📤 文件大小: ${this.formatFileSize(totalSize)}`);
      console.log(`📤 分块数: ${totalChunks}`);
      console.log(`📤 目标路径: ${targetPath}`);
      console.log(`📤 MQTT主题: file/${this.username}/${this.deviceName}`);

      // 读取文件
      const arrayBuffer = await this.readFileAsArrayBuffer(file);
      const uint8Array = new Uint8Array(arrayBuffer);

      // 分块发送
      for (let i = 0; i < totalChunks; i++) {
        const start = i * this.chunkSize;
        const end = Math.min(start + this.chunkSize, totalSize);
        const chunk = uint8Array.slice(start, end);

        // 转换为Base64
        const base64Data = this.arrayBufferToBase64(chunk);

        // 发送分块
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
        
        if (i === 0) {
          console.log(`📤 发送第一个分块，消息示例:`, {
            type: message.type,
            fileId: message.fileId,
            chunkIndex: message.chunkIndex,
            totalChunks: message.totalChunks,
            fileName: message.fileName,
            targetPath: message.targetPath,
            dataLength: base64Data.length
          });
        }
        
        await this.publishMqttMessage(topic, JSON.stringify(message));

        // 更新进度
        this.transferProgress = Math.round(((i + 1) / totalChunks) * 100);
        this.progressText = `正在传输: ${i + 1}/${totalChunks} (${this.formatFileSize(end)}/${this.formatFileSize(totalSize)})`;

        // 延迟一下，避免MQTT消息过快
        await this.sleep(50);
      }

      console.log('📤 文件传输完成');
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
        const message = {
          type: 'file-cancel',
          fileId: this.fileId
        };
        const topic = `file/${this.username}/${this.deviceName}`;
        this.mqttClient.publish(topic, JSON.stringify(message), { qos: 1 });
      }
      this.resetState();
    },

    resetState() {
      this.isTransferring = false;
      this.transferProgress = 0;
      this.selectedFile = null;
      this.fileList = [];
      this.targetPath = '/sdcard/Download/';
      this.customPath = '';
    }
  }
};
</script>

<style scoped>
.file-upload-container {
  padding: 20px 0;
  background-color: #fff;
}

.file-info {
  margin-top: 20px;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.file-info p {
  margin: 5px 0;
  color: #606266;
}

.path-selector {
  margin-top: 20px;
  padding: 15px;
  background-color: #f9fafc;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
}

.transfer-progress {
  margin-top: 20px;
}

.progress-text {
  margin-top: 10px;
  text-align: center;
  color: #606266;
  font-size: 14px;
}

/* 确保对话框背景为白色 */
::v-deep .el-dialog {
  background-color: #fff;
}

::v-deep .el-dialog__header {
  background-color: #fff;
  border-bottom: 1px solid #e4e7ed;
}

::v-deep .el-dialog__body {
  background-color: #fff;
  color: #606266;
}

::v-deep .el-dialog__footer {
  background-color: #fff;
  border-top: 1px solid #e4e7ed;
}

/* 上传区域样式优化 */
::v-deep .el-upload {
  width: 100%;
  text-align: center;
}

::v-deep .el-upload-dragger {
  width: 100%;
  background-color: #fafafa;
  border: 2px dashed #d9d9d9;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

::v-deep .el-upload-dragger:hover {
  border-color: #409EFF;
}

::v-deep .el-upload-dragger .el-icon-upload {
  margin: 40px 0 16px;
  font-size: 67px;
  color: #c0c4cc;
  display: block;
}

::v-deep .el-upload__text {
  color: #606266;
  font-size: 14px;
  text-align: center;
  line-height: 1.5;
}

::v-deep .el-upload__text em {
  color: #409EFF;
  font-style: normal;
}

::v-deep .el-upload__tip {
  color: #909399;
  font-size: 12px;
  text-align: center;
  margin-top: 7px;
  line-height: 1.5;
}
</style>
