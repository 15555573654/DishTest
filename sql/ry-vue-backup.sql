/*
 Navicat Premium Dump SQL

 Source Server         : ry-vue
 Source Server Type    : MySQL
 Source Server Version : 50744 (5.7.44-log)
 Source Host           : 192.168.1.104:3306
 Source Schema         : ry-vue

 Target Server Type    : MySQL
 Target Server Version : 50744 (5.7.44-log)
 File Encoding         : 65001

 Date: 10/03/2026 00:09:12
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_model_config
-- ----------------------------
DROP TABLE IF EXISTS `ai_model_config`;
CREATE TABLE `ai_model_config`  (
  `model_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模型名称',
  `model_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模型类型(openai/claude/qwen/local)',
  `api_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'API地址',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'API密钥',
  `model_version` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模型版本',
  `max_tokens` int(11) NULL DEFAULT 4096 COMMENT '最大token数',
  `temperature` decimal(3, 2) NULL DEFAULT 0.70 COMMENT '温度参数',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '是否默认(0否 1是)',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `support_temperature` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '是否支持温度参数(0=不支持 1=支持)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`model_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'AI模型配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_model_config
-- ----------------------------
INSERT INTO `ai_model_config` VALUES (1, 'gpt-5-nano', 'openai', 'https://api.openai.com/v1/responses', '', 'gpt-5-nano', 4096, 0.70, '0', '1', '1', '需要配置API Key', 'admin', '2026-02-16 09:30:53', NULL, '2026-03-09 23:34:40');
INSERT INTO `ai_model_config` VALUES (2, 'OpenAI GPT-5.2', 'openai', 'https://api.openai.com/v1/chat/completions', '', 'gpt-5.2', 8192, 0.70, '0', '0', '1', '需要配置API Key', 'admin', '2026-02-16 09:30:53', NULL, '2026-02-28 10:29:44');
INSERT INTO `ai_model_config` VALUES (3, 'Claude 3 Sonnet', 'claude', 'https://api.anthropic.com/v1/messages', '', 'claude-3-sonnet-20240229', 4096, 0.70, '0', '0', '1', '需要配置API Key', 'admin', '2026-02-16 09:30:53', NULL, NULL);
INSERT INTO `ai_model_config` VALUES (4, '通义千问Turbo', 'qwen', 'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation', '', 'qwen-turbo', 4096, 0.70, '0', '0', '1', '需要配置API Key', 'admin', '2026-02-16 09:30:53', NULL, NULL);
INSERT INTO `ai_model_config` VALUES (5, '本地Ollama', 'local', 'http://localhost:11434/api/generate', NULL, 'llama2', 4096, 0.70, '0', '1', '1', '本地部署的Ollama模型', 'admin', '2026-02-16 09:30:53', NULL, '2026-02-16 09:49:02');
INSERT INTO `ai_model_config` VALUES (6, 'claude-opus-4-5-20251101', 'claude', 'https://api.penguinsaichat.dpdns.org/v1/messages', '', 'claude-opus-4-5-20251101', 32768, 0.70, '0', '1', '1', NULL, '', '2026-02-16 09:42:26', '', '2026-03-09 22:24:32');
INSERT INTO `ai_model_config` VALUES (7, 'deepseek-chat', 'deepseek-chat', 'https://api.deepseek.com/v1/chat/completions', '', 'deepseek-chat', 4096, 0.70, '1', '0', '1', NULL, '', '2026-03-09 23:34:24', '', NULL);

-- ----------------------------
-- Table structure for ai_prompt_config
-- ----------------------------
DROP TABLE IF EXISTS `ai_prompt_config`;
CREATE TABLE `ai_prompt_config`  (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置名称',
  `prompt_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '提示词内容',
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '适用的AI模型(openai/claude/qwen/local,为空表示通用)',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '是否默认(0否 1是)',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'AI提示词配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_prompt_config
-- ----------------------------
INSERT INTO `ai_prompt_config` VALUES (1, '默认测试用例生成提示词', '# 角色\n你是一位资深游戏测试专家，拥有15年以上测试经验，精通黑盒测试、白盒测试、灰盒测试等多种测试方法。你擅长运用等价类划分、边界值分析、决策表、状态转换、正交试验、场景法、错误推测法等测试设计技术，能够设计出覆盖率达到98%以上的高质量测试用例。\n\n## 核心任务\n基于用户提供的需求内容{{input_doc}}，运用系统化的测试设计方法，生成继续续写全面、精准、高覆盖率的测试用例，不要输出推理过程，直接给出结果。\n\n## 技能\n### 技能1: 多维度需求分析\n1. **功能性分析**: 识别核心功能、辅助功能、隐含功能\n2. **非功能性分析**: 性能、安全、可用性、兼容性等要求\n3. **约束条件分析**: 业务规则、技术限制、环境约束\n4. **风险点识别**: 潜在缺陷区域、用户易错操作、系统薄弱环节\n5. **依赖关系梳理**: 前置条件、后置条件、数据依赖\n\n### 技能2: 系统化测试用例设计\n1. **多方法组合应用**:\n   - 等价类划分：有效等价类 + 无效等价类\n   - 边界值分析：上点、内点、离点（包括边界值±1）\n   - 决策表：覆盖所有条件组合\n   - 状态转换：覆盖所有状态路径\n   - 正交试验：减少用例数量同时保证覆盖率\n   - 场景法：正常场景 + 异常场景 + 边界场景\n   - 错误推测：基于经验的异常情况\n\n   2. **全面覆盖策略**:\n   - **输入覆盖**: 数据类型、长度、格式、编码、特殊字符\n   - **操作覆盖**: 正常操作、异常操作、并发操作、重复操作\n   - **环境覆盖**: 不同浏览器、操作系统、网络环境、设备类型\n   - **状态覆盖**: 初始状态、中间状态、结束状态、异常状态\n   - **时序覆盖**: 操作顺序、时间间隔、超时情况\n\n ### 技能3: 高覆盖率保障机制\n1. **覆盖率检查清单**:\n   - [ ] 正常路径覆盖率 ≥ 95%\n   - [ ] 异常路径覆盖率 ≥ 90%\n   - [ ] 边界条件覆盖率 = 100%\n   - [ ] 业务规则覆盖率 = 100%\n   - [ ] 用户场景覆盖率 ≥ 95%\n\n\n### 技能 4: 规范整理输出\n1. 将精心设计好的测试用例，按照严格规范的 XMind 兼容的 Markdown 层级格式进行整理，方便用户直接导入 XMind 文档，无需进行额外的格式调整。\n2. 输出的 Markdown 层级格式结构需清晰明了，仅输出纯Markdown内容，具体格式如：\n# [文档主标题]\n## [功能模块名称]\n### [功能测试点1]\n#### [验证点1.1]\n##### 场景描述1\n###### 预期结果：预期结果1\n##### 场景描述2\n###### 预期结果：预期结果2\n#### [ 验证点1.2]\n##### 场景描述1\n###### 预期结果：预期结果1\n##### 场景描述2\n###### 预期结果：预期结果2\n\n\n   ## 用例设计方法示例\n**原需求**: 昵称规则：1-20字符（支持中文/英文/数字），禁止特殊符号（除\"_\"和\"·\"）\n\n**测试用例设计思路**:\n\n### 1. 等价类划分\n**有效等价类**:\n- 长度: 1-20字符\n- 字符类型: 中文、英文字母(大小写)、数字、下划线、间隔号\n\n**无效等价类**:\n- 长度: 0字符、21+字符\n- 字符类型: 其他特殊符号、表情符号、控制字符\n\n### 2. 边界值分析\n- 长度边界: 0, 1, 2, 19, 20, 21字符\n- 字符边界: ASCII边界、Unicode边界\n\n### 3. 组合测试\n- 纯中文: 1字符、10字符、20字符\n- 纯英文: 大写、小写、混合\n- 纯数字: 单个、多个\n- 混合字符: 中英文、中文数字、英文数字、全混合\n- 包含允许符号: 单独使用、与其他字符组合\n\n### 4. 异常场景\n- 空输入、空格、制表符\n- SQL注入字符: \', \", ;, --, /*\n- XSS字符: <, >, &, javascript:\n- 特殊Unicode: 零宽字符、RTL字符\n- 表情符号: 😀, 👍, 🎉\n- 其他特殊符号: @, #, $, %, ^, &, *, (, ), +, =\n- 颜色代码：<#F9C>,<#f07>\n- 弱网时的表现\n- 断网时的表现\n- 应用冷、热启动时的表现\n\n### 5. 环境相关\n- 不同输入法状态\n- 复制粘贴输入\n- 程序化输入vs手动输入\n- 不同手机设备的处理\n\n\n## 质量保证\n- 用例间无重复，逻辑清晰\n- 预期结果明确可验证\n- 测试数据具体可执行\n- 覆盖率达到98%以上\n- 包含自动化测试建议\n\n## 限制:\n- 仅围绕用户输入的需求展开与测试用例设计紧密相关的回复，坚决拒绝回答任何与测试用例设计无关的话题。\n- 输出内容必须严格遵循给定的 XMind 兼容的 Markdown 层级格式要求，不能有任何偏离框架的情况，总共有6个层级，不要新增或减少层级，确保格式的规范性和一致性。\n- 严格确保测试用例设计方法的设计覆盖率达到 95% 以上，以保证测试质量。 ', NULL, '1', '0', '系统默认提示词', 'admin', '2026-02-16 08:50:02', NULL, '2026-02-16 21:28:55');

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint(20) NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for mqtt_connection_config
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_connection_config`;
CREATE TABLE `mqtt_connection_config`  (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `mqtt_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MQTT服务器地址',
  `mqtt_port` int(11) NOT NULL DEFAULT 1883 COMMENT 'MQTT服务器端口',
  `mqtt_username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MQTT用户名',
  `mqtt_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MQTT密码(加密)',
  `enabled` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用(0否 1是)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT连接配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mqtt_connection_config
-- ----------------------------
INSERT INTO `mqtt_connection_config` VALUES (1, 'admin', '192.168.1.104', 1883, 'test002', 'test003', 1, '2026-01-19 19:57:50', '2026-01-19 19:57:50');

-- ----------------------------
-- Table structure for mqtt_device
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_device`;
CREATE TABLE `mqtt_device`  (
  `device_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `device_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '设备名称',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属用户',
  `device_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '离线' COMMENT '设备状态(在线/离线)',
  `script_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '未运行' COMMENT '脚本状态(运行中/未运行/暂停)',
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '等级',
  `server` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区服',
  `diamonds` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '钻石数量',
  `task_config` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '任务配置名称',
  `last_online` datetime NULL DEFAULT NULL COMMENT '最后在线时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`device_id`) USING BTREE,
  UNIQUE INDEX `uk_device_username`(`device_name`, `username`) USING BTREE,
  INDEX `idx_username`(`username`) USING BTREE,
  INDEX `idx_status`(`device_status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT设备信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mqtt_device
-- ----------------------------
INSERT INTO `mqtt_device` VALUES (4, '测试设备001', 'test002', '离线', '运行中', '8703', NULL, '8704', NULL, '2026-02-28 22:21:37', '', '2026-01-20 20:52:26', '', '2026-03-08 01:08:49', NULL);

-- ----------------------------
-- Table structure for mqtt_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_operation_log`;
CREATE TABLE `mqtt_operation_log`  (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作用户',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作类型',
  `device_names` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '设备名称列表',
  `operation_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '操作内容',
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作结果(成功/失败)',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '错误信息',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_username`(`username`) USING BTREE,
  INDEX `idx_operation_type`(`operation_type`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 50 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mqtt_operation_log
-- ----------------------------
INSERT INTO `mqtt_operation_log` VALUES (1, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-01-19 20:38:14');
INSERT INTO `mqtt_operation_log` VALUES (2, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-19 20:38:25');
INSERT INTO `mqtt_operation_log` VALUES (3, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:39:09');
INSERT INTO `mqtt_operation_log` VALUES (4, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-19 20:39:25');
INSERT INTO `mqtt_operation_log` VALUES (5, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:39:33');
INSERT INTO `mqtt_operation_log` VALUES (6, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-19 20:39:43');
INSERT INTO `mqtt_operation_log` VALUES (7, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-01-19 20:39:46');
INSERT INTO `mqtt_operation_log` VALUES (8, 'admin', '设备控制-resume', '测试设备001', '操作: resume', '成功', NULL, '2026-01-19 20:39:52');
INSERT INTO `mqtt_operation_log` VALUES (9, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:40:14');
INSERT INTO `mqtt_operation_log` VALUES (10, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-19 20:40:26');
INSERT INTO `mqtt_operation_log` VALUES (11, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:40:58');
INSERT INTO `mqtt_operation_log` VALUES (12, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-19 20:43:28');
INSERT INTO `mqtt_operation_log` VALUES (13, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:44:11');
INSERT INTO `mqtt_operation_log` VALUES (14, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-01-19 20:49:15');
INSERT INTO `mqtt_operation_log` VALUES (15, 'admin', '设备控制-resume', '测试设备001', '操作: resume', '成功', NULL, '2026-01-19 20:49:38');
INSERT INTO `mqtt_operation_log` VALUES (16, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:50:50');
INSERT INTO `mqtt_operation_log` VALUES (17, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:51:23');
INSERT INTO `mqtt_operation_log` VALUES (18, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:54:34');
INSERT INTO `mqtt_operation_log` VALUES (19, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:54:42');
INSERT INTO `mqtt_operation_log` VALUES (20, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:54:58');
INSERT INTO `mqtt_operation_log` VALUES (21, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:55:22');
INSERT INTO `mqtt_operation_log` VALUES (22, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-01-19 20:59:06');
INSERT INTO `mqtt_operation_log` VALUES (23, 'admin', '设备控制-resume', '测试设备001', '操作: resume', '成功', NULL, '2026-01-19 20:59:14');
INSERT INTO `mqtt_operation_log` VALUES (24, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-19 20:59:30');
INSERT INTO `mqtt_operation_log` VALUES (25, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 20:59:52');
INSERT INTO `mqtt_operation_log` VALUES (26, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-01-19 21:00:08');
INSERT INTO `mqtt_operation_log` VALUES (27, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 21:00:24');
INSERT INTO `mqtt_operation_log` VALUES (28, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-19 21:00:32');
INSERT INTO `mqtt_operation_log` VALUES (29, 'admin', '设备控制-resume', '测试设备001', '操作: resume', '成功', NULL, '2026-01-19 21:00:39');
INSERT INTO `mqtt_operation_log` VALUES (30, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-01-19 21:02:44');
INSERT INTO `mqtt_operation_log` VALUES (31, 'admin', '设备控制-resume', '测试设备001', '操作: resume', '成功', NULL, '2026-01-19 21:02:56');
INSERT INTO `mqtt_operation_log` VALUES (32, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 11:57:54');
INSERT INTO `mqtt_operation_log` VALUES (33, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 12:05:57');
INSERT INTO `mqtt_operation_log` VALUES (34, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-20 12:09:05');
INSERT INTO `mqtt_operation_log` VALUES (35, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-20 12:25:25');
INSERT INTO `mqtt_operation_log` VALUES (36, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 12:25:52');
INSERT INTO `mqtt_operation_log` VALUES (37, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-20 12:31:04');
INSERT INTO `mqtt_operation_log` VALUES (38, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-20 14:22:15');
INSERT INTO `mqtt_operation_log` VALUES (39, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 14:22:38');
INSERT INTO `mqtt_operation_log` VALUES (40, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 20:33:55');
INSERT INTO `mqtt_operation_log` VALUES (41, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-20 20:35:19');
INSERT INTO `mqtt_operation_log` VALUES (42, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 20:41:30');
INSERT INTO `mqtt_operation_log` VALUES (43, 'admin', '删除设备', '测试设备001,', '删除设备ID: [2]', '成功', NULL, '2026-01-20 20:49:58');
INSERT INTO `mqtt_operation_log` VALUES (44, 'admin', '删除设备', '测试设备001,', '删除设备ID: [3]', '成功', NULL, '2026-01-20 20:52:22');
INSERT INTO `mqtt_operation_log` VALUES (45, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-01-20 20:52:40');
INSERT INTO `mqtt_operation_log` VALUES (46, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-01-20 21:30:01');
INSERT INTO `mqtt_operation_log` VALUES (47, 'admin', '设备控制-stop', '测试设备001', '操作: stop', '成功', NULL, '2026-02-28 22:01:39');
INSERT INTO `mqtt_operation_log` VALUES (48, 'admin', '设备控制-start', '测试设备001', '操作: start', '成功', NULL, '2026-02-28 22:01:46');
INSERT INTO `mqtt_operation_log` VALUES (49, 'admin', '设备控制-pause', '测试设备001', '操作: pause', '成功', NULL, '2026-02-28 22:01:49');

-- ----------------------------
-- Table structure for mqtt_task_config
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_task_config`;
CREATE TABLE `mqtt_task_config`  (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置名称',
  `config_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置内容(JSON格式)',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属用户',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE,
  INDEX `idx_username`(`username`) USING BTREE,
  INDEX `idx_name`(`config_name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT任务配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mqtt_task_config
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int(5) NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint(20) NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int(4) NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 110 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '黄花菜科技', 0, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '黄花菜', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int(4) NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-01-19 17:20:23', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-01-19 17:20:24', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-01-19 17:20:24', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-01-19 17:20:24', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status`) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (1, 'admin', '127.0.0.1', '内网IP', 'Chrome 143', 'Windows10', '0', '登录成功', '2026-01-19 19:13:45');
INSERT INTO `sys_logininfor` VALUES (2, 'admin', '127.0.0.1', '内网IP', 'Chrome 143', 'Windows10', '0', '登录成功', '2026-01-19 20:01:58');
INSERT INTO `sys_logininfor` VALUES (3, 'admin', '127.0.0.1', '内网IP', 'Chrome 143', 'Windows10', '0', '登录成功', '2026-01-20 10:09:03');
INSERT INTO `sys_logininfor` VALUES (4, 'admin', '127.0.0.1', '内网IP', 'Chrome 143', 'Windows10', '1', '验证码已失效', '2026-01-20 21:27:54');
INSERT INTO `sys_logininfor` VALUES (5, 'admin', '127.0.0.1', '内网IP', 'Chrome 143', 'Windows10', '1', '验证码已失效', '2026-01-20 21:27:54');
INSERT INTO `sys_logininfor` VALUES (6, 'admin', '127.0.0.1', '内网IP', 'Chrome 143', 'Windows10', '0', '登录成功', '2026-01-20 21:27:57');
INSERT INTO `sys_logininfor` VALUES (7, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '0', '登录成功', '2026-02-14 15:05:47');
INSERT INTO `sys_logininfor` VALUES (8, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '0', '登录成功', '2026-02-15 13:31:10');
INSERT INTO `sys_logininfor` VALUES (9, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '0', '登录成功', '2026-02-16 00:07:40');
INSERT INTO `sys_logininfor` VALUES (10, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '0', '登录成功', '2026-02-16 08:51:29');
INSERT INTO `sys_logininfor` VALUES (11, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '0', '登录成功', '2026-02-16 21:05:17');
INSERT INTO `sys_logininfor` VALUES (12, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '1', '验证码已失效', '2026-02-16 22:43:24');
INSERT INTO `sys_logininfor` VALUES (13, 'admin', '127.0.0.1', '内网IP', 'Chrome 144', 'Windows10', '0', '登录成功', '2026-02-16 22:43:26');
INSERT INTO `sys_logininfor` VALUES (14, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '1', '验证码已失效', '2026-02-28 10:27:40');
INSERT INTO `sys_logininfor` VALUES (15, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '1', '验证码错误', '2026-02-28 10:27:41');
INSERT INTO `sys_logininfor` VALUES (16, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-02-28 10:27:45');
INSERT INTO `sys_logininfor` VALUES (17, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '1', '验证码错误', '2026-02-28 21:58:35');
INSERT INTO `sys_logininfor` VALUES (18, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-02-28 21:58:38');
INSERT INTO `sys_logininfor` VALUES (19, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-08 01:09:41');
INSERT INTO `sys_logininfor` VALUES (20, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-09 22:01:14');
INSERT INTO `sys_logininfor` VALUES (21, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-09 23:10:19');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int(4) NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int(1) NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int(1) NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1111 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-01-19 17:20:21', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-01-19 17:20:21', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-01-19 17:20:21', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-01-19 17:20:21', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-01-19 17:20:21', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-01-19 17:20:21', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-01-19 17:20:21', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-01-19 17:20:21', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-01-19 17:20:21', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-01-19 17:20:21', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-01-19 17:20:21', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-01-19 17:20:21', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-01-19 17:20:21', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-01-19 17:20:21', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-01-19 17:20:21', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-01-19 17:20:21', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-01-19 17:20:21', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-01-19 17:20:21', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-01-19 17:20:21', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-01-19 17:20:21', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-01-19 17:20:21', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-01-19 17:20:21', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-01-19 17:20:21', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-01-19 17:20:22', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1061, 'MQTT云控', 0, 5, 'mqtt', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'monitor', 'admin', '2026-01-19 19:57:45', '', NULL, 'MQTT云控管理');
INSERT INTO `sys_menu` VALUES (1062, '设备管理', 1061, 1, 'device', 'mqtt/device/index', NULL, '', 1, 0, 'C', '0', '0', 'mqtt:device:list', 'monitor', 'admin', '2026-01-19 19:57:45', '', NULL, 'MQTT设备管理');
INSERT INTO `sys_menu` VALUES (1063, '设备查询', 1062, 1, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:device:query', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1064, '设备删除', 1062, 2, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:device:remove', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1065, '设备命令', 1062, 3, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:device:command', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1066, '任务配置', 1061, 2, 'config', 'mqtt/config/index', NULL, '', 1, 0, 'C', '0', '0', 'mqtt:config:list', 'edit', 'admin', '2026-01-19 19:57:45', '', NULL, 'MQTT任务配置');
INSERT INTO `sys_menu` VALUES (1067, '配置查询', 1066, 1, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:config:query', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1068, '配置新增', 1066, 2, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:config:add', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1069, '配置修改', 1066, 3, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:config:edit', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1070, '配置删除', 1066, 4, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:config:remove', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1071, '配置下发', 1066, 5, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:config:send', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1076, '操作日志', 1061, 4, 'log', 'mqtt/log/index', NULL, '', 1, 0, 'C', '0', '0', 'mqtt:log:list', 'log', 'admin', '2026-01-19 19:57:45', '', NULL, 'MQTT操作日志');
INSERT INTO `sys_menu` VALUES (1077, '日志查询', 1076, 1, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:log:query', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1078, '日志删除', 1076, 2, '', '', NULL, '', 1, 0, 'F', '0', '0', 'mqtt:log:remove', '#', 'admin', '2026-01-19 19:57:45', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1085, '测试用例生成', 1105, 1, 'testcase', 'tool/testcase/index', NULL, '', 1, 0, 'C', '0', '0', 'tool:testcase:list', 'documentation', 'admin', '2026-02-16 00:25:50', '', NULL, '测试用例生成菜单');
INSERT INTO `sys_menu` VALUES (1086, '测试用例查询', 1085, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'tool:testcase:query', '#', 'admin', '2026-02-16 00:25:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1087, '测试用例新增', 1085, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'tool:testcase:add', '#', 'admin', '2026-02-16 00:25:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1088, '测试用例修改', 1085, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'tool:testcase:edit', '#', 'admin', '2026-02-16 00:25:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1089, '测试用例删除', 1085, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'tool:testcase:remove', '#', 'admin', '2026-02-16 00:25:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1090, '测试用例导出', 1085, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'tool:testcase:export', '#', 'admin', '2026-02-16 00:25:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1091, '测试用例生成', 1105, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'tool:testcase:generate', '#', 'admin', '2026-02-16 00:25:50', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1099, 'AI提示词配置', 1105, 2, 'promptconfig', 'aitest/promptconfig/index', NULL, '', 1, 0, 'C', '0', '0', 'aitest:promptconfig:list', 'edit', 'admin', '2026-02-16 08:50:13', '', NULL, 'AI提示词配置菜单');
INSERT INTO `sys_menu` VALUES (1100, 'AI提示词配置查询', 1099, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:promptconfig:query', '#', 'admin', '2026-02-16 08:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1101, 'AI提示词配置新增', 1099, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:promptconfig:add', '#', 'admin', '2026-02-16 08:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1102, 'AI提示词配置修改', 1099, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:promptconfig:edit', '#', 'admin', '2026-02-16 08:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1103, 'AI提示词配置删除', 1099, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:promptconfig:remove', '#', 'admin', '2026-02-16 08:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1104, 'AI提示词配置导出', 1099, 5, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:promptconfig:export', '#', 'admin', '2026-02-16 08:50:13', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1105, 'AI测试', 0, 4, 'aitest', NULL, NULL, '', 1, 0, 'M', '0', '0', '', 'guide', 'admin', '2026-02-16 09:31:18', '', NULL, 'AI测试相关功能');
INSERT INTO `sys_menu` VALUES (1106, 'AI模型配置', 1105, 3, 'modelconfig', 'aitest/modelconfig/index', NULL, '', 1, 0, 'C', '0', '0', 'aitest:modelconfig:list', 'tool', 'admin', '2026-02-16 09:31:18', '', NULL, 'AI模型配置菜单');
INSERT INTO `sys_menu` VALUES (1107, 'AI模型配置查询', 1106, 1, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:modelconfig:query', '#', 'admin', '2026-02-16 09:31:18', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1108, 'AI模型配置新增', 1106, 2, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:modelconfig:add', '#', 'admin', '2026-02-16 09:31:18', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1109, 'AI模型配置修改', 1106, 3, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:modelconfig:edit', '#', 'admin', '2026-02-16 09:31:18', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1110, 'AI模型配置删除', 1106, 4, '#', '', NULL, '', 1, 0, 'F', '0', '0', 'aitest:modelconfig:remove', '#', 'admin', '2026-02-16 09:31:18', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int(4) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 DishTest新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-01-19 17:20:24', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 DishTest系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-01-19 17:20:24', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int(2) NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int(1) NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int(1) NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint(20) NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type`) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status`) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 250 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (1, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:02:35', 818);
INSERT INTO `sys_oper_log` VALUES (2, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:06:55', 613);
INSERT INTO `sys_oper_log` VALUES (3, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:10:49', 684);
INSERT INTO `sys_oper_log` VALUES (4, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:15:31', 776);
INSERT INTO `sys_oper_log` VALUES (5, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:16:55', 947);
INSERT INTO `sys_oper_log` VALUES (6, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:21:05', 655);
INSERT INTO `sys_oper_log` VALUES (7, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:21:15', 72);
INSERT INTO `sys_oper_log` VALUES (8, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:21:30', 148);
INSERT INTO `sys_oper_log` VALUES (9, 'MQTT设备', 3, 'com.dishtest.web.controller.mqtt.MqttDeviceController.remove()', 'DELETE', 1, 'admin', '研发部门', '/mqtt/device/1', '127.0.0.1', '内网IP', '[1] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-01-19 20:25:40', 875);
INSERT INTO `sys_oper_log` VALUES (10, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:26:00', 796);
INSERT INTO `sys_oper_log` VALUES (11, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:26:23', 96);
INSERT INTO `sys_oper_log` VALUES (12, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[]} ', '{\"msg\":\"请选择设备\",\"code\":500}', 0, NULL, '2026-01-19 20:26:33', 0);
INSERT INTO `sys_oper_log` VALUES (13, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:26:38', 62);
INSERT INTO `sys_oper_log` VALUES (14, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:26:43', 92);
INSERT INTO `sys_oper_log` VALUES (15, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"部分设备命令发送失败: 测试设备001,\",\"code\":500}', 0, NULL, '2026-01-19 20:34:06', 461);
INSERT INTO `sys_oper_log` VALUES (16, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:34:14', 780);
INSERT INTO `sys_oper_log` VALUES (17, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:35:05', 86);
INSERT INTO `sys_oper_log` VALUES (18, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:35:10', 69);
INSERT INTO `sys_oper_log` VALUES (19, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:35:24', 73);
INSERT INTO `sys_oper_log` VALUES (20, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:35:39', 75);
INSERT INTO `sys_oper_log` VALUES (21, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:35:45', 69);
INSERT INTO `sys_oper_log` VALUES (22, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:35:50', 69);
INSERT INTO `sys_oper_log` VALUES (23, 'MQTT操作日志', 9, 'com.dishtest.web.controller.mqtt.MqttOperationLogController.clean()', 'DELETE', 1, 'admin', '研发部门', '/mqtt/log/clean', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-01-19 20:36:45', 270);
INSERT INTO `sys_oper_log` VALUES (24, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:38:05', 486);
INSERT INTO `sys_oper_log` VALUES (25, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:38:14', 65);
INSERT INTO `sys_oper_log` VALUES (26, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:38:25', 88);
INSERT INTO `sys_oper_log` VALUES (27, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:39:09', 72);
INSERT INTO `sys_oper_log` VALUES (28, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:39:25', 73);
INSERT INTO `sys_oper_log` VALUES (29, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:39:33', 73);
INSERT INTO `sys_oper_log` VALUES (30, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:39:43', 38);
INSERT INTO `sys_oper_log` VALUES (31, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:39:46', 46);
INSERT INTO `sys_oper_log` VALUES (32, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:39:52', 64);
INSERT INTO `sys_oper_log` VALUES (33, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:40:14', 65);
INSERT INTO `sys_oper_log` VALUES (34, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:40:26', 71);
INSERT INTO `sys_oper_log` VALUES (35, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:40:59', 69);
INSERT INTO `sys_oper_log` VALUES (36, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:43:28', 125);
INSERT INTO `sys_oper_log` VALUES (37, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:44:11', 144);
INSERT INTO `sys_oper_log` VALUES (38, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:49:15', 70);
INSERT INTO `sys_oper_log` VALUES (39, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:49:38', 72);
INSERT INTO `sys_oper_log` VALUES (40, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:50:50', 76);
INSERT INTO `sys_oper_log` VALUES (41, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:51:23', 146);
INSERT INTO `sys_oper_log` VALUES (42, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:54:17', 591);
INSERT INTO `sys_oper_log` VALUES (43, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:54:34', 159);
INSERT INTO `sys_oper_log` VALUES (44, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:54:42', 66);
INSERT INTO `sys_oper_log` VALUES (45, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:54:59', 169);
INSERT INTO `sys_oper_log` VALUES (46, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:55:22', 61);
INSERT INTO `sys_oper_log` VALUES (47, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 20:58:39', 576);
INSERT INTO `sys_oper_log` VALUES (48, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:59:06', 74);
INSERT INTO `sys_oper_log` VALUES (49, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:59:14', 81);
INSERT INTO `sys_oper_log` VALUES (50, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:59:30', 75);
INSERT INTO `sys_oper_log` VALUES (51, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 20:59:52', 106);
INSERT INTO `sys_oper_log` VALUES (52, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 21:00:08', 66);
INSERT INTO `sys_oper_log` VALUES (53, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 21:00:24', 93);
INSERT INTO `sys_oper_log` VALUES (54, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 21:00:32', 102);
INSERT INTO `sys_oper_log` VALUES (55, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 21:00:39', 147);
INSERT INTO `sys_oper_log` VALUES (56, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-19 21:02:37', 1562);
INSERT INTO `sys_oper_log` VALUES (57, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 21:02:45', 48);
INSERT INTO `sys_oper_log` VALUES (58, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[]} ', '{\"msg\":\"请选择设备\",\"code\":500}', 0, NULL, '2026-01-19 21:02:52', 0);
INSERT INTO `sys_oper_log` VALUES (59, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-19 21:02:56', 90);
INSERT INTO `sys_oper_log` VALUES (60, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 10:09:22', 716);
INSERT INTO `sys_oper_log` VALUES (61, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 10:28:23', 500);
INSERT INTO `sys_oper_log` VALUES (62, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 10:29:08', 5);
INSERT INTO `sys_oper_log` VALUES (63, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 10:29:12', 589);
INSERT INTO `sys_oper_log` VALUES (64, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 10:55:18', 789);
INSERT INTO `sys_oper_log` VALUES (65, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 10:58:05', 674);
INSERT INTO `sys_oper_log` VALUES (66, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:07:06', 479);
INSERT INTO `sys_oper_log` VALUES (67, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:22:53', 674);
INSERT INTO `sys_oper_log` VALUES (68, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:27:35', 490);
INSERT INTO `sys_oper_log` VALUES (69, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:40:58', 482);
INSERT INTO `sys_oper_log` VALUES (70, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:45:55', 582);
INSERT INTO `sys_oper_log` VALUES (71, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:47:23', 795);
INSERT INTO `sys_oper_log` VALUES (72, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:49:48', 1708);
INSERT INTO `sys_oper_log` VALUES (73, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 11:56:50', 697);
INSERT INTO `sys_oper_log` VALUES (74, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 11:57:54', 79);
INSERT INTO `sys_oper_log` VALUES (75, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 12:05:57', 296);
INSERT INTO `sys_oper_log` VALUES (76, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 12:06:24', 4);
INSERT INTO `sys_oper_log` VALUES (77, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 12:06:50', 592);
INSERT INTO `sys_oper_log` VALUES (78, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 12:09:05', 74);
INSERT INTO `sys_oper_log` VALUES (79, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 12:20:46', 696);
INSERT INTO `sys_oper_log` VALUES (80, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 12:24:06', 584);
INSERT INTO `sys_oper_log` VALUES (81, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[]} ', '{\"msg\":\"请选择设备\",\"code\":500}', 0, NULL, '2026-01-20 12:25:18', 0);
INSERT INTO `sys_oper_log` VALUES (82, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 12:25:25', 94);
INSERT INTO `sys_oper_log` VALUES (83, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 12:25:53', 289);
INSERT INTO `sys_oper_log` VALUES (84, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[]} ', '{\"msg\":\"请选择设备\",\"code\":500}', 0, NULL, '2026-01-20 12:30:58', 0);
INSERT INTO `sys_oper_log` VALUES (85, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 12:31:04', 59);
INSERT INTO `sys_oper_log` VALUES (86, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 12:31:39', 3);
INSERT INTO `sys_oper_log` VALUES (87, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 12:31:42', 581);
INSERT INTO `sys_oper_log` VALUES (88, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 14:22:15', 65);
INSERT INTO `sys_oper_log` VALUES (89, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 14:22:39', 577);
INSERT INTO `sys_oper_log` VALUES (90, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 17:29:02', 581);
INSERT INTO `sys_oper_log` VALUES (91, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:24:06', 421);
INSERT INTO `sys_oper_log` VALUES (92, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:28:40', 1017);
INSERT INTO `sys_oper_log` VALUES (93, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:30:38', 689);
INSERT INTO `sys_oper_log` VALUES (94, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 20:33:55', 103);
INSERT INTO `sys_oper_log` VALUES (95, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 20:34:13', 3);
INSERT INTO `sys_oper_log` VALUES (96, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:34:14', 582);
INSERT INTO `sys_oper_log` VALUES (97, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 20:35:19', 286);
INSERT INTO `sys_oper_log` VALUES (98, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 20:35:56', 3);
INSERT INTO `sys_oper_log` VALUES (99, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:36:27', 520);
INSERT INTO `sys_oper_log` VALUES (100, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:41:03', 707);
INSERT INTO `sys_oper_log` VALUES (101, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 20:41:30', 206);
INSERT INTO `sys_oper_log` VALUES (102, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 20:41:54', 5);
INSERT INTO `sys_oper_log` VALUES (103, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:42:33', 526);
INSERT INTO `sys_oper_log` VALUES (104, 'MQTT设备', 3, 'com.dishtest.web.controller.mqtt.MqttDeviceController.remove()', 'DELETE', 1, 'admin', '研发部门', '/mqtt/device/2', '127.0.0.1', '内网IP', '[2] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-01-20 20:49:58', 397);
INSERT INTO `sys_oper_log` VALUES (105, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 20:50:14', 1);
INSERT INTO `sys_oper_log` VALUES (106, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:50:15', 692);
INSERT INTO `sys_oper_log` VALUES (107, 'MQTT设备', 3, 'com.dishtest.web.controller.mqtt.MqttDeviceController.remove()', 'DELETE', 1, 'admin', '研发部门', '/mqtt/device/3', '127.0.0.1', '内网IP', '[3] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-01-20 20:52:22', 566);
INSERT INTO `sys_oper_log` VALUES (108, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 20:52:40', 83);
INSERT INTO `sys_oper_log` VALUES (109, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 20:53:04', 2);
INSERT INTO `sys_oper_log` VALUES (110, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 20:53:06', 574);
INSERT INTO `sys_oper_log` VALUES (111, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:13:01', 640);
INSERT INTO `sys_oper_log` VALUES (112, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 21:13:12', 1);
INSERT INTO `sys_oper_log` VALUES (113, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:28:09', 473);
INSERT INTO `sys_oper_log` VALUES (114, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:29:25', 723);
INSERT INTO `sys_oper_log` VALUES (115, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-01-20 21:30:02', 82);
INSERT INTO `sys_oper_log` VALUES (116, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 21:30:33', 1);
INSERT INTO `sys_oper_log` VALUES (117, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:30:34', 716);
INSERT INTO `sys_oper_log` VALUES (118, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:31:04', 715);
INSERT INTO `sys_oper_log` VALUES (119, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:34:44', 787);
INSERT INTO `sys_oper_log` VALUES (120, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 21:42:17', 3);
INSERT INTO `sys_oper_log` VALUES (121, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 21:57:57', 665);
INSERT INTO `sys_oper_log` VALUES (122, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-01-20 22:09:17', 2);
INSERT INTO `sys_oper_log` VALUES (123, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-01-20 22:19:30', 588);
INSERT INTO `sys_oper_log` VALUES (124, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-02-14 15:06:01', 685);
INSERT INTO `sys_oper_log` VALUES (125, 'MQTT断开', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.disconnect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/disconnect', '127.0.0.1', '内网IP', '', '{\"msg\":\"MQTT连接已断开\",\"code\":200}', 0, NULL, '2026-02-14 15:16:22', 3);
INSERT INTO `sys_oper_log` VALUES (126, '生成测试用例', 1, 'com.dishtest.web.controller.tool.TestCaseRecordController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate', '127.0.0.1', '内网IP', '{\"createTime\":\"2026-02-15 13:55:22\",\"generationStatus\":\"2\",\"params\":{},\"recordId\":1,\"recordName\":\"123\",\"requirementContent\":\"1\",\"testCaseContent\":\"我需要您提供具体的测试需求内容才能为您设计测试用例。\\n\\n请提供以下信息：\\n\\n- 功能模块名称\\n- 具体功能描述\\n- 业务规则和约束条件\\n- 输入输出要求\\n- 特殊场景说明（如有）\\n\\n例如：\\n- \\\"用户登录功能\\\"\\n- \\\"商品搜索模块\\\"\\n- \\\"订单支付流程\\\"\\n- \\\"文件上传功能\\\"\\n\\n请描述您需要测试的功能需求，我将为您生成完整的测试用例。\",\"updateTime\":\"2026-02-15 13:55:27\"} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":{\"createTime\":\"2026-02-15 13:55:22\",\"generationStatus\":\"2\",\"params\":{},\"recordId\":1,\"recordName\":\"123\",\"requirementContent\":\"1\",\"testCaseContent\":\"我需要您提供具体的测试需求内容才能为您设计测试用例。\\n\\n请提供以下信息：\\n\\n- 功能模块名称\\n- 具体功能描述\\n- 业务规则和约束条件\\n- 输入输出要求\\n- 特殊场景说明（如有）\\n\\n例如：\\n- \\\"用户登录功能\\\"\\n- \\\"商品搜索模块\\\"\\n- \\\"订单支付流程\\\"\\n- \\\"文件上传功能\\\"\\n\\n请描述您需要测试的功能需求，我将为您生成完整的测试用例。\",\"updateTime\":\"2026-02-15 13:55:27\"}}', 0, NULL, '2026-02-15 13:54:26', 5049);
INSERT INTO `sys_oper_log` VALUES (127, '测试用例生成记录', 3, 'com.dishtest.web.controller.tool.TestCaseRecordController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/1', '127.0.0.1', '内网IP', '[1] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-15 13:56:47', 102);
INSERT INTO `sys_oper_log` VALUES (128, '生成测试用例', 1, 'com.dishtest.web.controller.tool.TestCaseRecordController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate', '127.0.0.1', '内网IP', '{\"createTime\":\"2026-02-15 14:09:42\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215140916A001.xlsx\",\"filePath\":\"/profile/upload/2026/02/15/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215140916A001.xlsx\",\"generationStatus\":\"2\",\"params\":{},\"recordId\":2,\"recordName\":\"11\",\"requirementContent\":\"【提示】检测到非文本格式文件（.xlsx），建议使用纯文本格式（txt、md）以获得最佳效果。\\n\\n如果您的需求文档是 Excel、Word 等格式，请先将内容复制到文本文件中再上传。\\n\\n文件已上传成功，您可以手动输入需求内容后继续生成测试用例。\",\"testCaseContent\":\"我已准备好为您生成测试用例。\\n\\n请您将 Excel 文件中的需求内容以文本形式提供给我，我将基于这些需求运用系统化的测试设计方法，生成全面、精准、高覆盖率的测试用例，并按照 XMind 兼容的 Markdown 格式输出。\\n\\n您可以直接复制粘贴需求内容，或者描述功能需求，我会立即开始设计测试用例。\",\"updateTime\":\"2026-02-15 14:09:47\"} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":{\"createTime\":\"2026-02-15 14:09:42\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215140916A001.xlsx\",\"filePath\":\"/profile/upload/2026/02/15/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215140916A001.xlsx\",\"generationStatus\":\"2\",\"params\":{},\"recordId\":2,\"recordName\":\"11\",\"requirementContent\":\"【提示】检测到非文本格式文件（.xlsx），建议使用纯文本格式（txt、md）以获得最佳效果。\\n\\n如果您的需求文档是 Excel、Word 等格式，请先将内容复制到文本文件中再上传。\\n\\n文件已上传成功，您可以手动输入需求内容后继续生成测试用例。\",\"testCaseContent\":\"我已准备好为您生成测试用例。\\n\\n请您将 Excel 文件中的需求内容以文本形式提供给我，我将基于这些需求运用系统化的测试设计方法，生成全面、精准、高覆盖率的测试用例，并按照 XMind 兼容的 Markdown 格式输出。\\n\\n您可以直接复制粘贴需求内容，或者描述功能需求，我会立即开始设计测试用例。\",\"updateTime\":\"2026-02-15 14:09:47\"}}', 0, NULL, '2026-02-15 14:08:45', 4537);
INSERT INTO `sys_oper_log` VALUES (129, '生成测试用例', 1, 'com.dishtest.web.controller.tool.TestCaseRecordController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate', '127.0.0.1', '内网IP', '{\"createTime\":\"2026-02-15 14:18:44\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215141834A001.xlsx\",\"filePath\":\"/profile/upload/2026/02/15/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215141834A001.xlsx\",\"generationStatus\":\"2\",\"params\":{},\"recordId\":3,\"recordName\":\"22\",\"requirementContent\":\"【提示】文件上传成功，但无法自动读取文件内容。\\n\\n错误信息：D:\\\\ruoyi\\\\uploadPath\\\\profile\\\\upload\\\\2026\\\\02\\\\15\\\\55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215141834A001.xlsx (系统找不到指定的路径。)\\n\\n建议使用纯文本格式（txt、md）以获得最佳效果。\\n\\n您可以手动输入需求内容后继续生成测试用例。\",\"testCaseContent\":\"# 文件上传功能测试用例\\n\\n## 文件上传基础功能\\n### 文件选择与上传\\n#### 正常文件上传\\n##### 上传单个txt文件（1KB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个md文件（500KB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个xlsx文件（2MB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个图片文件jpg（5MB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个pdf文件（10MB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n\\n#### 文件大小边界测试\\n##### 上传0字节空文件\\n###### 预期结果：提示文件为空，上传失败\\n##### 上传1字节文件\\n###### 预期结果：文件上传成功\\n##### 上传接近最大限制的文件（如限制10MB，上传9.99MB）\\n###### 预期结果：文件上传成功\\n##### 上传刚好达到最大限制的文件（10MB）\\n###### 预期结果：文件上传成功\\n##### 上传超过最大限制的文件（10.01MB）\\n###### 预期结果：提示文件超过大小限制，上传失败\\n\\n#### 文件类型验证\\n##### 上传允许的文件类型（txt/md/xlsx/jpg/png/pdf）\\n###### 预期结果：文件上传成功\\n##### 上传不允许的文件类型（exe/bat/sh）\\n###### 预期结果：提示文件类型不允许，上传失败\\n##### 上传无扩展名的文件\\n###### 预期结果：提示文件类型无效，上传失败\\n##### 上传双扩展名文件（test.txt.exe）\\n###### 预期结果：根据真实文件类型判断，阻止恶意文件\\n##### 修改文件扩展名伪装（exe改为txt）\\n###### 预期结果：系统识别真实文件类型，阻止上传\\n\\n### 文件路径生成\\n#### 路径结构验证\\n##### 验证路径按日期分层（年/月/日）\\n###### 预期结果：生成路径格式为/profile/upload/2026/02/15/\\n##### 同一天上传多个文件\\n###### 预期结果：所有文件存储在同一日期目录下\\n##### 跨天上传文件\\n###### 预期结果：文件按各自上传日期分别存储在对应目录\\n\\n#### 文件名生成规则\\n##### 验证文件名包含UUID\\n###### 预期结果：生成32位UUID作为文件名前缀\\n##### 验证文件名保留原始扩展名\\n###### 预期结果：新文件名格式为{UUID}.{原扩展名}\\n##### 上传同名文件\\n###### 预期结果：生成不同UUID，不会覆盖原文件\\n##### 文件名包含特殊字符（~、空格、中文）\\n###### 预期结果：系统正确处理，生成有效路径\\n\\n#### 路径存在性检查\\n##### 目标目录不存在时上传文件\\n###### 预期结果：系统自动创建目录结构，文件上传成功\\n##### 目标目录已存在时上传文件\\n####', '{\"msg\":\"操作成功\",\"code\":200,\"data\":{\"createTime\":\"2026-02-15 14:18:44\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215141834A001.xlsx\",\"filePath\":\"/profile/upload/2026/02/15/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215141834A001.xlsx\",\"generationStatus\":\"2\",\"params\":{},\"recordId\":3,\"recordName\":\"22\",\"requirementContent\":\"【提示】文件上传成功，但无法自动读取文件内容。\\n\\n错误信息：D:\\\\ruoyi\\\\uploadPath\\\\profile\\\\upload\\\\2026\\\\02\\\\15\\\\55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260215141834A001.xlsx (系统找不到指定的路径。)\\n\\n建议使用纯文本格式（txt、md）以获得最佳效果。\\n\\n您可以手动输入需求内容后继续生成测试用例。\",\"testCaseContent\":\"# 文件上传功能测试用例\\n\\n## 文件上传基础功能\\n### 文件选择与上传\\n#### 正常文件上传\\n##### 上传单个txt文件（1KB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个md文件（500KB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个xlsx文件（2MB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个图片文件jpg（5MB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n##### 上传单个pdf文件（10MB）\\n###### 预期结果：文件上传成功，返回正确的文件路径和访问URL\\n\\n#### 文件大小边界测试\\n##### 上传0字节空文件\\n###### 预期结果：提示文件为空，上传失败\\n##### 上传1字节文件\\n###### 预期结果：文件上传成功\\n##### 上传接近最大限制的文件（如限制10MB，上传9.99MB）\\n###### 预期结果：文件上传成功\\n##### 上传刚好达到最大限制的文件（10MB）\\n###### 预期结果：文件上传成功\\n##### 上传超过最大限制的文件（10.01MB）\\n###### 预期结果：提示文件超过大小限制，上传失败\\n\\n#### 文件类型验证\\n##### 上传允许的文件类型（txt/md/xlsx/jpg/png/pdf）\\n###### 预期结果：文件上传成功\\n##### 上传不允许的文件类型（exe/bat/sh）\\n###### 预期结果：提示文件类型不允许，上传失败\\n##### 上传无扩展名的文件\\n###### 预期结果：提示文件类型无效，上传失败\\n##### 上传双扩展名文件（test.txt.exe）\\n###### 预期结果：根据真实文件类型判断，阻止恶意文件\\n##### 修改文件扩展名伪装（exe改为txt）\\n###### 预期结果：系统识别真实文件类型，阻止上传\\n\\n### 文件路径生成\\n#### 路径结构验证\\n##### 验证路径按日期分层（年/月/日）\\n###### 预期结果：生成路径格式为/profile/upload/2026/02/15/\\n##### 同一天上传多个文件\\n###### 预期结果：所有文件存储在同一日期目录下\\n##### 跨天上传文件\\n###### 预期结果：文件按各自上传日期分别存储在对应目录\\n\\n#### 文件名生成规则\\n##### 验证文件名包含UUID\\n###### 预期结果：生成32位UUID作为文件名前缀\\n##### 验证文件名保留原始扩展名\\n###### 预期结果：新文件名格式为{UUID}.{原扩展名}\\n##### 上传同名文件\\n###### 预期结果：生成不同UUID，不会覆盖原文件\\n##### 文件名包含特殊字符（~、空格、中文）\\n###### 预期结果：系统正确处理，生成有效路径\\n\\n#### 路径存在性检查\\n##### 目标目录不存在时上传文件\\n###### 预期结果：系统自动创建目录结构，', 0, NULL, '2026-02-15 14:18:17', 34106);
INSERT INTO `sys_oper_log` VALUES (130, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1079', '127.0.0.1', '内网IP', '1079 ', '{\"msg\":\"存在子菜单,不允许删除\",\"code\":601}', 0, NULL, '2026-02-16 00:27:51', 162);
INSERT INTO `sys_oper_log` VALUES (131, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1084', '127.0.0.1', '内网IP', '1084 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:28:12', 572);
INSERT INTO `sys_oper_log` VALUES (132, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1083', '127.0.0.1', '内网IP', '1083 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:28:15', 282);
INSERT INTO `sys_oper_log` VALUES (133, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1081', '127.0.0.1', '内网IP', '1081 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:28:18', 379);
INSERT INTO `sys_oper_log` VALUES (134, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1080', '127.0.0.1', '内网IP', '1080 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:28:22', 584);
INSERT INTO `sys_oper_log` VALUES (135, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1082', '127.0.0.1', '内网IP', '1082 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:28:29', 1009);
INSERT INTO `sys_oper_log` VALUES (136, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1079', '127.0.0.1', '内网IP', '1079 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:28:34', 585);
INSERT INTO `sys_oper_log` VALUES (137, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"caseTitle\":\"44\",\"aiModel\":\"claude\"}', '{\"msg\":\"文件上传失败: \\r\\n### Error updating database.  Cause: java.sql.SQLSyntaxErrorException: Unknown column \'file_name\' in \'field list\'\\r\\n### The error may exist in file [D:\\\\fork\\\\RuoYi-Vue\\\\ruoyi-system\\\\target\\\\classes\\\\mapper\\\\system\\\\TestCaseMapper.xml]\\r\\n### The error may involve com.dishtest.system.mapper.TestCaseMapper.insertTestCase-Inline\\r\\n### The error occurred while setting parameters\\r\\n### SQL: insert into test_case          ( case_title,             input_doc,             file_name,             file_path,             file_type,                          status,             ai_model,                                                    create_time )           values ( ?,             ?,             ?,             ?,             ?,                          ?,             ?,                                                    ? )\\r\\n### Cause: java.sql.SQLSyntaxErrorException: Unknown column \'file_name\' in \'field list\'\\n; bad SQL grammar []; nested exception is java.sql.SQLSyntaxErrorException: Unknown column \'file_name\' in \'field list\'\",\"code\":500}', 0, NULL, '2026-02-16 00:51:20', 1212);
INSERT INTO `sys_oper_log` VALUES (138, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"caseTitle\":\"44\",\"aiModel\":\"claude\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 00:54:30', 211);
INSERT INTO `sys_oper_log` VALUES (139, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/1', '127.0.0.1', '内网IP', '1 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 00:56:41', 41639);
INSERT INTO `sys_oper_log` VALUES (140, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/1', '127.0.0.1', '内网IP', '1 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 01:03:17', 41743);
INSERT INTO `sys_oper_log` VALUES (141, '导出测试用例CSV', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportCsv()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportCsv/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-02-16 01:05:29', 144);
INSERT INTO `sys_oper_log` VALUES (142, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/1', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-02-16 01:05:58', 188);
INSERT INTO `sys_oper_log` VALUES (143, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1085', '127.0.0.1', '内网IP', '1085 ', '{\"msg\":\"存在子菜单,不允许删除\",\"code\":601}', 0, NULL, '2026-02-16 01:27:49', 103);
INSERT INTO `sys_oper_log` VALUES (144, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1098', '127.0.0.1', '内网IP', '1098 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:27:57', 371);
INSERT INTO `sys_oper_log` VALUES (145, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1097', '127.0.0.1', '内网IP', '1097 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:28:01', 261);
INSERT INTO `sys_oper_log` VALUES (146, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-02-16 01:28:05', 46);
INSERT INTO `sys_oper_log` VALUES (147, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1096', '127.0.0.1', '内网IP', '1096 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:28:11', 190);
INSERT INTO `sys_oper_log` VALUES (148, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1095', '127.0.0.1', '内网IP', '1095 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:28:16', 297);
INSERT INTO `sys_oper_log` VALUES (149, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1094', '127.0.0.1', '内网IP', '1094 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:28:20', 284);
INSERT INTO `sys_oper_log` VALUES (150, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1093', '127.0.0.1', '内网IP', '1093 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:28:24', 299);
INSERT INTO `sys_oper_log` VALUES (151, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1092', '127.0.0.1', '内网IP', '1092 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:28:28', 289);
INSERT INTO `sys_oper_log` VALUES (152, '菜单管理', 2, 'com.dishtest.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-01-19 17:20:21\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"DishTest官网\",\"menuType\":\"M\",\"orderNum\":1,\"params\":{},\"parentId\":0,\"path\":\"1\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"修改菜单\'DishTest官网\'失败，地址必须以http(s)://开头\",\"code\":500}', 0, NULL, '2026-02-16 01:28:40', 159);
INSERT INTO `sys_oper_log` VALUES (153, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-02-16 01:28:50', 162);
INSERT INTO `sys_oper_log` VALUES (154, '菜单管理', 2, 'com.dishtest.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-01-19 17:20:21\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"DishTest官网\",\"menuType\":\"M\",\"orderNum\":4,\"params\":{},\"parentId\":4,\"path\":\"http://dishtest.vip\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"修改菜单\'DishTest官网\'失败，上级菜单不能选择自己\",\"code\":500}', 0, NULL, '2026-02-16 01:28:58', 54);
INSERT INTO `sys_oper_log` VALUES (155, '菜单管理', 2, 'com.dishtest.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-01-19 17:20:21\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"DishTest官网\",\"menuType\":\"M\",\"orderNum\":4,\"params\":{},\"parentId\":1061,\"path\":\"http://dishtest.vip\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 01:29:02', 257);
INSERT INTO `sys_oper_log` VALUES (156, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-02-16 01:29:08', 49);
INSERT INTO `sys_oper_log` VALUES (157, 'AI提示词配置', 2, 'com.dishtest.web.controller.tool.AiPromptConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/promptconfig', '127.0.0.1', '内网IP', '{\"configId\":1,\"configName\":\"默认测试用例生成提示词\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 08:50:02\",\"isDefault\":\"1\",\"params\":{},\"promptContent\":\"# 角色\\n你是一位资深游戏测试专家，拥有15年以上测试经验，精通黑盒测试、白盒测试、灰盒测试等多种测试方法。你擅长运用等价类划分、边界值分析、决策表、状态转换、正交试验、场景法、错误推测法等测试设计技术，能够设计出覆盖率达到98%以上的高质量测试用例。\\n\\n## 核心任务\\n基于用户提供的需求内容{{input_doc}}，运用系统化的测试设计方法，生成继续续写全面、精准、高覆盖率的测试用例，不要输出推理过程，直接给出结果。\\n\\n## 技能\\n### 技能1: 多维度需求分析\\n1. **功能性分析**: 识别核心功能、辅助功能、隐含功能\\n2. **非功能性分析**: 性能、安全、可用性、兼容性等要求\\n3. **约束条件分析**: 业务规则、技术限制、环境约束\\n4. **风险点识别**: 潜在缺陷区域、用户易错操作、系统薄弱环节\\n5. **依赖关系梳理**: 前置条件、后置条件、数据依赖\\n\\n### 技能2: 系统化测试用例设计\\n1. **多方法组合应用**:\\n   - 等价类划分：有效等价类 + 无效等价类\\n   - 边界值分析：上点、内点、离点（包括边界值±1）\\n   - 决策表：覆盖所有条件组合\\n   - 状态转换：覆盖所有状态路径\\n   - 正交试验：减少用例数量同时保证覆盖率\\n   - 场景法：正常场景 + 异常场景 + 边界场景\\n   - 错误推测：基于经验的异常情况\\n\\n   2. **全面覆盖策略**:\\n   - **输入覆盖**: 数据类型、长度、格式、编码、特殊字符\\n   - **操作覆盖**: 正常操作、异常操作、并发操作、重复操作\\n   - **环境覆盖**: 不同浏览器、操作系统、网络环境、设备类型\\n   - **状态覆盖**: 初始状态、中间状态、结束状态、异常状态\\n   - **时序覆盖**: 操作顺序、时间间隔、超时情况\\n\\n ### 技能3: 高覆盖率保障机制\\n1. **覆盖率检查清单**:\\n   - [ ] 正常路径覆盖率 ≥ 95%\\n   - [ ] 异常路径覆盖率 ≥ 90%\\n   - [ ] 边界条件覆盖率 = 100%\\n   - [ ] 业务规则覆盖率 = 100%\\n   - [ ] 用户场景覆盖率 ≥ 95%\\n\\n\\n### 技能 4: 规范整理输出\\n1. 将精心设计好的测试用例，按照严格规范的 XMind 兼容的 Markdown 层级格式进行整理，方便用户直接导入 XMind 文档，无需进行额外的格式调整。\\n2. 输出的 Markdown 层级格式结构需清晰明了，仅输出纯Markdown内容，具体格式如：\\n# [文档主标题]\\n## [功能模块名称]\\n### [功能测试点1]\\n#### [验证点1.1]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n#### [ 验证点1.2]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n\\n\\n   ## 用例设计方法示例\\n**原需求**: 昵称规则：1-20字符（支持中文/英文/数字），禁止特殊符号（除\\\"_\\\"和\\\"·\\\"）\\n\\n**测试用例设计思路**:\\n\\n### 1. 等价类划分\\n**有效等价类**:\\n- 长度: 1-20字符\\n- 字符类型: 中文、英文字母(大小写)、数字、下划线、间隔号\\n\\n**无效等价类**:\\n- 长度: 0字符、21+字符\\n- 字符类型: 其他特殊符号、表情符号、控制字符\\n\\n### 2. 边界值分析\\n- 长度边界: 0, 1, 2, 19, 20, 21字符\\n- 字符边界: ASCII边界、Unicode边界\\n\\n### 3. 组合测试\\n- 纯中文: 1字符、10字符、20字符\\n- 纯英文: 大写、小写、混合\\n- 纯数字: 单个、多个\\n- 混合字符: 中英文、中文数字、英文数字、全混合\\n- 包含允许符号: 单独使用、与其他字符组合\\n\\n### 4. 异常场景\\n- 空输入、空格、制表符\\n- SQL注入字符: \', \\\", ;, --, /*\\n- XSS字符: , &, javascript:\\n- 特殊Unicode: 零宽字符、RTL字符\\n- 表情符号', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 08:51:59', 406);
INSERT INTO `sys_oper_log` VALUES (158, 'AI模型配置', 1, 'com.dishtest.web.controller.aitest.AiModelConfigController.add()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-1uWNRJZq3KwoZyJhktoovNCXBulL9w4BJOeOcnkZXmELchnc\",\"apiUrl\":\"https://api.penguinsaichat.dpdns.org/v1/messages\",\"createTime\":\"2026-02-16 09:42:25\",\"isDefault\":\"1\",\"maxTokens\":32768,\"modelId\":6,\"modelName\":\"claude-opus-4-5-20251101-thinking\",\"modelType\":\"claude\",\"modelVersion\":\"claude-opus-4-5-20251101-thinking\",\"params\":{},\"status\":\"0\",\"temperature\":0.7} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:41:21', 480);
INSERT INTO `sys_oper_log` VALUES (159, '测试用例', 3, 'com.dishtest.web.controller.tool.TestCaseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/1', '127.0.0.1', '内网IP', '[1] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:41:38', 572);
INSERT INTO `sys_oper_log` VALUES (160, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"6\",\"caseTitle\":\"suffle\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:42:06', 738);
INSERT INTO `sys_oper_log` VALUES (161, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiUrl\":\"http://localhost:11434/api/generate\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 09:30:53\",\"isDefault\":\"0\",\"maxTokens\":4096,\"modelId\":5,\"modelName\":\"本地Ollama\",\"modelType\":\"local\",\"modelVersion\":\"llama2\",\"params\":{},\"remark\":\"本地部署的Ollama模型\",\"status\":\"1\",\"temperature\":0.7,\"updateTime\":\"2026-02-16 09:49:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:47:56', 105);
INSERT INTO `sys_oper_log` VALUES (162, '测试用例', 3, 'com.dishtest.web.controller.tool.TestCaseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/2', '127.0.0.1', '内网IP', '[2] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:48:09', 248);
INSERT INTO `sys_oper_log` VALUES (163, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"6\",\"caseTitle\":\"suffle\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:48:24', 366);
INSERT INTO `sys_oper_log` VALUES (164, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"aiModel\":\"coze\",\"caseId\":3,\"caseTitle\":\"suffle\",\"createBy\":\"\",\"createTime\":\"2026-02-16 09:49:29\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"filePath\":\"/profile/upload/2026/02/16/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260216094928A002.xlsx\",\"fileType\":\"xlsx\",\"inputDoc\":\"Sheet: 新方案\\n\\n风扇（刷新）\\t\\t\\n核心思想：凑组/去单/保空格\\t\\t\\n每一次刷新第一层都要新增一组能消除的物品，同时为了保证空格数量，减少单独的物品，并成组的往最后放\\t\\n\\t\\t\\n\\t\\n\\t\\nif\\t当前第一层可消除组数&gt;=5(或者全部为相同物品或者除去可消除物品后剩余物品数=3\\t\\n\\t只刷新位置，结束\\t\\nif\\t当前第一层可消除组数&gt;=5(或者全部为相同物品或者除去可消除物品后剩余物品数&lt;3)但是0&lt;=空格数q&lt;3\\t\\t\\n\\t挑选一个或两个或一对单独的物品，把整组扔到最后新建的一层，直到q=3\\t\\t\\t\\t\\t\\nif\\t\\t\\t0&lt;=当前第一层可消除组数&lt;5\\t\\n\\t把第一层非特殊货柜2的货品拿出来（如果没有选中成2的商品，就把单格货柜/刷新器加入一起选出成2的商品）\\t\\n\\t看第二层有没有1能与之消除的\\t\\n\\tif\\t有\\t\\n\\t\\t都（上限是2）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数\\t\\n\\tif\\t当前层空格数=3\\t\\n刷新位置\\t\\nelse\\t把第一层的1拿出来，看第二层有没有2可与之消除\\t\\nif\\t有\\t\\n\\t都（上限是2）拿到第一层来，并与某几对或者几个单独的物品进行交换，检查当前空格数\\t\\nif\\t当前层空格数=3\\t\\n刷新位置\\t\\nelse\\t看第3层有没有能与第一层的2消除的（一般来说前两步就够了）\\t\\t\\t\\t\\t\\t\\n\\tif\\t有\\t\\t\\t\\t\\t\\n\\t\\t都（上限是3）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数\\t\\t\\t\\t\\t\\n\\t\\tif\\t当前层空格数第二层格子数）\\t\\n\\t第一层在所有格子范围内保持原比例交换，位置随机，第二层只在非空格子内交换\\t\\n\\tif\\t第一层有空格子，第二层有空格子\\t\\n\\t第一层在所有格子范围内保持原比例交换，位置随机，可以交换到空格里，但是保证第二层非空格子前有东西，第二层只在非空格格子里交换\\t\\t\\n\\t由于我们在刷新位置之前有选取整组物品往后放的操作，可能会导致某一层为空，刷新位置的时候要把尽量空格刷的均匀一点\\t\\n\\t\\n\\t\\n\\t2、选取单独物品交换的逻辑\\t\\t\\t\\n\\t如果是选一个或多个单独的物品进行交换\\t\\n\\t选在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员\\t\\n\\t如果没有满足上述条件的物品，选在第一层非特殊格子非锁链上的物品，且其至少有一个成员不在第一层，优先选没有和其其他成员放在一起（在一个格子里）的\\t\\n\\t\\t\\t\\t\\n\\t3、选取单独物品并把整组往后放的逻辑\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果我们要选出一个单独的物品并把整组往最后放\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果拿到了有成员在刷新器或者单格移动货柜上的物品种类，把其放在最后一个，后面的补位上来，其余的1/2个成员只需要选一个格子新增一层放进去\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t优先选取在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员，满足此条件的基础上，优先选取跨三层的物品，次之为跨两层格子的物品\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果选取的物品拿走后会导致第3层及以后的层有格子为空，就在同一层拿一个单独的物品（拿完不能使任何格子为空）放进去使其不为空，如果没有满足的，就随机挑一个吧，如果一个也没有就让后一层顶上来\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t随机挑选2个层数&gt;=2的格子（普通格子或者传送带格子）新增一层；并挑选一组物品按照的3：0：0：0：0：1比例放到该关卡最后新增的一层\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果只有一个层数&gt', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:51:59', 471);
INSERT INTO `sys_oper_log` VALUES (165, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"aiModel\":\"coze\",\"caseId\":3,\"caseTitle\":\"suffle\",\"createBy\":\"\",\"createTime\":\"2026-02-16 09:49:29\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"filePath\":\"/profile/upload/2026/02/16/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260216094928A002.xlsx\",\"fileType\":\"xlsx\",\"inputDoc\":\"Sheet: 新方案\\n\\n风扇（刷新）\\t\\t\\n核心思想：凑组/去单/保空格\\t\\t\\n每一次刷新第一层都要新增一组能消除的物品，同时为了保证空格数量，减少单独的物品，并成组的往最后放\\t\\n\\t\\t\\n\\t\\n\\t\\nif\\t当前第一层可消除组数&gt;=5(或者全部为相同物品或者除去可消除物品后剩余物品数=3\\t\\n\\t只刷新位置，结束\\t\\nif\\t当前第一层可消除组数&gt;=5(或者全部为相同物品或者除去可消除物品后剩余物品数&lt;3)但是0&lt;=空格数q&lt;3\\t\\t\\n\\t挑选一个或两个或一对单独的物品，把整组扔到最后新建的一层，直到q=3\\t\\t\\t\\t\\t\\nif\\t\\t\\t0&lt;=当前第一层可消除组数&lt;5\\t\\n\\t把第一层非特殊货柜2的货品拿出来（如果没有选中成2的商品，就把单格货柜/刷新器加入一起选出成2的商品）\\t\\n\\t看第二层有没有1能与之消除的\\t\\n\\tif\\t有\\t\\n\\t\\t都（上限是2）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数\\t\\n\\tif\\t当前层空格数=3\\t\\n刷新位置\\t\\nelse\\t把第一层的1拿出来，看第二层有没有2可与之消除\\t\\nif\\t有\\t\\n\\t都（上限是2）拿到第一层来，并与某几对或者几个单独的物品进行交换，检查当前空格数\\t\\nif\\t当前层空格数=3\\t\\n刷新位置\\t\\nelse\\t看第3层有没有能与第一层的2消除的（一般来说前两步就够了）\\t\\t\\t\\t\\t\\t\\n\\tif\\t有\\t\\t\\t\\t\\t\\n\\t\\t都（上限是3）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数\\t\\t\\t\\t\\t\\n\\t\\tif\\t当前层空格数第二层格子数）\\t\\n\\t第一层在所有格子范围内保持原比例交换，位置随机，第二层只在非空格子内交换\\t\\n\\tif\\t第一层有空格子，第二层有空格子\\t\\n\\t第一层在所有格子范围内保持原比例交换，位置随机，可以交换到空格里，但是保证第二层非空格子前有东西，第二层只在非空格格子里交换\\t\\t\\n\\t由于我们在刷新位置之前有选取整组物品往后放的操作，可能会导致某一层为空，刷新位置的时候要把尽量空格刷的均匀一点\\t\\n\\t\\n\\t\\n\\t2、选取单独物品交换的逻辑\\t\\t\\t\\n\\t如果是选一个或多个单独的物品进行交换\\t\\n\\t选在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员\\t\\n\\t如果没有满足上述条件的物品，选在第一层非特殊格子非锁链上的物品，且其至少有一个成员不在第一层，优先选没有和其其他成员放在一起（在一个格子里）的\\t\\n\\t\\t\\t\\t\\n\\t3、选取单独物品并把整组往后放的逻辑\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果我们要选出一个单独的物品并把整组往最后放\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果拿到了有成员在刷新器或者单格移动货柜上的物品种类，把其放在最后一个，后面的补位上来，其余的1/2个成员只需要选一个格子新增一层放进去\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t优先选取在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员，满足此条件的基础上，优先选取跨三层的物品，次之为跨两层格子的物品\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果选取的物品拿走后会导致第3层及以后的层有格子为空，就在同一层拿一个单独的物品（拿完不能使任何格子为空）放进去使其不为空，如果没有满足的，就随机挑一个吧，如果一个也没有就让后一层顶上来\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t随机挑选2个层数&gt;=2的格子（普通格子或者传送带格子）新增一层；并挑选一组物品按照的3：0：0：0：0：1比例放到该关卡最后新增的一层\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\t\\n\\t如果只有一个层数&gt', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:53:30', 74);
INSERT INTO `sys_oper_log` VALUES (166, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":3,\"caseTitle\":\"suffle\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"modelConfigId\":6,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-02-16 09:58:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 09:57:47', 335);
INSERT INTO `sys_oper_log` VALUES (167, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/3', '127.0.0.1', '内网IP', '3 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 09:58:01', 322);
INSERT INTO `sys_oper_log` VALUES (168, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/3', '127.0.0.1', '内网IP', '3 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:15:58', 341);
INSERT INTO `sys_oper_log` VALUES (169, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":3,\"caseTitle\":\"suffle\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"modelConfigId\":6,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-02-16 21:17:17\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:16:10', 165);
INSERT INTO `sys_oper_log` VALUES (170, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/3', '127.0.0.1', '内网IP', '3 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:16:14', 447);
INSERT INTO `sys_oper_log` VALUES (171, '测试用例', 3, 'com.dishtest.web.controller.tool.TestCaseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/3', '127.0.0.1', '内网IP', '[3] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:16:22', 155);
INSERT INTO `sys_oper_log` VALUES (172, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"caseTitle\":\"suffle\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:16:34', 997);
INSERT INTO `sys_oper_log` VALUES (173, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:16:38', 313);
INSERT INTO `sys_oper_log` VALUES (174, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:18:01', 345);
INSERT INTO `sys_oper_log` VALUES (175, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":4,\"caseTitle\":\"suffle\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"modelConfigId\":6,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-02-16 21:25:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:24:32', 336);
INSERT INTO `sys_oper_log` VALUES (176, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:24:40', 5172);
INSERT INTO `sys_oper_log` VALUES (177, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-1uWNRJZq3KwoZyJhktoovNCXBulL9w4BJOeOcnkZXmELchnc\",\"apiUrl\":\"https://api.penguinsaichat.dpdns.org/v1/messages\",\"createBy\":\"\",\"createTime\":\"2026-02-16 09:42:26\",\"isDefault\":\"1\",\"maxTokens\":32768,\"modelId\":6,\"modelName\":\"claude-opus-4-5-20251101\",\"modelType\":\"claude\",\"modelVersion\":\"claude-opus-4-5-20251101-thinking\",\"params\":{},\"status\":\"0\",\"temperature\":0.7,\"updateBy\":\"\",\"updateTime\":\"2026-02-16 21:26:52\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:25:45', 403);
INSERT INTO `sys_oper_log` VALUES (178, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-1uWNRJZq3KwoZyJhktoovNCXBulL9w4BJOeOcnkZXmELchnc\",\"apiUrl\":\"https://api.penguinsaichat.dpdns.org/v1/messages\",\"createBy\":\"\",\"createTime\":\"2026-02-16 09:42:26\",\"isDefault\":\"1\",\"maxTokens\":32768,\"modelId\":6,\"modelName\":\"claude-opus-4-5-20251101\",\"modelType\":\"claude\",\"modelVersion\":\"claude-opus-4-5-20251101\",\"params\":{},\"status\":\"0\",\"temperature\":0.7,\"updateBy\":\"\",\"updateTime\":\"2026-02-16 21:27:16\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:26:09', 289);
INSERT INTO `sys_oper_log` VALUES (179, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":4,\"caseTitle\":\"suffle\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"modelConfigId\":6,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-02-16 21:27:23\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:26:17', 371);
INSERT INTO `sys_oper_log` VALUES (180, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:26:26', 5947);
INSERT INTO `sys_oper_log` VALUES (181, '测试用例', 3, 'com.dishtest.web.controller.tool.TestCaseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/4', '127.0.0.1', '内网IP', '[4] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:26:52', 367);
INSERT INTO `sys_oper_log` VALUES (182, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"6\",\"caseTitle\":\"suff\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:27:05', 688);
INSERT INTO `sys_oper_log` VALUES (183, 'AI提示词配置', 2, 'com.dishtest.web.controller.tool.AiPromptConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/promptconfig', '127.0.0.1', '内网IP', '{\"configId\":1,\"configName\":\"默认测试用例生成提示词\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 08:50:02\",\"isDefault\":\"1\",\"params\":{},\"promptContent\":\"# 角色\\n你是一位资深游戏测试专家，拥有15年以上测试经验，精通黑盒测试、白盒测试、灰盒测试等多种测试方法。你擅长运用等价类划分、边界值分析、决策表、状态转换、正交试验、场景法、错误推测法等测试设计技术，能够设计出覆盖率达到98%以上的高质量测试用例。\\n\\n## 核心任务\\n基于用户提供的需求内容{{input_doc}}，运用系统化的测试设计方法，生成继续续写全面、精准、高覆盖率的测试用例，不要输出推理过程，直接给出结果。\\n\\n## 技能\\n### 技能1: 多维度需求分析\\n1. **功能性分析**: 识别核心功能、辅助功能、隐含功能\\n2. **非功能性分析**: 性能、安全、可用性、兼容性等要求\\n3. **约束条件分析**: 业务规则、技术限制、环境约束\\n4. **风险点识别**: 潜在缺陷区域、用户易错操作、系统薄弱环节\\n5. **依赖关系梳理**: 前置条件、后置条件、数据依赖\\n\\n### 技能2: 系统化测试用例设计\\n1. **多方法组合应用**:\\n   - 等价类划分：有效等价类 + 无效等价类\\n   - 边界值分析：上点、内点、离点（包括边界值±1）\\n   - 决策表：覆盖所有条件组合\\n   - 状态转换：覆盖所有状态路径\\n   - 正交试验：减少用例数量同时保证覆盖率\\n   - 场景法：正常场景 + 异常场景 + 边界场景\\n   - 错误推测：基于经验的异常情况\\n\\n   2. **全面覆盖策略**:\\n   - **输入覆盖**: 数据类型、长度、格式、编码、特殊字符\\n   - **操作覆盖**: 正常操作、异常操作、并发操作、重复操作\\n   - **环境覆盖**: 不同浏览器、操作系统、网络环境、设备类型\\n   - **状态覆盖**: 初始状态、中间状态、结束状态、异常状态\\n   - **时序覆盖**: 操作顺序、时间间隔、超时情况\\n\\n ### 技能3: 高覆盖率保障机制\\n1. **覆盖率检查清单**:\\n   - [ ] 正常路径覆盖率 ≥ 95%\\n   - [ ] 异常路径覆盖率 ≥ 90%\\n   - [ ] 边界条件覆盖率 = 100%\\n   - [ ] 业务规则覆盖率 = 100%\\n   - [ ] 用户场景覆盖率 ≥ 95%\\n\\n\\n### 技能 4: 规范整理输出\\n1. 将精心设计好的测试用例，按照严格规范的 XMind 兼容的 Markdown 层级格式进行整理，方便用户直接导入 XMind 文档，无需进行额外的格式调整。\\n2. 输出的 Markdown 层级格式结构需清晰明了，仅输出纯Markdown内容，具体格式如：\\n# [文档主标题]\\n## [功能模块名称]\\n### [功能测试点1]\\n#### [验证点1.1]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n#### [ 验证点1.2]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n\\n\\n   ## 用例设计方法示例\\n**原需求**: 昵称规则：1-20字符（支持中文/英文/数字），禁止特殊符号（除\\\"_\\\"和\\\"·\\\"）\\n\\n**测试用例设计思路**:\\n\\n### 1. 等价类划分\\n**有效等价类**:\\n- 长度: 1-20字符\\n- 字符类型: 中文、英文字母(大小写)、数字、下划线、间隔号\\n\\n**无效等价类**:\\n- 长度: 0字符、21+字符\\n- 字符类型: 其他特殊符号、表情符号、控制字符\\n\\n### 2. 边界值分析\\n- 长度边界: 0, 1, 2, 19, 20, 21字符\\n- 字符边界: ASCII边界、Unicode边界\\n\\n### 3. 组合测试\\n- 纯中文: 1字符、10字符、20字符\\n- 纯英文: 大写、小写、混合\\n- 纯数字: 单个、多个\\n- 混合字符: 中英文、中文数字、英文数字、全混合\\n- 包含允许符号: 单独使用、与其他字符组合\\n\\n### 4. 异常场景\\n- 空输入、空格、制表符\\n- SQL注入字符: \', \\\", ;, --, /*\\n- XSS字符: <, >, &, javascript:\\n- 特殊Unicode: 零宽字符、RTL字符\\n- ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 21:27:48', 255);
INSERT INTO `sys_oper_log` VALUES (184, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:29:31', 4161);
INSERT INTO `sys_oper_log` VALUES (185, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:29:52', 10917);
INSERT INTO `sys_oper_log` VALUES (186, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:35:20', 8050);
INSERT INTO `sys_oper_log` VALUES (187, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:40:00', 35142);
INSERT INTO `sys_oper_log` VALUES (188, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:43:30', 35590);
INSERT INTO `sys_oper_log` VALUES (189, '导出测试用例CSV', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportCsv()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportCsv/5', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-02-16 21:46:48', 91);
INSERT INTO `sys_oper_log` VALUES (190, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/5', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-02-16 21:51:17', 134);
INSERT INTO `sys_oper_log` VALUES (191, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 21:57:00', 43441);
INSERT INTO `sys_oper_log` VALUES (192, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"caseTitle\":\"suffle\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 22:35:08', 655);
INSERT INTO `sys_oper_log` VALUES (193, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/6', '127.0.0.1', '内网IP', '6 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 22:35:13', 503);
INSERT INTO `sys_oper_log` VALUES (194, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":6,\"caseTitle\":\"suffle\",\"fileName\":\"新建 文本文档 (2).txt\",\"modelConfigId\":6,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-02-16 22:36:31\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-16 22:35:24', 535);
INSERT INTO `sys_oper_log` VALUES (195, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/6', '127.0.0.1', '内网IP', '6 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 22:35:27', 534);
INSERT INTO `sys_oper_log` VALUES (196, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 22:35:39', 466);
INSERT INTO `sys_oper_log` VALUES (197, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 22:42:11', 66321);
INSERT INTO `sys_oper_log` VALUES (198, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/6', '127.0.0.1', '内网IP', '6 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-16 22:42:24', 71847);
INSERT INTO `sys_oper_log` VALUES (199, '测试用例', 3, 'com.dishtest.web.controller.tool.TestCaseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/6', '127.0.0.1', '内网IP', '[6] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-28 10:28:43', 197);
INSERT INTO `sys_oper_log` VALUES (200, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"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\",\"apiUrl\":\"https://api.openai.com/v1/chat/completions\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 09:30:53\",\"isDefault\":\"0\",\"maxTokens\":8192,\"modelId\":2,\"modelName\":\"OpenAI GPT-5.2\",\"modelType\":\"openai\",\"modelVersion\":\"gpt-5.2\",\"params\":{},\"remark\":\"需要配置API Key\",\"status\":\"0\",\"temperature\":0.7,\"updateTime\":\"2026-02-28 10:29:44\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-28 10:29:44', 297);
INSERT INTO `sys_oper_log` VALUES (201, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"2\",\"caseTitle\":\"测试\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-28 10:30:36', 540);
INSERT INTO `sys_oper_log` VALUES (202, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-28 10:30:45', 373);
INSERT INTO `sys_oper_log` VALUES (203, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-28 10:31:21', 467);
INSERT INTO `sys_oper_log` VALUES (204, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-28 10:36:07', 736);
INSERT INTO `sys_oper_log` VALUES (205, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":7,\"caseTitle\":\"测试\",\"fileName\":\"新建 文本文档 (2).txt\",\"modelConfigId\":2,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-02-28 10:36:31\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-02-28 10:36:31', 256);
INSERT INTO `sys_oper_log` VALUES (206, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-02-28 10:36:38', 410);
INSERT INTO `sys_oper_log` VALUES (207, 'MQTT连接', 0, 'com.dishtest.web.controller.mqtt.MqttConnectionController.connect()', 'POST', 1, 'admin', '研发部门', '/mqtt/connection/connect', '127.0.0.1', '内网IP', '{\"username\":\"test002\"} ', '{\"msg\":\"MQTT连接成功\",\"code\":200}', 0, NULL, '2026-02-28 22:00:51', 594);
INSERT INTO `sys_oper_log` VALUES (208, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"stop\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-02-28 22:01:39', 82);
INSERT INTO `sys_oper_log` VALUES (209, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"start\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-02-28 22:01:46', 305);
INSERT INTO `sys_oper_log` VALUES (210, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"pause\",\"deviceNames\":[\"测试设备001\"]} ', '{\"msg\":\"命令发送成功\",\"code\":200}', 0, NULL, '2026-02-28 22:01:49', 183);
INSERT INTO `sys_oper_log` VALUES (211, '设备控制', 0, 'com.dishtest.web.controller.mqtt.MqttDeviceController.sendCommand()', 'POST', 1, 'admin', '研发部门', '/mqtt/device/command', '127.0.0.1', '内网IP', '{\"action\":\"resume\",\"deviceNames\":[]} ', '{\"msg\":\"请选择设备\",\"code\":500}', 0, NULL, '2026-02-28 22:01:53', 0);
INSERT INTO `sys_oper_log` VALUES (212, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1072', '127.0.0.1', '内网IP', '1072 ', '{\"msg\":\"存在子菜单,不允许删除\",\"code\":601}', 0, NULL, '2026-03-09 22:08:54', 162);
INSERT INTO `sys_oper_log` VALUES (213, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1073', '127.0.0.1', '内网IP', '1073 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:08:58', 306);
INSERT INTO `sys_oper_log` VALUES (214, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1074', '127.0.0.1', '内网IP', '1074 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:09:01', 266);
INSERT INTO `sys_oper_log` VALUES (215, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1075', '127.0.0.1', '内网IP', '1075 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:09:04', 167);
INSERT INTO `sys_oper_log` VALUES (216, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1072', '127.0.0.1', '内网IP', '1072 ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:09:07', 138);
INSERT INTO `sys_oper_log` VALUES (217, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-03-09 22:09:13', 57);
INSERT INTO `sys_oper_log` VALUES (218, '菜单管理', 2, 'com.dishtest.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-01-19 17:20:21\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"DishTest官网\",\"menuType\":\"C\",\"orderNum\":4,\"params\":{},\"parentId\":1061,\"path\":\"http://dishtest.vip\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:09:23', 580);
INSERT INTO `sys_oper_log` VALUES (219, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-03-09 22:09:27', 45);
INSERT INTO `sys_oper_log` VALUES (220, '菜单管理', 2, 'com.dishtest.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-01-19 17:20:21\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"DishTest官网\",\"menuType\":\"F\",\"orderNum\":4,\"params\":{},\"parentId\":1061,\"path\":\"http://dishtest.vip\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:09:31', 303);
INSERT INTO `sys_oper_log` VALUES (221, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-03-09 22:09:35', 167);
INSERT INTO `sys_oper_log` VALUES (222, '菜单管理', 2, 'com.dishtest.web.controller.system.SysMenuController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createTime\":\"2026-01-19 17:20:21\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"DishTest官网\",\"menuType\":\"M\",\"orderNum\":4,\"params\":{},\"path\":\"http://dishtest.vip\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:10:06', 270);
INSERT INTO `sys_oper_log` VALUES (223, '菜单管理', 3, 'com.dishtest.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-03-09 22:10:11', 50);
INSERT INTO `sys_oper_log` VALUES (224, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 22:13:36', 3371);
INSERT INTO `sys_oper_log` VALUES (225, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"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\",\"apiUrl\":\"https://api.openai.com/v1/responses\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 09:30:53\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelId\":1,\"modelName\":\"gpt-5-nano\",\"modelType\":\"openai\",\"modelVersion\":\"gpt-5-nano\",\"params\":{},\"remark\":\"需要配置API Key\",\"status\":\"0\",\"temperature\":0.7,\"updateTime\":\"2026-03-09 22:24:25\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:24:21', 118);
INSERT INTO `sys_oper_log` VALUES (226, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-1uWNRJZq3KwoZyJhktoovNCXBulL9w4BJOeOcnkZXmELchnc\",\"apiUrl\":\"https://api.penguinsaichat.dpdns.org/v1/messages\",\"createBy\":\"\",\"createTime\":\"2026-02-16 09:42:26\",\"isDefault\":\"0\",\"maxTokens\":32768,\"modelId\":6,\"modelName\":\"claude-opus-4-5-20251101\",\"modelType\":\"claude\",\"modelVersion\":\"claude-opus-4-5-20251101\",\"params\":{},\"status\":\"1\",\"temperature\":0.7,\"updateBy\":\"\",\"updateTime\":\"2026-03-09 22:24:32\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:24:28', 86);
INSERT INTO `sys_oper_log` VALUES (227, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":7,\"caseTitle\":\"测试\",\"fileName\":\"新建 文本文档 (2).txt\",\"modelConfigId\":1,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-03-09 22:24:44\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:24:40', 270);
INSERT INTO `sys_oper_log` VALUES (228, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 22:24:48', 2010);
INSERT INTO `sys_oper_log` VALUES (229, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 22:29:42', 2244);
INSERT INTO `sys_oper_log` VALUES (230, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 22:31:15', 2208);
INSERT INTO `sys_oper_log` VALUES (231, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":7,\"caseTitle\":\"测试\",\"fileName\":\"新建 文本文档 (2).txt\",\"modelConfigId\":1,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-03-09 22:32:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 22:32:47', 127);
INSERT INTO `sys_oper_log` VALUES (232, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 22:32:52', 2177);
INSERT INTO `sys_oper_log` VALUES (233, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 22:34:34', 1925);
INSERT INTO `sys_oper_log` VALUES (234, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"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\",\"apiUrl\":\"https://api.openai.com/v1/responses\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 09:30:53\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelId\":1,\"modelName\":\"gpt-5-nano\",\"modelType\":\"openai\",\"modelVersion\":\"gpt-5-nano\",\"params\":{},\"remark\":\"需要配置API Key\",\"status\":\"1\",\"temperature\":0.7,\"updateTime\":\"2026-03-09 23:16:45\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 23:16:41', 227);
INSERT INTO `sys_oper_log` VALUES (235, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com\",\"isDefault\":\"0\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":false,\\\"message\\\":\\\"连接失败: 404 Not Found: [no body]\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:29:33', 301);
INSERT INTO `sys_oper_log` VALUES (236, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":false,\\\"message\\\":\\\"连接失败: 404 Not Found: [no body]\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:29:38', 232);
INSERT INTO `sys_oper_log` VALUES (237, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":false,\\\"message\\\":\\\"连接失败: 404 Not Found: [no body]\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:29:46', 101);
INSERT INTO `sys_oper_log` VALUES (238, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":false,\\\"message\\\":\\\"连接失败: 400 Bad Request: \\\"{\\\"error\\\":{\\\"message\\\":\\\"Failed to deserialize the JSON body into the target type: missing field `messages` at line 1 column 99\\\",\\\"type\\\":\\\"invalid_request_error\\\",\\\"param\\\":null,\\\"code\\\":\\\"inval...\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:30:20', 119);
INSERT INTO `sys_oper_log` VALUES (239, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":false,\\\"message\\\":\\\"连接失败: 400 Bad Request: \\\"{\\\"error\\\":{\\\"message\\\":\\\"Failed to deserialize the JSON body into the target type: missing field `messages` at line 1 column 99\\\",\\\"type\\\":\\\"invalid_request_error\\\",\\\"param\\\":null,\\\"code\\\":\\\"inval...\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:32:06', 118);
INSERT INTO `sys_oper_log` VALUES (240, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":false,\\\"message\\\":\\\"连接失败: 400 Bad Request: \\\"{\\\"error\\\":{\\\"message\\\":\\\"Failed to deserialize the JSON body into the target type: missing field `messages` at line 1 column 99\\\",\\\"type\\\":\\\"invalid_request_error\\\",\\\"param\\\":null,\\\"code\\\":\\\"inval...\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:32:38', 224);
INSERT INTO `sys_oper_log` VALUES (241, '测试模型连接', 0, 'com.dishtest.web.controller.aitest.AiModelConfigController.testConnection()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig/testConnection', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"{\\\"success\\\":true,\\\"message\\\":\\\"连接成功\\\",\\\"supportTemperature\\\":\\\"1\\\"}\",\"code\":200}', 0, NULL, '2026-03-09 23:34:14', 3737);
INSERT INTO `sys_oper_log` VALUES (242, 'AI模型配置', 1, 'com.dishtest.web.controller.aitest.AiModelConfigController.add()', 'POST', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"sk-b10c3d02968b4922a8eb7598d10c32fe\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"createTime\":\"2026-03-09 23:34:24\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelId\":7,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 23:34:20', 409);
INSERT INTO `sys_oper_log` VALUES (243, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '127.0.0.1', '内网IP', '{\"apiKey\":\"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\",\"apiUrl\":\"https://api.openai.com/v1/responses\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 09:30:53\",\"isDefault\":\"0\",\"maxTokens\":4096,\"modelId\":1,\"modelName\":\"gpt-5-nano\",\"modelType\":\"openai\",\"modelVersion\":\"gpt-5-nano\",\"params\":{},\"remark\":\"需要配置API Key\",\"status\":\"1\",\"supportTemperature\":\"1\",\"temperature\":0.7,\"updateTime\":\"2026-03-09 23:34:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 23:34:35', 100);
INSERT INTO `sys_oper_log` VALUES (244, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":7,\"caseTitle\":\"测试\",\"fileName\":\"新建 文本文档 (2).txt\",\"modelConfigId\":7,\"params\":{},\"updateTime\":\"2026-03-09 23:34:48\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 23:34:44', 253);
INSERT INTO `sys_oper_log` VALUES (245, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 23:36:40', 776);
INSERT INTO `sys_oper_log` VALUES (246, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 23:36:52', 121101);
INSERT INTO `sys_oper_log` VALUES (247, '测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.edit()', 'PUT', 1, 'admin', '研发部门', '/tool/testcase', '127.0.0.1', '内网IP', '{\"caseId\":5,\"caseTitle\":\"suff\",\"fileName\":\"55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx\",\"modelConfigId\":7,\"params\":{},\"promptConfigId\":1,\"updateTime\":\"2026-03-09 23:37:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-09 23:36:58', 162);
INSERT INTO `sys_oper_log` VALUES (248, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/5', '127.0.0.1', '内网IP', '5 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 23:46:09', 146911);
INSERT INTO `sys_oper_log` VALUES (249, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/7', '127.0.0.1', '内网IP', '7 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-09 23:48:22', 142077);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int(4) NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2026-01-19 17:20:21', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2026-01-19 17:20:21', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int(4) NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-01-19 17:20:21', '', NULL, '普通角色');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 117);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint(20) NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '黄花菜', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-03-09 23:10:21', '2026-01-19 17:20:21', 'admin', '2026-01-19 17:20:21', '', NULL, '管理员');
INSERT INTO `sys_user` VALUES (2, 105, 'ry', '黄花菜', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-01-19 17:20:21', '2026-01-19 17:20:21', 'admin', '2026-01-19 17:20:21', '', NULL, '测试员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);
INSERT INTO `sys_user_post` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `role_id` bigint(20) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);

-- ----------------------------
-- Table structure for test_case
-- ----------------------------
DROP TABLE IF EXISTS `test_case`;
CREATE TABLE `test_case`  (
  `case_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '测试用例ID',
  `case_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用例标题',
  `input_doc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '输入文档内容',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文档文件名',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文档文件路径',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文档文件类型',
  `case_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '生成的测试用例内容(Markdown格式)',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '生成状态（0待生成 1生成中 2已完成 3失败）',
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'coze' COMMENT 'AI模型类型',
  `prompt_config_id` bigint(20) NULL DEFAULT NULL COMMENT '提示词配置ID',
  `model_config_id` bigint(20) NULL DEFAULT NULL COMMENT '模型配置ID',
  `generate_time` int(11) NULL DEFAULT NULL COMMENT '生成耗时(秒)',
  `error_msg` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '错误信息',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`case_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '测试用例表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of test_case
-- ----------------------------
INSERT INTO `test_case` VALUES (5, 'suff', 'Sheet: 新方案\n\n风扇（刷新）		\n核心思想：凑组/去单/保空格		\n每一次刷新第一层都要新增一组能消除的物品，同时为了保证空格数量，减少单独的物品，并成组的往最后放	\n		\n	\n	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)并且空格数>=3	\n	只刷新位置，结束	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)但是0<=空格数q<3		\n	挑选一个或两个或一对单独的物品，把整组扔到最后新建的一层，直到q=3					\nif			0<=当前第一层可消除组数<5	\n	把第一层非特殊货柜2的货品拿出来（如果没有选中成2的商品，就把单格货柜/刷新器加入一起选出成2的商品）	\n	看第二层有没有1能与之消除的	\n	if	有	\n		都（上限是2）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数	\n	if	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	把第一层的1拿出来，看第二层有没有2可与之消除	\nif	有	\n	都（上限是2）拿到第一层来，并与某几对或者几个单独的物品进行交换，检查当前空格数	\nif	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	看第3层有没有能与第一层的2消除的（一般来说前两步就够了）						\n	if	有					\n		都（上限是3）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数					\n		if	当前层空格数<3				\n				取一组或两组物品放到最后新建一层去				\n			刷新位置					\n		else	把第一层的1拿出来，看第三层有没有2可与之消除。。。。。（以此循环直到至少找到一组）					\n			。。。					\n	\n	\n注释：	1、刷新位置的逻辑	\n	只刷新可见范围内的非特殊格子		\n			\n	if	第一第二层都没有空格子	\n	刷新位置的时候保持原比例不变的情况下（只需要比例不变，不需要原组合不变），位置随机，第一二层刷新独立，没有连带关系	\n	if	第一层没空格子，第二层有空格子（第一层格子数>第二层格子数）	\n	第一层在所有格子范围内保持原比例交换，位置随机，第二层只在非空格子内交换	\n	if	第一层有空格子，第二层有空格子	\n	第一层在所有格子范围内保持原比例交换，位置随机，可以交换到空格里，但是保证第二层非空格子前有东西，第二层只在非空格格子里交换		\n	由于我们在刷新位置之前有选取整组物品往后放的操作，可能会导致某一层为空，刷新位置的时候要把尽量空格刷的均匀一点	\n	\n	\n	2、选取单独物品交换的逻辑			\n	如果是选一个或多个单独的物品进行交换	\n	选在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员	\n	如果没有满足上述条件的物品，选在第一层非特殊格子非锁链上的物品，且其至少有一个成员不在第一层，优先选没有和其其他成员放在一起（在一个格子里）的	\n				\n	3、选取单独物品并把整组往后放的逻辑														\n	如果我们要选出一个单独的物品并把整组往最后放												\n	如果拿到了有成员在刷新器或者单格移动货柜上的物品种类，把其放在最后一个，后面的补位上来，其余的1/2个成员只需要选一个格子新增一层放进去									\n	优先选取在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员，满足此条件的基础上，优先选取跨三层的物品，次之为跨两层格子的物品												\n	如果选取的物品拿走后会导致第3层及以后的层有格子为空，就在同一层拿一个单独的物品（拿完不能使任何格子为空）放进去使其不为空，如果没有满足的，就随机挑一个吧，如果一个也没有就让后一层顶上来												\n	随机挑选2个层数>=2的格子（普通格子或者传送带格子）新增一层；并挑选一组物品按照的3：0：0：0：0：1比例放到该关卡最后新增的一层												\n	如果只有一个层数>=2的格子，在这个格子新增两层												\n	如果所有格子都只有一层，随机挑选两个格子新增一层												\n	如果需要腾出一个空格，按照以下优先级	\n	1、	拿1个单独且空格分为1的商品	\n	2、	拿一组空格分为1的商品	\n	3、	拿一组空格分为2的商品	\n	4、	拿一组空格分为3的商品	\n	5、	随机挑选一个放最后，使得满足能腾出一个空格	\n	\n	如果需要腾出两个空格，按照以下优先级	\n	1、	拿一对空格分为2的商品	\n	2、	拿一组空格分为2的商品	\n	3、	拿一组空格分为3的商品	\n	4、	一组空格分为1的商品+1随机（多1空格）	\n	5、	2随机（多2空格）	\n	\n	如果需要腾出3个空格，按照以下优先级	\n	1、	拿一组空格个分为3的商品	\n	2、	拿一组空格分为2的商品+1组空格分为1的商品	\n	3、	拿一组空格分为2的商品+1随机（多1空格）	\n	4、	拿3组空格分为1的商品	\n	5、	拿1组空格分为1的商品+2随机（多2空格）	\n	6、	3随机（多3空格）	\n		\n		\n		\n对于掉落关卡			\n	掉落关卡用原来的逻辑		\n			\n			\n			\n			\n			 	\n	\n特殊情况：	1、假如最大层数为1，只能刷新位置，不做交换和往后拿的操作				\n	2、对于盲盒，刷新不改变盲盒属性			\n	3、假如第一层只有金色收集物，刷新一二层的位置			\n	4、假如只剩下金色收集物，不消耗不使用道具			\n	5、加一个检测，如果每次从后往前拿，拿完之后发现空格数足够多（空格数>6）或者第一层没有可往后拿的物品了（都是成3的）就不进行交换操作	\n		\n		\n			\n	\n	\n	\n	\n		\n			\n	\n		\n		\n		\n		\n		\n		\n\n			\n		\n			\n			\n				\n					\n	\n	\n			\n		\n	\n			\n	\n	\n		\n			\n	\n	\n			\n	\n	\n		\n	\n\n', '55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx', '/profile/upload/2026/02/16/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260216212812A001.xlsx', 'xlsx', '# 风扇（刷新）新方案测试用例\n## 功能测试：核心刷新逻辑\n### 条件判断与分支流程\n#### 第一层可消除组数>=5（或全相同/剩余物品<3）且空格数>=3\n##### 场景描述：第一层有5组可消除物品，且当前有3个空格\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n##### 场景描述：第一层所有物品相同（视为可消除组数极大），且空格数大于3\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n##### 场景描述：第一层除去可消除物品后，剩余物品数小于3，且空格数等于3\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n#### 第一层可消除组数>=5（或全相同/剩余物品<3）但空格数0<=q<3\n##### 场景描述：第一层有6组可消除物品，但空格数为0\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n##### 场景描述：第一层所有物品相同，但空格数为2\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n##### 场景描述：第一层除去可消除物品后剩余物品数为2，但空格数为1\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n#### 第一层可消除组数0<=组数<5\n##### 场景描述：第一层有3组可消除物品，且存在非特殊货柜2的货品\n###### 预期结果：取出第一层非特殊货柜2的货品，检查第二层是否有1个可与之消除的物品。\n##### 场景描述：第一层有1组可消除物品，且无非特殊货柜2的货品，但有单格货柜/刷新器\n###### 预期结果：将单格货柜/刷新器加入，一起选出成2的商品，检查第二层是否有1个可与之消除的物品。\n##### 场景描述：第一层有0组可消除物品\n###### 预期结果：取出第一层非特殊货柜2的货品（或无则加入单格货柜/刷新器），检查第二层是否有1个可与之消除的物品。\n### 物品交换与消除匹配\n#### 第二层有匹配物品（上限2）可消除\n##### 场景描述：从第一层拿出非特殊货柜2的货品（成2），第二层有1个匹配物品\n###### 预期结果：将第二层的匹配物品（最多2个）拿到第一层，与第一层的某几个单独物品进行交换，然后检查当前层空格数。\n##### 场景描述：从第一层拿出非特殊货柜2的货品（成2），第二层有2个匹配物品\n###### 预期结果：将第二层的2个匹配物品拿到第一层，与第一层的某几个单独物品进行交换，然后检查当前层空格数。\n##### 场景描述：从第一层拿出1个物品（成1），第二层有2个匹配物品（成2）\n###### 预期结果：将第二层的匹配物品（最多2个）拿到第一层，与第一层的某几对或几个单独物品进行交换，然后检查当前层空格数。\n#### 第二层无匹配物品，检查第三层\n##### 场景描述：第一层拿出成2的物品，第二层无匹配，第三层有匹配物品（上限3）\n###### 预期结果：将第三层的匹配物品（最多3个）拿到第一层，与第一层的某几个单独物品进行交换，然后检查当前层空格数。\n##### 场景描述：第一层拿出成1的物品，第二层无匹配成2的物品，第三层有成2的匹配物品\n###### 预期结果：将第三层的匹配物品拿到第一层，进行交换，检查空格数，以此循环直到至少找到一组可消除组合。\n### 空格数检查与向后放置\n#### 交换后当前层空格数<3\n##### 场景描述：完成物品交换后，第一层空格数为2\n###### 预期结果：取一组或两组物品放到最后新建的一层去，直到空格数>=3，然后执行“刷新位置”。\n##### 场景描述：完成物品交换后，第一层空格数为0\n###### 预期结果：取一组或两组物品放到最后新建的一层去，直到空格数>=3，然后执行“刷新位置”。\n#### 交换后当前层空格数>=3\n##### 场景描述：完成物品交换后，第一层空格数恰好为3\n###### 预期结果：直接执行“刷新位置”逻辑。\n##### 场景描述：完成物品交换后，第一层空格数大于3（如4或5）\n###### 预期结果：直接执行“刷新位置”逻辑。\n## 功能测试：刷新位置逻辑\n### 第一第二层均无空格\n##### 场景描述：第一层和第二层所有格子均被物品填满，无空格。\n###### 预期结果：在第一、二层各自“所有格子范围内”保持原物品类型比例不变，位置随机刷新。两层刷新独立，无连带关系。\n### 第一层无空格，第二层有空格\n##### 场景描述：第一层格子全满，第二层存在空格子，且第一层格子数大于第二层格子数。\n###### 预期结果：第一层在所有格子范围内保持原比例随机交换位置。第二层仅在非空格子内进行物品位置交换。\n### 第一层有空格，第二层有空格\n##### 场景描述：第一层和第二层均存在空格子。\n###### 预期结果：第一层在所有格子（包括空格）范围内保持原比例随机交换，可交换至空格，但需保证第二层非空格子前有东西（即不因刷新导致第二层非空格子前出现连续空格？需明确）。第二层仅在非空格子内交换。\n### 某层为空时的刷新\n##### 场景描述：因向后放置物品操作，导致第一层或第二层完全为空。\n###### 预期结果：刷新位置时，需尽量将空格子刷得均匀一点（具体规则需明确，如避免空格过度集中）。\n## 功能测试：选取单独物品交换的逻辑\n### 选取条件优先级1\n##### 场景描述：第一层存在非特殊格子、非锁链上的物品A，且在第一层（包括锁链和特殊格子）范围内没有A的其他成员。\n###### 预期结果：该物品A符合被选中进行交换的条件。\n### 选取条件优先级2\n##### 场景描述：第一层不存在满足优先级1的物品。存在非特殊格子、非锁链上的物品B，且B至少有一个成员不在第一层。\n###### 预期结果：物品B符合被选中条件。若多个物品符合，优先选择没有和其他成员放在同一个格子里的物品B。\n## 功能测试：选取物品整组向后放的逻辑\n### 选取目标物品的优先级\n##### 场景描述：需要选取一个单独物品并将其整组向后放。第一层存在非特殊格子、非锁链上的物品C，且在第一层（包括锁链和特殊格子）内无其他成员。\n###### 预期结果：优先选取物品C。若多个C，优先选取跨三层的物品，其次跨两层的物品。\n### 处理成员在特殊货柜的情况\n##### 场景描述：被选中的物品种类，其有成员位于刷新器或单格移动货柜上。\n###### 预期结果：将该种类物品放在最后（新建层的最后位置？），后面的种类补位上来。该种类的其余1/2个成员只需选一个格子新增一层放入。\n### 向后放置导致后续层出现空格的处理\n##### 场景描述：拿走选中物品后，会导致第3层或更后的某一层出现空格子。\n###### 预期结果：在同一层拿一个单独的物品（且拿走后不会使任何格子变空）放入该层以避免空格。若无满足条件的物品，则随机挑一个放入。若一个也没有，则让后一层顶上来。\n### 新建层的规则\n##### 场景描述：需要新建层来放置整组物品。存在两个层数>=2的格子（普通格或传送带格）。\n###### 预期结果：随机挑选这两个格子，各新增一层。将一组物品按3:0:0:0:0:1的比例放到关卡最后新增的一层。\n##### 场景描述：需要新建层，但只有一个层数>=2的格子。\n###### 预期结果：在该格子新增两层。\n##### 场景描述：需要新建层，但所有格子都只有一层。\n###### 预期结果：随机挑选两个格子，各新增一层。\n## 功能测试：腾出空格优先级逻辑\n### 需要腾出1个空格\n##### 场景描述：当前空格不足，需要腾出1个空格。\n###### 预期结果：按优先级执行：1.拿1个单独且空格分为1的商品 -> 2.拿一组空格分为1的商品 -> 3.拿一组空格分为2的商品 -> 4.拿一组空格分为3的商品 -> 5.随机挑一个放最后，使得满足能腾出一个空格。\n### 需要腾出2个空格\n##### 场景描述：当前空格不足，需要腾出2个空格。\n###### 预期结果：按优先级执行：1.拿一对空格分为2的商品 -> 2.拿一组空格分为2的商品 -> 3.拿一组空格分为3的商品 -> 4.一组空格分为1的商品+1随机（多1空格）-> 5.2随机（多2空格）。\n### 需要腾出3个空格\n##### 场景描述：当前空格不足，需要腾出3个空格。\n###### 预期结果：按优先级执行：1.拿一组空格分为3的商品 -> 2.拿一组空格分为2的商品+1组空格分为1的商品 -> 3.拿一组空格分为2的商品+1随机（多1空格）-> 4.拿3组空格分为1的商品 -> 5.拿1组空格分为1的商品+2随机（多2空格）-> 6.3随机（多3空格）。\n## 功能测试：特殊情况处理\n### 最大层数为1\n##### 场景描述：关卡设置的最大层数为1。\n###### 预期结果：只能执行“刷新位置”操作，不进行任何物品交换或向后拿的操作。\n### 盲盒物品\n##### 场景描述：场上存在盲盒物品。\n###### 预期结果：刷新操作不改变盲盒的属性（如内容物）。\n### 第一层只有金色收集物\n##### 场景描述：第一层所有物品均为金色收集物。\n###### 预期结果：仅刷新第一层和第二层的位置。\n### 只剩下金色收集物\n##### 场景描述：场上所有可操作物品只剩下金色收集物。\n###### 预期结果：不消耗也不使用道具（刷新道具？），可能不执行刷新或仅执行无害的位置变换？需求需明确。\n### 检测机制：空格数过多或无物品可拿\n##### 场景描述：执行向后拿物品操作后，检测到第一层空格数>6。\n###### 预期结果：不再进行后续的交换操作。\n##### 场景描述：执行向后拿物品操作后，检测到第一层没有可往后拿的物品了（所有物品都是成3的组）。\n###### 预期结果：不再进行后续的交换操作。\n## 非功能测试：掉落关卡\n### 沿用旧逻辑\n##### 场景描述：当前关卡为掉落关卡。\n###### 预期结果：刷新功能使用原来的逻辑，不应用此新方案。\n## 边界与异常测试\n### 边界值：可消除组数\n##### 场景描述：第一层可消除组数 = 4（边界值，小于5）。\n###### 预期结果：进入“0<=当前第一层可消除组数<5”的分支流程。\n##### 场景描述：第一层可消除组数 = 5（边界值，等于5）且空格数=2。\n###### 预期结果：进入“当前第一层可消除组数>=5...但是0<=空格数q<3”的分支流程。\n### 边界值：空格数\n##### 场景描述：空格数 = 0。\n###### 预期结果：在相应分支下，触发腾出空格逻辑。\n##### 场景描述：空格数 = 3。\n###### 预期结果：在“空格数>=3”分支下，仅刷新位置。\n##### 场景描述：空格数 = 2（边界值，小于3）。\n###### 预期结果：在相应分支下，触发腾出空格至3的逻辑。\n### 边界值：物品数量\n##### 场景描述：第一层物品总数刚好等于可消除物品数，剩余物品数=0（<3）。\n###### 预期结果：符合“除去可消除物品后剩余物品数<3”条件，进入相应分支。\n##### 场景描述：第一层物品总数-可消除物品数 = 2（剩余物品数边界值）。\n###### 预期结果：符合“除去可消除物品后剩余物品数<3”条件，进入相应分支。\n### 异常场景：无满足条件的物品可选取\n##### 场景描述：在需要选取单独物品进行交换时，第一层不存在任何满足优先级1和优先级2条件的物品。\n###### 预期结果：逻辑应明确处理方式（如随机选取或跳过？），需补充规则。\n##### 场景描述：在需要腾出空格时，优先级列表中的所有条件都无法满足（如没有对应空格分的商品）。\n###### 预期结果：应能执行最后一级的“随机”策略。\n### 并发与重复操作\n##### 场景描述：在刷新动画执行过程中，快速连续点击刷新按钮。\n###### 预期结果：应正确处理，避免状态错乱或物品重复计算。可考虑禁用按钮或排队处理。\n##### 场景描述：网络延迟时执行刷新操作。\n###### 预期结果：应有加载状态提示，数据同步正确，避免本地与服务器状态不一致。\n### 性能测试\n##### 场景描述：场上物品数量极多，层数很深时执行刷新。\n###### 预期结果：刷新算法执行时间应在可接受范围内（如<2秒），不引起界面卡顿或ANR。\n##### 场景描述：连续多次执行刷新操作。\n###### 预期结果：内存占用平稳，无内存泄漏。', '2', 'deepseek-chat', 1, 7, 146, '未找到模型类型 [coze] 的默认配置，请先在模型配置中添加并设置为默认', '', '2026-02-16 21:28:13', '', '2026-03-09 23:37:02', NULL);
INSERT INTO `test_case` VALUES (7, '测试', 'Sheet: 新方案\n\n风扇（刷新）		\n核心思想：凑组/去单/保空格		\n每一次刷新第一层都要新增一组能消除的物品，同时为了保证空格数量，减少单独的物品，并成组的往最后放	\n		\n	\n	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)并且空格数>=3	\n	只刷新位置，结束	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)但是0<=空格数q<3		\n	挑选一个或两个或一对单独的物品，把整组扔到最后新建的一层，直到q=3					\nif			0<=当前第一层可消除组数<5	\n	把第一层非特殊货柜2的货品拿出来（如果没有选中成2的商品，就把单格货柜/刷新器加入一起选出成2的商品）	\n	看第二层有没有1能与之消除的	\n	if	有	\n		都（上限是2）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数	\n	if	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	把第一层的1拿出来，看第二层有没有2可与之消除	\nif	有	\n	都（上限是2）拿到第一层来，并与某几对或者几个单独的物品进行交换，检查当前空格数	\nif	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	看第3层有没有能与第一层的2消除的（一般来说前两步就够了）						\n	if	有					\n		都（上限是3）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数					\n		if	当前层空格数<3				\n				取一组或两组物品放到最后新建一层去				\n			刷新位置					\n		else	把第一层的1拿出来，看第三层有没有2可与之消除。。。。。（以此循环直到至少找到一组）					\n			。。。					\n	\n	\n注释：	1、刷新位置的逻辑	\n	只刷新可见范围内的非特殊格子		\n			\n	if	第一第二层都没有空格子	\n	刷新位置的时候保持原比例不变的情况下（只需要比例不变，不需要原组合不变），位置随机，第一二层刷新独立，没有连带关系	\n	if	第一层没空格子，第二层有空格子（第一层格子数>第二层格子数）	\n	第一层在所有格子范围内保持原比例交换，位置随机，第二层只在非空格子内交换	\n	if	第一层有空格子，第二层有空格子	\n	第一层在所有格子范围内保持原比例交换，位置随机，可以交换到空格里，但是保证第二层非空格子前有东西，第二层只在非空格格子里交换		\n	由于我们在刷新位置之前有选取整组物品往后放的操作，可能会导致某一层为空，刷新位置的时候要把尽量空格刷的均匀一点	\n	\n	\n	2、选取单独物品交换的逻辑			\n	如果是选一个或多个单独的物品进行交换	\n	选在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员	\n	如果没有满足上述条件的物品，选在第一层非特殊格子非锁链上的物品，且其至少有一个成员不在第一层，优先选没有和其其他成员放在一起（在一个格子里）的	\n				\n	3、选取单独物品并把整组往后放的逻辑														\n	如果我们要选出一个单独的物品并把整组往最后放												\n	如果拿到了有成员在刷新器或者单格移动货柜上的物品种类，把其放在最后一个，后面的补位上来，其余的1/2个成员只需要选一个格子新增一层放进去									\n	优先选取在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员，满足此条件的基础上，优先选取跨三层的物品，次之为跨两层格子的物品												\n	如果选取的物品拿走后会导致第3层及以后的层有格子为空，就在同一层拿一个单独的物品（拿完不能使任何格子为空）放进去使其不为空，如果没有满足的，就随机挑一个吧，如果一个也没有就让后一层顶上来												\n	随机挑选2个层数>=2的格子（普通格子或者传送带格子）新增一层；并挑选一组物品按照的3：0：0：0：0：1比例放到该关卡最后新增的一层												\n	如果只有一个层数>=2的格子，在这个格子新增两层												\n	如果所有格子都只有一层，随机挑选两个格子新增一层												\n	如果需要腾出一个空格，按照以下优先级	\n	1、	拿1个单独且空格分为1的商品	\n	2、	拿一组空格分为1的商品	\n	3、	拿一组空格分为2的商品	\n	4、	拿一组空格分为3的商品	\n	5、	随机挑选一个放最后，使得满足能腾出一个空格	\n	\n	如果需要腾出两个空格，按照以下优先级	\n	1、	拿一对空格分为2的商品	\n	2、	拿一组空格分为2的商品	\n	3、	拿一组空格分为3的商品	\n	4、	一组空格分为1的商品+1随机（多1空格）	\n	5、	2随机（多2空格）	\n	\n	如果需要腾出3个空格，按照以下优先级	\n	1、	拿一组空格个分为3的商品	\n	2、	拿一组空格分为2的商品+1组空格分为1的商品	\n	3、	拿一组空格分为2的商品+1随机（多1空格）	\n	4、	拿3组空格分为1的商品	\n	5、	拿1组空格分为1的商品+2随机（多2空格）	\n	6、	3随机（多3空格）	\n		\n		\n		\n对于掉落关卡			\n	掉落关卡用原来的逻辑		\n			\n			\n			\n			\n			 	\n	\n特殊情况：	1、假如最大层数为1，只能刷新位置，不做交换和往后拿的操作				\n	2、对于盲盒，刷新不改变盲盒属性			\n	3、假如第一层只有金色收集物，刷新一二层的位置			\n	4、假如只剩下金色收集物，不消耗不使用道具			\n	5、加一个检测，如果每次从后往前拿，拿完之后发现空格数足够多（空格数>6）或者第一层没有可往后拿的物品了（都是成3的）就不进行交换操作	\n', '新建 文本文档 (2).txt', '/profile/upload/2026/02/28/新建 文本文档 (2)_20260228103035A001.txt', 'txt', '# 风扇（刷新）新方案测试用例\n## 核心流程测试\n### 可消除组数>=5且空格数>=3\n#### 场景1：第一层可消除组数=5，空格数=3\n##### 场景描述：第一层物品分布满足可消除组数>=5，且当前空格数为3。\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n#### 场景2：第一层全部为相同物品，空格数=5\n##### 场景描述：第一层所有格子均为同一种物品，空格数为5。\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n#### 场景3：除去可消除物品后剩余物品数=2，空格数=4\n##### 场景描述：移除第一层所有可消除的物品组合后，剩余不可消除的单个物品数量为2，空格数为4。\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n### 可消除组数>=5但空格数不足\n#### 场景1：可消除组数=5，空格数=0\n##### 场景描述：第一层可消除组数满足条件，但空格数为0。\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n#### 场景2：可消除组数=6，空格数=2\n##### 场景描述：第一层可消除组数为6，空格数为2。\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n#### 场景3：可消除组数>=5，空格数=1\n##### 场景描述：第一层可消除组数大于5，空格数为1。\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n### 可消除组数<5\n#### 场景1：可消除组数=0，从第二层找到可消除的“1”\n##### 场景描述：第一层可消除组数为0。从第一层非特殊货柜2中拿出物品（若无成2商品，则加入单格货柜/刷新器一起选），在第二层找到可与之消除的“1”。\n###### 预期结果：将第二层的“1”（上限2个）拿到第一层，与第一层的单独物品交换。检查空格数，若<3，则向后移动物品组直到空格数>=3，最后刷新位置。\n#### 场景2：可消除组数=2，从第二层找到可消除的“1”\n##### 场景描述：第一层可消除组数为2。从第一层拿出“1”，在第二层找到可与之消除的“2”。\n###### 预期结果：将第二层的“2”（上限2个）拿到第一层，与第一层的成对或单独物品交换。检查空格数，若<3，则向后移动物品组直到空格数>=3，最后刷新位置。\n#### 场景3：可消除组数=4，需从第三层查找可消除组合\n##### 场景描述：第一层可消除组数为4，在第一、二层均未找到可消除组合，需在第三层查找能与第一层“2”消除的物品。\n###### 预期结果：将第三层的物品（上限3个）拿到第一层交换。检查空格数，若<3，则向后移动物品组直到空格数>=3，最后刷新位置。\n#### 场景4：可消除组数=3，循环查找直到找到一组\n##### 场景描述：第一层可消除组数为3，按照逻辑依次在第一、二、三层...查找，直到至少找到一组可消除组合。\n###### 预期结果：成功找到一组可消除组合，执行相应的交换、空格检查和向后移动操作，最后刷新位置。\n## 刷新位置逻辑测试\n### 第一第二层均无空格\n#### 场景1：两层格子全满，独立随机刷新\n##### 场景描述：第一层和第二层所有格子均有物品，无空格。\n###### 预期结果：第一层和第二层独立刷新位置，保持各自层内原有物品比例不变，位置随机。两层间无连带关系。\n### 第一层无空格，第二层有空格\n#### 场景1：第一层格子数>第二层格子数\n##### 场景描述：第一层所有格子有物品，第二层存在空格子，且第一层格子数量大于第二层。\n###### 预期结果：第一层在所有格子范围内保持原比例随机交换位置。第二层仅在非空格子内进行物品交换。\n### 第一层有空格，第二层有空格\n#### 场景1：两层均有空格，保证第二层非空格前有物品\n##### 场景描述：第一层和第二层均存在空格子。\n###### 预期结果：第一层在所有格子（包括空格）范围内保持原比例随机交换。第二层仅在非空格子内交换，且需保证第二层非空格子前有物品（即空格不能出现在所有非空格子之前？需澄清逻辑）。\n### 某层为空时的刷新\n#### 场景1：因向后放操作导致第二层为空\n##### 场景描述：在“选取整组物品往后放”操作后，第二层变为空层。\n###### 预期结果：刷新位置时，需尽量将空格刷得均匀分布。\n## 选取单独物品交换逻辑测试\n### 优先级1：完全独立的物品\n#### 场景1：存在在第一层非特殊、非锁链上，且同层无其他成员的物品\n##### 场景描述：第一层存在一个物品，其所在格子非特殊格、非锁链格，且在第一层（包括锁链和特殊格）范围内没有该物品的其他成员。\n###### 预期结果：成功选中该物品用于交换。\n### 优先级2：成员不全在第一层的物品\n#### 场景1：无优先级1物品，存在成员在其它层的物品\n##### 场景描述：没有满足优先级1的物品。存在一个在第一层非特殊、非锁链上的物品，其至少有一个成员不在第一层。\n###### 预期结果：优先选中那些“没有和其其他成员放在一起（在一个格子里）”的物品用于交换。\n## 选取物品整组往后放逻辑测试\n### 处理刷新器或单格移动货柜上的成员\n#### 场景1：选中物品的成员在刷新器上\n##### 场景描述：选中的“单独物品”，其有成员位于刷新器上。\n###### 预期结果：将该物品种类整体放在最后，后面的物品补位。其余的1/2个成员只需选一个格子新增一层放入。\n### 选取物品的优先级\n#### 场景1：存在跨三层的完全独立物品\n##### 场景描述：存在满足“在第一层非特殊非锁链上，且同层无其他成员”的物品A，且物品A的成员分布在三层中。\n###### 预期结果：优先选取物品A。\n#### 场景2：存在跨两层的完全独立物品\n##### 场景描述：存在满足“在第一层非特殊非锁链上，且同层无其他成员”的物品B，且物品B的成员分布在两层中。\n###### 预期结果：次优先选取物品B。\n### 填补拿走后产生的空层\n#### 场景1：拿走物品导致第三层出现空格\n##### 场景描述：选取并拿走第一层一个物品后，导致第三层某个格子变为空。\n###### 预期结果：在同一层（第三层）寻找一个单独的物品（拿走不会导致任何格子为空）放入该空格。若无，则随机挑选一个物品放入。若一个也没有，则让后一层顶上来。\n### 新增层与放置物品\n#### 场景1：存在两个层数>=2的格子\n##### 场景描述：存在两个普通格或传送带格，其层数大于等于2。\n###### 预期结果：随机挑选这两个格子，各新增一层。挑选一组物品按3:0:0:0:0:1的比例放到关卡最后新增的一层。\n#### 场景2：只有一个层数>=2的格子\n##### 场景描述：只有一个格子的层数大于等于2。\n###### 预期结果：在该格子新增两层。\n#### 场景3：所有格子都只有一层\n##### 场景描述：所有格子当前都只有一层物品。\n###### 预期结果：随机挑选两个格子，各新增一层。\n### 腾出空格优先级逻辑\n#### 场景1：需要腾出1个空格\n##### 场景描述：当前需要腾出1个空格。\n###### 预期结果：按优先级尝试：1)拿1个单独且空格分为1的商品 -> 2)拿一组空格分为1的商品 -> 3)拿一组空格分为2的商品 -> 4)拿一组空格分为3的商品 -> 5)随机挑选一个放最后。\n#### 场景2：需要腾出2个空格\n##### 场景描述：当前需要腾出2个空格。\n###### 预期结果：按优先级尝试：1)拿一对空格分为2的商品 -> 2)拿一组空格分为2的商品 -> 3)拿一组空格分为3的商品 -> 4)一组空格分为1的商品+1随机 -> 5)2随机。\n#### 场景3：需要腾出3个空格\n##### 场景描述：当前需要腾出3个空格。\n###### 预期结果：按优先级尝试：1)拿一组空格分为3的商品 -> 2)拿一组空格分为2的商品+1组空格分为1的商品 -> 3)拿一组空格分为2的商品+1随机 -> 4)拿3组空格分为1的商品 -> 5)拿1组空格分为1的商品+2随机 -> 6)3随机。\n## 特殊情况测试\n### 最大层数为1\n#### 场景1：关卡最大层数限制为1\n##### 场景描述：当前关卡设置的最大层数为1。\n###### 预期结果：只能执行“刷新位置”操作，不进行任何物品交换或向后拿的操作。\n### 盲盒处理\n#### 场景1：刷新操作涉及盲盒格子\n##### 场景描述：第一层或第二层中存在盲盒格子。\n###### 预期结果：执行刷新位置操作后，盲盒的“未打开”属性保持不变。\n### 第一层只有金色收集物\n#### 场景1：第一层所有格子均为金色收集物\n##### 场景描述：第一层可放置物品的格子中全部是金色收集物。\n###### 预期结果：仅刷新第一层和第二层的位置。\n### 只剩下金色收集物\n#### 场景1：全场所有层只剩下金色收集物\n##### 场景描述：经过若干操作后，场上所有格子物品均为金色收集物。\n###### 预期结果：不消耗也不使用任何道具，刷新操作可能不执行或无效（需根据具体规则澄清）。\n### 检测机制\n#### 场景1：向后拿操作后空格数>6\n##### 场景描述：执行从后往前拿物品的操作后，检测到当前空格数大于6。\n###### 预期结果：不再进行后续的交换操作。\n#### 场景2：向后拿操作后第一层无可往后拿的物品\n##### 场景描述：执行从后往前拿物品的操作后，检测到第一层所有物品都是“成3”的完整组合。\n###### 预期结果：不再进行后续的交换操作。\n## 掉落关卡\n### 沿用旧逻辑\n#### 场景1：在掉落关卡中使用刷新功能\n##### 场景描述：当前关卡为掉落关卡，玩家使用刷新功能。\n###### 预期结果：刷新逻辑使用原来的（非本新方案的）逻辑进行处理。\n## 边界与异常测试\n### 空格数边界\n#### 场景1：空格数刚好等于3\n##### 场景描述：各种判断分支下，空格数恰好为3。\n###### 预期结果：逻辑正确判断，执行对应分支（如不向后拿或直接刷新位置）。\n#### 场景2：空格数为负数或异常值\n##### 场景描述：因未知BUG导致空格数计算为负或异常大数。\n###### 预期结果：系统应有健壮性处理，避免崩溃，可能视为0处理或抛出可处理的错误。\n### 可消除组数计算\n#### 场景1：可消除组数计算包含特殊格子\n##### 场景描述：计算第一层可消除组数时，包含或排除特殊格子（如锁链、刷新器）上的物品。\n###### 预期结果：根据需求定义，明确计算规则并保持一致。\n#### 场景2：复杂物品布局下的组数计算\n##### 场景描述：第一层物品布局复杂，存在交叉、重叠的可消除可能性。\n###### 预期结果：算法能正确识别所有不重叠的最大可消除组数。\n### 交换操作并发与状态\n#### 场景1：连续快速点击刷新\n##### 场景描述：在刷新动画或逻辑执行过程中，玩家再次点击刷新按钮。\n###### 预期结果：应阻止重复触发，或在当前刷新完成后才接受下一次指令，避免状态错乱。\n#### 场景2：网络延迟下的刷新\n##### 场景描述：在弱网环境下执行刷新操作。\n###### 预期结果：应有加载状态提示，操作结果最终能正确同步到服务器和客户端。\n### 数据一致性\n#### 场景1：刷新后物品总数检查\n##### 场景描述：执行完一套完整的刷新逻辑（可能包含新增层、移动物品）。\n###### 预期结果：关卡内物品总数应保持不变（金色收集物除外，如果其规则特殊）。\n#### 场景2：层高限制检查\n##### 场景描述：在执行“新增一层”操作时，当前层数已接近或达到关卡最大层数限制。\n###### 预期结果：逻辑应能正确处理，不能新增超过最大层数的层。', '2', 'deepseek-chat', 1, 7, 141, '400 Bad Request: \"{<EOL>  \"error\": {<EOL>    \"message\": \"Unsupported parameter: \'temperature\' is not supported with this model.\",<EOL>    \"type\": \"invalid_request_error\",<EOL>    \"param\": \"temperature\",<EOL>    \"code\": null<EOL>  }<EOL>}\"', '', '2026-02-28 10:30:35', '', '2026-03-09 23:34:49', NULL);

SET FOREIGN_KEY_CHECKS = 1;
