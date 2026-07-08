<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'

const route = useRoute()
const router = useRouter()
const flash = useFlashStore()

const form = reactive({ password: '', password_confirmation: '' })
const errors = ref([])
const submitting = ref(false)

async function resetPassword() {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await authApi.resetPassword({
      reset_password_token: route.query.reset_password_token,
      password: form.password,
      password_confirmation: form.password_confirmation
    })
    flash.notice(data.message)
    router.push({ name: 'login' })
  } catch (error) {
    errors.value = error.response?.data?.errors || ['パスワードの変更に失敗しました']
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <div class="form-signin mx-auto">
      <h2>新しいパスワードの設定</h2>
      <div v-if="errors.length" class="alert alert-danger" role="alert">
        <ul class="mb-0">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </div>
      <form @submit.prevent="resetPassword">
        <div class="form-floating mb-3">
          <input id="reset-password" v-model="form.password" type="password" class="form-control" placeholder="新しいパスワード" autocomplete="new-password" autofocus />
          <label for="reset-password">新しいパスワード</label>
        </div>
        <div class="form-floating mb-3">
          <input id="reset-password-confirmation" v-model="form.password_confirmation" type="password" class="form-control" placeholder="新しいパスワード（確認）" autocomplete="new-password" />
          <label for="reset-password-confirmation">新しいパスワード（確認）</label>
        </div>
        <button type="submit" class="btn btn-primary w-100" :disabled="submitting">パスワードを変更する</button>
      </form>
    </div>
  </div>
</template>
