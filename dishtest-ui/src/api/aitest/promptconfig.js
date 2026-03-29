import request from '@/utils/request'

// 查询AI提示词配置列表
export function listPromptconfig(query) {
  return request({
    url: '/aitest/promptconfig/list',
    method: 'get',
    params: query
  })
}

// 查询AI提示词配置详细
export function getPromptconfig(configId) {
  return request({
    url: '/aitest/promptconfig/' + configId,
    method: 'get'
  })
}

// 新增AI提示词配置
export function addPromptconfig(data) {
  return request({
    url: '/aitest/promptconfig',
    method: 'post',
    data: data
  })
}

// 修改AI提示词配置
export function updatePromptconfig(data) {
  return request({
    url: '/aitest/promptconfig',
    method: 'put',
    data: data
  })
}

// 删除AI提示词配置
export function delPromptconfig(configId) {
  return request({
    url: '/aitest/promptconfig/' + configId,
    method: 'delete'
  })
}
