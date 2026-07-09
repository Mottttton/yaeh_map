<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
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
  <div class="mx-auto mt-10 w-full max-w-xl px-4">
    <h2 class="mb-4 text-2xl font-semibold">アカウント登録</h2>
    <Alert v-if="errors.length" variant="destructive" role="alert" class="mb-4">
      <AlertDescription>
        <ul class="list-disc pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </AlertDescription>
    </Alert>
    <form class="space-y-4" @submit.prevent="signup">
      <div class="space-y-2">
        <Label for="account-name">アカウント名</Label>
        <Input id="account-name" v-model="form.name" type="text" autocomplete="username" autofocus />
        <p class="text-muted-foreground text-sm">半角英数字と_で入力してください</p>
      </div>
      <div class="space-y-2">
        <Label for="account-email">メールアドレス</Label>
        <Input id="account-email" v-model="form.email" type="email" autocomplete="email" />
      </div>
      <div class="space-y-2">
        <Label for="account-nickname">ニックネーム</Label>
        <Input id="account-nickname" v-model="form.nickname" type="text" autocomplete="nickname" />
      </div>
      <div class="space-y-2">
        <Label for="account-portrait">アイコン</Label>
        <Input id="account-portrait" type="file" accept="image/png,image/jpeg" @change="onPortraitChange" />
      </div>
      <div class="space-y-2">
        <Label for="account-region">地域</Label>
        <select id="account-region" v-model="form.region" class="native-select">
          <option value=""></option>
          <option v-for="region in meta.regions" :key="region.value" :value="region.label">{{ region.label }}</option>
        </select>
      </div>
      <div class="space-y-2">
        <Label for="account-self-introduction">自己紹介</Label>
        <Textarea id="account-self-introduction" v-model="form.self_introduction" class="h-25" />
      </div>
      <div class="space-y-2">
        <Label for="account-password">パスワード</Label>
        <Input id="account-password" v-model="form.password" type="password" autocomplete="new-password" />
        <p class="text-muted-foreground text-sm italic">パスワードは6文字以上で入力してください</p>
      </div>
      <div class="space-y-2">
        <Label for="account-password-confirmation">パスワード（確認）</Label>
        <Input id="account-password-confirmation" v-model="form.password_confirmation" type="password" autocomplete="new-password" />
      </div>
      <div class="actions">
        <Button id="create-account" type="submit" :disabled="submitting">アカウント登録</Button>
      </div>
    </form>
    <div class="mt-6 text-sm">
      <router-link class="text-primary hover:underline" :to="{ name: 'login' }">ログインはこちら</router-link>
    </div>
  </div>
</template>
