import request from '@/utils/request'

// 连接MQTT服务器
export function connect(data) {
  return request({
    url: '/mqtt/connection/connect',
    method: 'post',
    data: data
  })
}

// 断开MQTT连接
export function disconnect() {
  return request({
    url: '/mqtt/connection/disconnect',
    method: 'post'
  })
}

// 获取MQTT连接状态
export function getStatus() {
  return request({
    url: '/mqtt/connection/status',
    method: 'get'
  })
}
