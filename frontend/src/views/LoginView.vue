<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'
import { extractErrorMessage } from '../api/errors'

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
    const redirect = route.query.redirect
    router.push(typeof redirect === 'string' ? redirect : { name: 'posts' })
  } catch (error) {
    errorMessage.value = extractErrorMessage(error, 'ログインに失敗しました')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="mx-auto mt-10 w-full max-w-sm px-4">
    <h2 class="mb-4 text-2xl font-semibold">ログイン</h2>
    <Alert v-if="errorMessage" variant="destructive" role="alert" class="mb-4">
      <AlertDescription>{{ errorMessage }}</AlertDescription>
    </Alert>
    <form class="space-y-4" @submit.prevent="login">
      <div class="space-y-2">
        <Label for="login-email">メールアドレス</Label>
        <Input id="login-email" v-model="form.email" type="email" autocomplete="email" autofocus />
      </div>
      <div class="space-y-2">
        <Label for="login-password">パスワード</Label>
        <Input id="login-password" v-model="form.password" type="password" autocomplete="current-password" />
      </div>
      <div class="flex items-center gap-2">
        <Checkbox
          id="login-remember"
          :model-value="form.remember_me"
          @update:model-value="(v) => (form.remember_me = v === true)"
        />
        <Label for="login-remember" class="font-normal">ログインを記憶する</Label>
      </div>
      <Button id="sign-in-submit" type="submit" class="w-full" :disabled="submitting">ログイン</Button>
    </form>
    <div class="mt-6 space-y-1 text-sm">
      <div>
        <router-link class="text-primary hover:underline" :to="{ name: 'signup' }">新規登録はこちら</router-link>
      </div>
      <div>
        <router-link class="text-primary hover:underline" :to="{ name: 'password-forgot' }">パスワードを忘れた場合</router-link>
      </div>
    </div>
  </div>
</template>
