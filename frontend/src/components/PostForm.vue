<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import { Textarea } from '@/components/ui/textarea'
import { useMetaStore } from '../stores/meta'
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
const emit = defineEmits<{ submit: [formData: FormData] }>()

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
const photoFiles = ref<File[]>([])

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

function onFilesChange(event: Event) {
  const input = event.target as HTMLInputElement
  photoFiles.value = Array.from(input.files ?? [])
}

function submit() {
  const formData = new FormData()
  formData.append('post[title]', form.title)
  formData.append('post[description]', form.description)
  formData.append('post[genre]', form.genre)
  formData.append('post[region]', form.region)
  formData.append('post[prefecture]', form.prefecture)
  formData.append('post[place]', form.place)
  formData.append('post[latitude]', String(form.latitude))
  formData.append('post[longitude]', String(form.longitude))
  // ファイルを選び直した場合のみ写真を送信する（既存の写真は置き換えになる）
  photoFiles.value.forEach((file) => formData.append('post[photos][]', file))
  emit('submit', formData)
}
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
      <div v-if="initialPost && initialPost.photos.length" class="grid grid-cols-2 gap-2">
        <img v-for="photo in initialPost.photos" :key="photo.url" :src="photo.thumb_url" class="w-full rounded-md" alt="投稿写真" />
      </div>
      <Input id="post-photos" type="file" multiple accept="image/png,image/jpeg" @change="onFilesChange" />
    </div>

    <div class="actions flex justify-center">
      <Button :id="mode === 'new' ? 'create-post' : 'update-post'" type="submit" :disabled="submitting">
        {{ mode === 'new' ? '登録する' : '更新する' }}
      </Button>
    </div>
  </form>
</template>
