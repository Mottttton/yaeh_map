<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import { Textarea } from '@/components/ui/textarea'
import { useMetaStore } from '../stores/meta'
import { uploadsApi, type PostPayload } from '../api'
import { extractErrors } from '../api/errors'
import { usePendingUploadsGuard } from '../composables/usePendingUploads'
import MapPicker from './MapPicker.vue'
import type { MapLocation, Post } from '../types'

const props = withDefaults(
  defineProps<{
    mode: 'new' | 'edit'
    initialPost?: Post | null
    submitting?: boolean
  }>(),
  {
    initialPost: null,
    submitting: false
  }
)
const emit = defineEmits<{ submit: [payload: PostPayload] }>()

const meta = useMetaStore()

interface PostFormState {
  title: string
  description: string
  genre: string
  prefecture: string
  region: string
  place: string
  latitude: number | ''
  longitude: number | ''
}

// 表示中の写真。既存写真（保存済み）と新規アップロード（未確定）を1つのリストで扱い、
// 送信時は残す写真の signed_id を全量送る（含めなかった既存写真は削除される）
interface PhotoItem {
  signedId: string
  previewUrl: string
  isNew: boolean
}

const MAX_PHOTOS = 4

const form = reactive<PostFormState>({
  title: '',
  description: '',
  genre: '',
  prefecture: '',
  region: '',
  place: '',
  latitude: '',
  longitude: ''
})
const photos = ref<PhotoItem[]>([])
const uploadErrors = ref<string[]>([])
const uploadingCount = ref(0)
// 送信が成功したら true（未確定アップロードを「確定済み」とみなし離脱ガードを解除する）
const saved = ref(false)
// file input をリセットするための key（同じファイルの選び直しにも対応）
const photosInputKey = ref(0)

const uploading = computed(() => uploadingCount.value > 0)
const hasPendingPhotos = computed(() => pendingSignedIds().length > 0)

function pendingSignedIds() {
  if (saved.value) return []
  return photos.value.filter((photo) => photo.isNew).map((photo) => photo.signedId)
}

usePendingUploadsGuard({
  message:
    props.mode === 'new'
      ? '投稿が完了していないため、アップロードした写真は破棄されます。ページを離れますか？'
      : 'アップロードした写真はまだ保存されていません。このページを離れると破棄されます。よろしいですか？',
  pendingSignedIds,
  onDiscard: () => {
    photos.value.filter((photo) => photo.isNew).forEach((photo) => URL.revokeObjectURL(photo.previewUrl))
  }
})

onMounted(async () => {
  await meta.ensureLoaded()
  if (props.initialPost) {
    form.title = props.initialPost.title
    form.description = props.initialPost.description
    form.genre = props.initialPost.genre
    form.prefecture = props.initialPost.prefecture || ''
    form.region = props.initialPost.region
    form.place = props.initialPost.place
    form.latitude = props.initialPost.latitude
    form.longitude = props.initialPost.longitude
    photos.value = props.initialPost.photos.map((photo) => ({
      signedId: photo.signed_id,
      previewUrl: photo.thumb_url,
      isNew: false
    }))
  }
})

// 地図から位置が選択されたらフォームへ反映（旧 map_common.js の hidden フィールド入力に相当）
function onLocationSelected(location: MapLocation) {
  form.latitude = location.latitude
  form.longitude = location.longitude
  if (location.place) form.place = location.place
  if (location.prefecture) form.prefecture = location.prefecture
  if (location.region) form.region = location.region
}

// 都道府県を手動で変更した場合も地域を自動設定する（旧 inputRegion 相当）
function onPrefectureChange() {
  const region = meta.prefectureToRegion[form.prefecture]
  if (region) form.region = region
}

// 選択した画像をその場でアップロードして未確定の blob を作る（保存確定はフォーム送信時）
async function onFilesChange(event: Event) {
  const input = event.target as HTMLInputElement
  const files = Array.from(input.files ?? [])
  photosInputKey.value++
  if (!files.length) return
  uploadErrors.value = []
  if (photos.value.length + files.length > MAX_PHOTOS) {
    uploadErrors.value = [`写真は${MAX_PHOTOS}枚までです`]
    return
  }
  for (const file of files) {
    uploadingCount.value++
    try {
      const { data } = await uploadsApi.create(file)
      photos.value.push({
        signedId: data.signed_id,
        previewUrl: URL.createObjectURL(file),
        isNew: true
      })
    } catch (error) {
      uploadErrors.value = extractErrors(error, '写真のアップロードに失敗しました')
    } finally {
      uploadingCount.value--
    }
  }
}

function removePhoto(photo: PhotoItem) {
  photos.value = photos.value.filter((item) => item.signedId !== photo.signedId)
  if (photo.isNew) {
    // 未確定のアップロードは即座に破棄する
    void uploadsApi.destroy(photo.signedId).catch(() => {})
    URL.revokeObjectURL(photo.previewUrl)
  }
  // 既存写真はリストから外すだけで、削除の確定はフォーム送信時（photo_signed_ids に含めない）
}

function submit() {
  emit('submit', {
    post: {
      title: form.title,
      description: form.description,
      genre: form.genre,
      region: form.region,
      prefecture: form.prefecture,
      place: form.place,
      latitude: form.latitude,
      longitude: form.longitude,
      photo_signed_ids: photos.value.map((photo) => photo.signedId)
    }
  })
}

// 送信成功後に親ビューから呼ぶ。未確定アップロードを確定済み扱いにして離脱ガードを解除する
function markSaved() {
  saved.value = true
  photos.value.filter((photo) => photo.isNew).forEach((photo) => URL.revokeObjectURL(photo.previewUrl))
}

defineExpose({ markSaved })
</script>

<template>
  <form class="space-y-4" @submit.prevent="submit">
    <div class="space-y-2">
      <Label for="post-title">タイトル</Label>
      <Input id="post-title" v-model="form.title" type="text" placeholder="タイトル" />
    </div>
    <div class="space-y-2">
      <Label for="post-description">詳細</Label>
      <Textarea id="post-description" v-model="form.description" placeholder="詳細" class="h-50" />
    </div>

    <RadioGroup
      :model-value="form.genre"
      class="flex flex-wrap justify-around gap-4"
      @update:model-value="(v) => (form.genre = String(v ?? ''))"
    >
      <div v-for="genre in meta.genres" :key="genre.value" class="flex items-center gap-2">
        <RadioGroupItem :id="`post_genre_${genre.value}`" :value="genre.label" />
        <Label :for="`post_genre_${genre.value}`" class="font-normal">{{ genre.label }}</Label>
      </div>
    </RadioGroup>

    <MapPicker
      :initial-latitude="initialPost ? initialPost.latitude : null"
      :initial-longitude="initialPost ? initialPost.longitude : null"
      :emit-initial-location="mode === 'new'"
      @location-selected="onLocationSelected"
    />

    <div class="space-y-2">
      <Label for="post-prefecture">都道府県</Label>
      <select id="post-prefecture" v-model="form.prefecture" class="native-select" @change="onPrefectureChange">
        <option value=""></option>
        <option v-for="prefecture in meta.prefectures" :key="prefecture.value" :value="prefecture.label">{{ prefecture.label }}</option>
      </select>
    </div>

    <div class="space-y-2">
      <Label for="post-photos">写真 <span class="text-muted-foreground font-normal">(4枚まで)</span></Label>
      <Alert v-if="uploadErrors.length" variant="destructive" role="alert">
        <AlertDescription>
          <ul class="list-disc pl-4">
            <li v-for="error in uploadErrors" :key="error">{{ error }}</li>
          </ul>
        </AlertDescription>
      </Alert>
      <div v-if="photos.length" class="grid grid-cols-2 gap-2">
        <div v-for="photo in photos" :key="photo.signedId" class="relative">
          <img :src="photo.previewUrl" class="w-full rounded-md" alt="投稿写真" />
          <Button
            type="button"
            variant="destructive"
            size="sm"
            class="absolute top-1 right-1"
            :aria-label="`写真を削除`"
            @click="removePhoto(photo)"
          >
            削除
          </Button>
          <span
            v-if="photo.isNew"
            class="bg-primary text-primary-foreground absolute bottom-1 left-1 rounded px-1.5 py-0.5 text-xs"
          >
            未保存
          </span>
        </div>
      </div>
      <Input
        id="post-photos"
        :key="photosInputKey"
        type="file"
        multiple
        accept="image/png,image/jpeg"
        :disabled="uploading || photos.length >= MAX_PHOTOS"
        @change="onFilesChange"
      />
      <p v-if="uploading" class="text-muted-foreground text-sm">アップロード中…</p>
      <p v-else-if="hasPendingPhotos" class="text-muted-foreground text-sm">
        「{{ mode === 'new' ? '登録する' : '更新する' }}」を押すと写真が保存されます
      </p>
    </div>

    <div class="actions flex justify-center">
      <Button :id="mode === 'new' ? 'create-post' : 'update-post'" type="submit" :disabled="submitting || uploading">
        {{ mode === 'new' ? '登録する' : '更新する' }}
      </Button>
    </div>
  </form>
</template>
