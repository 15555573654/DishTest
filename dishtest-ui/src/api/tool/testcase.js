import request from '@/utils/request'

// 查询测试用例列表
export function listTestCase(query) {
  return request({
    url: '/tool/testcase/list',
    method: 'get',
    params: query
  })
}

// 查询测试用例详细
export function getTestCase(caseId) {
  return request({
    url: '/tool/testcase/' + caseId,
    method: 'get'
  })
}

// 新增测试用例
export function addTestCase(data) {
  return request({
    url: '/tool/testcase',
    method: 'post',
    data: data
  })
}

// 修改测试用例
export function updateTestCase(data) {
  return request({
    url: '/tool/testcase',
    method: 'put',
    data: data
  })
}

// 删除测试用例
export function delTestCase(caseId) {
  return request({
    url: '/tool/testcase/' + caseId,
    method: 'delete'
  })
}

// 上传测试文档
export function uploadTestCase(data) {
  return request({
    url: '/tool/testcase/upload',
    method: 'post',
    headers: { 'Content-Type': 'multipart/form-data' },
    data: data
  })
}

// 生成测试用例
export function generateTestCase(caseId) {
  return request({
    url: '/tool/testcase/generate/' + caseId,
    method: 'post'
  })
}

// 导出CSV
export function exportCsv(caseId) {
  return request({
    url: '/tool/testcase/exportCsv/' + caseId,
    method: 'get',
    responseType: 'blob'
  })
}

// 导出XMind
export function exportXMind(caseId) {
  return request({
    url: '/tool/testcase/exportXMind/' + caseId,
    method: 'get',
    responseType: 'blob'
  })
}
