import request from '@/utils/request'

// 获取动态 TURN 临时凭证
export function getTurnCredentials() {
  return request({
    url: '/webrtc/turn/credentials',
    method: 'get'
  })
}
