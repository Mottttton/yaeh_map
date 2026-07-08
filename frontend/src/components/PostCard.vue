<script setup lang="ts">
import { computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { postsApi } from '../api'
import { staticMapUrl } from '../utils/googleMaps'
import { timeAgoInWords } from '../utils/timeAgo'
import FavoriteButton from './FavoriteButton.vue'
import PortraitIcon from './PortraitIcon.vue'
import type { FavoriteState, Post } from '../types'

const props = defineProps<{ post: Post }>()
const emit = defineEmits<{ deleted: [id: number] }>()

const auth = useAuthStore()
const flash = useFlashStore()

const isOwner = computed(() => auth.account?.id === props.post.account.id)
const canModerate = computed(() => isOwner.value || auth.isAdmin)
const mapImage = computed(() => staticMapUrl(props.post.latitude, props.post.longitude))
const totalSlides = computed(() => props.post.photos.length + 1)

// いいねの状態は一覧・詳細で共有する post オブジェクトへ反映する
function onFavoriteUpdated(state: FavoriteState) {
  props.post.favorited = state.favorited
  props.post.favorites_count = state.favorites_count
}

async function destroyPost() {
  if (!window.confirm('本当に削除してもよろしいですか？')) return
  const { data } = await postsApi.destroy(props.post.id)
  flash.notice(data.message)
  emit('deleted', props.post.id)
}
</script>

<template>
  <div class="post card shadow-sm">
    <h3 class="card-header fs-5">{{ post.title }}</h3>
    <div :id="`carousel-post-${post.id}`" class="post_map carousel slide card-img-top">
      <div v-if="post.photos.length" class="carousel-indicators rounded-pill bg-dark bg-opacity-25">
        <button
          v-for="index in totalSlides"
          :key="index"
          type="button"
          :data-bs-target="`#carousel-post-${post.id}`"
          :data-bs-slide-to="index - 1"
          :class="{ active: index === 1 }"
          :aria-current="index === 1 ? 'true' : undefined"
          :aria-label="`Slide ${index}`"
        ></button>
      </div>
      <div class="carousel-inner">
        <div
          v-for="(photo, index) in post.photos"
          :key="photo.url"
          class="carousel-item"
          :class="{ active: index === 0 }"
        >
          <img class="d-block w-100" :src="photo.thumb_url" alt="投稿写真" />
        </div>
        <div class="carousel-item" :class="{ active: post.photos.length === 0 }">
          <img v-if="mapImage" class="d-block w-100" :src="mapImage" alt="地図" />
          <div v-else class="map-placeholder">
            <i class="bi bi-pin-map-fill fs-1"></i>
            <span>{{ post.prefecture || post.region }}</span>
          </div>
        </div>
      </div>
      <template v-if="post.photos.length">
        <button class="carousel-control-prev" type="button" :data-bs-target="`#carousel-post-${post.id}`" data-bs-slide="prev">
          <span class="carousel-control-prev-icon bg-dark rounded-start-pill" aria-hidden="true"></span>
          <span class="visually-hidden">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" :data-bs-target="`#carousel-post-${post.id}`" data-bs-slide="next">
          <span class="carousel-control-next-icon bg-dark rounded-end-pill" aria-hidden="true"></span>
          <span class="visually-hidden">Next</span>
        </button>
      </template>
    </div>
    <div class="post_content card-body px-4">
      <div class="d-flex align-items-end justify-content-between mb-2">
        <div>
          <span>
            <PortraitIcon :url="post.account.portrait_thumb_url" />
          </span>
          <span class="fs-5">{{ post.account.nickname }}</span>
          (<router-link :to="{ name: 'account-show', params: { id: post.account.id } }" :class="`account-${post.account.id}`">@{{ post.account.name }}</router-link>)
        </div>
        <small class="text-body-secondary">{{ timeAgoInWords(post.created_at) }}</small>
      </div>
      <div class="mb-3">
        <span class="badge bg-primary">{{ post.genre }}</span>
        <span class="badge bg-primary">{{ post.region }}</span>
        <span v-if="post.prefecture" class="badge bg-primary">{{ post.prefecture }}</span>
      </div>
      <div class="post-group position-relative">
        <div class="mb-5 post-description">
          <p>{{ post.description }}</p>
        </div>
        <div class="position-absolute top-100 start-50 translate-middle h-75 w-100 wrap-rgba-white"></div>
        <div class="d-grid col-6 position-absolute top-100 start-50 translate-middle">
          <router-link :to="{ name: 'post-show', params: { id: post.id } }" class="show-post btn btn-primary" role="button">もっと見る</router-link>
        </div>
      </div>
      <div class="d-flex justify-content-between align-items-center">
        <div :id="`favorite-${post.id}`">
          <FavoriteButton :post="post" @updated="onFavoriteUpdated" />
        </div>
        <div class="btn-group">
          <template v-if="canModerate">
            <button type="button" class="destroy-post btn btn-sm btn-outline-danger" @click="destroyPost">削除</button>
            <router-link v-if="isOwner" :to="{ name: 'post-edit', params: { id: post.id } }" class="edit-post btn btn-sm btn-outline-secondary">編集</router-link>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>
