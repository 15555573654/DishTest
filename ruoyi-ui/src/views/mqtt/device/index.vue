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
import { listDevice, delDevice, sendCommand, getStatistics, batchSaveDevices } from "@/api/mqtt/device";
import { parseTime } from "@/utils/ruoyi";
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
        mqttHost: '192.168.1.120',
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
      // 实时设备数据（从MQTT接收）
      realtimeDevices: {},
      // 定时保存定时器
      saveTimer: null,
      // 数据是否有变化
      dataChanged: false,
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
      statistics: {
        totalDevices: 0,
        onlineDevices: 0,
        offlineDevices: 0,
        totalDiamonds: 0
      },
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
    // 加载历史设备数据
    this.getList();
    this.getStatistics();
  },
  beforeDestroy() {
    // 断开MQTT连接
    if (this.mqttClient) {
      this.mqttClient.end();
    }
    // 清除定时器
    if (this.saveTimer) {
      clearInterval(this.saveTimer);
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

          try {
            this.mqttClient = mqtt.connect(url, options);

            // 连接成功
            this.mqttClient.on('connect', () => {
              this.isConnected = true;
              this.currentUsername = username;
              this.connecting = false;
              this.saveConnectionConfig();
              this.$modal.msgSuccess("MQTT连接成功");

              // 订阅主题
              this.subscribeTopics(username);

              // 启动定时保存（每30秒保存一次）
              this.startAutoSave();

              // 初始加载历史数据
              this.getList();
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
              this.isConnected = false;
            });

            // 离线事件
            this.mqttClient.on('offline', () => {
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
    /** 统一脚本状态 */
    normalizeScriptStatus(rawStatus) {
      const statusMap = {
        '停止': '未运行',
        '运行中': '运行中',
        '暂停': '暂停',
        '在线': '运行中',
        'stopped': '未运行',
        'running': '运行中',
        'paused': '暂停'
      };
      return statusMap[rawStatus] || rawStatus;
    },
    /** 获取脚本状态字段（兼容中英文） */
    getRawScriptStatus(data) {
      return data.scriptStatus !== undefined ? data.scriptStatus : data.运行状态;
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
          }
        });
      });
    },
    /** 处理MQTT消息 */
    handleMqttMessage(topic, payload) {
      try {
        const data = JSON.parse(payload);
        const deviceName = data.deviceName;

        if (!deviceName) {
          console.warn('消息中没有deviceName:', payload);
          return;
        }

        // 初始化设备数据
        if (!this.realtimeDevices[deviceName]) {
          const newDevice = {
            deviceName: deviceName,
            username: this.currentUsername,
            deviceStatus: '离线',
            scriptStatus: '未运行',
            level: '',
            server: '',
            diamonds: '',
            taskConfig: '',
            lastOnline: new Date()
          };
          this.$set(this.realtimeDevices, deviceName, newDevice);
        }

        const device = this.realtimeDevices[deviceName];
        // 处理状态消息
        // 实际主题格式为: status/{username}/{deviceName}
        if (topic.startsWith('status/')) {
          // 设备在线/离线状态
          if (data.status) {
            this.$set(device, 'deviceStatus', data.status === 'online' ? '在线' : '离线');
            this.$set(device, 'lastOnline', new Date());
            this.dataChanged = true;
          }
          // 同时尝试从状态消息里更新脚本状态（如果客户端在这里返回）
          const rawScriptStatus = this.getRawScriptStatus(data);
          if (rawScriptStatus !== undefined) {
            this.$set(device, 'scriptStatus', this.normalizeScriptStatus(rawScriptStatus));
            this.dataChanged = true;
          }
        }
        // 处理响应消息（命令执行结果）
        // 实际主题格式为: response/{username}/{deviceName}
        else if (topic.startsWith('response/')) {
          const rawScriptStatus = this.getRawScriptStatus(data);
          if (rawScriptStatus !== undefined) {
            this.$set(device, 'scriptStatus', this.normalizeScriptStatus(rawScriptStatus));
            this.dataChanged = true;
          }
        }
        // 处理配置消息
        // 实际主题格式为: config/{username}/{deviceName}
        else if (topic.startsWith('config/')) {
          this.$set(device, 'deviceStatus', '在线');
          this.$set(device, 'lastOnline', new Date());

          if (data.type === 'post' && data.msg) {
            // msg字段是JSON字符串，需要再次解析
            try {
              const msgData = JSON.parse(data.msg);
              // 兼容旧版(中文字段)和新版(英文字段)的键名
              const levelVal = msgData.等级 !== undefined ? msgData.等级 : msgData.level;
              const serverVal = msgData.区服 !== undefined ? msgData.区服 : msgData.server;
              const diamondsVal = msgData.钻石 !== undefined ? msgData.钻石 : msgData.diamonds;
              const statusRaw = msgData.运行状态 !== undefined ? msgData.运行状态 : msgData.scriptStatus;

              if (levelVal !== undefined) {
                this.$set(device, 'level', levelVal);
              }
              if (serverVal !== undefined) {
                this.$set(device, 'server', serverVal);
              }
              if (diamondsVal !== undefined) {
                this.$set(device, 'diamonds', diamondsVal);
              }
              if (statusRaw !== undefined) {
                this.$set(device, 'scriptStatus', this.normalizeScriptStatus(statusRaw));
              }

              this.dataChanged = true;
            } catch (e) {
              console.error('解析msg字段失败:', e, data.msg);
            }
          }
        }

        // 更新显示列表和统计
        this.updateDeviceList();
        this.updateStatistics();

      } catch (e) {
        console.error('解析MQTT消息失败:', e, payload);
      }
    },
    /** 更新设备列表显示 */
    updateDeviceList() {
      const devices = Object.values(this.realtimeDevices);
      // 应用筛选条件
      let filteredDevices = devices;

      if (this.queryParams.deviceName) {
        filteredDevices = filteredDevices.filter(d =>
          d.deviceName.includes(this.queryParams.deviceName)
        );
      }

      if (this.queryParams.deviceStatus) {
        filteredDevices = filteredDevices.filter(d =>
          d.deviceStatus === this.queryParams.deviceStatus
        );
      }

      if (this.queryParams.scriptStatus) {
        filteredDevices = filteredDevices.filter(d =>
          d.scriptStatus === this.queryParams.scriptStatus
        );
      }

      // 分页
      this.total = filteredDevices.length;
      const start = (this.queryParams.pageNum - 1) * this.queryParams.pageSize;
      const end = start + this.queryParams.pageSize;

      // 使用Vue.set确保响应式更新
      this.deviceList = [...filteredDevices.slice(start, end)];
      this.loading = false;

    },
    /** 更新统计信息 */
    updateStatistics() {
      const devices = Object.values(this.realtimeDevices);

      this.statistics.totalDevices = devices.length;
      this.statistics.onlineDevices = devices.filter(d => d.deviceStatus === '在线').length;
      this.statistics.offlineDevices = devices.filter(d => d.deviceStatus === '离线').length;

      // 计算钻石总数
      let totalDiamonds = 0;
      devices.forEach(d => {
        const diamonds = parseInt(d.diamonds);
        if (!isNaN(diamonds)) {
          totalDiamonds += diamonds;
        }
      });
      this.statistics.totalDiamonds = totalDiamonds;
    },
    /** 启动自动保存 */
    startAutoSave() {
      if (this.saveTimer) {
        clearInterval(this.saveTimer);
      }
      // 每30秒保存一次到数据库
      this.saveTimer = setInterval(() => {
        if (this.dataChanged) {
          this.saveToDatabase();
        }
      }, 30000);
    },
    /** 保存到数据库 */
    saveToDatabase() {
      if (!this.dataChanged) return;

      const devices = Object.values(this.realtimeDevices);
      if (devices.length === 0) return;

      // 将 lastOnline 转成后端需要的字符串格式 yyyy-MM-dd HH:mm:ss
      const payloadDevices = devices.map(d => {
          const device = { ...d };
          if (device.lastOnline) {
            try {
              device.lastOnline = parseTime(device.lastOnline, '{y}-{m}-{d} {h}:{i}:{s}');
            } catch (e) {
              console.error('格式化 lastOnline 失败:', e, device.lastOnline);
              device.lastOnline = null;
            }
          } else {
            device.lastOnline = null;
          }
          return device;
        });

      // 调用后端API批量保存
      batchSaveDevices(payloadDevices).then(() => {
        this.dataChanged = false;
      }).catch(error => {
        console.error('设备数据保存失败:', error);
      });
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
        // 先保存数据
        if (this.dataChanged) {
          this.saveToDatabase();
        }

        // 清除定时器
        if (this.saveTimer) {
          clearInterval(this.saveTimer);
          this.saveTimer = null;
        }

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
      // 如果已连接MQTT，使用实时数据
      if (this.isConnected) {
        this.updateDeviceList();
        return;
      }

      // 未连接时，从数据库加载历史数据
      this.loading = true;
      listDevice(this.queryParams).then(response => {
        this.deviceList = response.rows;
        this.total = response.total;
        this.loading = false;

        // 将历史数据加载到realtimeDevices
        response.rows.forEach(device => {
          this.$set(this.realtimeDevices, device.deviceName, { ...device });
        });
      });
    },
    /** 获取统计信息 */
    getStatistics() {
      // 如果已连接MQTT，使用实时统计
      if (this.isConnected) {
        this.updateStatistics();
        return;
      }

      // 未连接时，从数据库获取统计
      getStatistics().then(response => {
        this.statistics = response.data;
      });
    },
    /** 刷新数据（列表+统计+主动请求状态） */
    refreshData() {
      this.getList();
      this.getStatistics();

      // 如果已连接MQTT，刷新时主动请求当前页设备的最新状态
      if (this.isConnected) {
        const deviceNames = this.deviceList.map(d => d.deviceName);
        if (deviceNames.length > 0) {
          const statusPromises = deviceNames.map(name => this.requestDeviceStatus(name));
          Promise.all(statusPromises).catch(err => {
            console.error('刷新时请求设备状态失败:', err);
          });
        }
      }
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
    /** 主动请求设备状态（通过MQTT命令） */
    requestDeviceStatus(deviceName) {
      // 约定使用 action = 'status' 主动查询设备当前状态
      return this.publishCommand(deviceName, 'status');
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

        Promise.all(promises)
          .then(() => {
            // 命令发送成功后，主动再请求一次设备状态
            const statusPromises = this.deviceNames.map(deviceName => {
              return this.requestDeviceStatus(deviceName);
            });
            return Promise.all(statusPromises);
          })
          .then(() => {
            this.$modal.msgSuccess(actionNames[action] + "命令已发送，正在获取最新状态");
          })
          .catch(() => {
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
