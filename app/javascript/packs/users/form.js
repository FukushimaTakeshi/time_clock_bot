import Vue from 'vue/dist/vue.esm'

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: "#user-form",
    data: {
      user: {
        id: "test",
        password: undefined
      }
    }
  })
})
