<template>
  <div class="redirect-container">
    <div class="redirect-content">
      <i class="el-icon-loading"></i>
      <p>正在跳转到设备管理...</p>
    </div>
  </div>
</template>

<script>
export default {
  name: "Index",
  created() {
    this.redirectToDevice();
  },
  activated() {
    // 当组件被 keep-alive 缓存后重新激活时也执行跳转
    this.redirectToDevice();
  },
  methods: {
    redirectToDevice() {
      // 检查当前路由，避免无限循环
      if (this.$route.path === '/index' || this.$route.path === '/') {
        this.$router.replace('/mqtt/device');
      }
    }
  }
}
</script>

<style scoped>
.redirect-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
}

.redirect-content {
  text-align: center;
  font-size: 16px;
  color: #606266;
}

.redirect-content i {
  font-size: 32px;
  margin-bottom: 10px;
}
</style>
