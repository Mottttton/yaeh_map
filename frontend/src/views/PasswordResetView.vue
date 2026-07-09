<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'
import { extractErrors } from '../api/errors'

const route = useRoute()
const router = useRouter()
const flash = useFlashStore()

const form = reactive({ password: '', password_confirmation: '' })
const errors = ref<string[]>([])
const submitting = ref(false)

async function resetPassword() {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await authApi.resetPassword({
      reset_password_token: String(route.query.reset_password_token ?? ''),
      password: form.password,
      password_confirmation: form.password_confirmation
    })
    flash.notice(data.message)
    router.push({ name: 'login' })
  } catch (error) {
    errors.value = extractErrors(error, 'パスワードの変更に失敗しました')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="mx-auto mt-10 w-full max-w-sm px-4">
    <h2 class="mb-4 text-2xl font-semibold">新しいパスワードの設定</h2>
    <Alert v-if="errors.length" variant="destructive" role="alert" class="mb-4">
      <AlertDescription>
        <ul class="list-disc pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </AlertDescription>
    </Alert>
    <form class="space-y-4" @submit.prevent="resetPassword">
      <div class="space-y-2">
        <Label for="reset-password">新しいパスワード</Label>
        <Input id="reset-password" v-model="form.password" type="password" autocomplete="new-password" autofocus />
      </div>
      <div class="space-y-2">
        <Label for="reset-password-confirmation">新しいパスワード（確認）</Label>
        <Input id="reset-password-confirmation" v-model="form.password_confirmation" type="password" autocomplete="new-password" />
      </div>
      <Button type="submit" class="w-full" :disabled="submitting">パスワードを変更する</Button>
    </form>
  </div>
</template>
