<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
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
  <form @submit.prevent="submit">
    <div class="form-floating mb-3">
      <input id="post-title" v-model="form.title" type="text" class="form-control" placeholder="タイトル" />
      <label for="post-title">タイトル</label>
    </div>
    <div class="form-floating mb-3">
      <textarea id="post-description" v-model="form.description" class="form-control" placeholder="詳細" style="height: 200px;"></textarea>
      <label for="post-description">詳細</label>
    </div>
    <div class="form-check form-check-inline mb-3 d-flex justify-content-around">
      <div v-for="genre in meta.genres" :key="genre.value">
        <input
          :id="`post_genre_${genre.value}`"
          v-model="form.genre"
          type="radio"
          name="post-genre"
          :value="genre.label"
        />
        <label :for="`post_genre_${genre.value}`">{{ genre.label }}</label>
      </div>
    </div>

    <MapPicker
      :initial-latitude="initialPost ? initialPost.latitude : null"
      :initial-longitude="initialPost ? initialPost.longitude : null"
      :emit-initial-location="mode === 'new'"
      @location-selected="onLocationSelected"
    />

    <div class="form-floating mb-3">
      <select id="post-prefecture" v-model="form.prefecture" class="form-select" @change="onPrefectureChange">
        <option value=""></option>
        <option v-for="prefecture in meta.prefectures" :key="prefecture.value" :value="prefecture.label">{{ prefecture.label }}</option>
      </select>
      <label for="post-prefecture">都道府県</label>
    </div>

    <div class="form-group mb-3">
      <label for="post-photos">写真</label>
      <span>(4枚まで)</span>
      <div v-if="initialPost && initialPost.photos.length" class="row g-2 mb-2">
        <img v-for="photo in initialPost.photos" :key="photo.url" :src="photo.thumb_url" width="48%" class="col-md-6" alt="投稿写真" />
      </div>
      <div class="input-group form-file mb-3">
        <input id="post-photos" type="file" class="form-control" multiple accept="image/png,image/jpeg" @change="onFilesChange" />
      </div>
    </div>

    <div class="actions d-flex justify-content-center">
      <button :id="mode === 'new' ? 'create-post' : 'update-post'" type="submit" class="btn btn-primary" :disabled="submitting">
        {{ mode === 'new' ? '登録する' : '更新する' }}
      </button>
    </div>
  </form>
</template>
