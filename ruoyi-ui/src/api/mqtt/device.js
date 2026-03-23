import request from '@/utils/request'

// 查询MQTT设备列表
export function listDevice(query) {
  return request({
    url: '/mqtt/device/list',
    method: 'get',
    params: query
  })
}

// 查询MQTT设备详细
export function getDevice(deviceId) {
  return request({
    url: '/mqtt/device/' + deviceId,
    method: 'get'
  })
}

// 新增MQTT设备
export function addDevice(data) {
  return request({
    url: '/mqtt/device',
    method: 'post',
    data: data
  })
}

// 修改MQTT设备
export function updateDevice(data) {
  return request({
    url: '/mqtt/device',
    method: 'put',
    data: data
  })
}

// 删除MQTT设备
export function delDevice(deviceId) {
  return request({
    url: '/mqtt/device/' + deviceId,
    method: 'delete'
  })
}

// 发送命令到设备
export function sendCommand(data) {
  return request({
    url: '/mqtt/device/command',
    method: 'post',
    data: data
  })
}

// 获取设备统计信息
export function getStatistics() {
  return request({
    url: '/mqtt/device/statistics',
    method: 'get'
  })
}
