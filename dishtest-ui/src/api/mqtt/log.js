import request from '@/utils/request'

// 查询MQTT操作日志列表
export function listLog(query) {
  return request({
    url: '/mqtt/log/list',
    method: 'get',
    params: query
  })
}

// 查询MQTT操作日志详细
export function getLog(logId) {
  return request({
    url: '/mqtt/log/' + logId,
    method: 'get'
  })
}

// 删除MQTT操作日志
export function delLog(logId) {
  return request({
    url: '/mqtt/log/' + logId,
    method: 'delete'
  })
}

// 清空MQTT操作日志
export function cleanLog() {
  return request({
    url: '/mqtt/log/clean',
    method: 'delete'
  })
}
