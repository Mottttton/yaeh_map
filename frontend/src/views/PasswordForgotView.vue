<script setup lang="ts">
import { ref } from 'vue'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
  <div class="mx-auto mt-10 w-full max-w-sm px-4">
    <h2 class="mb-4 text-2xl font-semibold">パスワード再設定</h2>
    <p class="mb-4 text-sm">登録したメールアドレスを入力してください。パスワード再設定用のリンクを送信します。</p>
    <Alert v-if="sent" class="mb-4">
      <AlertDescription>
        メールを送信しました。メール内のリンクからパスワードを再設定してください。
      </AlertDescription>
    </Alert>
    <form class="space-y-4" @submit.prevent="sendResetMail">
      <div class="space-y-2">
        <Label for="forgot-email">メールアドレス</Label>
        <Input id="forgot-email" v-model="email" type="email" autocomplete="email" autofocus />
      </div>
      <Button type="submit" class="w-full" :disabled="submitting">送信する</Button>
    </form>
    <div class="mt-6 text-sm">
      <router-link class="text-primary hover:underline" :to="{ name: 'login' }">ログインに戻る</router-link>
    </div>
  </div>
</template>
