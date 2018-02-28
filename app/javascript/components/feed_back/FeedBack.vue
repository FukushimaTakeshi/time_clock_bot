<template>
  <form id="feed-back-vue" action="hoge" accept-charset="UTF-8" data-remote="true" method="post">
    <input name="utf8" type="hidden" value="✓" />
    <input name="authenticity_token" type="hidden" value="csrf_token" />
    <div class="error-area">
      <p v-for="error in errors" :key="error.key">{{ error.message }}</p>
    </div>
    <div class="form-group">
      <label for="user_firstname">名前:</label>
      <input type="text" name="user[firstname]" v-model="firstname">
    </div>
    <div class="form-group">
      <label for="user_email">メール:</label>
      <input type="text" name="user[email]" v-model="email">
    </div>
    <div class="submit">
      <button name="button" type="submit" @click.prevent="onSubmit">
        登録する
      </button>
    </div>
  </form>
</template>

<script>
export default {
  data: function () {
    return {
      errors: [],
      firstname: '',
      email: '',
      csrf_token: ''
    }
  },
  mounted: function() {
    this.csrf_token = document.querySelector('[name=csrf-token]').content
  },
  methods: {
      onSubmit: function() {
        this.errors = []
        if(this.valid()) {
          console.log('submit!')
        }
      },
      valid: function() {
        this.validateFirstName()
        this.validateEmail()
        return this.errors.length === 0
      },
      validateFirstName: function() {
        if(this.firstname.length == 0) this.errors.push({ key: 'firstname', message: '名前を入力してください'})
      },
      validateEmail: function() {
        if(this.email == '') this.errors.push({ key: 'email', message: 'メールアドレスを入力してください' })
      },
  }
}
</script>
