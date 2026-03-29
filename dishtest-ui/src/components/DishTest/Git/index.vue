<template>
  <div>
    <svg-icon icon-class="github" @click="goto" />
  </div>
</template>

<script>
export default {
  name: 'DishTestGit',
  data() {
    return {
      url: 'https://gitee.com/y_project/DishTest'
    }
  },
  methods: {
    goto() {
      window.open(this.url)
    }
  }
}
</script>