import request from '@/utils/request'

// 查询MQTT任务配置列表
export function listConfig(query) {
  return request({
    url: '/mqtt/config/list',
    method: 'get',
    params: query
  })
}

// 查询MQTT任务配置详细
export function getConfig(configId) {
  return request({
    url: '/mqtt/config/' + configId,
    method: 'get'
  })
}

// 新增MQTT任务配置
export function addConfig(data) {
  return request({
    url: '/mqtt/config',
    method: 'post',
    data: data
  })
}

// 修改MQTT任务配置
export function updateConfig(data) {
  return request({
    url: '/mqtt/config',
    method: 'put',
    data: data
  })
}

// 删除MQTT任务配置
export function delConfig(configId) {
  return request({
    url: '/mqtt/config/' + configId,
    method: 'delete'
  })
}

// 发送配置到设备
export function sendConfig(data) {
  return request({
    url: '/mqtt/config/send',
    method: 'post',
    data: data
  })
}

// 验证JSON格式
export function validateJson(content) {
  return request({
    url: '/mqtt/config/validateJson',
    method: 'post',
    data: { content: content }
  })
}
