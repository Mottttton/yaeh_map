<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
  <div class="mx-auto mt-10 w-full max-w-xl px-4">
    <h2 class="mb-4 text-2xl font-semibold">アカウント情報の変更</h2>
    <Alert v-if="errors.length" variant="destructive" role="alert" class="mb-4">
      <AlertDescription>
        <ul class="list-disc pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </AlertDescription>
    </Alert>
    <form class="space-y-4" @submit.prevent="updateCredentials">
      <div class="space-y-2">
        <Label for="credentials-name">アカウント名</Label>
        <Input id="credentials-name" v-model="form.name" type="text" autocomplete="username" />
        <p class="text-muted-foreground text-sm italic">(半角英数字とアンダーバーで入力)</p>
      </div>
      <div class="space-y-2">
        <Label for="credentials-email">メールアドレス</Label>
        <Input id="credentials-email" v-model="form.email" type="email" autocomplete="email" />
      </div>

      <Collapsible>
        <CollapsibleTrigger as-child>
          <Button type="button" variant="outline">パスワードの変更</Button>
        </CollapsibleTrigger>
        <CollapsibleContent id="password-collapse" class="space-y-4 pt-3">
          <p class="text-muted-foreground text-sm italic">(変更しない場合は空欄のままにしてください)</p>
          <div class="space-y-2">
            <Label for="credentials-password">新規パスワード</Label>
            <Input id="credentials-password" v-model="form.password" type="password" autocomplete="new-password" />
            <p class="text-muted-foreground text-sm italic">パスワードは6文字以上で入力してください</p>
          </div>
          <div class="space-y-2">
            <Label for="credentials-password-confirmation">新規パスワード(確認)</Label>
            <Input id="credentials-password-confirmation" v-model="form.password_confirmation" type="password" autocomplete="new-password" />
          </div>
        </CollapsibleContent>
      </Collapsible>

      <div class="space-y-2">
        <Label for="credentials-current-password">現在のパスワード</Label>
        <Input id="credentials-current-password" v-model="form.current_password" type="password" autocomplete="current-password" />
      </div>
      <div class="actions mb-8 flex justify-evenly">
        <Button id="update-account" type="submit" :disabled="submitting">更新する</Button>
        <Button type="button" variant="secondary" @click="router.back()">戻る</Button>
      </div>
    </form>
    <hr class="my-6" />
    <div class="flex justify-center">
      <Button type="button" variant="destructive" @click="deleteAccount">アカウント削除</Button>
    </div>
  </div>
</template>
