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
import { accountsApi } from '../api'
import { extractErrors } from '../api/errors'
import PortraitIcon from '../components/PortraitIcon.vue'

const props = defineProps<{ id: string }>()

const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()
const meta = useMetaStore()

const form = reactive({ nickname: '', region: '', self_introduction: '' })
const portraitUrl = ref<string | null>(null)
const portraitFile = ref<File | null>(null)
const errors = ref<string[]>([])
const submitting = ref(false)

onMounted(async () => {
  // 他人のプロフィールは編集できない
  if (Number(props.id) !== auth.account?.id) {
    router.replace({ name: 'posts' })
    return
  }
  await meta.ensureLoaded()
  const { data } = await accountsApi.show(props.id)
  form.nickname = data.account.nickname
  form.region = data.account.region || ''
  form.self_introduction = data.account.self_introduction || ''
  portraitUrl.value = data.account.portrait_url
})

function onPortraitChange(event: Event) {
  const input = event.target as HTMLInputElement
  portraitFile.value = input.files?.[0] || null
}

async function updateProfile() {
  submitting.value = true
  errors.value = []
  const formData = new FormData()
  formData.append('account[nickname]', form.nickname)
  formData.append('account[region]', form.region)
  formData.append('account[self_introduction]', form.self_introduction)
  if (portraitFile.value) formData.append('account[portrait]', portraitFile.value)
  try {
    const { data } = await accountsApi.update(props.id, formData)
    flash.notice(data.message)
    router.push({ name: 'account-show', params: { id: props.id } })
  } catch (error) {
    errors.value = extractErrors(error, '更新に失敗しました')
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="mx-auto mt-10 w-full max-w-xl px-4">
    <h1 class="mb-4 text-3xl font-bold">プロフィール編集</h1>
    <Alert v-if="errors.length" variant="destructive" role="alert" class="mb-4">
      <AlertDescription>
        <ul class="list-disc pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </AlertDescription>
    </Alert>
    <form class="space-y-4" @submit.prevent="updateProfile">
      <div class="space-y-2">
        <div>
          <PortraitIcon :url="portraitUrl" size="profile" />
        </div>
        <Label for="account-portrait">アイコン</Label>
        <Input id="account-portrait" type="file" accept="image/png,image/jpeg" @change="onPortraitChange" />
      </div>
      <div class="space-y-2">
        <Label for="account-nickname">ニックネーム</Label>
        <Input id="account-nickname" v-model="form.nickname" type="text" />
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
        <Textarea id="account-self-introduction" v-model="form.self_introduction" class="h-62" />
      </div>
      <div class="actions">
        <Button id="update-profile" type="submit" :disabled="submitting">更新する</Button>
      </div>
    </form>
    <hr class="my-6" />
    <div class="space-y-2">
      <p>アカウント名、メールアドレス、パスワードの変更はこちら</p>
      <Button id="edit-credentials" as-child variant="outline">
        <router-link :to="{ name: 'credentials' }">変更</router-link>
      </Button>
    </div>
  </div>
</template>
