import Vue from 'vue/dist/vue.esm'

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: "#user-form",
    data: {
      user: {
        id: document.querySelector("[v-model='user.id']").value,
        password: document.querySelector("[v-model='user.password']").value,
      }
    },

    computed: {
      validation: function() {
        var user = this.user
        return {
          id: !!user.id.trim(),
          password: !!user.password.trim()
        }
      },

      isValid: function() {
        var validation = this.validation
        return Object.keys(validation).every(function (key) {
          return validation[key]
        })
      },
    }
  })
})
