<template>
  <div>
    <svg-icon icon-class="question" @click="goto" />
  </div>
</template>

<script>
export default {
  name: 'DishTestDoc',
  data() {
    return {
      url: 'http://doc.dishtest.vip/dishtest-vue'
    }
  },
  methods: {
    goto() {
      window.open(this.url)
    }
  }
}
</script>