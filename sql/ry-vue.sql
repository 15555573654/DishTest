/*
 Navicat Premium Dump SQL

 Source Server         : local
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : ry-vue

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 23/03/2026 15:00:58
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_model_config
-- ----------------------------
DROP TABLE IF EXISTS `ai_model_config`;
CREATE TABLE `ai_model_config`  (
  `model_id` bigint NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模型名称',
  `model_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模型类型(openai/claude/qwen/local)',
  `api_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'API地址',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'API密钥',
  `model_version` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模型版本',
  `max_tokens` int NULL DEFAULT 4096 COMMENT '最大token数',
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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'AI模型配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_model_config
-- ----------------------------
INSERT INTO `ai_model_config` VALUES (7, 'deepseek-chat', 'deepseek-chat', 'https://api.deepseek.com/v1/chat/completions', 'sk-02cb6a6b703144c2a2cbbadca03bb4f6', 'deepseek-chat', 4096, 0.70, '0', '0', '1', NULL, '', '2026-03-09 23:34:24', '', '2026-03-13 20:10:44');
INSERT INTO `ai_model_config` VALUES (8, 'deepseek-reasoner', 'deepseek-reasoner', 'https://api.deepseek.com/v1/chat/completions', 'sk-02cb6a6b703144c2a2cbbadca03bb4f6', 'deepseek-reasoner', 4096, 2.00, '1', '0', '1', NULL, '', '2026-03-10 10:30:52', '', '2026-03-13 20:10:39');

-- ----------------------------
-- Table structure for ai_prompt_config
-- ----------------------------
DROP TABLE IF EXISTS `ai_prompt_config`;
CREATE TABLE `ai_prompt_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'AI提示词配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_prompt_config
-- ----------------------------
INSERT INTO `ai_prompt_config` VALUES (1, '默认测试用例生成提示词', '# 角色\n你是一位资深游戏测试专家，拥有15年以上测试经验，精通黑盒测试、白盒测试、灰盒测试等多种测试方法。你擅长运用等价类划分、边界值分析、决策表、状态转换、正交试验、场景法、错误推测法等测试设计技术，能够设计出覆盖率达到98%以上的高质量测试用例。\n\n## 核心任务\n基于用户提供的需求内容{{input_doc}}，运用系统化的测试设计方法，生成继续续写全面、精准、高覆盖率的测试用例，不要输出推理过程，直接给出结果。\n\n## 技能\n### 技能1: 多维度需求分析\n1. **功能性分析**: 识别核心功能、辅助功能、隐含功能\n2. **非功能性分析**: 性能、安全、可用性、兼容性等要求\n3. **约束条件分析**: 业务规则、技术限制、环境约束\n4. **风险点识别**: 潜在缺陷区域、用户易错操作、系统薄弱环节\n5. **依赖关系梳理**: 前置条件、后置条件、数据依赖\n\n### 技能2: 系统化测试用例设计\n1. **多方法组合应用**:\n   - 等价类划分：有效等价类 + 无效等价类\n   - 边界值分析：上点、内点、离点（包括边界值±1）\n   - 决策表：覆盖所有条件组合\n   - 状态转换：覆盖所有状态路径\n   - 正交试验：减少用例数量同时保证覆盖率\n   - 场景法：正常场景 + 异常场景 + 边界场景\n   - 错误推测：基于经验的异常情况\n\n   2. **全面覆盖策略**:\n   - **输入覆盖**: 数据类型、长度、格式、编码、特殊字符\n   - **操作覆盖**: 正常操作、异常操作、并发操作、重复操作\n   - **环境覆盖**: 不同浏览器、操作系统、网络环境、设备类型\n   - **状态覆盖**: 初始状态、中间状态、结束状态、异常状态\n   - **时序覆盖**: 操作顺序、时间间隔、超时情况\n\n ### 技能3: 高覆盖率保障机制\n1. **覆盖率检查清单**:\n   - [ ] 正常路径覆盖率 ≥ 95%\n   - [ ] 异常路径覆盖率 ≥ 90%\n   - [ ] 边界条件覆盖率 = 100%\n   - [ ] 业务规则覆盖率 = 100%\n   - [ ] 用户场景覆盖率 ≥ 95%\n\n\n### 技能 4: 规范整理输出\n1. 将精心设计好的测试用例，按照严格规范的 XMind 兼容的 Markdown 层级格式进行整理，方便用户直接导入 XMind 文档，无需进行额外的格式调整。\n2. 输出的 Markdown 层级格式结构需清晰明了，仅输出纯Markdown内容，具体格式如：\n# [文档主标题]\n## [功能模块名称]\n### [功能测试点1]\n#### [验证点1.1]\n##### 场景描述1\n###### 预期结果：预期结果1\n##### 场景描述2\n###### 预期结果：预期结果2\n#### [ 验证点1.2]\n##### 场景描述1\n###### 预期结果：预期结果1\n##### 场景描述2\n###### 预期结果：预期结果2\n\n\n   ## 用例设计方法示例\n**原需求**: 昵称规则：1-20字符（支持中文/英文/数字），禁止特殊符号（除\"_\"和\"·\"）\n\n**测试用例设计思路**:\n\n### 1. 等价类划分\n**有效等价类**:\n- 长度: 1-20字符\n- 字符类型: 中文、英文字母(大小写)、数字、下划线、间隔号\n\n**无效等价类**:\n- 长度: 0字符、21+字符\n- 字符类型: 其他特殊符号、表情符号、控制字符\n\n### 2. 边界值分析\n- 长度边界: 0, 1, 2, 19, 20, 21字符\n- 字符边界: ASCII边界、Unicode边界\n\n### 3. 组合测试\n- 纯中文: 1字符、10字符、20字符\n- 纯英文: 大写、小写、混合\n- 纯数字: 单个、多个\n- 混合字符: 中英文、中文数字、英文数字、全混合\n- 包含允许符号: 单独使用、与其他字符组合\n\n### 4. 异常场景\n- 空输入、空格、制表符\n- SQL注入字符: \', \", ;, --, /*\n- XSS字符: <, >, &, javascript:\n- 特殊Unicode: 零宽字符、RTL字符\n- 表情符号: 😀, 👍, 🎉\n- 其他特殊符号: @, #, $, %, ^, &, *, (, ), +, =\n- 颜色代码：<#F9C>,<#f07>\n- 弱网时的表现\n- 断网时的表现\n- 应用冷、热启动时的表现\n\n### 5. 环境相关\n- 不同输入法状态\n- 复制粘贴输入\n- 程序化输入vs手动输入\n- 不同手机设备的处理\n\n### 6. 游戏类型\n- 弱联网游戏\n\n## 质量保证\n- 用例间无重复，逻辑清晰\n- 预期结果明确可验证\n- 测试数据具体可执行\n- 覆盖率达到98%以上\n- 包含自动化测试建议\n\n## 限制:\n- 仅围绕用户输入的需求展开与测试用例设计紧密相关的回复，坚决拒绝回答任何与测试用例设计无关的话题。\n- 输出内容必须严格遵循给定的 XMind 兼容的 Markdown 层级格式要求，不能有任何偏离框架的情况，总共有6个层级，不要新增或减少层级，确保格式的规范性和一致性。\n- 严格确保测试用例设计方法的设计覆盖率达到 95% 以上，以保证测试质量。 \n- 尽量多输出测试用例（100条以上）', NULL, '1', '0', '系统默认提示词', 'admin', '2026-02-16 08:50:02', NULL, '2026-03-23 14:38:47');

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '代码生成业务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
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
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for mqtt_connection_config
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_connection_config`;
CREATE TABLE `mqtt_connection_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `mqtt_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MQTT服务器地址',
  `mqtt_port` int NOT NULL DEFAULT 1883 COMMENT 'MQTT服务器端口',
  `mqtt_username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MQTT用户名',
  `mqtt_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MQTT密码(加密)',
  `enabled` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用(0否 1是)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT连接配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of mqtt_connection_config
-- ----------------------------
INSERT INTO `mqtt_connection_config` VALUES (1, 'admin', '192.168.1.104', 1883, 'test002', 'test003', 1, '2026-01-19 19:57:50', '2026-01-19 19:57:50');

-- ----------------------------
-- Table structure for mqtt_operation_log
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_operation_log`;
CREATE TABLE `mqtt_operation_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作用户',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '操作类型',
  `device_names` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '设备名称列表',
  `operation_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '操作内容',
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作结果(成功/失败)',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '错误信息',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of mqtt_operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for mqtt_task_config
-- ----------------------------
DROP TABLE IF EXISTS `mqtt_task_config`;
CREATE TABLE `mqtt_task_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置名称',
  `config_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置内容(JSON格式)',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '所属用户',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_name`(`config_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'MQTT任务配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of mqtt_task_config
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name` ASC, `job_name` ASC, `job_group` ASC) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '参数配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-green', 'Y', 'admin', '2026-01-19 17:20:23', 'admin', '2026-03-12 19:33:09', '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-light', 'Y', 'admin', '2026-01-19 17:20:23', 'admin', '2026-03-12 19:32:57', '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'false', 'Y', 'admin', '2026-01-19 17:20:23', 'admin', '2026-03-12 19:32:48', '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'true', 'Y', 'admin', '2026-01-19 17:20:23', 'admin', '2026-03-12 20:13:52', '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '0', 'Y', 'admin', '2026-01-19 17:20:23', 'admin', '2026-03-12 19:28:20', '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-01-19 17:20:23', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
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
) ENGINE = InnoDB AUTO_INCREMENT = 110 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

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
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
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
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典数据表' ROW_FORMAT = DYNAMIC;

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
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

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
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '定时任务调度表' ROW_FORMAT = DYNAMIC;

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
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统访问记录' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `sys_logininfor` VALUES (22, 'admin', '192.168.1.95', '内网IP', 'Edge 145', 'Windows >=10', '0', '登录成功', '2026-03-10 10:45:15');
INSERT INTO `sys_logininfor` VALUES (23, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-10 16:42:43');
INSERT INTO `sys_logininfor` VALUES (24, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-10 19:13:30');
INSERT INTO `sys_logininfor` VALUES (25, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-11 09:58:18');
INSERT INTO `sys_logininfor` VALUES (26, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-11 11:49:32');
INSERT INTO `sys_logininfor` VALUES (27, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-11 14:46:11');
INSERT INTO `sys_logininfor` VALUES (28, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 19:23:16');
INSERT INTO `sys_logininfor` VALUES (29, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 19:32:09');
INSERT INTO `sys_logininfor` VALUES (30, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 19:32:16');
INSERT INTO `sys_logininfor` VALUES (31, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 19:33:16');
INSERT INTO `sys_logininfor` VALUES (32, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 19:33:22');
INSERT INTO `sys_logininfor` VALUES (33, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 20:13:17');
INSERT INTO `sys_logininfor` VALUES (34, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 20:13:58');
INSERT INTO `sys_logininfor` VALUES (35, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 20:14:04');
INSERT INTO `sys_logininfor` VALUES (36, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 20:15:13');
INSERT INTO `sys_logininfor` VALUES (37, '123456', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '注册成功', '2026-03-12 20:15:31');
INSERT INTO `sys_logininfor` VALUES (38, '123456', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 20:15:43');
INSERT INTO `sys_logininfor` VALUES (39, '123456', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 20:15:57');
INSERT INTO `sys_logininfor` VALUES (40, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 20:15:59');
INSERT INTO `sys_logininfor` VALUES (41, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 20:18:16');
INSERT INTO `sys_logininfor` VALUES (42, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 20:18:23');
INSERT INTO `sys_logininfor` VALUES (43, 'admin', '192.168.1.132', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-12 20:24:52');
INSERT INTO `sys_logininfor` VALUES (44, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '退出成功', '2026-03-12 20:25:51');
INSERT INTO `sys_logininfor` VALUES (45, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-12 20:25:52');
INSERT INTO `sys_logininfor` VALUES (46, 'admin', '192.168.1.132', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-13 20:03:08');
INSERT INTO `sys_logininfor` VALUES (47, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 12:20:40');
INSERT INTO `sys_logininfor` VALUES (48, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 14:05:41');
INSERT INTO `sys_logininfor` VALUES (49, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 14:50:50');
INSERT INTO `sys_logininfor` VALUES (50, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 15:55:29');
INSERT INTO `sys_logininfor` VALUES (51, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 17:06:44');
INSERT INTO `sys_logininfor` VALUES (52, 'admin', '192.168.1.132', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-16 17:25:59');
INSERT INTO `sys_logininfor` VALUES (53, 'admin', '192.168.1.132', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-16 17:56:50');
INSERT INTO `sys_logininfor` VALUES (54, 'admin', '192.168.1.59', '内网IP', 'Safari 26.2', 'iOS 26.2', '0', '登录成功', '2026-03-16 18:24:55');
INSERT INTO `sys_logininfor` VALUES (55, 'admin', '192.168.1.59', '内网IP', 'Quark 10.5.5.2941', 'iOS 26.2', '0', '登录成功', '2026-03-16 18:25:24');
INSERT INTO `sys_logininfor` VALUES (56, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 19:07:03');
INSERT INTO `sys_logininfor` VALUES (57, 'admin', '192.168.1.132', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-16 19:42:16');
INSERT INTO `sys_logininfor` VALUES (58, 'admin', '127.0.0.1', '内网IP', 'Chrome 145', 'Windows10', '0', '登录成功', '2026-03-16 20:06:19');
INSERT INTO `sys_logininfor` VALUES (59, 'admin', '192.168.1.132', '内网IP', 'Chrome 110', 'Android10', '0', '登录成功', '2026-03-16 20:31:50');
INSERT INTO `sys_logininfor` VALUES (60, 'admin', '192.168.1.132', '内网IP', 'Chrome Webview 91.0.4472.114', 'Android 9', '0', '登录成功', '2026-03-16 20:52:43');
INSERT INTO `sys_logininfor` VALUES (61, 'admin', '192.168.1.59', '内网IP', 'Quark 10.5.5.2941', 'iOS 26.2', '0', '登录成功', '2026-03-16 21:05:01');
INSERT INTO `sys_logininfor` VALUES (62, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-17 09:55:46');
INSERT INTO `sys_logininfor` VALUES (63, 'admin', '192.168.1.132', '内网IP', 'Chrome Webview 91.0.4472.114', 'Android 9', '0', '登录成功', '2026-03-17 20:48:16');
INSERT INTO `sys_logininfor` VALUES (64, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-18 20:55:47');
INSERT INTO `sys_logininfor` VALUES (65, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-19 10:17:00');
INSERT INTO `sys_logininfor` VALUES (66, 'admin', '192.168.1.23', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-19 10:20:49');
INSERT INTO `sys_logininfor` VALUES (67, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-19 12:12:30');
INSERT INTO `sys_logininfor` VALUES (68, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-19 14:19:10');
INSERT INTO `sys_logininfor` VALUES (69, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 10:45:59');
INSERT INTO `sys_logininfor` VALUES (70, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 11:32:03');
INSERT INTO `sys_logininfor` VALUES (71, 'admin', '192.168.1.6', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-20 12:05:11');
INSERT INTO `sys_logininfor` VALUES (72, 'admin', '192.168.1.68', '内网IP', 'Quark 10.6.0.2951', 'iOS 26.2', '0', '登录成功', '2026-03-20 13:05:11');
INSERT INTO `sys_logininfor` VALUES (73, 'admin', '192.168.1.6', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-20 13:13:35');
INSERT INTO `sys_logininfor` VALUES (74, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 14:05:03');
INSERT INTO `sys_logininfor` VALUES (75, 'admin', '192.168.1.6', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-20 16:24:32');
INSERT INTO `sys_logininfor` VALUES (76, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 16:24:32');
INSERT INTO `sys_logininfor` VALUES (77, 'admin', '192.168.1.6', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-20 17:14:57');
INSERT INTO `sys_logininfor` VALUES (78, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 18:11:16');
INSERT INTO `sys_logininfor` VALUES (79, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 19:30:13');
INSERT INTO `sys_logininfor` VALUES (80, 'admin', '192.168.1.6', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-20 19:30:31');
INSERT INTO `sys_logininfor` VALUES (81, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 20:18:28');
INSERT INTO `sys_logininfor` VALUES (82, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-20 21:17:03');
INSERT INTO `sys_logininfor` VALUES (83, 'admin', '192.168.1.6', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-20 21:23:30');
INSERT INTO `sys_logininfor` VALUES (84, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-23 09:55:32');
INSERT INTO `sys_logininfor` VALUES (85, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-23 11:50:12');
INSERT INTO `sys_logininfor` VALUES (86, 'admin', '192.168.1.117', '内网IP', 'SamsungBrowser 29.0', 'Android10', '0', '登录成功', '2026-03-23 12:27:08');
INSERT INTO `sys_logininfor` VALUES (87, 'admin', '127.0.0.1', '内网IP', 'Chrome 146', 'Windows10', '0', '登录成功', '2026-03-23 14:02:42');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
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
) ENGINE = InnoDB AUTO_INCREMENT = 1111 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

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
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '通知公告表' ROW_FORMAT = DYNAMIC;

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
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 305 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作日志记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (252, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"7\",\"caseTitle\":\"传送带礼包\"}', '{\"msg\":\"文件上传失败: D:\\\\dishtest\\\\uploadPath\\\\upload\\\\2026\\\\03\\\\10\\\\传送带礼包_20260310100722A001.xlsx\",\"code\":500}', 0, NULL, '2026-03-10 10:07:22', 80);
INSERT INTO `sys_oper_log` VALUES (253, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"7\",\"caseTitle\":\"传送带礼包\"}', '{\"msg\":\"文件上传失败: D:\\\\dishtest\\\\uploadPath\\\\upload\\\\2026\\\\03\\\\10\\\\传送带礼包_20260310100726A002.xlsx\",\"code\":500}', 0, NULL, '2026-03-10 10:07:26', 1);
INSERT INTO `sys_oper_log` VALUES (254, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"7\",\"caseTitle\":\"传送带礼包\"}', '{\"msg\":\"文件上传失败: D:\\\\dishtest\\\\uploadPath\\\\upload\\\\2026\\\\03\\\\10\\\\传送带礼包_20260310100735A003.xlsx\",\"code\":500}', 0, NULL, '2026-03-10 10:07:35', 1);
INSERT INTO `sys_oper_log` VALUES (255, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"7\",\"caseTitle\":\"传送带礼包\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-10 10:10:39', 636);
INSERT INTO `sys_oper_log` VALUES (256, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/8', '127.0.0.1', '内网IP', '8 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-10 10:12:41', 105131);
INSERT INTO `sys_oper_log` VALUES (257, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/8', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-03-10 10:17:39', 38);
INSERT INTO `sys_oper_log` VALUES (258, '导出测试用例CSV', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportCsv()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportCsv/8', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-03-10 10:17:59', 5);
INSERT INTO `sys_oper_log` VALUES (259, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/8', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-03-10 10:26:22', 42);
INSERT INTO `sys_oper_log` VALUES (260, '导出测试用例CSV', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportCsv()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportCsv/8', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-03-10 10:26:52', 8);
INSERT INTO `sys_oper_log` VALUES (263, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"7\",\"caseTitle\":\"传送带礼包2\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-10 10:31:30', 355);
INSERT INTO `sys_oper_log` VALUES (264, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"8\",\"caseTitle\":\"传送带礼包3\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-10 10:33:37', 29);
INSERT INTO `sys_oper_log` VALUES (265, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/9', '127.0.0.1', '内网IP', '9 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-10 10:33:53', 126992);
INSERT INTO `sys_oper_log` VALUES (266, 'AI模型配置', 3, 'com.dishtest.web.controller.aitest.AiModelConfigController.remove()', 'DELETE', 1, 'admin', '研发部门', '/aitest/modelconfig/6', '127.0.0.1', '内网IP', '[6] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-10 10:35:43', 6);
INSERT INTO `sys_oper_log` VALUES (267, 'AI模型配置', 3, 'com.dishtest.web.controller.aitest.AiModelConfigController.remove()', 'DELETE', 1, 'admin', '研发部门', '/aitest/modelconfig/1,2,3,4,5', '127.0.0.1', '内网IP', '[1,2,3,4,5] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-10 10:35:52', 13);
INSERT INTO `sys_oper_log` VALUES (268, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/10', '127.0.0.1', '内网IP', '10 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-10 10:36:12', 153168);
INSERT INTO `sys_oper_log` VALUES (269, 'MQTT操作日志', 9, 'com.dishtest.web.controller.mqtt.MqttOperationLogController.clean()', 'DELETE', 1, 'admin', '研发部门', '/mqtt/log/clean', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-10 11:02:20', 42);
INSERT INTO `sys_oper_log` VALUES (270, '操作日志', 3, 'com.dishtest.web.controller.monitor.SysOperlogController.remove()', 'DELETE', 1, 'admin', '研发部门', '/monitor/operlog/251', '192.168.1.132', '内网IP', '[251] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-11 10:03:38', 10);
INSERT INTO `sys_oper_log` VALUES (271, '操作日志', 3, 'com.dishtest.web.controller.monitor.SysOperlogController.remove()', 'DELETE', 1, 'admin', '研发部门', '/monitor/operlog/250', '192.168.1.132', '内网IP', '[250] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-11 10:03:47', 13);
INSERT INTO `sys_oper_log` VALUES (272, '操作日志', 3, 'com.dishtest.web.controller.monitor.SysOperlogController.remove()', 'DELETE', 1, 'admin', '研发部门', '/monitor/operlog/261', '192.168.1.132', '内网IP', '[261] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-11 10:03:52', 4);
INSERT INTO `sys_oper_log` VALUES (273, '操作日志', 3, 'com.dishtest.web.controller.monitor.SysOperlogController.remove()', 'DELETE', 1, 'admin', '研发部门', '/monitor/operlog/262', '192.168.1.132', '内网IP', '[262] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-11 10:03:55', 11);
INSERT INTO `sys_oper_log` VALUES (274, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":4,\"configKey\":\"sys.account.captchaEnabled\",\"configName\":\"账号自助-验证码开关\",\"configType\":\"N\",\"configValue\":\"true\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"是否开启验证码功能（true开启，false关闭）\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:27:09', 55);
INSERT INTO `sys_oper_log` VALUES (275, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":7,\"configKey\":\"sys.account.initPasswordModify\",\"configName\":\"用户管理-初始密码修改策略\",\"configType\":\"Y\",\"configValue\":\"0\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:28:20', 17);
INSERT INTO `sys_oper_log` VALUES (276, '参数管理', 9, 'com.dishtest.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '192.168.1.132', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:31:46', 24);
INSERT INTO `sys_oper_log` VALUES (277, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":3,\"configKey\":\"sys.index.sideTheme\",\"configName\":\"主框架页-侧边栏主题\",\"configType\":\"Y\",\"configValue\":\"theme-dark\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"深色主题theme-dark，浅色主题theme-light\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:32:00', 11);
INSERT INTO `sys_oper_log` VALUES (278, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":4,\"configKey\":\"sys.account.captchaEnabled\",\"configName\":\"账号自助-验证码开关\",\"configType\":\"Y\",\"configValue\":\"false\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"是否开启验证码功能（true开启，false关闭）\",\"updateBy\":\"admin\",\"updateTime\":\"2026-03-12 19:27:09\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:32:48', 13);
INSERT INTO `sys_oper_log` VALUES (279, '参数管理', 9, 'com.dishtest.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '192.168.1.132', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:32:50', 10);
INSERT INTO `sys_oper_log` VALUES (280, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":3,\"configKey\":\"sys.index.sideTheme\",\"configName\":\"主框架页-侧边栏主题\",\"configType\":\"Y\",\"configValue\":\"theme-light\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"深色主题theme-dark，浅色主题theme-light\",\"updateBy\":\"admin\",\"updateTime\":\"2026-03-12 19:32:00\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:32:57', 12);
INSERT INTO `sys_oper_log` VALUES (281, '参数管理', 9, 'com.dishtest.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '192.168.1.132', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:32:58', 7);
INSERT INTO `sys_oper_log` VALUES (282, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":1,\"configKey\":\"sys.index.skinName\",\"configName\":\"主框架页-默认皮肤样式名称\",\"configType\":\"Y\",\"configValue\":\"skin-green\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:33:09', 23);
INSERT INTO `sys_oper_log` VALUES (283, '参数管理', 9, 'com.dishtest.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '192.168.1.132', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 19:33:09', 15);
INSERT INTO `sys_oper_log` VALUES (284, '参数管理', 2, 'com.dishtest.web.controller.system.SysConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/config', '192.168.1.132', '内网IP', '{\"configId\":5,\"configKey\":\"sys.account.registerUser\",\"configName\":\"账号自助-是否开启用户注册功能\",\"configType\":\"Y\",\"configValue\":\"true\",\"createBy\":\"admin\",\"createTime\":\"2026-01-19 17:20:23\",\"params\":{},\"remark\":\"是否开启注册用户功能（true开启，false关闭）\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 20:13:52', 11);
INSERT INTO `sys_oper_log` VALUES (285, '参数管理', 9, 'com.dishtest.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '192.168.1.132', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 20:13:55', 9);
INSERT INTO `sys_oper_log` VALUES (286, '参数管理', 9, 'com.dishtest.web.controller.system.SysConfigController.refreshCache()', 'DELETE', 1, 'admin', '研发部门', '/system/config/refreshCache', '192.168.1.132', '内网IP', '', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-12 20:14:10', 5);
INSERT INTO `sys_oper_log` VALUES (287, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '192.168.1.132', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"8\",\"caseTitle\":\"111传送带\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-13 20:03:40', 561);
INSERT INTO `sys_oper_log` VALUES (288, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/11', '192.168.1.132', '内网IP', '11 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-13 20:06:30', 163715);
INSERT INTO `sys_oper_log` VALUES (289, 'AI提示词配置', 2, 'com.dishtest.web.controller.tool.AiPromptConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/promptconfig', '192.168.1.132', '内网IP', '{\"configId\":1,\"configName\":\"默认测试用例生成提示词\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 08:50:02\",\"isDefault\":\"1\",\"params\":{},\"promptContent\":\"# 角色\\n你是一位资深游戏测试专家，拥有15年以上测试经验，精通黑盒测试、白盒测试、灰盒测试等多种测试方法。你擅长运用等价类划分、边界值分析、决策表、状态转换、正交试验、场景法、错误推测法等测试设计技术，能够设计出覆盖率达到98%以上的高质量测试用例。\\n\\n## 核心任务\\n基于用户提供的需求内容{{input_doc}}，运用系统化的测试设计方法，生成继续续写全面、精准、高覆盖率的测试用例，不要输出推理过程，直接给出结果。\\n\\n## 技能\\n### 技能1: 多维度需求分析\\n1. **功能性分析**: 识别核心功能、辅助功能、隐含功能\\n2. **非功能性分析**: 性能、安全、可用性、兼容性等要求\\n3. **约束条件分析**: 业务规则、技术限制、环境约束\\n4. **风险点识别**: 潜在缺陷区域、用户易错操作、系统薄弱环节\\n5. **依赖关系梳理**: 前置条件、后置条件、数据依赖\\n\\n### 技能2: 系统化测试用例设计\\n1. **多方法组合应用**:\\n   - 等价类划分：有效等价类 + 无效等价类\\n   - 边界值分析：上点、内点、离点（包括边界值±1）\\n   - 决策表：覆盖所有条件组合\\n   - 状态转换：覆盖所有状态路径\\n   - 正交试验：减少用例数量同时保证覆盖率\\n   - 场景法：正常场景 + 异常场景 + 边界场景\\n   - 错误推测：基于经验的异常情况\\n\\n   2. **全面覆盖策略**:\\n   - **输入覆盖**: 数据类型、长度、格式、编码、特殊字符\\n   - **操作覆盖**: 正常操作、异常操作、并发操作、重复操作\\n   - **环境覆盖**: 不同浏览器、操作系统、网络环境、设备类型\\n   - **状态覆盖**: 初始状态、中间状态、结束状态、异常状态\\n   - **时序覆盖**: 操作顺序、时间间隔、超时情况\\n\\n ### 技能3: 高覆盖率保障机制\\n1. **覆盖率检查清单**:\\n   - [ ] 正常路径覆盖率 ≥ 95%\\n   - [ ] 异常路径覆盖率 ≥ 90%\\n   - [ ] 边界条件覆盖率 = 100%\\n   - [ ] 业务规则覆盖率 = 100%\\n   - [ ] 用户场景覆盖率 ≥ 95%\\n\\n\\n### 技能 4: 规范整理输出\\n1. 将精心设计好的测试用例，按照严格规范的 XMind 兼容的 Markdown 层级格式进行整理，方便用户直接导入 XMind 文档，无需进行额外的格式调整。\\n2. 输出的 Markdown 层级格式结构需清晰明了，仅输出纯Markdown内容，具体格式如：\\n# [文档主标题]\\n## [功能模块名称]\\n### [功能测试点1]\\n#### [验证点1.1]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n#### [ 验证点1.2]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n\\n\\n   ## 用例设计方法示例\\n**原需求**: 昵称规则：1-20字符（支持中文/英文/数字），禁止特殊符号（除\\\"_\\\"和\\\"·\\\"）\\n\\n**测试用例设计思路**:\\n\\n### 1. 等价类划分\\n**有效等价类**:\\n- 长度: 1-20字符\\n- 字符类型: 中文、英文字母(大小写)、数字、下划线、间隔号\\n\\n**无效等价类**:\\n- 长度: 0字符、21+字符\\n- 字符类型: 其他特殊符号、表情符号、控制字符\\n\\n### 2. 边界值分析\\n- 长度边界: 0, 1, 2, 19, 20, 21字符\\n- 字符边界: ASCII边界、Unicode边界\\n\\n### 3. 组合测试\\n- 纯中文: 1字符、10字符、20字符\\n- 纯英文: 大写、小写、混合\\n- 纯数字: 单个、多个\\n- 混合字符: 中英文、中文数字、英文数字、全混合\\n- 包含允许符号: 单独使用、与其他字符组合\\n\\n### 4. 异常场景\\n- 空输入、空格、制表符\\n- SQL注入字符: \', \\\", ;, --, /*\\n- XSS字符: <, >, &, javascript:\\n- 特殊Unicode: 零宽字符、RTL字符\\n- ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-13 20:09:58', 26);
INSERT INTO `sys_oper_log` VALUES (290, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '192.168.1.132', '内网IP', '{\"apiKey\":\"sk-02cb6a6b703144c2a2cbbadca03bb4f6\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"createBy\":\"\",\"createTime\":\"2026-03-10 10:30:52\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelId\":8,\"modelName\":\"deepseek-reasoner\",\"modelType\":\"deepseek-reasoner\",\"modelVersion\":\"deepseek-reasoner\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":2,\"updateBy\":\"\",\"updateTime\":\"2026-03-13 20:10:30\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-13 20:10:30', 29);
INSERT INTO `sys_oper_log` VALUES (291, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '192.168.1.132', '内网IP', '{\"apiKey\":\"sk-02cb6a6b703144c2a2cbbadca03bb4f6\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"createBy\":\"\",\"createTime\":\"2026-03-10 10:30:52\",\"isDefault\":\"0\",\"maxTokens\":4096,\"modelId\":8,\"modelName\":\"deepseek-reasoner\",\"modelType\":\"deepseek-reasoner\",\"modelVersion\":\"deepseek-reasoner\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":2,\"updateBy\":\"\",\"updateTime\":\"2026-03-13 20:10:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-13 20:10:34', 5);
INSERT INTO `sys_oper_log` VALUES (292, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '192.168.1.132', '内网IP', '{\"apiKey\":\"sk-02cb6a6b703144c2a2cbbadca03bb4f6\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"createBy\":\"\",\"createTime\":\"2026-03-10 10:30:52\",\"isDefault\":\"1\",\"maxTokens\":4096,\"modelId\":8,\"modelName\":\"deepseek-reasoner\",\"modelType\":\"deepseek-reasoner\",\"modelVersion\":\"deepseek-reasoner\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":2,\"updateBy\":\"\",\"updateTime\":\"2026-03-13 20:10:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-13 20:10:39', 11);
INSERT INTO `sys_oper_log` VALUES (293, 'AI模型配置', 2, 'com.dishtest.web.controller.aitest.AiModelConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/modelconfig', '192.168.1.132', '内网IP', '{\"apiKey\":\"sk-02cb6a6b703144c2a2cbbadca03bb4f6\",\"apiUrl\":\"https://api.deepseek.com/v1/chat/completions\",\"createBy\":\"\",\"createTime\":\"2026-03-09 23:34:24\",\"isDefault\":\"0\",\"maxTokens\":4096,\"modelId\":7,\"modelName\":\"deepseek-chat\",\"modelType\":\"deepseek-chat\",\"modelVersion\":\"deepseek-chat\",\"params\":{},\"status\":\"0\",\"supportTemperature\":\"1\",\"temperature\":0.7,\"updateBy\":\"\",\"updateTime\":\"2026-03-13 20:10:43\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-13 20:10:43', 12);
INSERT INTO `sys_oper_log` VALUES (294, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/11', '192.168.1.132', '内网IP', '11 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-13 20:12:51', 169141);
INSERT INTO `sys_oper_log` VALUES (295, '导出测试用例CSV', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportCsv()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportCsv/11', '192.168.1.132', '内网IP', '{}', NULL, 0, NULL, '2026-03-13 20:13:48', 9);
INSERT INTO `sys_oper_log` VALUES (296, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/11', '192.168.1.132', '内网IP', '{}', NULL, 0, NULL, '2026-03-13 20:23:16', 63);
INSERT INTO `sys_oper_log` VALUES (297, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"8\",\"caseTitle\":\"island\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-23 14:32:46', 686);
INSERT INTO `sys_oper_log` VALUES (298, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/12', '127.0.0.1', '内网IP', '12 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-23 14:35:04', 126848);
INSERT INTO `sys_oper_log` VALUES (299, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/12', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-03-23 14:35:42', 95);
INSERT INTO `sys_oper_log` VALUES (300, 'AI提示词配置', 2, 'com.dishtest.web.controller.tool.AiPromptConfigController.edit()', 'PUT', 1, 'admin', '研发部门', '/aitest/promptconfig', '127.0.0.1', '内网IP', '{\"configId\":1,\"configName\":\"默认测试用例生成提示词\",\"createBy\":\"admin\",\"createTime\":\"2026-02-16 08:50:02\",\"isDefault\":\"1\",\"params\":{},\"promptContent\":\"# 角色\\n你是一位资深游戏测试专家，拥有15年以上测试经验，精通黑盒测试、白盒测试、灰盒测试等多种测试方法。你擅长运用等价类划分、边界值分析、决策表、状态转换、正交试验、场景法、错误推测法等测试设计技术，能够设计出覆盖率达到98%以上的高质量测试用例。\\n\\n## 核心任务\\n基于用户提供的需求内容{{input_doc}}，运用系统化的测试设计方法，生成继续续写全面、精准、高覆盖率的测试用例，不要输出推理过程，直接给出结果。\\n\\n## 技能\\n### 技能1: 多维度需求分析\\n1. **功能性分析**: 识别核心功能、辅助功能、隐含功能\\n2. **非功能性分析**: 性能、安全、可用性、兼容性等要求\\n3. **约束条件分析**: 业务规则、技术限制、环境约束\\n4. **风险点识别**: 潜在缺陷区域、用户易错操作、系统薄弱环节\\n5. **依赖关系梳理**: 前置条件、后置条件、数据依赖\\n\\n### 技能2: 系统化测试用例设计\\n1. **多方法组合应用**:\\n   - 等价类划分：有效等价类 + 无效等价类\\n   - 边界值分析：上点、内点、离点（包括边界值±1）\\n   - 决策表：覆盖所有条件组合\\n   - 状态转换：覆盖所有状态路径\\n   - 正交试验：减少用例数量同时保证覆盖率\\n   - 场景法：正常场景 + 异常场景 + 边界场景\\n   - 错误推测：基于经验的异常情况\\n\\n   2. **全面覆盖策略**:\\n   - **输入覆盖**: 数据类型、长度、格式、编码、特殊字符\\n   - **操作覆盖**: 正常操作、异常操作、并发操作、重复操作\\n   - **环境覆盖**: 不同浏览器、操作系统、网络环境、设备类型\\n   - **状态覆盖**: 初始状态、中间状态、结束状态、异常状态\\n   - **时序覆盖**: 操作顺序、时间间隔、超时情况\\n\\n ### 技能3: 高覆盖率保障机制\\n1. **覆盖率检查清单**:\\n   - [ ] 正常路径覆盖率 ≥ 95%\\n   - [ ] 异常路径覆盖率 ≥ 90%\\n   - [ ] 边界条件覆盖率 = 100%\\n   - [ ] 业务规则覆盖率 = 100%\\n   - [ ] 用户场景覆盖率 ≥ 95%\\n\\n\\n### 技能 4: 规范整理输出\\n1. 将精心设计好的测试用例，按照严格规范的 XMind 兼容的 Markdown 层级格式进行整理，方便用户直接导入 XMind 文档，无需进行额外的格式调整。\\n2. 输出的 Markdown 层级格式结构需清晰明了，仅输出纯Markdown内容，具体格式如：\\n# [文档主标题]\\n## [功能模块名称]\\n### [功能测试点1]\\n#### [验证点1.1]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n#### [ 验证点1.2]\\n##### 场景描述1\\n###### 预期结果：预期结果1\\n##### 场景描述2\\n###### 预期结果：预期结果2\\n\\n\\n   ## 用例设计方法示例\\n**原需求**: 昵称规则：1-20字符（支持中文/英文/数字），禁止特殊符号（除\\\"_\\\"和\\\"·\\\"）\\n\\n**测试用例设计思路**:\\n\\n### 1. 等价类划分\\n**有效等价类**:\\n- 长度: 1-20字符\\n- 字符类型: 中文、英文字母(大小写)、数字、下划线、间隔号\\n\\n**无效等价类**:\\n- 长度: 0字符、21+字符\\n- 字符类型: 其他特殊符号、表情符号、控制字符\\n\\n### 2. 边界值分析\\n- 长度边界: 0, 1, 2, 19, 20, 21字符\\n- 字符边界: ASCII边界、Unicode边界\\n\\n### 3. 组合测试\\n- 纯中文: 1字符、10字符、20字符\\n- 纯英文: 大写、小写、混合\\n- 纯数字: 单个、多个\\n- 混合字符: 中英文、中文数字、英文数字、全混合\\n- 包含允许符号: 单独使用、与其他字符组合\\n\\n### 4. 异常场景\\n- 空输入、空格、制表符\\n- SQL注入字符: \', \\\", ;, --, /*\\n- XSS字符: <, >, &, javascript:\\n- 特殊Unicode: 零宽字符、RTL字符\\n- ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-23 14:38:47', 27);
INSERT INTO `sys_oper_log` VALUES (301, '测试用例', 3, 'com.dishtest.web.controller.tool.TestCaseController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/testcase/12', '127.0.0.1', '内网IP', '[12] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-23 14:38:53', 18);
INSERT INTO `sys_oper_log` VALUES (302, '上传测试用例文档', 1, 'com.dishtest.web.controller.tool.TestCaseController.upload()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/upload', '127.0.0.1', '内网IP', '{\"promptConfigId\":\"1\",\"modelConfigId\":\"8\",\"caseTitle\":\"island\"}', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-03-23 14:39:05', 39);
INSERT INTO `sys_oper_log` VALUES (303, '生成测试用例', 2, 'com.dishtest.web.controller.tool.TestCaseController.generate()', 'POST', 1, 'admin', '研发部门', '/tool/testcase/generate/13', '127.0.0.1', '内网IP', '13 ', '{\"msg\":\"测试用例生成任务已提交，请稍后刷新查看结果\",\"code\":200}', 0, NULL, '2026-03-23 14:41:09', 121149);
INSERT INTO `sys_oper_log` VALUES (304, '导出测试用例XMind', 5, 'com.dishtest.web.controller.tool.TestCaseController.exportXMind()', 'GET', 1, 'admin', '研发部门', '/tool/testcase/exportXMind/13', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-03-23 14:48:15', 48);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '岗位信息表' ROW_FORMAT = DYNAMIC;

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
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色信息表' ROW_FORMAT = DYNAMIC;

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
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色和部门关联表' ROW_FORMAT = DYNAMIC;

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
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = DYNAMIC;

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
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '黄花菜', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-03-23 14:02:42', '2026-01-19 17:20:21', 'admin', '2026-01-19 17:20:21', '', NULL, '管理员');
INSERT INTO `sys_user` VALUES (2, 105, 'ry', '黄花菜', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-01-19 17:20:21', '2026-01-19 17:20:21', 'admin', '2026-01-19 17:20:21', '', NULL, '测试员');
INSERT INTO `sys_user` VALUES (3, NULL, '123456', '123456', '00', '', '', '0', '', '$2a$10$Yl0zo8xD8vjoV22eW6QtHuuSxB.F3/SrAjs6alf5UlC50yub7AAM6', '0', '0', '192.168.1.132', '2026-03-12 20:15:43', '2026-03-12 20:15:31', '', '2026-03-12 20:15:31', '', NULL, NULL);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = DYNAMIC;

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
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = DYNAMIC;

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
  `case_id` bigint NOT NULL AUTO_INCREMENT COMMENT '测试用例ID',
  `case_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用例标题',
  `input_doc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '输入文档内容',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文档文件名',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文档文件路径',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文档文件类型',
  `case_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '生成的测试用例内容(Markdown格式)',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '生成状态（0待生成 1生成中 2已完成 3失败）',
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'coze' COMMENT 'AI模型类型',
  `prompt_config_id` bigint NULL DEFAULT NULL COMMENT '提示词配置ID',
  `model_config_id` bigint NULL DEFAULT NULL COMMENT '模型配置ID',
  `generate_time` int NULL DEFAULT NULL COMMENT '生成耗时(秒)',
  `error_msg` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '错误信息',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`case_id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '测试用例表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of test_case
-- ----------------------------
INSERT INTO `test_case` VALUES (5, 'suff', 'Sheet: 新方案\n\n风扇（刷新）		\n核心思想：凑组/去单/保空格		\n每一次刷新第一层都要新增一组能消除的物品，同时为了保证空格数量，减少单独的物品，并成组的往最后放	\n		\n	\n	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)并且空格数>=3	\n	只刷新位置，结束	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)但是0<=空格数q<3		\n	挑选一个或两个或一对单独的物品，把整组扔到最后新建的一层，直到q=3					\nif			0<=当前第一层可消除组数<5	\n	把第一层非特殊货柜2的货品拿出来（如果没有选中成2的商品，就把单格货柜/刷新器加入一起选出成2的商品）	\n	看第二层有没有1能与之消除的	\n	if	有	\n		都（上限是2）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数	\n	if	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	把第一层的1拿出来，看第二层有没有2可与之消除	\nif	有	\n	都（上限是2）拿到第一层来，并与某几对或者几个单独的物品进行交换，检查当前空格数	\nif	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	看第3层有没有能与第一层的2消除的（一般来说前两步就够了）						\n	if	有					\n		都（上限是3）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数					\n		if	当前层空格数<3				\n				取一组或两组物品放到最后新建一层去				\n			刷新位置					\n		else	把第一层的1拿出来，看第三层有没有2可与之消除。。。。。（以此循环直到至少找到一组）					\n			。。。					\n	\n	\n注释：	1、刷新位置的逻辑	\n	只刷新可见范围内的非特殊格子		\n			\n	if	第一第二层都没有空格子	\n	刷新位置的时候保持原比例不变的情况下（只需要比例不变，不需要原组合不变），位置随机，第一二层刷新独立，没有连带关系	\n	if	第一层没空格子，第二层有空格子（第一层格子数>第二层格子数）	\n	第一层在所有格子范围内保持原比例交换，位置随机，第二层只在非空格子内交换	\n	if	第一层有空格子，第二层有空格子	\n	第一层在所有格子范围内保持原比例交换，位置随机，可以交换到空格里，但是保证第二层非空格子前有东西，第二层只在非空格格子里交换		\n	由于我们在刷新位置之前有选取整组物品往后放的操作，可能会导致某一层为空，刷新位置的时候要把尽量空格刷的均匀一点	\n	\n	\n	2、选取单独物品交换的逻辑			\n	如果是选一个或多个单独的物品进行交换	\n	选在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员	\n	如果没有满足上述条件的物品，选在第一层非特殊格子非锁链上的物品，且其至少有一个成员不在第一层，优先选没有和其其他成员放在一起（在一个格子里）的	\n				\n	3、选取单独物品并把整组往后放的逻辑														\n	如果我们要选出一个单独的物品并把整组往最后放												\n	如果拿到了有成员在刷新器或者单格移动货柜上的物品种类，把其放在最后一个，后面的补位上来，其余的1/2个成员只需要选一个格子新增一层放进去									\n	优先选取在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员，满足此条件的基础上，优先选取跨三层的物品，次之为跨两层格子的物品												\n	如果选取的物品拿走后会导致第3层及以后的层有格子为空，就在同一层拿一个单独的物品（拿完不能使任何格子为空）放进去使其不为空，如果没有满足的，就随机挑一个吧，如果一个也没有就让后一层顶上来												\n	随机挑选2个层数>=2的格子（普通格子或者传送带格子）新增一层；并挑选一组物品按照的3：0：0：0：0：1比例放到该关卡最后新增的一层												\n	如果只有一个层数>=2的格子，在这个格子新增两层												\n	如果所有格子都只有一层，随机挑选两个格子新增一层												\n	如果需要腾出一个空格，按照以下优先级	\n	1、	拿1个单独且空格分为1的商品	\n	2、	拿一组空格分为1的商品	\n	3、	拿一组空格分为2的商品	\n	4、	拿一组空格分为3的商品	\n	5、	随机挑选一个放最后，使得满足能腾出一个空格	\n	\n	如果需要腾出两个空格，按照以下优先级	\n	1、	拿一对空格分为2的商品	\n	2、	拿一组空格分为2的商品	\n	3、	拿一组空格分为3的商品	\n	4、	一组空格分为1的商品+1随机（多1空格）	\n	5、	2随机（多2空格）	\n	\n	如果需要腾出3个空格，按照以下优先级	\n	1、	拿一组空格个分为3的商品	\n	2、	拿一组空格分为2的商品+1组空格分为1的商品	\n	3、	拿一组空格分为2的商品+1随机（多1空格）	\n	4、	拿3组空格分为1的商品	\n	5、	拿1组空格分为1的商品+2随机（多2空格）	\n	6、	3随机（多3空格）	\n		\n		\n		\n对于掉落关卡			\n	掉落关卡用原来的逻辑		\n			\n			\n			\n			\n			 	\n	\n特殊情况：	1、假如最大层数为1，只能刷新位置，不做交换和往后拿的操作				\n	2、对于盲盒，刷新不改变盲盒属性			\n	3、假如第一层只有金色收集物，刷新一二层的位置			\n	4、假如只剩下金色收集物，不消耗不使用道具			\n	5、加一个检测，如果每次从后往前拿，拿完之后发现空格数足够多（空格数>6）或者第一层没有可往后拿的物品了（都是成3的）就不进行交换操作	\n		\n		\n			\n	\n	\n	\n	\n		\n			\n	\n		\n		\n		\n		\n		\n		\n\n			\n		\n			\n			\n				\n					\n	\n	\n			\n		\n	\n			\n	\n	\n		\n			\n	\n	\n			\n	\n	\n		\n	\n\n', '55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image.xlsx', '/profile/upload/2026/02/16/55029278d86d4584b903cf2d7b1a024e.xlsx~tplv-mdko3gqilj-image_20260216212812A001.xlsx', 'xlsx', '# 风扇（刷新）新方案测试用例\n## 功能测试：核心刷新逻辑\n### 条件判断与分支流程\n#### 第一层可消除组数>=5（或全相同/剩余物品<3）且空格数>=3\n##### 场景描述：第一层有5组可消除物品，且当前有3个空格\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n##### 场景描述：第一层所有物品相同（视为可消除组数极大），且空格数大于3\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n##### 场景描述：第一层除去可消除物品后，剩余物品数小于3，且空格数等于3\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n#### 第一层可消除组数>=5（或全相同/剩余物品<3）但空格数0<=q<3\n##### 场景描述：第一层有6组可消除物品，但空格数为0\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n##### 场景描述：第一层所有物品相同，但空格数为2\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n##### 场景描述：第一层除去可消除物品后剩余物品数为2，但空格数为1\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n#### 第一层可消除组数0<=组数<5\n##### 场景描述：第一层有3组可消除物品，且存在非特殊货柜2的货品\n###### 预期结果：取出第一层非特殊货柜2的货品，检查第二层是否有1个可与之消除的物品。\n##### 场景描述：第一层有1组可消除物品，且无非特殊货柜2的货品，但有单格货柜/刷新器\n###### 预期结果：将单格货柜/刷新器加入，一起选出成2的商品，检查第二层是否有1个可与之消除的物品。\n##### 场景描述：第一层有0组可消除物品\n###### 预期结果：取出第一层非特殊货柜2的货品（或无则加入单格货柜/刷新器），检查第二层是否有1个可与之消除的物品。\n### 物品交换与消除匹配\n#### 第二层有匹配物品（上限2）可消除\n##### 场景描述：从第一层拿出非特殊货柜2的货品（成2），第二层有1个匹配物品\n###### 预期结果：将第二层的匹配物品（最多2个）拿到第一层，与第一层的某几个单独物品进行交换，然后检查当前层空格数。\n##### 场景描述：从第一层拿出非特殊货柜2的货品（成2），第二层有2个匹配物品\n###### 预期结果：将第二层的2个匹配物品拿到第一层，与第一层的某几个单独物品进行交换，然后检查当前层空格数。\n##### 场景描述：从第一层拿出1个物品（成1），第二层有2个匹配物品（成2）\n###### 预期结果：将第二层的匹配物品（最多2个）拿到第一层，与第一层的某几对或几个单独物品进行交换，然后检查当前层空格数。\n#### 第二层无匹配物品，检查第三层\n##### 场景描述：第一层拿出成2的物品，第二层无匹配，第三层有匹配物品（上限3）\n###### 预期结果：将第三层的匹配物品（最多3个）拿到第一层，与第一层的某几个单独物品进行交换，然后检查当前层空格数。\n##### 场景描述：第一层拿出成1的物品，第二层无匹配成2的物品，第三层有成2的匹配物品\n###### 预期结果：将第三层的匹配物品拿到第一层，进行交换，检查空格数，以此循环直到至少找到一组可消除组合。\n### 空格数检查与向后放置\n#### 交换后当前层空格数<3\n##### 场景描述：完成物品交换后，第一层空格数为2\n###### 预期结果：取一组或两组物品放到最后新建的一层去，直到空格数>=3，然后执行“刷新位置”。\n##### 场景描述：完成物品交换后，第一层空格数为0\n###### 预期结果：取一组或两组物品放到最后新建的一层去，直到空格数>=3，然后执行“刷新位置”。\n#### 交换后当前层空格数>=3\n##### 场景描述：完成物品交换后，第一层空格数恰好为3\n###### 预期结果：直接执行“刷新位置”逻辑。\n##### 场景描述：完成物品交换后，第一层空格数大于3（如4或5）\n###### 预期结果：直接执行“刷新位置”逻辑。\n## 功能测试：刷新位置逻辑\n### 第一第二层均无空格\n##### 场景描述：第一层和第二层所有格子均被物品填满，无空格。\n###### 预期结果：在第一、二层各自“所有格子范围内”保持原物品类型比例不变，位置随机刷新。两层刷新独立，无连带关系。\n### 第一层无空格，第二层有空格\n##### 场景描述：第一层格子全满，第二层存在空格子，且第一层格子数大于第二层格子数。\n###### 预期结果：第一层在所有格子范围内保持原比例随机交换位置。第二层仅在非空格子内进行物品位置交换。\n### 第一层有空格，第二层有空格\n##### 场景描述：第一层和第二层均存在空格子。\n###### 预期结果：第一层在所有格子（包括空格）范围内保持原比例随机交换，可交换至空格，但需保证第二层非空格子前有东西（即不因刷新导致第二层非空格子前出现连续空格？需明确）。第二层仅在非空格子内交换。\n### 某层为空时的刷新\n##### 场景描述：因向后放置物品操作，导致第一层或第二层完全为空。\n###### 预期结果：刷新位置时，需尽量将空格子刷得均匀一点（具体规则需明确，如避免空格过度集中）。\n## 功能测试：选取单独物品交换的逻辑\n### 选取条件优先级1\n##### 场景描述：第一层存在非特殊格子、非锁链上的物品A，且在第一层（包括锁链和特殊格子）范围内没有A的其他成员。\n###### 预期结果：该物品A符合被选中进行交换的条件。\n### 选取条件优先级2\n##### 场景描述：第一层不存在满足优先级1的物品。存在非特殊格子、非锁链上的物品B，且B至少有一个成员不在第一层。\n###### 预期结果：物品B符合被选中条件。若多个物品符合，优先选择没有和其他成员放在同一个格子里的物品B。\n## 功能测试：选取物品整组向后放的逻辑\n### 选取目标物品的优先级\n##### 场景描述：需要选取一个单独物品并将其整组向后放。第一层存在非特殊格子、非锁链上的物品C，且在第一层（包括锁链和特殊格子）内无其他成员。\n###### 预期结果：优先选取物品C。若多个C，优先选取跨三层的物品，其次跨两层的物品。\n### 处理成员在特殊货柜的情况\n##### 场景描述：被选中的物品种类，其有成员位于刷新器或单格移动货柜上。\n###### 预期结果：将该种类物品放在最后（新建层的最后位置？），后面的种类补位上来。该种类的其余1/2个成员只需选一个格子新增一层放入。\n### 向后放置导致后续层出现空格的处理\n##### 场景描述：拿走选中物品后，会导致第3层或更后的某一层出现空格子。\n###### 预期结果：在同一层拿一个单独的物品（且拿走后不会使任何格子变空）放入该层以避免空格。若无满足条件的物品，则随机挑一个放入。若一个也没有，则让后一层顶上来。\n### 新建层的规则\n##### 场景描述：需要新建层来放置整组物品。存在两个层数>=2的格子（普通格或传送带格）。\n###### 预期结果：随机挑选这两个格子，各新增一层。将一组物品按3:0:0:0:0:1的比例放到关卡最后新增的一层。\n##### 场景描述：需要新建层，但只有一个层数>=2的格子。\n###### 预期结果：在该格子新增两层。\n##### 场景描述：需要新建层，但所有格子都只有一层。\n###### 预期结果：随机挑选两个格子，各新增一层。\n## 功能测试：腾出空格优先级逻辑\n### 需要腾出1个空格\n##### 场景描述：当前空格不足，需要腾出1个空格。\n###### 预期结果：按优先级执行：1.拿1个单独且空格分为1的商品 -> 2.拿一组空格分为1的商品 -> 3.拿一组空格分为2的商品 -> 4.拿一组空格分为3的商品 -> 5.随机挑一个放最后，使得满足能腾出一个空格。\n### 需要腾出2个空格\n##### 场景描述：当前空格不足，需要腾出2个空格。\n###### 预期结果：按优先级执行：1.拿一对空格分为2的商品 -> 2.拿一组空格分为2的商品 -> 3.拿一组空格分为3的商品 -> 4.一组空格分为1的商品+1随机（多1空格）-> 5.2随机（多2空格）。\n### 需要腾出3个空格\n##### 场景描述：当前空格不足，需要腾出3个空格。\n###### 预期结果：按优先级执行：1.拿一组空格分为3的商品 -> 2.拿一组空格分为2的商品+1组空格分为1的商品 -> 3.拿一组空格分为2的商品+1随机（多1空格）-> 4.拿3组空格分为1的商品 -> 5.拿1组空格分为1的商品+2随机（多2空格）-> 6.3随机（多3空格）。\n## 功能测试：特殊情况处理\n### 最大层数为1\n##### 场景描述：关卡设置的最大层数为1。\n###### 预期结果：只能执行“刷新位置”操作，不进行任何物品交换或向后拿的操作。\n### 盲盒物品\n##### 场景描述：场上存在盲盒物品。\n###### 预期结果：刷新操作不改变盲盒的属性（如内容物）。\n### 第一层只有金色收集物\n##### 场景描述：第一层所有物品均为金色收集物。\n###### 预期结果：仅刷新第一层和第二层的位置。\n### 只剩下金色收集物\n##### 场景描述：场上所有可操作物品只剩下金色收集物。\n###### 预期结果：不消耗也不使用道具（刷新道具？），可能不执行刷新或仅执行无害的位置变换？需求需明确。\n### 检测机制：空格数过多或无物品可拿\n##### 场景描述：执行向后拿物品操作后，检测到第一层空格数>6。\n###### 预期结果：不再进行后续的交换操作。\n##### 场景描述：执行向后拿物品操作后，检测到第一层没有可往后拿的物品了（所有物品都是成3的组）。\n###### 预期结果：不再进行后续的交换操作。\n## 非功能测试：掉落关卡\n### 沿用旧逻辑\n##### 场景描述：当前关卡为掉落关卡。\n###### 预期结果：刷新功能使用原来的逻辑，不应用此新方案。\n## 边界与异常测试\n### 边界值：可消除组数\n##### 场景描述：第一层可消除组数 = 4（边界值，小于5）。\n###### 预期结果：进入“0<=当前第一层可消除组数<5”的分支流程。\n##### 场景描述：第一层可消除组数 = 5（边界值，等于5）且空格数=2。\n###### 预期结果：进入“当前第一层可消除组数>=5...但是0<=空格数q<3”的分支流程。\n### 边界值：空格数\n##### 场景描述：空格数 = 0。\n###### 预期结果：在相应分支下，触发腾出空格逻辑。\n##### 场景描述：空格数 = 3。\n###### 预期结果：在“空格数>=3”分支下，仅刷新位置。\n##### 场景描述：空格数 = 2（边界值，小于3）。\n###### 预期结果：在相应分支下，触发腾出空格至3的逻辑。\n### 边界值：物品数量\n##### 场景描述：第一层物品总数刚好等于可消除物品数，剩余物品数=0（<3）。\n###### 预期结果：符合“除去可消除物品后剩余物品数<3”条件，进入相应分支。\n##### 场景描述：第一层物品总数-可消除物品数 = 2（剩余物品数边界值）。\n###### 预期结果：符合“除去可消除物品后剩余物品数<3”条件，进入相应分支。\n### 异常场景：无满足条件的物品可选取\n##### 场景描述：在需要选取单独物品进行交换时，第一层不存在任何满足优先级1和优先级2条件的物品。\n###### 预期结果：逻辑应明确处理方式（如随机选取或跳过？），需补充规则。\n##### 场景描述：在需要腾出空格时，优先级列表中的所有条件都无法满足（如没有对应空格分的商品）。\n###### 预期结果：应能执行最后一级的“随机”策略。\n### 并发与重复操作\n##### 场景描述：在刷新动画执行过程中，快速连续点击刷新按钮。\n###### 预期结果：应正确处理，避免状态错乱或物品重复计算。可考虑禁用按钮或排队处理。\n##### 场景描述：网络延迟时执行刷新操作。\n###### 预期结果：应有加载状态提示，数据同步正确，避免本地与服务器状态不一致。\n### 性能测试\n##### 场景描述：场上物品数量极多，层数很深时执行刷新。\n###### 预期结果：刷新算法执行时间应在可接受范围内（如<2秒），不引起界面卡顿或ANR。\n##### 场景描述：连续多次执行刷新操作。\n###### 预期结果：内存占用平稳，无内存泄漏。', '2', 'deepseek-chat', 1, 7, 146, '未找到模型类型 [coze] 的默认配置，请先在模型配置中添加并设置为默认', '', '2026-02-16 21:28:13', '', '2026-03-09 23:37:02', NULL);
INSERT INTO `test_case` VALUES (7, '测试', 'Sheet: 新方案\n\n风扇（刷新）		\n核心思想：凑组/去单/保空格		\n每一次刷新第一层都要新增一组能消除的物品，同时为了保证空格数量，减少单独的物品，并成组的往最后放	\n		\n	\n	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)并且空格数>=3	\n	只刷新位置，结束	\nif	当前第一层可消除组数>=5(或者全部为相同物品或者除去可消除物品后剩余物品数<3)但是0<=空格数q<3		\n	挑选一个或两个或一对单独的物品，把整组扔到最后新建的一层，直到q=3					\nif			0<=当前第一层可消除组数<5	\n	把第一层非特殊货柜2的货品拿出来（如果没有选中成2的商品，就把单格货柜/刷新器加入一起选出成2的商品）	\n	看第二层有没有1能与之消除的	\n	if	有	\n		都（上限是2）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数	\n	if	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	把第一层的1拿出来，看第二层有没有2可与之消除	\nif	有	\n	都（上限是2）拿到第一层来，并与某几对或者几个单独的物品进行交换，检查当前空格数	\nif	当前层空格数<3	\n取一组或两组物品放到最后新建一层去，直到空格数>=3	\n刷新位置	\nelse	看第3层有没有能与第一层的2消除的（一般来说前两步就够了）						\n	if	有					\n		都（上限是3）拿到第一层来，并与某几个单独的物品进行交换，检查当前层空格数					\n		if	当前层空格数<3				\n				取一组或两组物品放到最后新建一层去				\n			刷新位置					\n		else	把第一层的1拿出来，看第三层有没有2可与之消除。。。。。（以此循环直到至少找到一组）					\n			。。。					\n	\n	\n注释：	1、刷新位置的逻辑	\n	只刷新可见范围内的非特殊格子		\n			\n	if	第一第二层都没有空格子	\n	刷新位置的时候保持原比例不变的情况下（只需要比例不变，不需要原组合不变），位置随机，第一二层刷新独立，没有连带关系	\n	if	第一层没空格子，第二层有空格子（第一层格子数>第二层格子数）	\n	第一层在所有格子范围内保持原比例交换，位置随机，第二层只在非空格子内交换	\n	if	第一层有空格子，第二层有空格子	\n	第一层在所有格子范围内保持原比例交换，位置随机，可以交换到空格里，但是保证第二层非空格子前有东西，第二层只在非空格格子里交换		\n	由于我们在刷新位置之前有选取整组物品往后放的操作，可能会导致某一层为空，刷新位置的时候要把尽量空格刷的均匀一点	\n	\n	\n	2、选取单独物品交换的逻辑			\n	如果是选一个或多个单独的物品进行交换	\n	选在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员	\n	如果没有满足上述条件的物品，选在第一层非特殊格子非锁链上的物品，且其至少有一个成员不在第一层，优先选没有和其其他成员放在一起（在一个格子里）的	\n				\n	3、选取单独物品并把整组往后放的逻辑														\n	如果我们要选出一个单独的物品并把整组往最后放												\n	如果拿到了有成员在刷新器或者单格移动货柜上的物品种类，把其放在最后一个，后面的补位上来，其余的1/2个成员只需要选一个格子新增一层放进去									\n	优先选取在第一层非特殊格子非锁链上的物品，并且在第一层包括锁链和特殊格子范围内没有其其余的成员，满足此条件的基础上，优先选取跨三层的物品，次之为跨两层格子的物品												\n	如果选取的物品拿走后会导致第3层及以后的层有格子为空，就在同一层拿一个单独的物品（拿完不能使任何格子为空）放进去使其不为空，如果没有满足的，就随机挑一个吧，如果一个也没有就让后一层顶上来												\n	随机挑选2个层数>=2的格子（普通格子或者传送带格子）新增一层；并挑选一组物品按照的3：0：0：0：0：1比例放到该关卡最后新增的一层												\n	如果只有一个层数>=2的格子，在这个格子新增两层												\n	如果所有格子都只有一层，随机挑选两个格子新增一层												\n	如果需要腾出一个空格，按照以下优先级	\n	1、	拿1个单独且空格分为1的商品	\n	2、	拿一组空格分为1的商品	\n	3、	拿一组空格分为2的商品	\n	4、	拿一组空格分为3的商品	\n	5、	随机挑选一个放最后，使得满足能腾出一个空格	\n	\n	如果需要腾出两个空格，按照以下优先级	\n	1、	拿一对空格分为2的商品	\n	2、	拿一组空格分为2的商品	\n	3、	拿一组空格分为3的商品	\n	4、	一组空格分为1的商品+1随机（多1空格）	\n	5、	2随机（多2空格）	\n	\n	如果需要腾出3个空格，按照以下优先级	\n	1、	拿一组空格个分为3的商品	\n	2、	拿一组空格分为2的商品+1组空格分为1的商品	\n	3、	拿一组空格分为2的商品+1随机（多1空格）	\n	4、	拿3组空格分为1的商品	\n	5、	拿1组空格分为1的商品+2随机（多2空格）	\n	6、	3随机（多3空格）	\n		\n		\n		\n对于掉落关卡			\n	掉落关卡用原来的逻辑		\n			\n			\n			\n			\n			 	\n	\n特殊情况：	1、假如最大层数为1，只能刷新位置，不做交换和往后拿的操作				\n	2、对于盲盒，刷新不改变盲盒属性			\n	3、假如第一层只有金色收集物，刷新一二层的位置			\n	4、假如只剩下金色收集物，不消耗不使用道具			\n	5、加一个检测，如果每次从后往前拿，拿完之后发现空格数足够多（空格数>6）或者第一层没有可往后拿的物品了（都是成3的）就不进行交换操作	\n', '新建 文本文档 (2).txt', '/profile/upload/2026/02/28/新建 文本文档 (2)_20260228103035A001.txt', 'txt', '# 风扇（刷新）新方案测试用例\n## 核心流程测试\n### 可消除组数>=5且空格数>=3\n#### 场景1：第一层可消除组数=5，空格数=3\n##### 场景描述：第一层物品分布满足可消除组数>=5，且当前空格数为3。\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n#### 场景2：第一层全部为相同物品，空格数=5\n##### 场景描述：第一层所有格子均为同一种物品，空格数为5。\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n#### 场景3：除去可消除物品后剩余物品数=2，空格数=4\n##### 场景描述：移除第一层所有可消除的物品组合后，剩余不可消除的单个物品数量为2，空格数为4。\n###### 预期结果：仅执行“刷新位置”逻辑，不进行物品交换或向后移动操作，流程结束。\n### 可消除组数>=5但空格数不足\n#### 场景1：可消除组数=5，空格数=0\n##### 场景描述：第一层可消除组数满足条件，但空格数为0。\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n#### 场景2：可消除组数=6，空格数=2\n##### 场景描述：第一层可消除组数为6，空格数为2。\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n#### 场景3：可消除组数>=5，空格数=1\n##### 场景描述：第一层可消除组数大于5，空格数为1。\n###### 预期结果：执行“挑选单独物品向后放”逻辑，直到空格数达到3，然后执行“刷新位置”。\n### 可消除组数<5\n#### 场景1：可消除组数=0，从第二层找到可消除的“1”\n##### 场景描述：第一层可消除组数为0。从第一层非特殊货柜2中拿出物品（若无成2商品，则加入单格货柜/刷新器一起选），在第二层找到可与之消除的“1”。\n###### 预期结果：将第二层的“1”（上限2个）拿到第一层，与第一层的单独物品交换。检查空格数，若<3，则向后移动物品组直到空格数>=3，最后刷新位置。\n#### 场景2：可消除组数=2，从第二层找到可消除的“1”\n##### 场景描述：第一层可消除组数为2。从第一层拿出“1”，在第二层找到可与之消除的“2”。\n###### 预期结果：将第二层的“2”（上限2个）拿到第一层，与第一层的成对或单独物品交换。检查空格数，若<3，则向后移动物品组直到空格数>=3，最后刷新位置。\n#### 场景3：可消除组数=4，需从第三层查找可消除组合\n##### 场景描述：第一层可消除组数为4，在第一、二层均未找到可消除组合，需在第三层查找能与第一层“2”消除的物品。\n###### 预期结果：将第三层的物品（上限3个）拿到第一层交换。检查空格数，若<3，则向后移动物品组直到空格数>=3，最后刷新位置。\n#### 场景4：可消除组数=3，循环查找直到找到一组\n##### 场景描述：第一层可消除组数为3，按照逻辑依次在第一、二、三层...查找，直到至少找到一组可消除组合。\n###### 预期结果：成功找到一组可消除组合，执行相应的交换、空格检查和向后移动操作，最后刷新位置。\n## 刷新位置逻辑测试\n### 第一第二层均无空格\n#### 场景1：两层格子全满，独立随机刷新\n##### 场景描述：第一层和第二层所有格子均有物品，无空格。\n###### 预期结果：第一层和第二层独立刷新位置，保持各自层内原有物品比例不变，位置随机。两层间无连带关系。\n### 第一层无空格，第二层有空格\n#### 场景1：第一层格子数>第二层格子数\n##### 场景描述：第一层所有格子有物品，第二层存在空格子，且第一层格子数量大于第二层。\n###### 预期结果：第一层在所有格子范围内保持原比例随机交换位置。第二层仅在非空格子内进行物品交换。\n### 第一层有空格，第二层有空格\n#### 场景1：两层均有空格，保证第二层非空格前有物品\n##### 场景描述：第一层和第二层均存在空格子。\n###### 预期结果：第一层在所有格子（包括空格）范围内保持原比例随机交换。第二层仅在非空格子内交换，且需保证第二层非空格子前有物品（即空格不能出现在所有非空格子之前？需澄清逻辑）。\n### 某层为空时的刷新\n#### 场景1：因向后放操作导致第二层为空\n##### 场景描述：在“选取整组物品往后放”操作后，第二层变为空层。\n###### 预期结果：刷新位置时，需尽量将空格刷得均匀分布。\n## 选取单独物品交换逻辑测试\n### 优先级1：完全独立的物品\n#### 场景1：存在在第一层非特殊、非锁链上，且同层无其他成员的物品\n##### 场景描述：第一层存在一个物品，其所在格子非特殊格、非锁链格，且在第一层（包括锁链和特殊格）范围内没有该物品的其他成员。\n###### 预期结果：成功选中该物品用于交换。\n### 优先级2：成员不全在第一层的物品\n#### 场景1：无优先级1物品，存在成员在其它层的物品\n##### 场景描述：没有满足优先级1的物品。存在一个在第一层非特殊、非锁链上的物品，其至少有一个成员不在第一层。\n###### 预期结果：优先选中那些“没有和其其他成员放在一起（在一个格子里）”的物品用于交换。\n## 选取物品整组往后放逻辑测试\n### 处理刷新器或单格移动货柜上的成员\n#### 场景1：选中物品的成员在刷新器上\n##### 场景描述：选中的“单独物品”，其有成员位于刷新器上。\n###### 预期结果：将该物品种类整体放在最后，后面的物品补位。其余的1/2个成员只需选一个格子新增一层放入。\n### 选取物品的优先级\n#### 场景1：存在跨三层的完全独立物品\n##### 场景描述：存在满足“在第一层非特殊非锁链上，且同层无其他成员”的物品A，且物品A的成员分布在三层中。\n###### 预期结果：优先选取物品A。\n#### 场景2：存在跨两层的完全独立物品\n##### 场景描述：存在满足“在第一层非特殊非锁链上，且同层无其他成员”的物品B，且物品B的成员分布在两层中。\n###### 预期结果：次优先选取物品B。\n### 填补拿走后产生的空层\n#### 场景1：拿走物品导致第三层出现空格\n##### 场景描述：选取并拿走第一层一个物品后，导致第三层某个格子变为空。\n###### 预期结果：在同一层（第三层）寻找一个单独的物品（拿走不会导致任何格子为空）放入该空格。若无，则随机挑选一个物品放入。若一个也没有，则让后一层顶上来。\n### 新增层与放置物品\n#### 场景1：存在两个层数>=2的格子\n##### 场景描述：存在两个普通格或传送带格，其层数大于等于2。\n###### 预期结果：随机挑选这两个格子，各新增一层。挑选一组物品按3:0:0:0:0:1的比例放到关卡最后新增的一层。\n#### 场景2：只有一个层数>=2的格子\n##### 场景描述：只有一个格子的层数大于等于2。\n###### 预期结果：在该格子新增两层。\n#### 场景3：所有格子都只有一层\n##### 场景描述：所有格子当前都只有一层物品。\n###### 预期结果：随机挑选两个格子，各新增一层。\n### 腾出空格优先级逻辑\n#### 场景1：需要腾出1个空格\n##### 场景描述：当前需要腾出1个空格。\n###### 预期结果：按优先级尝试：1)拿1个单独且空格分为1的商品 -> 2)拿一组空格分为1的商品 -> 3)拿一组空格分为2的商品 -> 4)拿一组空格分为3的商品 -> 5)随机挑选一个放最后。\n#### 场景2：需要腾出2个空格\n##### 场景描述：当前需要腾出2个空格。\n###### 预期结果：按优先级尝试：1)拿一对空格分为2的商品 -> 2)拿一组空格分为2的商品 -> 3)拿一组空格分为3的商品 -> 4)一组空格分为1的商品+1随机 -> 5)2随机。\n#### 场景3：需要腾出3个空格\n##### 场景描述：当前需要腾出3个空格。\n###### 预期结果：按优先级尝试：1)拿一组空格分为3的商品 -> 2)拿一组空格分为2的商品+1组空格分为1的商品 -> 3)拿一组空格分为2的商品+1随机 -> 4)拿3组空格分为1的商品 -> 5)拿1组空格分为1的商品+2随机 -> 6)3随机。\n## 特殊情况测试\n### 最大层数为1\n#### 场景1：关卡最大层数限制为1\n##### 场景描述：当前关卡设置的最大层数为1。\n###### 预期结果：只能执行“刷新位置”操作，不进行任何物品交换或向后拿的操作。\n### 盲盒处理\n#### 场景1：刷新操作涉及盲盒格子\n##### 场景描述：第一层或第二层中存在盲盒格子。\n###### 预期结果：执行刷新位置操作后，盲盒的“未打开”属性保持不变。\n### 第一层只有金色收集物\n#### 场景1：第一层所有格子均为金色收集物\n##### 场景描述：第一层可放置物品的格子中全部是金色收集物。\n###### 预期结果：仅刷新第一层和第二层的位置。\n### 只剩下金色收集物\n#### 场景1：全场所有层只剩下金色收集物\n##### 场景描述：经过若干操作后，场上所有格子物品均为金色收集物。\n###### 预期结果：不消耗也不使用任何道具，刷新操作可能不执行或无效（需根据具体规则澄清）。\n### 检测机制\n#### 场景1：向后拿操作后空格数>6\n##### 场景描述：执行从后往前拿物品的操作后，检测到当前空格数大于6。\n###### 预期结果：不再进行后续的交换操作。\n#### 场景2：向后拿操作后第一层无可往后拿的物品\n##### 场景描述：执行从后往前拿物品的操作后，检测到第一层所有物品都是“成3”的完整组合。\n###### 预期结果：不再进行后续的交换操作。\n## 掉落关卡\n### 沿用旧逻辑\n#### 场景1：在掉落关卡中使用刷新功能\n##### 场景描述：当前关卡为掉落关卡，玩家使用刷新功能。\n###### 预期结果：刷新逻辑使用原来的（非本新方案的）逻辑进行处理。\n## 边界与异常测试\n### 空格数边界\n#### 场景1：空格数刚好等于3\n##### 场景描述：各种判断分支下，空格数恰好为3。\n###### 预期结果：逻辑正确判断，执行对应分支（如不向后拿或直接刷新位置）。\n#### 场景2：空格数为负数或异常值\n##### 场景描述：因未知BUG导致空格数计算为负或异常大数。\n###### 预期结果：系统应有健壮性处理，避免崩溃，可能视为0处理或抛出可处理的错误。\n### 可消除组数计算\n#### 场景1：可消除组数计算包含特殊格子\n##### 场景描述：计算第一层可消除组数时，包含或排除特殊格子（如锁链、刷新器）上的物品。\n###### 预期结果：根据需求定义，明确计算规则并保持一致。\n#### 场景2：复杂物品布局下的组数计算\n##### 场景描述：第一层物品布局复杂，存在交叉、重叠的可消除可能性。\n###### 预期结果：算法能正确识别所有不重叠的最大可消除组数。\n### 交换操作并发与状态\n#### 场景1：连续快速点击刷新\n##### 场景描述：在刷新动画或逻辑执行过程中，玩家再次点击刷新按钮。\n###### 预期结果：应阻止重复触发，或在当前刷新完成后才接受下一次指令，避免状态错乱。\n#### 场景2：网络延迟下的刷新\n##### 场景描述：在弱网环境下执行刷新操作。\n###### 预期结果：应有加载状态提示，操作结果最终能正确同步到服务器和客户端。\n### 数据一致性\n#### 场景1：刷新后物品总数检查\n##### 场景描述：执行完一套完整的刷新逻辑（可能包含新增层、移动物品）。\n###### 预期结果：关卡内物品总数应保持不变（金色收集物除外，如果其规则特殊）。\n#### 场景2：层高限制检查\n##### 场景描述：在执行“新增一层”操作时，当前层数已接近或达到关卡最大层数限制。\n###### 预期结果：逻辑应能正确处理，不能新增超过最大层数的层。', '2', 'deepseek-chat', 1, 7, 141, '400 Bad Request: \"{<EOL>  \"error\": {<EOL>    \"message\": \"Unsupported parameter: \'temperature\' is not supported with this model.\",<EOL>    \"type\": \"invalid_request_error\",<EOL>    \"param\": \"temperature\",<EOL>    \"code\": null<EOL>  }<EOL>}\"', '', '2026-02-28 10:30:35', '', '2026-03-09 23:34:49', NULL);
INSERT INTO `test_case` VALUES (8, '传送带礼包', 'Sheet: Sheet1\n\n活动时间	按照星期作为一个循环，进行3型+6型无尽礼包的开启和结束，两种类型为同一个活动，所以不会同时出现，需要区分当前活动的版本号	\n	时间与玩家开启金色收集物时间保持一致，并根据时间进行活动的循环	\n	根据金色收集物倒计时剩余时间来切换3型和6型无尽礼包	\n	3型传送带持续时间：4天；6型传送带持续时间：3天	\n	7d ≥ 3型 > 3d ; 3d ≥ 6型 > 0d0h	\n倒计时	3型传送带倒计时需要在数字上 -3，比如剩下金色收集物剩余时间6天6小时，那么三型传送带剩余时间3天6小时	\n	6型时间与金色收集物倒计时时间相等	\n解锁关卡	完成27关	\n活动入口	右侧第三位（如果出现通行证活动后，位置向下顺延）	\n引导	当活动开始后（3型无尽礼包或6型无尽礼包），玩家第一次进入游戏，或从其他页面（关卡页面、商城等）返回主页面，主动弹出此活动弹窗	\n	每次活动从开始到结束仅主动弹出一次	\n活动开启	当玩家在主页面时活动开启，直接出现活动图标，此时需要记录一个事件节点：下次冷启动、从其他页面返回主页面	\n	在该事件发生前，如果玩家点击了活动图标，则本次活动开启到结束期间不需要主动弹出活动弹窗	\n	否则，在该事件发生时，主动弹活动弹窗	\n活动结束	当玩家不在活动页面，则主界面图标消失，下个活动开启（比如3型无尽礼包图标消失，6型无尽礼包图标出现）	\n	当活动结束，玩家在活动页面时，倒计时变为“finished”，未领取的奖励仍可以继续领取，玩家退出界面后，则主界面图标消失，下个无尽礼包开启	\n	3型无尽礼包到期时自动切换为6型无尽礼包的入口，玩家有免费奖励没领取时也将无法领取	\n	异常说明：当到达无尽礼包切换时间节点，但是玩家未联网的状态，倒计时仍变为“finished”，关闭页面后图标消失，但不会拉取新一轮的无尽礼包活动，直到玩家联网后拉取活动并展示对应图标和时间	\n活动规则	三型无尽礼包按照顺序从上到下购买/领取	\n	三型无尽礼包的特殊说明：无尽礼包的颜色仅三种，当最上面的格子消失，下一格格子移动时，颜色会跟随变化，如右侧视频，弹出动画和视频保持一致	\n	六型无尽礼包按照“S”形顺序，从左上开始领取	\n	当玩家没有领取顺序上的第一格奖励时，点击后面几个格子上的按钮，弹出提示“Claim previous offer to unlock.”	\n	如果当前可点击的按钮为\"Free\"，玩家点击即领取对应的奖励，无尽礼包根据顺序移动，已领取的格子消失，同时下一个格子上的“锁”图标打开，并移动到可点击的第一位	\n	免费奖励的领取不受网络的限制	\n	如果当前可点击的按钮为价格，需要判断当前是否联网，已联网的状态下可以正常跳转至支付页面，未联网时，弹出提示“Please connect to the Internet and try again.”	\n	当玩家点击付费按钮，完成付费后，弹出【完成付费弹窗】，点击关闭或继续按钮，均回到活动页面并自动领取对应的奖励	\n	当玩家点击付费按钮，取消付费后，弹出【取消付费弹窗】，点击关闭或继续按钮，均回到活动页面	\n宝箱规则	玩家点击宝箱，弹出气泡，展示宝箱中的道具信息及数量，再次点击任意位置气泡消失	\n	如果有气泡在展示时，玩家点击了另外一个宝箱，则先前的气泡消失，展示当前点击的宝箱气泡	\n	气泡的展示规则，仅第一列的气泡箭头朝上弹出（气泡在下），其余列箭头朝下弹出（气泡在上）	\n	当一个格子内的奖励大于3个时，出现宝箱，并将道具奖励以宝箱的形式展示	\n玩家付费等级对活动的影响	大R、中R用户在进入活动页面时，无0.99$的礼包及奖励	\n	当第一次活动开启时，根据玩家的消费等级展示对应的礼包档位	\n	当玩家在此活动中累计充值$10以上时，不展示0.99$的礼包及奖励	\n		\n		\n		\n\nSheet: Sheet2\n\n\nSheet: Sheet3\n\n\n', '传送带礼包.xlsx', '/profile/upload/2026/03/10/传送带礼包_20260310101039A001.xlsx', 'xlsx', '# 无尽礼包活动测试用例设计\n## 活动时间与切换逻辑\n### 活动周期与版本切换\n#### 验证活动按金色收集物时间循环开启\n##### 场景描述：金色收集物倒计时剩余时间大于7天，进入游戏\n###### 预期结果：不显示无尽礼包活动入口\n##### 场景描述：金色收集物倒计时剩余时间在(3天, 7天]区间内，进入游戏\n###### 预期结果：显示3型无尽礼包活动入口，活动倒计时 = 金色收集物倒计时 - 3天\n##### 场景描述：金色收集物倒计时剩余时间在(0天0小时, 3天]区间内，进入游戏\n###### 预期结果：显示6型无尽礼包活动入口，活动倒计时 = 金色收集物倒计时\n#### 验证3型与6型活动互斥\n##### 场景描述：当前为3型无尽礼包活动期间\n###### 预期结果：主界面只显示3型活动入口，不显示6型活动入口\n##### 场景描述：当前为6型无尽礼包活动期间\n###### 预期结果：主界面只显示6型活动入口，不显示3型活动入口\n#### 验证活动持续时间\n##### 场景描述：3型无尽礼包活动开启，持续观察倒计时\n###### 预期结果：活动持续显示4天后自动结束/切换\n##### 场景描述：6型无尽礼包活动开启，持续观察倒计时\n###### 预期结果：活动持续显示3天后自动结束/切换\n### 倒计时显示规则\n#### 验证3型活动倒计时计算\n##### 场景描述：金色收集物剩余时间为6天6小时，查看3型活动倒计时\n###### 预期结果：3型活动倒计时显示为3天6小时\n##### 场景描述：金色收集物剩余时间为4天0小时，查看3型活动倒计时\n###### 预期结果：3型活动倒计时显示为1天0小时\n##### 场景描述：金色收集物剩余时间为3天1小时，查看3型活动倒计时\n###### 预期结果：3型活动倒计时显示为0天1小时（边界值：3型活动应已结束，切换为6型）\n#### 验证6型活动倒计时计算\n##### 场景描述：金色收集物剩余时间为2天23小时59分，查看6型活动倒计时\n###### 预期结果：6型活动倒计时显示为2天23小时59分\n##### 场景描述：金色收集物剩余时间为0天0小时1分，查看6型活动倒计时\n###### 预期结果：6型活动倒计时显示为0天0小时1分\n## 活动入口与引导\n### 解锁与入口位置\n#### 验证活动解锁条件\n##### 场景描述：玩家关卡进度为26关，进入游戏\n###### 预期结果：主界面不显示无尽礼包活动入口\n##### 场景描述：玩家关卡进度为27关，进入游戏\n###### 预期结果：主界面显示无尽礼包活动入口\n#### 验证入口位置排序\n##### 场景描述：无通行证活动，玩家已解锁无尽礼包，进入主界面\n###### 预期结果：无尽礼包入口位于右侧第三位（从右向左数）\n##### 场景描述：存在通行证活动，玩家已解锁无尽礼包，进入主界面\n###### 预期结果：无尽礼包入口位于右侧第四位（在通行证活动下方）\n### 活动弹窗引导\n#### 验证活动开始时的主动弹窗（首次触发）\n##### 场景描述：3型/6型活动开始后，玩家首次冷启动游戏\n###### 预期结果：进入主界面时，主动弹出对应无尽礼包活动弹窗\n##### 场景描述：3型/6型活动开始后，玩家从关卡页面返回主页面\n###### 预期结果：返回主界面时，主动弹出对应无尽礼包活动弹窗\n##### 场景描述：3型/6型活动开始后，玩家从商城页面返回主页面\n###### 预期结果：返回主界面时，主动弹出对应无尽礼包活动弹窗\n#### 验证弹窗仅出现一次的限制\n##### 场景描述：活动开始后，玩家冷启动看到弹窗并关闭，再次从关卡返回主页面\n###### 预期结果：不再弹出活动弹窗\n##### 场景描述：活动开始后，玩家未触发弹窗前，主动点击了主界面活动图标并进入\n###### 预期结果：本次活动期间，后续冷启动或从其他页面返回均不再弹出活动弹窗\n##### 场景描述：活动开始后，玩家触发了一次弹窗，活动结束后新一轮活动开始\n###### 预期结果：新一轮活动开始后，首次触发条件满足时会再次弹出新活动的弹窗\n## 活动开启与结束逻辑\n### 活动开启记录与判断\n#### 验证活动开启时图标的出现\n##### 场景描述：玩家在主页面时，活动开启时间点到达\n###### 预期结果：主页面立即出现活动图标\n#### 验证“事件节点”的记录与触发\n##### 场景描述：活动开启时玩家就在主页面（图标出现），随后玩家点击图标进入活动\n###### 预期结果：记录“已点击图标”状态，后续冷启动或返回主页面不弹窗\n##### 场景描述：活动开启时玩家就在主页面（图标出现），玩家未点击图标，直接冷启动游戏\n###### 预期结果：冷启动进入主界面时，弹出活动弹窗\n##### 场景描述：活动开启时玩家就在主页面（图标出现），玩家未点击图标，从商城返回主页面\n###### 预期结果：返回主界面时，弹出活动弹窗\n### 活动结束与切换\n#### 验证玩家不在活动页面时的结束\n##### 场景描述：3型活动倒计时结束，玩家正在主界面或关卡界面\n###### 预期结果：3型活动图标立即消失，6型活动图标出现\n#### 验证玩家在活动页面时的结束\n##### 场景描述：3型活动倒计时结束，玩家正在3型活动页面内\n###### 预期结果：页面倒计时显示变为“finished”，玩家仍可领取未领奖励\n##### 场景描述：3型活动倒计时结束，玩家正在3型活动页面内，领取剩余奖励后退出页面\n###### 预期结果：退出后，主界面3型图标消失，6型图标出现\n##### 场景描述：3型活动倒计时结束，玩家正在3型活动页面内，有免费奖励未领取，直接退出页面\n###### 预期结果：退出后，主界面3型图标消失，6型图标出现，未领取的免费奖励无法再领取\n#### 验证活动切换\n##### 场景描述：3型无尽礼包活动到期\n###### 预期结果：主界面活动入口自动切换为6型无尽礼包\n#### 验证断网下的异常结束逻辑\n##### 场景描述：到达3型切6型的时间节点，设备处于断网状态，玩家在活动页面\n###### 预期结果：活动页面倒计时变为“finished”\n##### 场景描述：到达3型切6型的时间节点，设备处于断网状态，玩家关闭活动页面回到主界面\n###### 预期结果：主界面3型活动图标消失，且不显示6型活动图标\n##### 场景描述：上述断网场景下，玩家重新连接网络\n###### 预期结果：拉取到6型活动数据，主界面显示6型活动图标及正确倒计时\n## 活动规则与交互\n### 礼包领取顺序与状态\n#### 验证3型无尽礼包领取顺序\n##### 场景描述：进入3型活动页面，从上到下有三个带锁格子\n###### 预期结果：仅最顶部的格子解锁可点击，下方格子显示锁定状态\n##### 场景描述：领取3型活动第一个免费奖励\n###### 预期结果：第一个格子消失，第二个格子移动至顶部并解锁，第三个格子移动至第二位但仍锁定\n#### 验证3型无尽礼包颜色变化\n##### 场景描述：3型活动初始三个格子颜色为红、蓝、黄（示例），领取顶部红色格子奖励\n###### 预期结果：红色格子消失，原第二个蓝色格子移动至顶部并变为红色，原第三个黄色格子移动至第二位并变为蓝色\n#### 验证6型无尽礼包领取顺序（S形）\n##### 场景描述：进入6型活动页面，礼包以2x3网格排列\n###### 预期结果：仅左上角第一个格子解锁可点击，其他格子锁定\n##### 场景描述：领取6型活动左上角（第一行第一列）奖励\n###### 预期结果：该格子消失，解锁顺序按S形（第一行第二列）移动到下一个格子\n##### 场景描述：领取完6型活动第一行所有奖励\n###### 预期结果：解锁顺序跳转至第二行最右侧格子，继续向左S形进行\n#### 验证顺序领取限制\n##### 场景描述：在3型/6型活动中，未领取第一个奖励时，点击第二个锁定的格子\n###### 预期结果：弹出提示“Claim previous offer to unlock.”\n##### 场景描述：在3型/6型活动中，已领取前N个奖励，点击第N+1个已解锁的格子\n###### 预期结果：正常弹出该格子的奖励信息或购买按钮\n### 奖励领取与付费\n#### 验证免费奖励领取\n##### 场景描述：点击当前可领取格子上的“Free”按钮（设备联网）\n###### 预期结果：成功领取奖励，格子消失，下一个格子解锁并移动到位\n##### 场景描述：点击当前可领取格子上的“Free”按钮（设备断网）\n###### 预期结果：成功领取奖励，格子消失，下一个格子解锁并移动到位（不受网络限制）\n#### 验证付费奖励购买流程\n##### 场景描述：点击当前可领取格子上的价格按钮（设备联网）\n###### 预期结果：正常跳转至支付页面（如App Store/Google Play）\n##### 场景描述：点击当前可领取格子上的价格按钮（设备断网）\n###### 预期结果：弹出提示“Please connect to the Internet and try again.”\n##### 场景描述：在支付页面完成付费\n###### 预期结果：弹出【完成付费弹窗】，点击关闭或继续按钮后返回活动页面并自动领取对应奖励\n##### 场景描述：在支付页面取消付费\n###### 预期结果：弹出【取消付费弹窗】，点击关闭或继续按钮后返回活动页面，奖励未领取\n### 宝箱与气泡交互\n#### 验证宝箱显示条件\n##### 场景描述：某个格子内包含1个道具奖励\n###### 预期结果：直接显示该道具图标，不显示宝箱\n##### 场景描述：某个格子内包含3个道具奖励\n###### 预期结果：直接显示3个道具图标，不显示宝箱\n##### 场景描述：某个格子内包含4个道具奖励\n###### 预期结果：显示一个宝箱图标\n#### 验证宝箱气泡交互\n##### 场景描述：点击宝箱格子\n###### 预期结果：弹出气泡，展示宝箱内所有道具信息及数量\n##### 场景描述：宝箱气泡弹出后，点击界面任意其他位置\n###### 预期结果：气泡消失\n##### 场景描述：点击宝箱A弹出气泡，不关闭气泡直接点击宝箱B\n###### 预期结果：宝箱A的气泡消失，同时弹出宝箱B的气泡\n#### 验证气泡弹出方向\n##### 场景描述：点击第一列（最左侧列）的宝箱\n###### 预期结果：气泡在宝箱下方弹出，箭头朝上\n##### 场景描述：点击第二列或更右侧列的宝箱\n###### 预期结果：气泡在宝箱上方弹出，箭头朝下\n## 付费等级与商业化\n### 验证玩家付费等级对礼包展示的影响\n#### 验证大R/中R用户初始状态\n##### 场景描述：大R用户（历史高付费）首次进入活动页面（3型或6型）\n###### 预期结果：活动列表中不包含价格为$0.99的礼包及其奖励格子\n##### 场景描述：中R用户（历史中付费）首次进入活动页面\n###### 预期结果：活动列表中不包含价格为$0.99的礼包及其奖励格子\n##### 场景描述：小R/非R用户（低/无付费）首次进入活动页面\n###### 预期结果：活动列表中包含价格为$0.99的礼包及其奖励格子\n#### 验证活动内累计充值的影响\n##### 场景描述：小R用户在本次无尽礼包活动中累计充值达到$10\n###### 预期结果：刷新活动页面后，$0.99的礼包及其奖励格子从列表中消失\n##### 场景描述：小R用户在本次无尽礼包活动中累计充值$9.99\n###### 预期结果：$0.99的礼包及其奖励格子仍然显示\n##### 场景描述：玩家在3型活动中累计充值$10，切换到6型活动\n###### 预期结果：进入6型活动页面，不显示$0.99的礼包', '2', 'deepseek-chat', 1, 7, 105, NULL, '', '2026-03-10 10:10:40', '', NULL, NULL);
INSERT INTO `test_case` VALUES (9, '传送带礼包2', 'Sheet: Sheet1\n\n活动时间	按照星期作为一个循环，进行3型+6型无尽礼包的开启和结束，两种类型为同一个活动，所以不会同时出现，需要区分当前活动的版本号	\n	时间与玩家开启金色收集物时间保持一致，并根据时间进行活动的循环	\n	根据金色收集物倒计时剩余时间来切换3型和6型无尽礼包	\n	3型传送带持续时间：4天；6型传送带持续时间：3天	\n	7d ≥ 3型 > 3d ; 3d ≥ 6型 > 0d0h	\n倒计时	3型传送带倒计时需要在数字上 -3，比如剩下金色收集物剩余时间6天6小时，那么三型传送带剩余时间3天6小时	\n	6型时间与金色收集物倒计时时间相等	\n解锁关卡	完成27关	\n活动入口	右侧第三位（如果出现通行证活动后，位置向下顺延）	\n引导	当活动开始后（3型无尽礼包或6型无尽礼包），玩家第一次进入游戏，或从其他页面（关卡页面、商城等）返回主页面，主动弹出此活动弹窗	\n	每次活动从开始到结束仅主动弹出一次	\n活动开启	当玩家在主页面时活动开启，直接出现活动图标，此时需要记录一个事件节点：下次冷启动、从其他页面返回主页面	\n	在该事件发生前，如果玩家点击了活动图标，则本次活动开启到结束期间不需要主动弹出活动弹窗	\n	否则，在该事件发生时，主动弹活动弹窗	\n活动结束	当玩家不在活动页面，则主界面图标消失，下个活动开启（比如3型无尽礼包图标消失，6型无尽礼包图标出现）	\n	当活动结束，玩家在活动页面时，倒计时变为“finished”，未领取的奖励仍可以继续领取，玩家退出界面后，则主界面图标消失，下个无尽礼包开启	\n	3型无尽礼包到期时自动切换为6型无尽礼包的入口，玩家有免费奖励没领取时也将无法领取	\n	异常说明：当到达无尽礼包切换时间节点，但是玩家未联网的状态，倒计时仍变为“finished”，关闭页面后图标消失，但不会拉取新一轮的无尽礼包活动，直到玩家联网后拉取活动并展示对应图标和时间	\n活动规则	三型无尽礼包按照顺序从上到下购买/领取	\n	三型无尽礼包的特殊说明：无尽礼包的颜色仅三种，当最上面的格子消失，下一格格子移动时，颜色会跟随变化，如右侧视频，弹出动画和视频保持一致	\n	六型无尽礼包按照“S”形顺序，从左上开始领取	\n	当玩家没有领取顺序上的第一格奖励时，点击后面几个格子上的按钮，弹出提示“Claim previous offer to unlock.”	\n	如果当前可点击的按钮为\"Free\"，玩家点击即领取对应的奖励，无尽礼包根据顺序移动，已领取的格子消失，同时下一个格子上的“锁”图标打开，并移动到可点击的第一位	\n	免费奖励的领取不受网络的限制	\n	如果当前可点击的按钮为价格，需要判断当前是否联网，已联网的状态下可以正常跳转至支付页面，未联网时，弹出提示“Please connect to the Internet and try again.”	\n	当玩家点击付费按钮，完成付费后，弹出【完成付费弹窗】，点击关闭或继续按钮，均回到活动页面并自动领取对应的奖励	\n	当玩家点击付费按钮，取消付费后，弹出【取消付费弹窗】，点击关闭或继续按钮，均回到活动页面	\n宝箱规则	玩家点击宝箱，弹出气泡，展示宝箱中的道具信息及数量，再次点击任意位置气泡消失	\n	如果有气泡在展示时，玩家点击了另外一个宝箱，则先前的气泡消失，展示当前点击的宝箱气泡	\n	气泡的展示规则，仅第一列的气泡箭头朝上弹出（气泡在下），其余列箭头朝下弹出（气泡在上）	\n	当一个格子内的奖励大于3个时，出现宝箱，并将道具奖励以宝箱的形式展示	\n玩家付费等级对活动的影响	大R、中R用户在进入活动页面时，无0.99$的礼包及奖励	\n	当第一次活动开启时，根据玩家的消费等级展示对应的礼包档位	\n	当玩家在此活动中累计充值$10以上时，不展示0.99$的礼包及奖励	\n		\n		\n		\n\nSheet: Sheet2\n\n\nSheet: Sheet3\n\n\n', '传送带礼包.xlsx', '/profile/upload/2026/03/10/传送带礼包_20260310103129A001.xlsx', 'xlsx', '# 无尽礼包活动测试用例设计\n## 活动时间与循环逻辑\n### 活动周期与切换\n#### 验证活动按金色收集物时间循环开启\n##### 场景描述：金色收集物倒计时剩余时间大于7天，进入游戏\n###### 预期结果：不显示3型或6型无尽礼包活动入口\n##### 场景描述：金色收集物倒计时剩余时间在(3天, 7天]区间内，进入游戏\n###### 预期结果：显示3型无尽礼包活动入口，活动倒计时 = 金色收集物倒计时 - 3天\n##### 场景描述：金色收集物倒计时剩余时间在(0天0小时, 3天]区间内，进入游戏\n###### 预期结果：显示6型无尽礼包活动入口，活动倒计时 = 金色收集物倒计时\n#### 验证3型与6型活动不会同时出现\n##### 场景描述：在3型活动进行期间，检查主界面\n###### 预期结果：只显示3型活动入口，不显示6型活动入口\n##### 场景描述：在6型活动进行期间，检查主界面\n###### 预期结果：只显示6型活动入口，不显示3型活动入口\n#### 验证活动版本号区分\n##### 场景描述：对比3型活动与6型活动的界面UI、奖励内容、购买顺序\n###### 预期结果：3型与6型活动在界面、内容、规则上存在明显差异，可通过版本号或类型标识区分\n### 倒计时计算\n#### 验证3型活动倒计时计算\n##### 场景描述：金色收集物剩余时间为6天6小时，进入3型活动\n###### 预期结果：3型活动界面显示剩余时间为3天6小时\n##### 场景描述：金色收集物剩余时间为4天0小时，进入3型活动\n###### 预期结果：3型活动界面显示剩余时间为1天0小时\n##### 场景描述：金色收集物剩余时间为3天1小时，进入3型活动\n###### 预期结果：3型活动界面显示剩余时间为0天1小时（边界值）\n#### 验证6型活动倒计时计算\n##### 场景描述：金色收集物剩余时间为2天12小时，进入6型活动\n###### 预期结果：6型活动界面显示剩余时间为2天12小时\n##### 场景描述：金色收集物剩余时间为0天1小时，进入6型活动\n###### 预期结果：6型活动界面显示剩余时间为0天1小时（边界值）\n## 活动入口与引导\n### 解锁条件\n#### 验证活动入口解锁条件\n##### 场景描述：玩家关卡进度为26关，进入主界面\n###### 预期结果：主界面右侧不显示无尽礼包活动入口\n##### 场景描述：玩家关卡进度为27关，进入主界面\n###### 预期结果：主界面右侧第三位（或无通行证时顺延后的正确位置）显示无尽礼包活动入口\n### 入口位置\n#### 验证入口位置排序\n##### 场景描述：当前无通行证活动，玩家已解锁活动，进入主界面\n###### 预期结果：活动入口位于主界面右侧按钮区域的第三位\n##### 场景描述：当前有通行证活动，玩家已解锁活动，进入主界面\n###### 预期结果：活动入口位于主界面右侧按钮区域的第四位（在通行证下方）\n### 活动弹窗引导\n#### 验证活动开始时的主动弹窗（首次进入）\n##### 场景描述：3型活动开启后，玩家首次冷启动游戏进入主界面\n###### 预期结果：主动弹出3型无尽礼包活动介绍弹窗\n##### 场景描述：6型活动开启后，玩家从商城页面返回主界面\n###### 预期结果：主动弹出6型无尽礼包活动介绍弹窗\n#### 验证弹窗触发次数限制\n##### 场景描述：活动开启后，玩家首次进入主界面看到弹窗，关闭后再次从关卡返回主界面\n###### 预期结果：不再主动弹出活动弹窗\n##### 场景描述：活动开启后，玩家在首次进入主界面前，先手动点击了活动入口图标并进入活动页面，然后返回主界面\n###### 预期结果：本次活动周期内，不再主动弹出活动弹窗\n#### 验证弹窗触发的事件节点记录\n##### 场景描述：活动开启时玩家在线，但未触发“首次进入”或“从其他页面返回”事件，直接点击了活动图标\n###### 预期结果：记录“已点击图标”状态，后续冷启动或从其他页面返回时不再弹窗\n##### 场景描述：活动开启时玩家不在线，上线后首次进入主界面\n###### 预期结果：主动弹出活动弹窗\n## 活动开启与结束\n### 活动开启逻辑\n#### 验证活动图标显示时机\n##### 场景描述：玩家在主页面时，活动开启时间到达\n###### 预期结果：主页面立即显示对应的无尽礼包活动图标\n##### 场景描述：玩家在关卡内时，活动开启时间到达，完成后返回主页面\n###### 预期结果：返回主页面时显示活动图标，并根据事件节点判断是否弹窗\n### 活动结束与切换\n#### 验证玩家不在活动页面时的结束逻辑\n##### 场景描述：6型活动倒计时结束，玩家正在关卡页面\n###### 预期结果：返回主页面时，6型活动图标消失；若满足条件，3型活动图标出现\n#### 验证玩家在活动页面时的结束逻辑\n##### 场景描述：3型活动倒计时结束，玩家正在3型活动页面内\n###### 预期结果：活动页面倒计时显示为“finished”，玩家仍可领取未领取的奖励；退出活动页面后，主界面3型图标消失\n##### 场景描述：3型活动倒计时结束，玩家正在3型活动页面内，领取完所有奖励后退出\n###### 预期结果：退出后主界面3型图标消失，若满足条件，6型图标出现\n#### 验证活动类型自动切换\n##### 场景描述：3型无尽礼包持续时间（4天）结束，金色收集物时间满足6型条件\n###### 预期结果：主界面活动图标自动从3型切换为6型\n##### 场景描述：3型无尽礼包到期切换6型时，玩家有3型的免费奖励未领取\n###### 预期结果：无法再领取3型的免费奖励，活动已切换为6型\n#### 验证断网下的活动切换异常处理\n##### 场景描述：到达活动切换时间节点时，设备处于断网状态\n###### 预期结果：当前活动页面倒计时变为“finished”，关闭页面后图标消失，但不会拉取和展示新一轮活动图标\n##### 场景描述：到达活动切换时间节点时断网，图标消失后，重新连接网络\n###### 预期结果：拉取最新的活动信息，并在主界面展示对应类型的活动图标和正确倒计时\n## 活动规则与交互\n### 奖励领取顺序\n#### 验证3型无尽礼包领取顺序\n##### 场景描述：进入3型活动页面，按照从上到下的顺序依次点击“Free”按钮\n###### 预期结果：每次点击领取当前第一格的奖励，该格消失，下方格子依次上移，颜色跟随变化，下一个格子的锁打开\n##### 场景描述：进入3型活动页面，不领取第一格奖励，直接点击第二格的按钮\n###### 预期结果：弹出提示“Claim previous offer to unlock.”，无法领取\n#### 验证6型无尽礼包领取顺序\n##### 场景描述：进入6型活动页面，按照“S”形顺序（左上->右上->左中...）依次点击“Free”按钮\n###### 预期结果：每次点击领取顺序上的第一格奖励，该格消失，下一个格子的锁打开并移动到可点击的第一位\n##### 场景描述：进入6型活动页面，不领取“S”形顺序上的第一格奖励，点击后面的格子按钮\n###### 预期结果：弹出提示“Claim previous offer to unlock.”，无法领取\n### 格子移动与动画\n#### 验证3型礼包格子移动与颜色变化\n##### 场景描述：领取3型活动的第一个免费奖励\n###### 预期结果：第一个格子以指定动画效果消失，第二个格子移动到顶部，并且其颜色变为原第一格的颜色（遵循三种颜色循环）\n##### 场景描述：连续领取3型活动的多个奖励，观察颜色变化\n###### 预期结果：格子的颜色始终在三种预设颜色中循环变化，与参考视频一致\n### 免费奖励领取\n#### 验证免费奖励领取逻辑\n##### 场景描述：点击当前可点击的“Free”按钮，设备联网正常\n###### 预期结果：成功领取奖励，格子移动，下一个奖励解锁\n##### 场景描述：点击当前可点击的“Free”按钮，设备断网\n###### 预期结果：成功领取奖励，格子移动，下一个奖励解锁（免费领取不受网络限制）\n### 付费流程\n#### 验证付费按钮点击逻辑（联网）\n##### 场景描述：点击当前可点击的付费按钮（如$4.99），设备联网\n###### 预期结果：正常跳转至支付页面（如App Store/Google Play）\n#### 验证付费按钮点击逻辑（断网）\n##### 场景描述：点击当前可点击的付费按钮，设备断网\n###### 预期结果：弹出提示“Please connect to the Internet and try again.”，不跳转支付\n#### 验证付费成功处理\n##### 场景描述：点击付费按钮，在支付页面完成支付\n###### 预期结果：弹出【完成付费弹窗】，点击弹窗的“关闭”或“继续”按钮后，返回活动页面并自动领取该付费格子的奖励\n#### 验证付费取消处理\n##### 场景描述：点击付费按钮，在支付页面取消支付\n###### 预期结果：弹出【取消付费弹窗】，点击弹窗的“关闭”或“继续”按钮后，返回活动页面，未领取奖励\n## 宝箱规则\n### 宝箱点击与气泡展示\n#### 验证宝箱点击交互\n##### 场景描述：点击一个包含多个奖励的宝箱格子\n###### 预期结果：弹出气泡，展示该宝箱内所有道具的图标和数量\n##### 场景描述：点击宝箱弹出气泡后，点击界面任意其他位置\n###### 预期结果：气泡消失\n##### 场景描述：点击宝箱A弹出气泡，不关闭气泡，直接点击宝箱B\n###### 预期结果：宝箱A的气泡消失，同时展示宝箱B的气泡\n#### 验证气泡弹出方向\n##### 场景描述：点击第一列（最左侧一列）的宝箱\n###### 预期结果：气泡在宝箱下方弹出，箭头朝上\n##### 场景描述：点击第二列及之后列的宝箱\n###### 预期结果：气泡在宝箱上方弹出，箭头朝下\n#### 验证宝箱出现条件\n##### 场景描述：查看一个格子内奖励道具数量为2个\n###### 预期结果：该格子直接展示2个道具图标，无宝箱\n##### 场景描述：查看一个格子内奖励道具数量为4个\n###### 预期结果：该格子显示一个宝箱图标，点击后气泡内展示4个道具信息\n## 付费等级与礼包展示\n### 初始礼包展示规则\n#### 验证大R用户初始礼包\n##### 场景描述：付费等级为大R的用户，首次进入3型或6型活动页面\n###### 预期结果：活动页面中不展示价格为$0.99的礼包及其对应奖励格子\n#### 验证中R用户初始礼包\n##### 场景描述：付费等级为中R的用户，首次进入3型或6型活动页面\n###### 预期结果：活动页面中不展示价格为$0.99的礼包及其对应奖励格子\n#### 验证小R/非R用户初始礼包\n##### 场景描述：付费等级为小R或非R的用户，首次进入3型或6型活动页面\n###### 预期结果：活动页面中正常展示所有礼包，包括$0.99的礼包\n### 累计充值影响规则\n#### 验证累计充值达标后的礼包变化\n##### 场景描述：一个小R用户，在本次无尽礼包活动中累计充值金额达到$10\n###### 预期结果：活动页面刷新，原本存在的$0.99礼包及其奖励格子消失\n##### 场景描述：一个非R用户，在本次无尽礼包活动中累计充值金额达到$9.99\n###### 预期结果：活动页面中$0.99的礼包仍然存在（边界值）\n##### 场景描述：一个中R用户，在活动中累计充值，但其初始已无$0.99礼包\n###### 预期结果：活动页面始终保持无$0.99礼包的状态\n#### 验证累计充值统计范围\n##### 场景描述：玩家在3型活动期间累计充值$6，切换到6型活动后又充值$5\n###### 预期结果：在6型活动中累计充值额达到$11，6型活动页面应移除$0.99礼包（如适用）\n##### 场景描述：玩家在本次无尽礼包活动开始前已有历史充值，进入本次活动\n###### 预期结果：仅根据本次活动周期内的累计充值金额判断是否移除$0.99礼包，历史充值不计入', '2', 'deepseek-chat', 1, 7, 126, NULL, '', '2026-03-10 10:31:30', '', NULL, NULL);
INSERT INTO `test_case` VALUES (10, '传送带礼包3', 'Sheet: Sheet1\n\n活动时间	按照星期作为一个循环，进行3型+6型无尽礼包的开启和结束，两种类型为同一个活动，所以不会同时出现，需要区分当前活动的版本号	\n	时间与玩家开启金色收集物时间保持一致，并根据时间进行活动的循环	\n	根据金色收集物倒计时剩余时间来切换3型和6型无尽礼包	\n	3型传送带持续时间：4天；6型传送带持续时间：3天	\n	7d ≥ 3型 > 3d ; 3d ≥ 6型 > 0d0h	\n倒计时	3型传送带倒计时需要在数字上 -3，比如剩下金色收集物剩余时间6天6小时，那么三型传送带剩余时间3天6小时	\n	6型时间与金色收集物倒计时时间相等	\n解锁关卡	完成27关	\n活动入口	右侧第三位（如果出现通行证活动后，位置向下顺延）	\n引导	当活动开始后（3型无尽礼包或6型无尽礼包），玩家第一次进入游戏，或从其他页面（关卡页面、商城等）返回主页面，主动弹出此活动弹窗	\n	每次活动从开始到结束仅主动弹出一次	\n活动开启	当玩家在主页面时活动开启，直接出现活动图标，此时需要记录一个事件节点：下次冷启动、从其他页面返回主页面	\n	在该事件发生前，如果玩家点击了活动图标，则本次活动开启到结束期间不需要主动弹出活动弹窗	\n	否则，在该事件发生时，主动弹活动弹窗	\n活动结束	当玩家不在活动页面，则主界面图标消失，下个活动开启（比如3型无尽礼包图标消失，6型无尽礼包图标出现）	\n	当活动结束，玩家在活动页面时，倒计时变为“finished”，未领取的奖励仍可以继续领取，玩家退出界面后，则主界面图标消失，下个无尽礼包开启	\n	3型无尽礼包到期时自动切换为6型无尽礼包的入口，玩家有免费奖励没领取时也将无法领取	\n	异常说明：当到达无尽礼包切换时间节点，但是玩家未联网的状态，倒计时仍变为“finished”，关闭页面后图标消失，但不会拉取新一轮的无尽礼包活动，直到玩家联网后拉取活动并展示对应图标和时间	\n活动规则	三型无尽礼包按照顺序从上到下购买/领取	\n	三型无尽礼包的特殊说明：无尽礼包的颜色仅三种，当最上面的格子消失，下一格格子移动时，颜色会跟随变化，如右侧视频，弹出动画和视频保持一致	\n	六型无尽礼包按照“S”形顺序，从左上开始领取	\n	当玩家没有领取顺序上的第一格奖励时，点击后面几个格子上的按钮，弹出提示“Claim previous offer to unlock.”	\n	如果当前可点击的按钮为\"Free\"，玩家点击即领取对应的奖励，无尽礼包根据顺序移动，已领取的格子消失，同时下一个格子上的“锁”图标打开，并移动到可点击的第一位	\n	免费奖励的领取不受网络的限制	\n	如果当前可点击的按钮为价格，需要判断当前是否联网，已联网的状态下可以正常跳转至支付页面，未联网时，弹出提示“Please connect to the Internet and try again.”	\n	当玩家点击付费按钮，完成付费后，弹出【完成付费弹窗】，点击关闭或继续按钮，均回到活动页面并自动领取对应的奖励	\n	当玩家点击付费按钮，取消付费后，弹出【取消付费弹窗】，点击关闭或继续按钮，均回到活动页面	\n宝箱规则	玩家点击宝箱，弹出气泡，展示宝箱中的道具信息及数量，再次点击任意位置气泡消失	\n	如果有气泡在展示时，玩家点击了另外一个宝箱，则先前的气泡消失，展示当前点击的宝箱气泡	\n	气泡的展示规则，仅第一列的气泡箭头朝上弹出（气泡在下），其余列箭头朝下弹出（气泡在上）	\n	当一个格子内的奖励大于3个时，出现宝箱，并将道具奖励以宝箱的形式展示	\n玩家付费等级对活动的影响	大R、中R用户在进入活动页面时，无0.99$的礼包及奖励	\n	当第一次活动开启时，根据玩家的消费等级展示对应的礼包档位	\n	当玩家在此活动中累计充值$10以上时，不展示0.99$的礼包及奖励	\n		\n		\n		\n\nSheet: Sheet2\n\n\nSheet: Sheet3\n\n\n', '传送带礼包.xlsx', '/profile/upload/2026/03/10/传送带礼包_20260310103337A002.xlsx', 'xlsx', '# 无尽礼包活动测试用例\n## 活动时间与倒计时\n### 基于等价类划分的剩余时间区间测试\n#### 剩余时间有效等价类验证\n##### 场景描述1：金色收集物剩余时间为7天整\n###### 预期结果：显示3型无尽礼包活动，剩余时间显示为4天整（7-3）\n##### 场景描述2：金色收集物剩余时间为3天1小时\n###### 预期结果：显示3型无尽礼包活动，剩余时间显示为0天1小时（3-3）\n##### 场景描述3：金色收集物剩余时间为3天整\n###### 预期结果：显示6型无尽礼包活动，剩余时间显示为3天整（3-0）\n##### 场景描述4：金色收集物剩余时间为1天\n###### 预期结果：显示6型无尽礼包活动，剩余时间显示为1天整\n##### 场景描述5：金色收集物剩余时间为0天1小时\n###### 预期结果：显示6型无尽礼包活动，剩余时间显示为0天1小时\n#### 剩余时间边界值测试\n##### 场景描述1：金色收集物剩余时间为7天0小时0分1秒（刚进入7天区间）\n###### 预期结果：显示3型无尽礼包活动，倒计时正确计算为4天0小时0分1秒\n##### 场景描述2：金色收集物剩余时间为3天0小时0分1秒（刚进入3天区间）\n###### 预期结果：显示6型无尽礼包活动，倒计时正确显示为3天0小时0分1秒\n##### 场景描述3：金色收集物剩余时间为3天0小时0分0秒（精确等于3天）\n###### 预期结果：显示6型无尽礼包活动，倒计时正确显示为3天0小时0分0秒\n##### 场景描述4：金色收集物剩余时间为0天0小时0分1秒（即将结束）\n###### 预期结果：显示6型无尽礼包活动，倒计时正确显示为0天0小时0分1秒\n##### 场景描述5：金色收集物剩余时间为0天0小时0分0秒（活动结束）\n###### 预期结果：当前活动结束，图标消失，准备拉取下一个周期的活动\n### 基于状态转换的活动周期测试\n#### 完整活动周期状态流转验证\n##### 场景描述1：玩家在线，从3型活动开启到自动切换6型活动\n###### 预期结果：3型活动持续4天后，主界面图标无缝切换为6型活动图标，时间显示为3天倒计时。\n##### 场景描述2：玩家在线，从6型活动结束到新一轮3型活动开启\n###### 预期结果：6型活动持续3天后，主界面图标消失，待金色收集物时间进入新周期后（>3天），3型活动图标出现。\n##### 场景描述3：玩家离线时到达活动切换节点（如3型切6型）\n###### 预期结果：玩家离线时，当前活动倒计时仍变为“finished”，图标不消失。联网后，自动拉取并展示正确的6型活动图标及时间。\n## 活动入口与引导\n### 基于场景法的入口位置测试\n#### 无通行证活动时的入口位置\n##### 场景描述1：无尽礼包活动开启，当前无通行证活动\n###### 预期结果：活动入口出现在主界面右侧第3个位置。\n#### 有通行证活动时的入口位置\n##### 场景描述1：无尽礼包活动开启，同时存在通行证活动\n###### 预期结果：活动入口出现在主界面右侧第4个位置（顺延一位）。\n### 基于决策表的引导弹窗触发逻辑测试\n#### 引导弹窗展示条件组合验证\n##### 场景描述1：活动开始后，玩家首次冷启动游戏，且之前未点击过活动图标\n###### 预期结果：进入主界面时，主动弹出活动引导弹窗。\n##### 场景描述2：活动开始后，玩家从关卡页面返回主页面，且之前未点击过活动图标\n###### 预期结果：返回主界面时，主动弹出活动引导弹窗。\n##### 场景描述3：活动开始后，玩家首次冷启动游戏，但在弹窗触发前手动点击了活动图标\n###### 预期结果：进入主界面时，不弹出活动引导弹窗。\n##### 场景描述4：活动开始后，玩家从商城返回主页面，但在弹窗触发前手动点击了活动图标\n###### 预期结果：返回主界面时，不弹出活动引导弹窗。\n##### 场景描述5：玩家在活动期间第二次冷启动或返回主页\n###### 预期结果：无论之前是否点击过图标，均不再弹出引导弹窗。\n## 活动开启与结束逻辑\n### 基于状态转换的活动结束页面内测试\n#### 玩家在活动页面内时活动结束\n##### 场景描述1：6型活动倒计时归零时，玩家正在活动页面内\n###### 预期结果：页面内倒计时变为“finished”状态，未领取的奖励仍可操作领取。\n##### 场景描述2：玩家在“finished”状态下领取完所有剩余奖励，然后退出活动页面\n###### 预期结果：退出后，主界面该活动图标消失。\n##### 场景描述3：玩家在“finished”状态下未领取奖励，直接退出活动页面\n###### 预期结果：退出后，主界面该活动图标消失，未领取的奖励作废。\n##### 场景描述4：3型活动“finished”后，玩家退出页面并联网\n###### 预期结果：主界面展示6型无尽礼包活动入口。\n### 基于错误推测法的活动结束异常网络测试\n#### 切换节点离线场景验证\n##### 场景描述1：3型活动倒计时结束应切换6型时，玩家设备处于断网状态\n###### 预期结果：3型活动页面内倒计时显示“finished”，关闭页面后图标消失。但不会出现6型活动入口。\n##### 场景描述2：上述场景中，玩家重新连接网络\n###### 预期结果：游戏拉取到6型活动数据，并在主界面正确展示6型活动图标和倒计时。\n## 活动规则测试\n### 基于决策表的奖励领取顺序测试\n#### 领取顺序限制验证\n##### 场景描述1：玩家点击当前可领取顺序后的格子（如第二格）上的按钮\n###### 预期结果：弹出提示“Claim previous offer to unlock.”，无法领取。\n##### 场景描述2：玩家点击当前可领取顺序上的格子（第一格）上的“Free”按钮\n###### 预期结果：成功领取奖励，该格子消失，下一格变为可领取状态。\n##### 场景描述3：3型无尽礼包，领取最上方格子后\n###### 预期结果：下方格子依次上移，且格子颜色按照规则（三种颜色循环）发生变化，动画与需求视频一致。\n##### 场景描述4：6型无尽礼包，领取顺序验证（从左上角开始“S”形）\n###### 预期结果：礼包领取顺序严格遵循从左到右、下一行从右到左的“S”形路径。\n### 基于正交试验法的奖励领取与网络状态测试\n#### 奖励类型与网络状态组合验证\n##### 场景描述1：点击“Free”按钮时，设备网络正常\n###### 预期结果：立即成功领取奖励，格子状态更新。\n##### 场景描述2：点击“Free”按钮时，设备断网\n###### 预期结果：立即成功领取奖励，格子状态更新。（免费奖励不受网络限制）\n##### 场景描述3：点击付费（价格）按钮时，设备网络正常\n###### 预期结果：正常跳转至支付页面。\n##### 场景描述4：点击付费（价格）按钮时，设备断网\n###### 预期结果：弹出提示“Please connect to the Internet and try again.”，无法跳转支付。\n### 基于场景法的付费流程测试\n#### 付费完成与取消场景\n##### 场景描述1：玩家点击付费按钮并成功完成支付\n###### 预期结果：弹出【完成付费弹窗】，点击关闭或继续按钮后返回活动页面，并自动领取对应奖励，格子状态更新。\n##### 场景描述2：玩家点击付费按钮但在支付流程中取消\n###### 预期结果：弹出【取消付费弹窗】，点击关闭或继续按钮后返回活动页面，奖励未被领取。\n##### 场景描述3：玩家在付费流程中（如商店界面）强制关闭游戏，再重新启动\n###### 预期结果：启动后根据支付平台回调决定是否发放奖励。若无回调，则奖励未领取，可再次点击购买。\n## 宝箱规则测试\n### 基于场景法的宝箱气泡交互测试\n#### 气泡显示与隐藏交互验证\n##### 场景描述1：玩家点击一个包含宝箱（奖励>3个）的格子\n###### 预期结果：弹出气泡，正确展示该宝箱内所有道具信息及数量。\n##### 场景描述2：气泡展示时，玩家点击屏幕任意非宝箱区域\n###### 预期结果：气泡消失。\n##### 场景描述3：气泡展示时，玩家点击另一个宝箱\n###### 预期结果：上一个气泡消失，新点击的宝箱气泡弹出并展示。\n##### 场景描述4：验证第一列宝箱的气泡箭头方向\n###### 预期结果：气泡在宝箱下方弹出，箭头朝上。\n##### 场景描述5：验证非第一列（如第二列）宝箱的气泡箭头方向\n###### 预期结果：气泡在宝箱上方弹出，箭头朝下。\n### 基于边界值分析的宝箱出现条件测试\n#### 奖励数量边界验证\n##### 场景描述1：一个格子内奖励道具数量为3个\n###### 预期结果：不出现宝箱，3个道具直接平铺展示。\n##### 场景描述2：一个格子内奖励道具数量为4个\n###### 预期结果：出现宝箱，点击后气泡内展示4个道具信息。\n## 付费等级对活动的影响\n### 基于等价类划分的用户付费等级测试\n#### 初始活动进入礼包展示验证\n##### 场景描述1：大R用户进入活动页面\n###### 预期结果：活动页面内无0.99$的礼包及奖励。\n##### 场景描述2：中R用户进入活动页面\n###### 预期结果：活动页面内无0.99$的礼包及奖励。\n##### 场景描述3：小R或非R用户进入活动页面\n###### 预期结果：活动页面内包含0.99$的礼包及奖励。\n### 基于正交试验法的累计充值行为测试\n#### 付费等级与累计充值组合验证\n##### 场景描述1：小R用户在本次活动开始后，累计充值金额达到$10\n###### 预期结果：达到$10的瞬间或下次刷新活动页面时，0.99$的礼包及奖励从界面中消失。\n##### 场景描述2：大R用户（初始已无0.99$礼包）在活动中累计充值任意金额\n###### 预期结果：活动页面始终保持无0.99$礼包的状态。\n##### 场景描述3：非R用户在活动中累计充值$9.99\n###### 预期结果：活动页面依然展示0.99$的礼包及奖励。\n##### 场景描述4：非R用户在活动中累计充值$10.01\n###### 预期结果：活动页面不再展示0.99$的礼包及奖励。', '2', 'deepseek-reasoner', 1, 8, 153, NULL, '', '2026-03-10 10:33:37', '', NULL, NULL);
INSERT INTO `test_case` VALUES (11, '111传送带', 'Sheet: Sheet1\n\n活动时间	按照星期作为一个循环，进行3型+6型无尽礼包的开启和结束，两种类型为同一个活动，所以不会同时出现，需要区分当前活动的版本号	\n	3型传送带持续时间：4天；6型传送带持续时间：3天	\n	活动开启时间 Mon 08:00:00 UTC	\n	Mon 08:00:00 ≤ 3型 < Fri 08:00:00	\n	Fri 08:00:00 ≤ 6型 < Mon 08:00:00	\n	当玩家达到解锁等级后，活动按照时间统一开启，不会因为玩家上线的时间或客户端的时间改变剩余时间	\n	首次需要玩家联网才能收到此活动，并展示活动图标	\n解锁关卡	完成27关	\n活动入口	右侧第三位（如果出现通行证活动后，位置向下顺延）	\n引导	当活动开始后（3型无尽礼包或6型无尽礼包），玩家第一次进入游戏，或从其他页面（关卡页面、商城等）返回主页面，主动弹出此活动弹窗	\n	每次活动从开始到结束仅主动弹出一次	\n活动开启	当玩家在主页面时活动开启，直接出现活动图标，此时需要记录一个事件节点：下次冷启动、从其他页面返回主页面	\n	在该事件发生前，如果玩家点击了活动图标，则本次活动开启到结束期间不需要主动弹出活动弹窗	\n	否则，在该事件发生时，主动弹活动弹窗	\n活动结束	当玩家不在活动页面，则主界面图标消失，下个活动开启（比如3型无尽礼包图标消失，6型无尽礼包图标出现）	\n	当活动结束，玩家在活动页面时，倒计时变为“finished”，未领取的奖励仍可以继续领取，玩家退出界面后，则主界面图标消失，下个无尽礼包开启	\n	3型无尽礼包到期时自动切换为6型无尽礼包的入口，玩家有免费奖励没领取时也将无法领取	\n	异常说明：当到达无尽礼包切换时间节点，但是玩家未联网的状态，倒计时仍变为“finished”，关闭页面后图标消失，但不会拉取新一轮的无尽礼包活动，直到玩家联网后拉取活动并展示对应图标和时间	\n活动规则	三型无尽礼包按照顺序从上到下购买/领取	\n	三型无尽礼包的特殊说明：无尽礼包的颜色仅三种，当最上面的格子消失，下一格格子移动时，颜色会跟随变化，如右侧视频，弹出动画和视频保持一致	\n	六型无尽礼包按照“S”形顺序，从左上开始领取	\n	当玩家没有领取顺序上的第一格奖励时，点击后面几个格子上的按钮，弹出提示“Claim previous offer to unlock.”当一格的动效没有完成时，点击后面的格子同样弹出提示	\n	如果当前可点击的按钮为\"Free\"，玩家点击即领取对应的奖励，无尽礼包根据顺序移动，已领取的格子消失，同时下一个格子上的“锁”图标打开，并移动到可点击的第一位	\n	免费奖励的领取不受网络的限制	\n	如果当前可点击的按钮为价格，需要判断当前是否联网，已联网的状态下可以正常跳转至支付页面，未联网时，弹出提示“Please connect to the Internet and try again.”	\n	当玩家点击付费按钮，完成付费后，弹出【完成付费弹窗】，点击关闭或继续按钮，均回到活动页面并自动领取对应的奖励	\n	当玩家点击付费按钮，取消付费后，弹出【取消付费弹窗】，点击关闭或继续按钮，均回到活动页面	\n宝箱规则	玩家点击宝箱，弹出气泡，展示宝箱中的道具信息及数量，再次点击任意位置气泡消失	\n	如果有气泡在展示时，玩家点击了另外一个宝箱，则先前的气泡消失，展示当前点击的宝箱气泡	\n	气泡的展示规则，仅第一列的气泡箭头朝上弹出（气泡在下），其余列箭头朝下弹出（气泡在上）	\n	当一个格子内的奖励大于3个时，出现宝箱，并将道具奖励以宝箱的形式展示	\n玩家付费等级对活动的影响	大R、中R用户在进入活动页面时，无0.99$的礼包及奖励	\n	当第一次活动开启时，根据玩家的消费等级展示对应的礼包档位	\n	当玩家在此活动中累计充值$10以上时，不展示0.99$的礼包及奖励	\n活动奖励		\n音效需求		\n动效需求		\n\nSheet: Sheet2\n\n\nSheet: Sheet3\n\n\n', '传送带礼包.xlsx', '/profile/upload/2026/03/13/传送带礼包_20260313200340A001.xlsx', 'xlsx', '# 无尽礼包活动测试用例\n## 活动时间控制\n### 活动版本与时间循环\n#### 3型与6型活动切换时序\n##### 场景描述：星期一 07:59:59 UTC，当前为6型无尽礼包活动\n###### 预期结果：活动仍为6型，倒计时正常显示剩余1秒。\n##### 场景描述：星期一 08:00:00 UTC，服务器时间更新\n###### 预期结果：6型活动结束，3型活动立即开启，主界面图标和内容切换为3型无尽礼包，倒计时显示为4天整。\n##### 场景描述：星期一 08:00:01 UTC，当前为3型无尽礼包活动\n###### 预期结果：活动为3型，倒计时显示剩余3天23小时59分59秒。\n##### 场景描述：星期五 07:59:59 UTC，当前为3型无尽礼包活动\n###### 预期结果：活动仍为3型，倒计时正常显示剩余1秒。\n##### 场景描述：星期五 08:00:00 UTC，服务器时间更新\n###### 预期结果：3型活动结束，6型活动立即开启，主界面图标和内容切换为6型无尽礼包，倒计时显示为3天整。\n##### 场景描述：星期五 08:00:01 UTC，当前为6型无尽礼包活动\n###### 预期结果：活动为6型，倒计时显示剩余2天23小时59分59秒。\n#### 活动持续时间验证\n##### 场景描述：3型活动开启后，客户端时间与服务器同步，不进行任何操作，静置4天\n###### 预期结果：活动倒计时从4天0时0分0秒逐渐减少至0秒，并在第4天Mon 08:00:00准时结束切换。\n##### 场景描述：6型活动开启后，客户端时间与服务器同步，不进行任何操作，静置3天\n###### 预期结果：活动倒计时从3天0时0分0秒逐渐减少至0秒，并在第3天Fri 08:00:00准时结束切换。\n#### 活动开启时间统一性\n##### 场景描述：玩家A在星期一08:00:00前完成27关并保持在线，玩家B在星期一09:00:00完成27关并首次上线\n###### 预期结果：玩家A在08:00:00看到活动开启。玩家B在09:00:00上线时，看到的活动剩余时间与玩家A一致（少于24小时），而不是从4天开始。\n##### 场景描述：玩家修改客户端系统时间为下周一，然后启动游戏\n###### 预期结果：活动显示的剩余时间和版本与服务器实际时间一致，不受客户端错误时间影响。\n#### 首次活动激活依赖网络\n##### 场景描述：玩家完成27关后，在离线状态下重启游戏或返回主页面\n###### 预期结果：主界面不展示无尽礼包活动图标。\n##### 场景描述：玩家完成27关后，在联网状态下重启游戏\n###### 预期结果：主界面展示对应的无尽礼包活动图标。\n## 活动入口与引导\n### 入口位置\n#### 入口排序规则\n##### 场景描述：当前无通行证活动\n###### 预期结果：无尽礼包活动入口位于主界面右侧第三位。\n##### 场景描述：当前有通行证活动\n###### 预期结果：无尽礼包活动入口位于主界面右侧第四位（在通行证入口下方）。\n### 主动引导弹窗\n#### 弹窗触发条件（每次活动仅一次）\n##### 场景描述：活动开始后，玩家首次冷启动游戏（进程完全关闭后启动）\n###### 预期结果：进入主界面时，主动弹出无尽礼包活动介绍弹窗。\n##### 场景描述：活动开始后，玩家从关卡页面返回主页面\n###### 预期结果：返回主界面时，主动弹出无尽礼包活动介绍弹窗。\n##### 场景描述：活动开始后，玩家从商城页面返回主页面\n###### 预期结果：返回主界面时，主动弹出无尽礼包活动介绍弹窗。\n##### 场景描述：活动开始后，玩家在主界面，直接点击了活动图标进入\n###### 预期结果：不触发主动弹窗。此后直到本次活动结束，即使冷启动或从其他页面返回，也不再弹出该活动弹窗。\n##### 场景描述：活动开始后，玩家首次冷启动看到了弹窗，关闭弹窗后，再次冷启动\n###### 预期结果：不再弹出活动弹窗。\n##### 场景描述：3型活动结束后，6型活动开始，玩家首次进入游戏\n###### 预期结果：弹出6型无尽礼包的活动介绍弹窗（视为新一次活动）。\n## 活动开启与状态记录\n### 开启与事件记录逻辑\n#### 场景描述：活动开始时，玩家正在主页面\n###### 预期结果：活动图标直接出现。系统记录“需要检查弹窗”的状态。\n#### 场景描述：活动开始时，玩家正在关卡内\n###### 预期结果：玩家退出关卡返回主页面时，活动图标出现，并同时弹出活动弹窗（因为“返回主页面”事件发生）。\n### 事件节点判断\n#### 场景描述：活动图标出现后，玩家在触发“冷启动”或“返回主页面”事件前，点击了图标\n###### 预期结果：进入活动页面，且本次活动周期内不再触发主动弹窗。\n#### 场景描述：活动图标出现后，玩家未点击图标，直接进行了冷启动\n###### 预期结果：冷启动进入主界面时，弹出活动弹窗。\n#### 场景描述：活动图标出现后，玩家未点击图标，切换到关卡页面再返回\n###### 预期结果：返回主界面时，弹出活动弹窗。\n## 活动结束与切换\n### 正常结束（玩家不在活动页）\n#### 场景描述：6型活动倒计时归零时，玩家正在主界面或关卡中\n###### 预期结果：主界面6型活动图标立即消失，3型活动图标出现。\n### 正常结束（玩家在活动页）\n#### 场景描述：3型活动倒计时归零时，玩家正在3型活动页面内\n###### 预期结果：页面倒计时显示变为“finished”，玩家仍可领取未领的奖励。退出此页面后，主界面3型图标消失，6型图标出现。\n#### 场景描述：在“finished”状态领取最后一个免费奖励\n###### 预期结果：可以正常领取，奖励到账。\n#### 场景描述：在“finished”状态，尝试购买一个未购买的付费礼包（网络正常）\n###### 预期结果：可以正常跳转支付，支付成功后领取奖励。\n### 活动切换与奖励继承\n#### 场景描述：3型活动到期，有未领取的免费奖励，自动切换到6型活动\n###### 预期结果：3型未领取的奖励无法再领取，主界面显示6型活动。\n### 异常结束（切换时无网络）\n#### 场景描述：到达3型切6型的时间节点，玩家设备处于离线状态，且正在活动页面\n###### 预期结果：活动倒计时显示变为“finished”。\n#### 场景描述：上述情况下，玩家关闭活动页面\n###### 预期结果：主界面3型活动图标消失，且没有新的6型活动图标出现。\n#### 场景描述：上述情况下，玩家连接网络\n###### 预期结果：主界面拉取到最新的6型活动并展示其图标和正确倒计时。\n## 活动规则-通用\n### 领取顺序锁定\n#### 场景描述：在3型/6型活动中，不领取顺序上的第一个奖励，直接点击第二个奖励的按钮\n###### 预期结果：弹出提示“Claim previous offer to unlock.”，无法领取。\n#### 场景描述：在3型/6型活动中，不领取顺序上的第一个奖励，直接点击第三个奖励的按钮\n###### 预期结果：弹出提示“Claim previous offer to unlock.”，无法领取。\n#### 场景描述：点击第一个奖励，但奖励发放动画（如金币飞入）尚未播放完毕时，立即点击第二个奖励\n###### 预期结果：弹出提示“Claim previous offer to unlock.”，无法领取。\n### 免费奖励领取\n#### 场景描述：当前可点击按钮为“Free”，设备处于飞行模式（无网络）\n###### 预期结果：点击“Free”按钮，奖励正常发放到账，格子顺序移动。\n#### 场景描述：连续点击多个“Free”奖励\n###### 预期结果：每个奖励依次正常领取，界面顺序正确更新。\n### 付费流程\n#### 场景描述：当前可点击按钮为价格（如$4.99），设备网络正常\n###### 预期结果：点击按钮，正常跳转至应用商店/支付页面。\n#### 场景描述：当前可点击按钮为价格，设备无网络连接\n###### 预期结果：点击按钮，弹出提示“Please connect to the Internet and try again.”，不跳转支付。\n#### 场景描述：跳转支付页面后，完成付费\n###### 预期结果：弹出【完成付费弹窗】，点击“关闭”或“继续”按钮，均返回到活动页面，且对应的奖励已自动领取，格子顺序更新。\n#### 场景描述：跳转支付页面后，取消付费\n###### 预期结果：弹出【取消付费弹窗】，点击“关闭”或“继续”按钮，均返回到活动页面，奖励未领取，格子顺序不变。\n## 活动规则-3型无尽礼包\n### 领取顺序与视觉表现\n#### 场景描述：顺序领取3型礼包（从上到下）\n###### 预期结果：每次领取后，当前格子消失，下方格子依次上移，最下方出现新的锁定格子。\n#### 场景描述：观察格子移动时的颜色变化\n###### 预期结果：格子颜色按既定三种颜色循环变化，与需求视频中的动画保持一致。\n#### 场景描述：连续快速点击领取免费和付费奖励\n###### 预期结果：界面顺序更新正确，无错位或显示异常，动画可正常衔接或跳过。\n## 活动规则-6型无尽礼包\n### 领取顺序（“S”形）\n#### 场景描述：从左上角第一个开始，按“S”形路径依次领取\n###### 预期结果：领取顺序符合“S”形走向（例如：行1从左到右，行2从右到左，以此类推）。\n#### 场景描述：不按顺序点击非首位的格子\n###### 预期结果：弹出提示“Claim previous offer to unlock.”。\n## 宝箱规则\n### 气泡触发与消失\n#### 场景描述：点击一个包含多个奖励（>3）的宝箱格子\n###### 预期结果：弹出气泡，正确展示内含的所有道具图标和数量。\n#### 场景描述：点击气泡外任意区域\n###### 预期结果：气泡消失。\n#### 场景描述：展示宝箱A的气泡时，点击宝箱B\n###### 预期结果：宝箱A的气泡消失，同时展示宝箱B的气泡。\n### 气泡箭头方向\n#### 场景描述：点击第一列（最左边一列）的宝箱\n###### 预期结果：气泡在宝箱下方弹出，箭头朝上。\n#### 场景描述：点击第二列及以后列的宝箱\n###### 预期结果：气泡在宝箱上方弹出，箭头朝下。\n## 付费等级对活动的影响\n### 首次活动开启的礼包展示\n#### 场景描述：大R用户（历史累计消费高）首次进入活动页面\n###### 预期结果：活动礼包列表中不包含$0.99档位的礼包。\n#### 场景描述：中R用户首次进入活动页面\n###### 预期结果：活动礼包列表中不包含$0.99档位的礼包。\n#### 场景描述：小R/非R用户首次进入活动页面\n###### 预期结果：活动礼包列表中包含$0.99档位的礼包。\n### 活动过程中消费等级变化\n#### 场景描述：小R玩家在本次3型活动中累计充值达到$10\n###### 预期结果：充值后，活动页面立即刷新，$0.99的礼包及奖励从列表中消失。后续的6型活动中也不再出现$0.99礼包。\n#### 场景描述：小R玩家在本次3型活动中累计充值$9.99\n###### 预期结果：$0.99的礼包仍然存在。\n## 网络与客户端异常\n### 网络状态变化\n#### 场景描述：点击付费按钮时网络正常，支付过程中断网\n###### 预期结果：支付流程中断，根据商店策略可能提示失败。不应卡死。\n#### 场景描述：在活动页面，网络从连通变为断开\n###### 预期结果：免费按钮仍可点击，付费按钮点击时提示无网络。\n#### 场景描述：在活动页面，网络从断开变为连通\n###### 预期结果：付费按钮恢复正常点击跳转功能。\n### 客户端状态变化\n#### 场景描述：领取免费奖励时，接到电话或切换到其他应用\n###### 预期结果：返回游戏后，奖励应已到账，活动界面状态正常。\n#### 场景描述：支付过程中，强制关闭游戏\n###### 预期结果：再次启动游戏后，应能正确处理支付未完成状态，可通过商店回调或恢复购买机制处理，避免资金损失或奖励丢失。\n#### 场景描述：活动期间，游戏客户端崩溃重启\n###### 预期结果：重启后进入活动页面，状态应与崩溃前一致（已领取的奖励消失，未领取的奖励和顺序正确保留）。\n## 边界与异常场景\n### 解锁关卡边界\n#### 场景描述：玩家通过第26关\n###### 预期结果：主界面不显示无尽礼包活动入口。\n#### 场景描述：玩家通过第27关\n###### 预期结果：主界面在下次满足活动开启或触发条件时，显示无尽礼包活动入口。\n### 时间边界（极端情况）\n#### 场景描述：玩家在星期一07:59:59完成第27关并立即上线\n###### 预期结果：拉取到的应为即将结束的6型活动（剩余1秒），然后迅速切换为3型活动。\n#### 场景描述：活动最后1秒，点击领取免费奖励\n###### 预期结果：奖励应能成功领取到账。\n#### 场景描述：活动最后1秒，点击付费按钮并成功支付\n###### 预期结果：支付成功后，应能正常领取奖励，即使活动时间已过（因玩家仍在活动页面）。\n### 显示与性能\n#### 场景描述：活动页面元素（宝箱、按钮、倒计时）在不同分辨率设备上的显示\n###### 预期结果：布局正确，无重叠、截断或错位。\n#### 场景描述：快速、连续进行领取、支付、打开宝箱等操作\n###### 预期结果：客户端响应流畅，无卡顿、闪退或数据不同步。\n#### 场景描述：系统时间被手动大幅调整（如调至下个月）后打开游戏\n###### 预期结果：活动倒计时和版本仍与服务器同步，显示正确。', '2', 'deepseek-reasoner', 1, 8, 169, NULL, '', '2026-03-13 20:03:41', '', NULL, NULL);
INSERT INTO `test_case` VALUES (13, 'island', 'Sheet: Sheet1\n\n活动类型	常驻活动							\n解锁关卡	完成15关							\n活动入口	左侧第三位							\n活动开始	1、基于玩家自身开始时间 24 小时计时，当玩家完成对应解锁关卡时，活动直接开启。点击主页面上的活动入口弹出参与活动页面（此时是活动未参与状态，此时开始计时）							\n	2、点击“Start”按钮，PK开始，此时出现弹出召集100位玩家进行比赛的动效+弹窗							\n	根据玩家的过关时间，展示不同的剩余人数N							\n		1、快速通关型每过一关后的取值的范围	2、稳步过关型每过一关后的取值的范围	2、持续过关型每过一关后的取值的范围				\n	第一关	100 → 95	100 → 90	100 → 85 （给玩家紧迫感）				\n	第二关	94 → 80	89 → 75	84 → 70				\n	第三关	79 → 60	74 → 60	69 → 50				\n	第四关	59 → 45	59 → 45	49 → 40				\n	第五关	44 → 30	44 → 30	39 → 25				\n	第六关	39 → 16	29 → 16	24 → 16				\n	第七关	1 =< N =< 15（概率分布在最后）						\n	时间	通关时间小于2小时	通关时间在2~6小时	通关时间在6小时以上				\n		平均17分钟以下通过一关	平均17~51分钟通过一关	平均51分钟以上通过一关				\n过关时间	当玩家完成一关时，判断玩家总过关时间在哪个区间内，并根据区间内的剩余人数范围取值							\n	玩家从点击“Start”按钮开始计时，直到完成第一关，为玩家通过第一关所用时间							\n	玩家从点击“Start”按钮开始计时，直到完成第二关，累计时间为玩家通过第二关所用时间，以此类推							\n	如：玩家完成第2关的总时间是70分钟，玩家所在的范围属于“稳步过关型”（通过两关的时间在34~102分钟之间），所以在90 → 75 内取值							\n	需要判断当前人数的取值小于上一关剩余人数的取值（第一关除外）							\n过关规则	胜利：玩家在第一次挑战关卡时过关，即算作胜利，在活动页面展示向前一步的动效，并展示对应的剩余玩家数量							\n	在胜利结算页面返回后，优先进入此活动页面，展示对应胜利/失败动效							\n	失败：活动进入冷却状态，展示倒计时30min，倒计时结束后仍然可以继续参加活动，以点击“Start”按钮开始重复上述步骤							\n	特殊说明：玩家失败后，计算倒计时结束时间是否超过玩家开始刷新时间，如果超过，则弹出“失败”页面后，玩家点击屏幕返回【主页】，不展示活动入口；如果没超过，按正常步骤展示倒计时时间							\n活动结束	玩家在自己的重置时间没有完成活动时，当日的活动视为失败，再次进入游戏或进入主页面，回到活动未参与状态							\n	玩家从点击“Start”按钮开始计时，当在24小时内完成活动时，主页活动图标消失，直到24小时结束，主页活动图标再次出现，玩家可参与活动							\n引导	首次开启活动提供手引导							\n	当玩家连续3天没有参与此活动时，第4天玩家完成1关后进入主页面，主动弹出活动弹窗（包括未上线天数）							\n活动剩余人数概率	1.0	0.02						\n	2.0	0.03						\n	3.0	0.05						\n	4.0	0.07						\n	5.0	0.08						\n	6.0	0.1						\n	7.0	0.1						\n	8.0	0.1						\n	9.0	0.1						\n	10.0	0.1						\n	11.0	0.08						\n	12.0	0.07						\n	13.0	0.05						\n	14.0	0.03						\n	15.0	0.02						\n活动保底机制	当玩家完成50次活动，均没有获得过剩余人数为1时，下一次一定为1							\n	当玩家连续参与活动，持续3天剩余人数在11-15人之间时，降低11-15人的权重（*0.5），以天累乘的形式，直到玩家出现其他数字							\n	当玩家连续参与活动，持续3天剩余人数在1-5人之间时，降低1-5人的权重（*0.5），以天累乘的形式，直到玩家出现其他数字							\n	例如：玩家连续3天的剩余人数为12、15、11，第四天降低权重后，最终剩余人数为13，那么第五天需要在第四天降低权重后的基础上，再次降低权重（*0.5）							\n异常场景	未联网状态下无法参与活动							\n	当在未联网状态下，玩家点击“Start”按钮，提示“You need an internet connection to start Island Voyage！”							\n	当玩家过关后断网，弹出活动页面后提示“You\'re offline. Reconnect to continue the competition！”							\n	当玩家一直是未联网状态时，活动页面的剩余人数中展示“ — — ”							\n	联网后，一次性提交所有未同步关卡，服务器下发活动结果，玩家进入主页面，弹出弱提示引导玩家点击活动图标后，按结果播放淘汰动画，不受活动时间限制							\n\nSheet: Sheet2\n\n\nSheet: Sheet3\n\n\n', 'island.xlsx', '/profile/upload/2026/03/23/island_20260323143905A002.xlsx', 'xlsx', '# 常驻PK活动测试用例\n## 1. 活动入口与状态\n### 1.1 入口显示逻辑\n#### 1.1.1 入口显示条件\n##### 场景描述1：玩家未完成第15关\n###### 预期结果：活动入口不显示。\n##### 场景描述2：玩家刚刚完成第15关\n###### 预期结果：活动入口立即在主页左侧第三位显示。\n#### 1.1.2 入口隐藏/显示时机\n##### 场景描述1：玩家点击Start按钮，活动开始后\n###### 预期结果：主页活动入口应保持显示（若需求未明确要求隐藏）。\n##### 场景描述2：玩家在24小时内完成7关，活动胜利结束\n###### 预期结果：主页活动入口消失。\n##### 场景描述3：玩家活动失败（未在24小时内完成）或24小时倒计时结束后\n###### 预期结果：主页活动入口再次出现，状态重置为“未参与”。\n##### 场景描述4：玩家活动失败，进入30分钟冷却，但冷却结束时已超过其24小时活动开始时间\n###### 预期结果：返回主页后，不展示活动入口。\n### 1.2 入口点击响应\n#### 1.2.1 正常点击\n##### 场景描述1：活动处于“未参与”状态时，点击入口\n###### 预期结果：弹出活动介绍/参与页面，页面显示“Start”按钮，并开始24小时倒计时（或显示活动已开始的提示）。\n##### 场景描述2：活动处于“进行中”状态时，点击入口\n###### 预期结果：进入活动主页面，展示当前剩余人数、已过关数等信息。\n##### 场景描述3：活动处于“失败冷却”状态时，点击入口\n###### 预期结果：进入活动页面，显示30分钟冷却倒计时。\n#### 1.2.2 异常点击\n##### 场景描述1：在完全无网络状态下，点击活动入口\n###### 预期结果：应有提示（如“网络连接失败”），或页面显示为“--”状态。\n## 2. 活动开始与引导\n### 2.1 首次引导\n#### 2.1.1 引导触发与执行\n##### 场景描述1：玩家首次解锁活动（完成第15关后），首次点击活动入口\n###### 预期结果：出现强引导（如手指动画），指引玩家查看活动页面并点击“Start”按钮。\n##### 场景描述2：在引导过程中，玩家点击屏幕其他区域\n###### 预期结果：引导应正常进行或提供跳过选项，不应导致界面异常。\n### 2.2 Start流程\n#### 2.2.1 正常启动流程\n##### 场景描述1：在活动“未参与”页面，点击“Start”按钮\n###### 预期结果：1. 出现召集100位玩家的动效+弹窗。2. 弹窗关闭后，进入活动主页面，剩余人数初始为100，并正式开始24小时与每关计时。\n##### 场景描述2：在活动“失败冷却”结束且活动总时间未超24小时时，点击“Start”按钮\n###### 预期结果：流程同上，剩余人数重新从100开始计算。\n#### 2.2.2 异常启动流程\n##### 场景描述1：在未联网状态下，点击“Start”按钮\n###### 预期结果：弹出提示：“You need an internet connection to start Island Voyage！”\n##### 场景描述2：点击“Start”瞬间网络断开\n###### 预期结果：应有明确的网络错误提示，活动不应开始。\n##### 场景描述3：快速连续点击“Start”按钮\n###### 预期结果：应做防重处理，只触发一次活动开始逻辑。\n## 3. 闯关与剩余人数逻辑\n### 3.1 玩家类型判定\n#### 3.1.1 通关时间区间判定\n##### 场景描述1：玩家完成第1关用时16分钟\n###### 预期结果：判定为“快速通关型”（<2小时，平均<17分钟/关），第一关剩余人数在100→95范围内取值。\n##### 场景描述2：玩家完成第2关总用时70分钟\n###### 预期结果：判定为“稳步过关型”（2~6小时，平均34~102分钟/2关=17~51分钟/关），第二关剩余人数在89→75范围内取值。\n##### 场景描述3：玩家完成第3关总用时200分钟\n###### 预期结果：判定为“持续过关型”（>6小时，平均>200/3≈66.7分钟/关 >51分钟），第三关剩余人数在69→50范围内取值。\n##### 场景描述4：玩家完成第1关用时正好2小时（120分钟）\n###### 预期结果：判定为“稳步过关型”（属于2~6小时区间）。\n##### 场景描述5：玩家完成第1关用时正好6小时（360分钟）\n###### 预期结果：判定为“持续过关型”（属于6小时以上区间）。\n### 3.2 剩余人数减少逻辑\n#### 3.2.1 数值范围与单调性\n##### 场景描述1：玩家为快速型，第一关完成后\n###### 预期结果：剩余人数N1满足 95 <= N1 <= 100。\n##### 场景描述2：玩家为快速型，第二关完成后\n###### 预期结果：剩余人数N2满足 80 <= N2 <= 94，且 N2 < N1。\n##### 场景描述3：玩家为稳步型，完成第七关后\n###### 预期结果：剩余人数N7满足 1 <= N7 <= 15，且 N7 < N6。\n##### 场景描述4：测试所有类型所有关卡\n###### 预期结果：每关完成后的剩余人数取值，均严格符合Sheet1中对应类型和关卡的数值范围，且后一关人数必小于前一关（第一关除外）。\n#### 3.2.2 第7关特殊概率\n##### 场景描述1：大量模拟玩家完成第7关\n###### 预期结果：剩余人数为1-15的概率分布应基本符合需求表中的概率（1:2%，2:3%...15:2%）。\n##### 场景描述2：单个玩家多次活动至第7关\n###### 预期结果：其获得的剩余人数应符合随机分布，不应出现明显模式（在无保底触发时）。\n### 3.3 活动状态更新与显示\n#### 3.3.1 过关动效与页面跳转\n##### 场景描述1：玩家第一次挑战某关即成功过关\n###### 预期结果：1. 弹出胜利结算页面。2. 从胜利结算页面返回后，**优先进入活动页面**，展示“向前一步”动效，并更新显示新的剩余人数。\n##### 场景描述2：玩家挑战某关失败\n###### 预期结果：不触发活动相关的剩余人数更新动效。\n#### 3.3.2 断网后数据同步\n##### 场景描述1：玩家在联网状态下过关，弹出活动页面前断网\n###### 预期结果：提示“You‘re offline. Reconnect to continue the competition！”，动效和人数更新暂停。\n##### 场景描述2：玩家在一直断网状态下过关数次，然后恢复网络\n###### 预期结果：恢复网络后，服务器一次性处理所有未同步关卡，计算结果。玩家进入主页面时收到弱提示，点击活动图标后，按最终结果一次性播放所有淘汰动画（例如从100直接降到N）。\n##### 场景描述3：断网时，活动页面剩余人数显示\n###### 预期结果：显示为“ — — ”。\n## 4. 活动结束与失败处理\n### 4.1 活动胜利结束\n#### 4.1.1 正常胜利流程\n##### 场景描述1：玩家在24小时内完成第7关\n###### 预期结果：弹出最终胜利结算，返回主页后活动入口图标消失。\n##### 场景描述2：玩家在活动入口消失期间（24小时倒计时未结束）查看主页\n###### 预期结果：活动入口持续不显示。\n##### 场景描述3：玩家活动胜利后，24小时总活动时间结束\n###### 预期结果：活动入口重新出现，状态为“未参与”。\n### 4.2 活动失败处理\n#### 4.2.1 单次挑战失败冷却\n##### 场景描述1：玩家在某一关挑战失败\n###### 预期结果：1. 进入活动页面，显示30分钟冷却倒计时。2. 倒计时准确从30:00开始减少。3. 倒计时结束后，页面出现“Start”按钮，可重新开始。\n##### 场景描述2：冷却期间退出活动页面再进入\n###### 预期结果：倒计时应持续、准确地显示剩余时间。\n##### 场景描述3：冷却期间杀死游戏进程，30分钟后重新进入游戏\n###### 预期结果：进入活动页面，冷却应已结束，显示“Start”按钮。\n#### 4.2.2 24小时活动总时间失败\n##### 场景描述1：玩家自点击Start起，24小时内未完成第7关\n###### 预期结果：活动自动结束，视为失败。玩家再次进入游戏或主页面时，活动入口出现，状态重置为“未参与”。\n##### 场景描述2：玩家在23小时59分时完成第6关，未来得及挑战第7关即超时\n###### 预期结果：24小时到，活动失败，状态重置。\n### 4.3 冷却与总时间的冲突规则\n#### 4.3.1 特殊说明验证\n##### 场景描述1：玩家失败冷却结束时间点早于其活动开始后24小时的结束时间点\n###### 预期结果：冷却结束后，正常展示“Start”按钮，可继续参与。\n##### 场景描述2：玩家失败冷却结束时间点晚于其活动开始后24小时的结束时间点\n###### 预期结果：弹出“失败”页面后，玩家点击返回主页，活动入口不展示（因为总活动时间已耗尽）。\n## 5. 保底与权重机制\n### 5.1 50次保底机制\n#### 5.1.1 保底触发条件\n##### 场景描述1：玩家连续参与50次活动（每次均完成至第7关），剩余人数从未为1\n###### 预期结果：第51次活动完成第7关时，剩余人数强制为1。\n##### 场景描述2：玩家在第30次活动中获得了剩余人数1\n###### 预期结果：保底计数器重置。需要再连续50次未获得1，才会触发下一次保底。\n##### 场景描述3：玩家活动未完成至第7关（中途失败或放弃）\n###### 预期结果：该次活动不计入保底计数。\n### 5.2 连续高/低人数权重衰减\n#### 5.2.1 连续高人数（11-15）衰减\n##### 场景描述1：玩家连续3天剩余人数为12, 15, 11\n###### 预期结果：第4天，11-15每个数字的权重乘以0.5，再重新归一化计算概率。\n##### 场景描述2：第4天玩家剩余人数为13\n###### 预期结果：第5天，在昨天已衰减的基础上，11-15的权重再次乘以0.5（即累计*0.25），直到玩家获得1-10的数字为止。\n##### 场景描述3：玩家第4天剩余人数为8（非11-15）\n###### 预期结果：第5天，权重衰减重置，恢复原始概率表。\n#### 5.2.2 连续低人数（1-5）衰减\n##### 场景描述1：玩家连续3天剩余人数为2, 1, 4\n###### 预期结果：第4天，1-5每个数字的权重乘以0.5，再重新归一化计算概率。\n##### 场景描述2：机制验证同高人数衰减场景2、3\n###### 预期结果：逻辑应与高人数衰减对称。\n## 6. 引导与提醒\n### 6.1 连续未参与弹窗\n#### 6.1.1 弹窗触发条件\n##### 场景描述1：玩家连续3天未点击活动入口参与活动，第4天完成任意1关后进入主页\n###### 预期结果：主动弹出活动宣传/引导弹窗。\n##### 场景描述2：玩家有未上线天数（例如2天未登录），算入连续未参与天数\n###### 预期结果：应触发，需求明确说明“包括未上线天数”。\n##### 场景描述3：玩家连续2天未参与，第3天参与了\n###### 预期结果：连续未参与天数重置为0。\n##### 场景描述4：玩家已处于活动进行中状态\n###### 预期结果：不应触发此弹窗。\n## 7. 时间与性能\n### 7.1 时间准确性\n#### 7.1.1 各类计时器\n##### 场景描述1：24小时活动总计时\n###### 预期结果：从点击Start起，服务器与客户端时间同步，准确倒计时24小时，不受设备休眠、杀进程影响。\n##### 场景描述2：30分钟失败冷却计时\n###### 预期结果：计时准确，客户端与服务器时间一致，防止本地修改时间作弊。\n##### 场景描述3：每关通关时间计时\n###### 预期结果：从点击Start开始累积，计时精确到秒，用于准确判断玩家类型。\n### 7.2 性能与兼容性\n#### 7.2.1 客户端性能\n##### 场景描述1：在低端安卓设备上，播放召集100人动效及过关动效\n###### 预期结果：动效流畅，不导致明显卡顿或闪退。\n##### 场景描述2：活动页面长时间打开（超过1小时）\n###### 预期结果：内存占用正常，无泄漏。\n#### 7.2.2 网络性能\n##### 场景描述3：在弱网络（高延迟、低带宽）下，点击Start、过关同步等操作\n###### 预期结果：有适当的加载提示，超时后有重试或错误提示机制，不卡死界面。\n##### 场景描述4：在Wi-Fi/4G/5G网络间切换\n###### 预期结果：活动状态能正确保持，计时不同步，数据能正常同步。\n## 8. 异常与边界场景\n### 8.1 服务器交互异常\n#### 8.1.1 请求失败与重试\n##### 场景描述1：点击Start时，服务器返回错误（非网络问题）\n###### 预期结果：提示活动开始失败，允许玩家重试。\n##### 场景描述2：过关同步时，服务器无响应\n###### 预期结果：客户端应缓存结果，并在有网络后自动重试同步，给予玩家提示。\n##### 场景描述3：活动期间，玩家账号在其他设备登录\n###### 预期结果：当前设备活动应被强制结束或同步为最新状态，避免状态冲突。\n### 8.2 客户端异常\n#### 8.2.1 应用生命周期\n##### 场景描述1：在活动进行中，来电或切换到其他应用\n###### 预期结果：返回游戏后，活动计时应继续，状态不变。\n##### 场景描述2：在活动动效播放时，强制杀死游戏进程\n###### 预期结果：重启游戏后，活动状态应能恢复至动效播放前或完成同步后的正确状态。\n##### 场景描述3：设备时间被手动修改\n###### 预期结果：活动计时应以服务器时间为准，防止通过修改本地时间绕过冷却或24小时限制。\n### 8.3 数据', '2', 'deepseek-reasoner', 1, 8, 121, NULL, '', '2026-03-23 14:39:05', '', NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
