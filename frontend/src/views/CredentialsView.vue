<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'
import { extractErrors } from '../api/errors'

const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()

const form = reactive({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
  current_password: ''
})
const errors = ref<string[]>([])
const submitting = ref(false)

onMounted(() => {
  form.name = auth.account?.name || ''
  form.email = auth.account?.email || ''
})

async function updateCredentials() {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await authApi.updateCredentials({ account: { ...form } })
    auth.setAccount(data.account)
    flash.notice(data.message)
    router.push({ name: 'account-show', params: { id: data.account.id } })
  } catch (error) {
    errors.value = extractErrors(error, '更新に失敗しました')
  } finally {
    submitting.value = false
  }
}

async function deleteAccount() {
  if (!window.confirm('アカウントを削除すると投稿した内容も全て削除されますがよろしいですか？')) return
  const { data } = await authApi.deleteAccount()
  auth.clear()
  flash.notice(data.message)
  router.push({ name: 'top' })
}
</script>

<template>
  <div class="container mt-5">
    <h2>アカウント情報の変更</h2>
    <div v-if="errors.length" class="alert alert-danger" role="alert">
      <ul class="mb-0">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </div>
    <form @submit.prevent="updateCredentials">
      <div class="form-floating mb-3">
        <input id="credentials-name" v-model="form.name" type="text" class="form-control" placeholder="アカウント名" autocomplete="username" />
        <label for="credentials-name">アカウント名</label>
        <i>(半角英数字とアンダーバーで入力)</i>
      </div>
      <div class="form-floating mb-3">
        <input id="credentials-email" v-model="form.email" type="email" class="form-control" placeholder="メールアドレス" autocomplete="email" />
        <label for="credentials-email">メールアドレス</label>
      </div>
      <div class="mb-3">
        <a
          class="btn btn-outline-secondary"
          data-bs-toggle="collapse"
          href="#password-collapse"
          role="button"
          aria-expanded="false"
          aria-controls="password-collapse"
        >パスワードの変更</a>
        <div class="collapse" id="password-collapse">
          <i>(変更しない場合は空欄のままにしてください)</i>
          <div class="form-floating mb-3">
            <input id="credentials-password" v-model="form.password" type="password" class="form-control" placeholder="新規パスワード" autocomplete="new-password" />
            <label for="credentials-password">新規パスワード</label>
            <em>パスワードは6文字以上で入力してください</em>
          </div>
          <div class="form-floating mb-3">
            <input id="credentials-password-confirmation" v-model="form.password_confirmation" type="password" class="form-control" placeholder="新規パスワード(確認)" autocomplete="new-password" />
            <label for="credentials-password-confirmation">新規パスワード(確認)</label>
          </div>
        </div>
      </div>
      <div class="form-floating mb-3">
        <input id="credentials-current-password" v-model="form.current_password" type="password" class="form-control" placeholder="現在のパスワード" autocomplete="current-password" />
        <label for="credentials-current-password">現在のパスワード</label>
      </div>
      <div class="actions mb-5 d-flex justify-content-evenly">
        <button id="update-account" type="submit" class="btn btn-primary" :disabled="submitting">更新する</button>
        <button type="button" class="btn btn-secondary" @click="router.back()">戻る</button>
      </div>
    </form>
    <hr />
    <div class="dropdown d-flex justify-content-center">
      <button type="button" class="btn btn-outline-danger" @click="deleteAccount">アカウント削除</button>
    </div>
  </div>
</template>
