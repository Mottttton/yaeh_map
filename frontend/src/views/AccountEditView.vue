<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { useMetaStore } from '../stores/meta'
import { accountsApi, uploadsApi, type AccountUpdatePayload } from '../api'
import { extractErrors } from '../api/errors'
import { usePendingUploadsGuard } from '../composables/usePendingUploads'
import PortraitIcon from '../components/PortraitIcon.vue'

const props = defineProps<{ id: string }>()

const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()
const meta = useMetaStore()

const form = reactive({ nickname: '', region: '', self_introduction: '' })
// 保存済みのアイコン URL（サーバー上で確定しているもの）
const portraitUrl = ref<string | null>(null)
// アップロード済み・未確定のアイコン（「更新する」で確定、離脱時は破棄）
const pendingPortrait = ref<{ signedId: string; previewUrl: string } | null>(null)
// 保存済みアイコンの削除予約（「更新する」で確定）
const removeRequested = ref(false)
const uploading = ref(false)
const errors = ref<string[]>([])
const submitting = ref(false)
// file input をリセットするための key（同じファイルの選び直しにも対応）
const portraitInputKey = ref(0)

// プレビュー表示: 未確定アップロード > 削除予約(なし) > 保存済み
const displayPortraitUrl = computed(() => {
  if (pendingPortrait.value) return pendingPortrait.value.previewUrl
  return removeRequested.value ? null : portraitUrl.value
})

usePendingUploadsGuard({
  message: 'アップロードしたアイコンはまだ保存されていません。このページを離れると破棄されます。よろしいですか？',
  pendingSignedIds: () => (pendingPortrait.value ? [pendingPortrait.value.signedId] : []),
  onDiscard: () => clearPendingPortrait({ deleteBlob: false })
})

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

async function onPortraitChange(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  uploading.value = true
  errors.value = []
  try {
    const { data } = await uploadsApi.create(file)
    // 選び直した場合は前の未確定アップロードを破棄する
    clearPendingPortrait({ deleteBlob: true })
    pendingPortrait.value = { signedId: data.signed_id, previewUrl: URL.createObjectURL(file) }
    removeRequested.value = false
  } catch (error) {
    errors.value = extractErrors(error, 'アイコンのアップロードに失敗しました')
    portraitInputKey.value++
  } finally {
    uploading.value = false
  }
}

// アイコンの「削除」ボタン。未確定アップロードがあれば取り消し、
// なければ保存済みアイコンの削除を予約する（どちらも「更新する」までは確定しない）
function removePortrait() {
  if (pendingPortrait.value) {
    clearPendingPortrait({ deleteBlob: true })
  } else if (portraitUrl.value) {
    removeRequested.value = true
  }
  portraitInputKey.value++
}

function clearPendingPortrait({ deleteBlob }: { deleteBlob: boolean }) {
  if (!pendingPortrait.value) return
  if (deleteBlob) {
    void uploadsApi.destroy(pendingPortrait.value.signedId).catch(() => {})
  }
  URL.revokeObjectURL(pendingPortrait.value.previewUrl)
  pendingPortrait.value = null
}

async function updateProfile() {
  submitting.value = true
  errors.value = []
  const payload: AccountUpdatePayload = {
    account: {
      nickname: form.nickname,
      region: form.region,
      self_introduction: form.self_introduction
    }
  }
  if (pendingPortrait.value) {
    payload.account.portrait = pendingPortrait.value.signedId
  } else if (removeRequested.value) {
    payload.account.remove_portrait = true
  }
  try {
    const { data } = await accountsApi.update(props.id, payload)
    // 保存が確定したので未確定扱いを解除する（離脱ガードを無効化。blob は添付済みなので削除しない）
    clearPendingPortrait({ deleteBlob: false })
    removeRequested.value = false
    portraitUrl.value = data.account.portrait_url
    await auth.fetchSession()
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
        <div class="flex items-end gap-4">
          <PortraitIcon :url="displayPortraitUrl" size="profile" />
          <Button
            v-if="displayPortraitUrl"
            id="remove-portrait"
            type="button"
            variant="outline"
            size="sm"
            @click="removePortrait"
          >
            アイコンを削除
          </Button>
        </div>
        <p v-if="pendingPortrait" class="text-muted-foreground text-sm">
          プレビュー表示中です。「更新する」を押すとアイコンが保存されます
        </p>
        <p v-else-if="removeRequested" class="text-muted-foreground text-sm">
          「更新する」を押すとアイコンが削除されます
        </p>
        <Label for="account-portrait">アイコン</Label>
        <Input
          id="account-portrait"
          :key="portraitInputKey"
          type="file"
          accept="image/png,image/jpeg"
          :disabled="uploading"
          @change="onPortraitChange"
        />
        <p v-if="uploading" class="text-muted-foreground text-sm">アップロード中…</p>
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
        <Button id="update-profile" type="submit" :disabled="submitting || uploading">更新する</Button>
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
