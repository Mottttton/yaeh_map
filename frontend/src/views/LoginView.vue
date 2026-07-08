<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()

const form = reactive({ email: '', password: '', remember_me: false })
const errorMessage = ref('')
const submitting = ref(false)

async function login() {
  submitting.value = true
  errorMessage.value = ''
  try {
    const { data } = await authApi.login(form)
    auth.setAccount(data.account)
    flash.notice(data.message)
    router.push(route.query.redirect || { name: 'posts' })
  } catch (error) {
    errorMessage.value = error.response?.data?.error || 'ログインに失敗しました'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <div class="form-signin mx-auto">
      <h2>ログイン</h2>
      <div v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</div>
      <form @submit.prevent="login">
        <div class="form-floating">
          <input id="login-email" v-model="form.email" type="email" class="form-control" placeholder="メールアドレス" autocomplete="email" autofocus />
          <label for="login-email">メールアドレス</label>
        </div>
        <div class="form-floating">
          <input id="login-password" v-model="form.password" type="password" class="form-control" placeholder="パスワード" autocomplete="current-password" />
          <label for="login-password">パスワード</label>
        </div>
        <div class="form-check mb-3">
          <input id="login-remember" v-model="form.remember_me" type="checkbox" class="form-check-input" />
          <label for="login-remember" class="form-check-label">ログインを記憶する</label>
        </div>
        <button id="sign-in-submit" type="submit" class="btn btn-primary w-100" :disabled="submitting">ログイン</button>
      </form>
      <div class="mt-4">
        <div><router-link :to="{ name: 'signup' }">新規登録はこちら</router-link></div>
        <div><router-link :to="{ name: 'password-forgot' }">パスワードを忘れた場合</router-link></div>
      </div>
    </div>
  </div>
</template>
