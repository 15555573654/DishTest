<template>
  <div class="app-container">
    <!-- 统计信息 -->
    <el-row :gutter="20" class="mb8">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="statistic-item">
            <i class="el-icon-monitor statistic-icon"></i>
            <div class="statistic-content">
              <div class="statistic-value">{{ statistics.totalDevices || 0 }}</div>
              <div class="statistic-label">设备总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="statistic-item">
            <i class="el-icon-success statistic-icon" style="color: #67C23A"></i>
            <div class="statistic-content">
              <div class="statistic-value">{{ statistics.onlineDevices || 0 }}</div>
              <div class="statistic-label">在线设备</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="statistic-item">
            <i class="el-icon-error statistic-icon" style="color: #F56C6C"></i>
            <div class="statistic-content">
              <div class="statistic-value">{{ statistics.offlineDevices || 0 }}</div>
              <div class="statistic-label">离线设备</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="statistic-item">
            <i class="el-icon-coin statistic-icon" style="color: #E6A23C"></i>
            <div class="statistic-content">
              <div class="statistic-value">{{ statistics.totalDiamonds || 0 }}</div>
              <div class="statistic-label">钻石总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 查询和连接表单 -->
    <div class="query-connection-wrapper">
      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px" class="query-form">
        <el-form-item label="设备名称" prop="deviceName">
          <el-input
            v-model="queryParams.deviceName"
            placeholder="请输入设备名称"
            clearable
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="设备状态" prop="deviceStatus">
          <el-select v-model="queryParams.deviceStatus" placeholder="设备状态" clearable>
            <el-option label="在线" value="在线" />
            <el-option label="离线" value="离线" />
          </el-select>
        </el-form-item>
        <el-form-item label="脚本状态" prop="scriptStatus">
          <el-select v-model="queryParams.scriptStatus" placeholder="脚本状态" clearable>
            <el-option label="运行中" value="运行中" />
            <el-option label="未运行" value="未运行" />
            <el-option label="暂停" value="暂停" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- MQTT连接设置 -->
      <el-form ref="connectionForm" :model="connectionForm" :rules="connectionRules" inline size="small" class="connection-form">
        <el-form-item label="服务器状态">
          <el-tag :type="isConnected ? 'success' : 'info'" size="medium">
            {{ isConnected ? '已连接' : '未连接' }}
          </el-tag>
          <span v-if="isConnected" style="margin-left: 10px; color: #67C23A; font-size: 12px">
            <i class="el-icon-user"></i> {{ currentUsername }}
          </span>
        </el-form-item>
        <el-form-item prop="username">
          <el-input v-model="connectionForm.username" placeholder="用户名" :disabled="isConnected" style="width: 120px" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="connectionForm.password" type="password" placeholder="密码" show-password :disabled="isConnected" style="width: 120px" />
        </el-form-item>
        <el-form-item>
          <el-button
            v-if="!isConnected"
            type="primary"
            size="small"
            @click="handleConnect"
            :loading="connecting"
            v-hasPermi="['mqtt:connection:connect']"
          >连接</el-button>
          <el-button
            v-else
            type="danger"
            size="small"
            @click="handleDisconnect"
            v-hasPermi="['mqtt:connection:disconnect']"
          >断开</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 操作按钮 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-video-play"
          size="mini"
          :disabled="multiple || !isConnected"
          @click="handleCommand('start')"
          v-hasPermi="['mqtt:device:command']"
        >启动</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-video-pause"
          size="mini"
          :disabled="multiple || !isConnected"
          @click="handleCommand('stop')"
          v-hasPermi="['mqtt:device:command']"
        >停止</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-video-pause"
          size="mini"
          :disabled="multiple || !isConnected"
          @click="handleCommand('pause')"
          v-hasPermi="['mqtt:device:command']"
        >暂停</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-video-play"
          size="mini"
          :disabled="multiple || !isConnected"
          @click="handleCommand('resume')"
          v-hasPermi="['mqtt:device:command']"
        >恢复</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="info"
          plain
          icon="el-icon-refresh"
          size="mini"
          :disabled="multiple || !isConnected"
          @click="handleCommand('updateScript')"
          v-hasPermi="['mqtt:device:command']"
        >更新脚本</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple || !isConnected"
          @click="handleDelete"
          v-hasPermi="['mqtt:device:remove']"
        >删除设备</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="refreshData"></right-toolbar>
    </el-row>

    <!-- 设备列表 -->
    <el-table v-loading="loading" :data="deviceList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="序号" type="index" width="50" align="center" />
      <el-table-column label="设备名称" align="center" prop="deviceName" :show-overflow-tooltip="true" />
      <el-table-column label="设备状态" align="center" prop="deviceStatus" width="100">
        <template slot-scope="scope">
          <el-tag :type="scope.row.deviceStatus === '在线' ? 'success' : 'info'">
            {{ scope.row.deviceStatus }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="脚本状态" align="center" prop="scriptStatus" width="100">
        <template slot-scope="scope">
          <el-tag
            :type="scope.row.scriptStatus === '运行中' ? 'success' : (scope.row.scriptStatus === '暂停' ? 'warning' : 'info')">
            {{ scope.row.scriptStatus }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="等级" align="center" prop="level" width="80" />
      <el-table-column label="区服" align="center" prop="server" :show-overflow-tooltip="true" />
      <el-table-column label="钻石数量" align="center" prop="diamonds" width="100" />
      <el-table-column label="任务配置" align="center" prop="taskConfig" :show-overflow-tooltip="true" />
      <el-table-column label="最后在线" align="center" prop="lastOnline" width="160">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.lastOnline) }}</span>
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
  </div>
</template>

<script>
import { listDevice, delDevice, sendCommand, getStatistics } from "@/api/mqtt/device";
import mqtt from 'mqtt';

export default {
  name: "MqttDevice",
  data() {
    return {
      // MQTT连接相关
      mqttClient: null,
      isConnected: false,
      currentUsername: '',
      connecting: false,
      connectionForm: {
        mqttHost: 'localhost',
        mqttPort: '8083',
        username: '',
        password: ''
      },
      connectionRules: {
        username: [
          { required: true, message: "用户名不能为空", trigger: "blur" }
        ],
        password: [
          { required: true, message: "密码不能为空", trigger: "blur" }
        ]
      },
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 选中设备名称数组
      deviceNames: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 设备表格数据
      deviceList: [],
      // 统计信息
      statistics: {},
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        deviceName: null,
        deviceStatus: null,
        scriptStatus: null
      }
    };
  },
  created() {
    // 从localStorage加载连接配置
    this.loadConnectionConfig();
    // 获取设备列表和统计
    this.getList();
    this.getStatistics();
  },
  beforeDestroy() {
    // 断开MQTT连接
    if (this.mqttClient) {
      this.mqttClient.end();
    }
  },
  methods: {
    /** 加载连接配置 */
    loadConnectionConfig() {
      const config = localStorage.getItem('mqttConnectionConfig');
      if (config) {
        try {
          const savedConfig = JSON.parse(config);
          this.connectionForm = { ...this.connectionForm, ...savedConfig };
        } catch (e) {
          console.error('加载连接配置失败', e);
        }
      }
    },
    /** 保存连接配置 */
    saveConnectionConfig() {
      const config = {
        mqttHost: this.connectionForm.mqttHost,
        mqttPort: this.connectionForm.mqttPort,
        username: this.connectionForm.username,
        password: this.connectionForm.password
      };
      localStorage.setItem('mqttConnectionConfig', JSON.stringify(config));
    },
    /** 连接MQTT */
    handleConnect() {
      this.$refs["connectionForm"].validate(valid => {
        if (valid) {
          this.connecting = true;

          const { mqttHost, mqttPort, username, password } = this.connectionForm;
          const url = `ws://${mqttHost}:${mqttPort}/mqtt`;

          const options = {
            clientId: 'mqtt_web_' + username + '_' + Math.random().toString(16).substr(2, 8),
            username: username,
            password: password,
            clean: true,
            reconnectPeriod: 0, // 禁用自动重连，避免一直尝试
            connectTimeout: 10000
          };

          console.log('尝试连接MQTT服务器:', url);
          console.log('连接选项:', { ...options, password: '***' });

          try {
            this.mqttClient = mqtt.connect(url, options);

            // 连接成功
            this.mqttClient.on('connect', () => {
              console.log('MQTT连接成功');
              this.isConnected = true;
              this.currentUsername = username;
              this.connecting = false;
              this.saveConnectionConfig();
              this.$modal.msgSuccess("MQTT连接成功");

              // 订阅主题
              this.subscribeTopics(username);

              // 刷新数据
              this.refreshData();
            });

            // 连接失败
            this.mqttClient.on('error', (err) => {
              console.error('MQTT连接错误:', err);
              this.connecting = false;
              this.isConnected = false;

              let errorMsg = "MQTT连接失败";
              if (err.message) {
                errorMsg += ": " + err.message;
              }

              // 常见错误提示
              if (err.message && err.message.includes('ECONNREFUSED')) {
                errorMsg = "连接被拒绝，请检查MQTT服务器地址和端口是否正确";
              } else if (err.message && err.message.includes('timeout')) {
                errorMsg = "连接超时，请检查MQTT服务器是否开启WebSocket支持";
              }

              this.$modal.msgError(errorMsg);

              // 清理客户端
              if (this.mqttClient) {
                this.mqttClient.end(true);
                this.mqttClient = null;
              }
            });

            // 连接断开
            this.mqttClient.on('close', () => {
              console.log('MQTT连接已断开');
              this.isConnected = false;
            });

            // 离线事件
            this.mqttClient.on('offline', () => {
              console.log('MQTT客户端离线');
              this.connecting = false;
              this.isConnected = false;
            });

            // 接收消息
            this.mqttClient.on('message', (topic, message) => {
              this.handleMqttMessage(topic, message.toString());
            });

            // 设置超时，如果10秒内没有连接成功，则取消
            setTimeout(() => {
              if (this.connecting) {
                console.error('连接超时');
                this.connecting = false;
                this.$modal.msgError("连接超时，请检查MQTT服务器配置");
                if (this.mqttClient) {
                  this.mqttClient.end(true);
                  this.mqttClient = null;
                }
              }
            }, 10000);

          } catch (err) {
            console.error('创建MQTT客户端失败:', err);
            this.connecting = false;
            this.$modal.msgError("创建MQTT客户端失败: " + err.message);
          }
        }
      });
    },
    /** 订阅主题 */
    subscribeTopics(username) {
      if (!this.mqttClient) return;

      const topics = [
        `response/${username}/#`,
        `status/${username}/#`,
        `config/${username}/#`
      ];

      topics.forEach(topic => {
        this.mqttClient.subscribe(topic, { qos: 1 }, (err) => {
          if (err) {
            console.error('订阅主题失败:', topic, err);
          } else {
            console.log('订阅主题成功:', topic);
          }
        });
      });
    },
    /** 处理MQTT消息 */
    handleMqttMessage(topic, payload) {
      console.log('收到MQTT消息:', topic, payload);

      // 收到消息后刷新设备列表和统计
      this.refreshData();
    },
    /** 发送MQTT命令 */
    publishCommand(deviceName, action, params = {}) {
      if (!this.mqttClient || !this.isConnected) {
        this.$modal.msgError("MQTT未连接");
        return Promise.reject('MQTT未连接');
      }

      const topic = `commands/${this.currentUsername}/${deviceName}`;
      const message = JSON.stringify({
        action: action,
        ...params
      });

      return new Promise((resolve, reject) => {
        this.mqttClient.publish(topic, message, { qos: 1 }, (err) => {
          if (err) {
            console.error('发送命令失败:', err);
            reject(err);
          } else {
            console.log('发送命令成功:', topic, message);
            resolve();
          }
        });
      });
    },
    /** 断开连接 */
    handleDisconnect() {
      this.$modal.confirm('是否确认断开MQTT连接？').then(() => {
        if (this.mqttClient) {
          this.mqttClient.end();
          this.mqttClient = null;
        }
        this.isConnected = false;
        this.currentUsername = '';
        this.$modal.msgSuccess("MQTT连接已断开");
      }).catch(() => {});
    },
    /** 查询设备列表 */
    getList() {
      this.loading = true;
      listDevice(this.queryParams).then(response => {
        this.deviceList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    /** 获取统计信息 */
    getStatistics() {
      getStatistics().then(response => {
        this.statistics = response.data;
      });
    },
    /** 刷新数据（列表+统计） */
    refreshData() {
      this.getList();
      this.getStatistics();
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
      this.getStatistics();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.deviceId);
      this.deviceNames = selection.map(item => item.deviceName);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },
    /** 发送命令 */
    handleCommand(action) {
      const actionNames = {
        'start': '启动',
        'stop': '停止',
        'pause': '暂停',
        'resume': '恢复',
        'updateScript': '更新脚本'
      };

      this.$modal.confirm('是否确认' + actionNames[action] + '选中的设备？').then(() => {
        // 使用前端MQTT直接发送命令
        const promises = this.deviceNames.map(deviceName => {
          return this.publishCommand(deviceName, action);
        });

        Promise.all(promises).then(() => {
          this.$modal.msgSuccess(actionNames[action] + "命令已发送");
          setTimeout(() => {
            this.refreshData();
          }, 1000);
        }).catch(() => {
          this.$modal.msgError(actionNames[action] + "命令发送失败");
        });
      }).catch(() => {});
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const deviceIds = row.deviceId || this.ids;
      this.$modal.confirm('是否确认删除选中的设备？').then(() => {
        return delDevice(deviceIds);
      }).then(() => {
        this.getList();
        this.getStatistics();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    }
  }
};
</script>

<style scoped>
.query-connection-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

.query-form {
  flex: 1;
  min-width: 400px;
}

.connection-form {
  flex-shrink: 0;
  margin-left: 20px;
}

/* 小屏幕时换行 */
@media (max-width: 1400px) {
  .query-connection-wrapper {
    flex-direction: column;
  }

  .connection-form {
    margin-left: 0;
    margin-top: 10px;
    width: 100%;
    text-align: right;
  }
}

.statistic-item {
  display: flex;
  align-items: center;
  padding: 10px;
}

.statistic-icon {
  font-size: 48px;
  color: #409EFF;
  margin-right: 20px;
}

.statistic-content {
  flex: 1;
}

.statistic-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.statistic-label {
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}

.statistic-username {
  font-size: 12px;
  color: #67C23A;
  margin-top: 5px;
}
</style>
