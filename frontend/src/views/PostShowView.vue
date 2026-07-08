<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { postsApi } from '../api'
import { embedMapUrl, googleMapsLinkUrl } from '../utils/googleMaps'
import { timeAgoInWords } from '../utils/timeAgo'
import FavoriteButton from '../components/FavoriteButton.vue'
import PortraitIcon from '../components/PortraitIcon.vue'
import type { FavoriteState, Post } from '../types'

const props = defineProps<{ id: string }>()

const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()

const post = ref<Post | null>(null)

const isOwner = computed(() => !!post.value && auth.account?.id === post.value.account.id)
const canModerate = computed(() => isOwner.value || auth.isAdmin)
const embedUrl = computed(() => (post.value ? embedMapUrl(post.value.place, post.value.latitude, post.value.longitude) : null))
const externalMapUrl = computed(() => (post.value ? googleMapsLinkUrl(post.value.latitude, post.value.longitude) : ''))

onMounted(async () => {
  const { data } = await postsApi.show(props.id)
  post.value = data.post
})

function onFavoriteUpdated(state: FavoriteState) {
  if (!post.value) return
  post.value.favorited = state.favorited
  post.value.favorites_count = state.favorites_count
}

async function destroyPost() {
  if (!post.value) return
  if (!window.confirm('本当に削除してもよろしいですか？')) return
  const { data } = await postsApi.destroy(post.value.id)
  flash.notice(data.message)
  router.push({ name: 'posts' })
}
</script>

<template>
  <div v-if="post" class="container mt-5">
    <div>
      <h1>情報詳細</h1>
      <div>
        <h2>{{ post.title }}</h2>
      </div>
      <div class="d-flex justify-content-between mb-2">
        <div>
          <span class="badge bg-primary">{{ post.genre }}</span>
          <span class="badge bg-primary">{{ post.region }}</span>
          <span v-if="post.prefecture" class="badge bg-primary">{{ post.prefecture }}</span>
        </div>
        <div>
          <small class="text-body-secondary">{{ timeAgoInWords(post.created_at) }}</small>
        </div>
      </div>
      <div class="d-flex justify-content-between align-items-end mb-3">
        <div>
          <span>
            <PortraitIcon :url="post.account.portrait_thumb_url" />
          </span>
          <span class="fs-5">{{ post.account.nickname }}</span>
          (<router-link :to="{ name: 'account-show', params: { id: post.account.id } }" :class="`account-${post.account.id}`">@{{ post.account.name }}</router-link>)
        </div>
        <div :id="`favorite-${post.id}`">
          <FavoriteButton :post="post" @updated="onFavoriteUpdated" />
        </div>
      </div>
      <div v-if="post.photos.length" class="mb-3 row g-2">
        <img v-for="photo in post.photos" :key="photo.url" :src="photo.thumb_url" class="col-sm-6" alt="投稿写真" />
      </div>
      <div class="mb-3 post-description" style="height: auto; overflow-y: visible;">
        <p>{{ post.description }}</p>
      </div>
      <div v-if="embedUrl" class="map mb-1">
        <iframe
          frameborder="0"
          style="border:0"
          referrerpolicy="no-referrer-when-downgrade"
          :src="embedUrl"
          allowfullscreen
        ></iframe>
      </div>
      <div v-else class="mb-3">
        <a :href="externalMapUrl" target="_blank" rel="noopener">
          <i class="bi bi-pin-map-fill"></i> Google マップで場所を確認する
        </a>
      </div>
      <div class="d-flex justify-content-evenly">
        <template v-if="canModerate">
          <button id="destroy-post" type="button" class="btn btn-outline-danger" @click="destroyPost">削除</button>
          <router-link v-if="isOwner" id="edit-post" :to="{ name: 'post-edit', params: { id: post.id } }" class="btn btn-outline-primary">編集</router-link>
        </template>
        <router-link id="back" :to="{ name: 'posts' }" class="btn btn-secondary">戻る</router-link>
      </div>
    </div>
  </div>
</template>
