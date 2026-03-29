import request from '@/utils/request'

// 查询AI模型配置列表
export function listModelconfig(query) {
  return request({
    url: '/aitest/modelconfig/list',
    method: 'get',
    params: query
  })
}

// 查询AI模型配置详细
export function getModelconfig(modelId) {
  return request({
    url: '/aitest/modelconfig/' + modelId,
    method: 'get'
  })
}

// 新增AI模型配置
export function addModelconfig(data) {
  return request({
    url: '/aitest/modelconfig',
    method: 'post',
    data: data
  })
}

// 修改AI模型配置
export function updateModelconfig(data) {
  return request({
    url: '/aitest/modelconfig',
    method: 'put',
    data: data
  })
}

// 删除AI模型配置
export function delModelconfig(modelId) {
  return request({
    url: '/aitest/modelconfig/' + modelId,
    method: 'delete'
  })
}

// 测试模型连接
export function testConnection(data) {
  return request({
    url: '/aitest/modelconfig/testConnection',
    method: 'post',
    data: data
  })
}
