<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { useMetaStore } from '../stores/meta'
import { authApi } from '../api'
import { extractErrors } from '../api/errors'

const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()
const meta = useMetaStore()

const form = reactive({
  name: '',
  email: '',
  nickname: '',
  region: '',
  self_introduction: '',
  password: '',
  password_confirmation: ''
})
const portraitFile = ref<File | null>(null)
const errors = ref<string[]>([])
const submitting = ref(false)

onMounted(() => {
  meta.ensureLoaded()
})

function onPortraitChange(event: Event) {
  const input = event.target as HTMLInputElement
  portraitFile.value = input.files?.[0] || null
}

async function signup() {
  submitting.value = true
  errors.value = []
  const formData = new FormData()
  formData.append('account[name]', form.name)
  formData.append('account[email]', form.email)
  formData.append('account[nickname]', form.nickname)
  formData.append('account[region]', form.region)
  formData.append('account[self_introduction]', form.self_introduction)
  formData.append('account[password]', form.password)
  formData.append('account[password_confirmation]', form.password_confirmation)
  if (portraitFile.value) formData.append('account[portrait]', portraitFile.value)
  try {
    const { data } = await authApi.signup(formData)
    auth.setAccount(data.account)
    flash.notice(data.message)
    router.push({ name: 'posts' })
  } catch (error) {
    errors.value = extractErrors(error, '登録に失敗しました')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <h2>アカウント登録</h2>
    <div v-if="errors.length" class="alert alert-danger" role="alert">
      <ul class="mb-0">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </div>
    <form @submit.prevent="signup">
      <div class="form-floating mb-3">
        <input id="account-name" v-model="form.name" type="text" class="form-control" placeholder="アカウント名" autocomplete="username" autofocus />
        <label for="account-name">アカウント名</label>
        <span>半角英数字と_で入力してください</span>
      </div>
      <div class="form-floating mb-3">
        <input id="account-email" v-model="form.email" type="email" class="form-control" placeholder="メールアドレス" autocomplete="email" />
        <label for="account-email">メールアドレス</label>
      </div>
      <div class="form-floating mb-3">
        <input id="account-nickname" v-model="form.nickname" type="text" class="form-control" placeholder="ニックネーム" autocomplete="nickname" />
        <label for="account-nickname">ニックネーム</label>
      </div>
      <div class="form-group mb-3">
        <label for="account-portrait">アイコン</label>
        <div class="input-group form-file">
          <input id="account-portrait" type="file" class="form-control" accept="image/png,image/jpeg" @change="onPortraitChange" />
        </div>
      </div>
      <div class="form-floating mb-3">
        <select id="account-region" v-model="form.region" class="form-select">
          <option value=""></option>
          <option v-for="region in meta.regions" :key="region.value" :value="region.label">{{ region.label }}</option>
        </select>
        <label for="account-region">地域</label>
      </div>
      <div class="form-floating mb-3">
        <textarea id="account-self-introduction" v-model="form.self_introduction" class="form-control" placeholder="自己紹介" style="height: 100px;"></textarea>
        <label for="account-self-introduction">自己紹介</label>
      </div>
      <div class="form-floating mb-3">
        <input id="account-password" v-model="form.password" type="password" class="form-control" placeholder="パスワード" autocomplete="new-password" />
        <label for="account-password">パスワード</label>
      </div>
      <em>パスワードは6文字以上で入力してください</em>
      <div class="form-floating mb-3">
        <input id="account-password-confirmation" v-model="form.password_confirmation" type="password" class="form-control" placeholder="パスワード（確認）" autocomplete="new-password" />
        <label for="account-password-confirmation">パスワード（確認）</label>
      </div>
      <div class="actions">
        <button id="create-account" type="submit" class="btn btn-primary" :disabled="submitting">アカウント登録</button>
      </div>
    </form>
    <div class="mt-4">
      <router-link :to="{ name: 'login' }">ログインはこちら</router-link>
    </div>
  </div>
</template>
