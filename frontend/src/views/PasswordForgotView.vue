<script setup>
import { ref } from 'vue'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'

const flash = useFlashStore()

const email = ref('')
const sent = ref(false)
const submitting = ref(false)

async function sendResetMail() {
  submitting.value = true
  try {
    const { data } = await authApi.sendResetMail(email.value)
    flash.notice(data.message)
    sent.value = true
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <div class="form-signin mx-auto">
      <h2>パスワード再設定</h2>
      <p>登録したメールアドレスを入力してください。パスワード再設定用のリンクを送信します。</p>
      <div v-if="sent" class="alert alert-success">
        メールを送信しました。メール内のリンクからパスワードを再設定してください。
      </div>
      <form @submit.prevent="sendResetMail">
        <div class="form-floating mb-3">
          <input id="forgot-email" v-model="email" type="email" class="form-control" placeholder="メールアドレス" autocomplete="email" autofocus />
          <label for="forgot-email">メールアドレス</label>
        </div>
        <button type="submit" class="btn btn-primary w-100" :disabled="submitting">送信する</button>
      </form>
      <div class="mt-4">
        <router-link :to="{ name: 'login' }">ログインに戻る</router-link>
      </div>
    </div>
  </div>
</template>
