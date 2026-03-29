import { marked } from 'marked';

/**
 * 测试用例内容解析 mixin
 * 共享 Markdown渲染、表格解析、思维导图解析、文件下载 方法
 */
export default {
  data() {
    return {
      parsedTableData: []
    };
  },
  methods: {
    renderMarkdown(content) {
      if (!content) return '';
      return marked(content);
    },
    parseContentToTable(content) {
      if (!content) { this.parsedTableData = []; return; }

      console.log('开始解析内容，长度:', content.length);
      console.log('内容前500字符:', content.substring(0, 500));

      // 尝试多种格式解析
      let data = [];

      // 方法1: 尝试解析标准 Markdown 格式
      data = this.parseStandardMarkdown(content);
      console.log('标准Markdown解析结果:', data.length, '条');
      if (data.length > 0) {
        this.parsedTableData = data;
        return;
      }

      // 方法2: 尝试解析 Markdown 表格格式
      data = this.parseMarkdownTable(content);
      console.log('Markdown表格解析结果:', data.length, '条');
      if (data.length > 0) {
        this.parsedTableData = data;
        return;
      }

      // 方法3: 尝试解析列表格式
      data = this.parseListFormat(content);
      console.log('列表格式解析结果:', data.length, '条');
      if (data.length > 0) {
        this.parsedTableData = data;
        return;
      }

      // 方法4: 尝试解析纯文本格式
      data = this.parsePlainText(content);
      console.log('纯文本解析结果:', data.length, '条');
      this.parsedTableData = data;
    },

    // 解析标准 Markdown 层级格式
    parseStandardMarkdown(content) {
      const lines = content.split('\n');
      const data = [];
      let module = '', testPoint = '', verifyPoint = '', scenario = '';

      for (let line of lines) {
        line = line.trim();
        if (!line) continue;

        if (line.startsWith('## ')) {
          module = line.substring(3).trim();
        } else if (line.startsWith('### ')) {
          testPoint = line.substring(4).trim();
        } else if (line.startsWith('#### ')) {
          verifyPoint = line.substring(5).trim();
        } else if (line.startsWith('##### ')) {
          scenario = line.substring(6).trim();
        } else if (line.startsWith('###### ')) {
          let text = line.substring(7).trim();
          let expected = text.replace(/^预期结果[：:]/, '').trim();
          data.push({ module, testPoint, verifyPoint, scenario, expected });
        }
      }
      return data;
    },

    // 解析 Markdown 表格格式
    parseMarkdownTable(content) {
      const data = [];
      const lines = content.split('\n');
      let inTable = false;

      for (let line of lines) {
        line = line.trim();
        if (!line) continue;

        // 检测表格行
        if (line.startsWith('|') && line.endsWith('|')) {
          const cells = line.split('|').map(c => c.trim()).filter(c => c);

          // 跳过分隔行
          if (cells.every(c => /^[-:]+$/.test(c))) {
            inTable = true;
            continue;
          }

          if (!inTable) {
            // 表头行，跳过
            continue;
          } else {
            // 数据行
            if (cells.length >= 4) {
              data.push({
                module: cells[0] || '',
                testPoint: cells[1] || '',
                verifyPoint: cells[2] || '',
                scenario: cells[3] || '',
                expected: cells[4] || ''
              });
            }
          }
        }
      }
      return data;
    },

    // 解析列表格式
    parseListFormat(content) {
      const data = [];
      const lines = content.split('\n');

      console.log('parseListFormat: 总行数', lines.length);

      // 上下文状态
      let currentModule = '';
      let currentTestPoint = '';
      let currentVerifyPoint = '';
      let currentScenario = '';
      let currentScenarioDesc = '';
      let currentExpected = '';

      for (let i = 0; i < lines.length; i++) {
        let line = lines[i].trim();
        if (!line) continue;

        console.log(`行${i}: ${line.substring(0, 50)}`);

        // 检测是否是新的测试点/验证点（通常是较短的标题行，不包含冒号）
        // 例如："可消除组数>=5且空格数>=3"
        if (!line.includes('：') && !line.includes(':') &&
            !line.startsWith('场景') &&
            line.length < 100 &&
            !line.includes('。')) {

          // 如果之前有完整的场景，先保存
          if (currentScenario && currentExpected) {
            data.push({
              module: currentModule,
              testPoint: currentTestPoint,
              verifyPoint: currentVerifyPoint,
              scenario: currentScenario + (currentScenarioDesc ? '；' + currentScenarioDesc : ''),
              expected: currentExpected
            });
            currentScenario = '';
            currentScenarioDesc = '';
            currentExpected = '';
          }

          // 判断是测试点还是验证点
          if (!currentTestPoint) {
            currentTestPoint = line;
            console.log('  -> 识别为测试点:', line);
          } else {
            currentVerifyPoint = line;
            console.log('  -> 识别为验证点:', line);
          }
          continue;
        }

        // 匹配场景编号（场景1：、场景2：等）
        const scenarioMatch = line.match(/^场景\s*(\d+)[：:]\s*(.*)$/);
        if (scenarioMatch) {
          console.log('  -> 匹配到场景:', scenarioMatch[2]);

          // 保存之前的场景
          if (currentScenario && currentExpected) {
            data.push({
              module: currentModule,
              testPoint: currentTestPoint,
              verifyPoint: currentVerifyPoint,
              scenario: currentScenario + (currentScenarioDesc ? '；' + currentScenarioDesc : ''),
              expected: currentExpected
            });
          }

          // 开始新场景
          currentScenario = scenarioMatch[2].trim();
          currentScenarioDesc = '';
          currentExpected = '';
          continue;
        }

        // 匹配场景描述
        const scenarioDescMatch = line.match(/^场景描述[：:]\s*(.*)$/);
        if (scenarioDescMatch) {
          currentScenarioDesc = scenarioDescMatch[1].trim();
          console.log('  -> 场景描述:', currentScenarioDesc);
          continue;
        }

        // 匹配预期结果
        const expectedMatch = line.match(/^预期结果[：:]\s*(.*)$/);
        if (expectedMatch) {
          currentExpected = expectedMatch[1].trim();
          console.log('  -> 预期结果:', currentExpected);

          // 如果有完整的场景信息，立即保存
          if (currentScenario) {
            const record = {
              module: currentModule,
              testPoint: currentTestPoint,
              verifyPoint: currentVerifyPoint,
              scenario: currentScenario + (currentScenarioDesc ? '；' + currentScenarioDesc : ''),
              expected: currentExpected
            };
            console.log('  -> 保存记录:', record);
            data.push(record);

            // 重置场景相关变量，但保留上下文
            currentScenario = '';
            currentScenarioDesc = '';
            currentExpected = '';
          }
          continue;
        }

        // 如果行很长且包含句号，可能是场景描述或预期结果的延续
        if (line.length > 50 || line.includes('。')) {
          if (currentScenarioDesc && !currentExpected) {
            currentScenarioDesc += line;
          } else if (currentExpected) {
            currentExpected += line;
          } else if (currentScenario && !currentScenarioDesc) {
            currentScenarioDesc = line;
          }
        }
      }

      // 保存最后一个场景
      if (currentScenario && currentExpected) {
        data.push({
          module: currentModule,
          testPoint: currentTestPoint,
          verifyPoint: currentVerifyPoint,
          scenario: currentScenario + (currentScenarioDesc ? '；' + currentScenarioDesc : ''),
          expected: currentExpected
        });
      }

      console.log('parseListFormat 最终结果:', data.length, '条记录');
      return data;
    },

    // 解析纯文本格式（最后的兜底方案）
    parsePlainText(content) {
      const data = [];
      const lines = content.split('\n');
      let currentCase = { module: '', testPoint: '', verifyPoint: '', scenario: '', expected: '' };
      let lineBuffer = [];

      for (let line of lines) {
        line = line.trim();
        if (!line) {
          if (lineBuffer.length >= 2) {
            // 至少有场景和预期结果
            currentCase.scenario = lineBuffer.slice(0, -1).join(' ');
            currentCase.expected = lineBuffer[lineBuffer.length - 1];
            data.push({ ...currentCase });
            lineBuffer = [];
          }
          continue;
        }

        // 检测是否是标题行（可能是模块或测试点）
        if (line.length < 50 && !line.includes('。') && !line.includes('.')) {
          if (!currentCase.module) {
            currentCase.module = line;
          } else if (!currentCase.testPoint) {
            currentCase.testPoint = line;
          } else {
            lineBuffer.push(line);
          }
        } else {
          lineBuffer.push(line);
        }
      }

      // 处理最后的缓冲
      if (lineBuffer.length >= 2) {
        currentCase.scenario = lineBuffer.slice(0, -1).join(' ');
        currentCase.expected = lineBuffer[lineBuffer.length - 1];
        data.push(currentCase);
      }

      return data;
    },
    parseContentToMindMap(content, title) {
      const root = { id: 'root', topic: title || '测试用例', children: [] };

      // 尝试标准 Markdown 格式
      let result = this.parseMindMapFromMarkdown(content, title);
      if (result.data.children.length > 0) return result;

      // 尝试从表格数据解析
      if (this.parsedTableData && this.parsedTableData.length > 0) {
        return this.parseMindMapFromTable(this.parsedTableData, title);
      }

      // 返回基本结构
      return { meta: { name: title || '测试用例', version: '1.0' }, format: 'node_tree', data: root };
    },

    parseMindMapFromMarkdown(content, title) {
      const lines = content.split('\n');
      const root = { id: 'root', topic: title || '测试用例', children: [] };
      let id = 1;

      // 上下文状态
      let moduleNode = null;
      let testPointNode = null;
      let verifyPointNode = null;
      let scenarioNode = null;

      for (let line of lines) {
        line = line.trim();
        if (!line) continue;

        // 忽略 # 一级标题（已经有根标题 title）
        if (line.startsWith('# ') && !line.startsWith('## ')) {
          continue;
        }

        // 标准 Markdown 标题
        if (line.startsWith('## ')) {
          moduleNode = { id: 'n' + id++, topic: line.substring(3).trim(), children: [] };
          root.children.push(moduleNode);
          testPointNode = verifyPointNode = scenarioNode = null;
          continue;
        } else if (line.startsWith('### ') && moduleNode) {
          testPointNode = { id: 'n' + id++, topic: line.substring(4).trim(), children: [] };
          moduleNode.children.push(testPointNode);
          verifyPointNode = scenarioNode = null;
          continue;
        } else if (line.startsWith('#### ') && testPointNode) {
          verifyPointNode = { id: 'n' + id++, topic: line.substring(5).trim(), children: [] };
          testPointNode.children.push(verifyPointNode);
          scenarioNode = null;
          continue;
        } else if (line.startsWith('##### ')) {
          const parent = verifyPointNode || testPointNode || moduleNode;
          if (parent) {
            scenarioNode = { id: 'n' + id++, topic: line.substring(6).trim(), children: [] };
            parent.children.push(scenarioNode);
          }
          continue;
        } else if (line.startsWith('###### ')) {
          const parent = scenarioNode || verifyPointNode || testPointNode || moduleNode;
          if (parent) {
            parent.children.push({ id: 'n' + id++, topic: line.substring(7).trim() });
          }
          continue;
        }

        // 匹配功能模块
        const moduleMatch = line.match(/^(?:功能模块|模块)[：:]\s*(.+)$/i);
        if (moduleMatch) {
          moduleNode = { id: 'n' + id++, topic: moduleMatch[1].trim(), children: [] };
          root.children.push(moduleNode);
          testPointNode = verifyPointNode = scenarioNode = null;
          continue;
        }

        // 匹配测试点
        const testPointMatch = line.match(/^(?:测试点|测试项)[：:]\s*(.+)$/i);
        if (testPointMatch && moduleNode) {
          testPointNode = { id: 'n' + id++, topic: testPointMatch[1].trim(), children: [] };
          moduleNode.children.push(testPointNode);
          verifyPointNode = scenarioNode = null;
          continue;
        }

        // 匹配验证点或场景组
        const verifyPointMatch = line.match(/^(?:验证点|检查点)[：:]\s*(.+)$/i);
        if (verifyPointMatch && testPointNode) {
          verifyPointNode = { id: 'n' + id++, topic: verifyPointMatch[1].trim(), children: [] };
          testPointNode.children.push(verifyPointNode);
          scenarioNode = null;
          continue;
        }

        // 匹配场景编号（场景1：、场景2：等）
        const scenarioNumMatch = line.match(/^场景\s*(\d+)[：:]\s*(.+)$/i);
        if (scenarioNumMatch) {
          const parent = verifyPointNode || testPointNode || moduleNode;
          if (parent) {
            scenarioNode = { id: 'n' + id++, topic: scenarioNumMatch[2].trim(), children: [] };
            parent.children.push(scenarioNode);
          }
          continue;
        }

        // 匹配场景描述
        const scenarioDescMatch = line.match(/^(?:场景描述|描述)[：:]\s*(.+)$/i);
        if (scenarioDescMatch && scenarioNode) {
          scenarioNode.children.push({ id: 'n' + id++, topic: '描述：' + scenarioDescMatch[1].trim() });
          continue;
        }

        // 匹配预期结果
        const expectedMatch = line.match(/^(?:预期结果|期望结果)[：:]\s*(.+)$/i);
        if (expectedMatch && scenarioNode) {
          scenarioNode.children.push({ id: 'n' + id++, topic: '预期：' + expectedMatch[1].trim() });
          continue;
        }

        // 列表项
        if ((line.startsWith('-') || line.startsWith('*') || /^\d+\./.test(line))) {
          const text = line.replace(/^[-*\d.]\s*/, '').trim();
          const parent = scenarioNode || verifyPointNode || testPointNode || moduleNode;
          if (parent) {
            parent.children.push({ id: 'n' + id++, topic: text });
          }
          continue;
        }

        // 未匹配的行，如果较短且不包含句号，可能是标题
        if (line.length < 80 && !line.includes('。') && !line.includes('.')) {
          const parent = testPointNode || moduleNode;
          if (parent && !verifyPointNode) {
            verifyPointNode = { id: 'n' + id++, topic: line, children: [] };
            parent.children.push(verifyPointNode);
            scenarioNode = null;
          }
        }
      }

      return { meta: { name: title || '测试用例', version: '1.0' }, format: 'node_tree', data: root };
    },

    parseMindMapFromTable(tableData, title) {
      const root = { id: 'root', topic: title || '测试用例', children: [] };
      let id = 1;
      const moduleMap = {};

      for (let row of tableData) {
        // 按模块分组
        if (!moduleMap[row.module]) {
          moduleMap[row.module] = { id: 'n' + id++, topic: row.module, children: [] };
          root.children.push(moduleMap[row.module]);
        }

        const moduleNode = moduleMap[row.module];

        // 添加测试点
        let testPointNode = moduleNode.children.find(n => n.topic === row.testPoint);
        if (!testPointNode) {
          testPointNode = { id: 'n' + id++, topic: row.testPoint, children: [] };
          moduleNode.children.push(testPointNode);
        }

        // 添加验证点
        if (row.verifyPoint) {
          let verifyNode = testPointNode.children.find(n => n.topic === row.verifyPoint);
          if (!verifyNode) {
            verifyNode = { id: 'n' + id++, topic: row.verifyPoint, children: [] };
            testPointNode.children.push(verifyNode);
          }

          // 添加场景和预期
          if (row.scenario) {
            const scenarioNode = { id: 'n' + id++, topic: row.scenario, children: [] };
            verifyNode.children.push(scenarioNode);
            if (row.expected) {
              scenarioNode.children.push({ id: 'n' + id++, topic: '预期：' + row.expected });
            }
          }
        } else {
          // 没有验证点，直接添加场景
          if (row.scenario) {
            const scenarioNode = { id: 'n' + id++, topic: row.scenario, children: [] };
            testPointNode.children.push(scenarioNode);
            if (row.expected) {
              scenarioNode.children.push({ id: 'n' + id++, topic: '预期：' + row.expected });
            }
          }
        }
      }

      return { meta: { name: title || '测试用例', version: '1.0' }, format: 'node_tree', data: root };
    },
    renderMindMap(containerId, content, title) {
      if (typeof jsMind === 'undefined') {
        this.$modal.msgError("思维导图库加载失败");
        return;
      }
      if (!content) return;
      const container = document.getElementById(containerId);
      if (!container) return;
      container.innerHTML = '';
      try {
        const jm = new jsMind({ container: containerId, theme: 'primary', editable: false, mode: 'full' });
        jm.show(this.parseContentToMindMap(content, title));
        return jm;
      } catch (error) {
        this.$modal.msgError("思维导图渲染失败: " + error.message);
      }
    },
    downloadFile(data, filename, mimeType) {
      const blob = new Blob([data], { type: mimeType });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      link.click();
      window.URL.revokeObjectURL(url);
    }
  }
};
