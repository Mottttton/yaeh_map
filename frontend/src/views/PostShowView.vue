<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { MapPinIcon } from '@lucide/vue'
import { useRouter } from 'vue-router'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
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
  <div v-if="post" class="mx-auto mt-10 w-full max-w-4xl px-4">
    <h1 class="text-3xl font-bold">情報詳細</h1>
    <h2 class="mt-2 mb-4 text-2xl font-semibold">{{ post.title }}</h2>

    <div class="mb-2 flex items-center justify-between">
      <div class="flex flex-wrap gap-1">
        <Badge>{{ post.genre }}</Badge>
        <Badge>{{ post.region }}</Badge>
        <Badge v-if="post.prefecture">{{ post.prefecture }}</Badge>
      </div>
      <small class="text-muted-foreground">{{ timeAgoInWords(post.created_at) }}</small>
    </div>

    <div class="mb-4 flex items-end justify-between">
      <div class="flex items-center gap-1">
        <PortraitIcon :url="post.account.portrait_thumb_url" />
        <span class="text-lg">{{ post.account.nickname }}</span>
        <span>
          (<router-link
            :to="{ name: 'account-show', params: { id: post.account.id } }"
            :class="`account-${post.account.id}`"
            class="text-primary hover:underline"
          >@{{ post.account.name }}</router-link>)
        </span>
      </div>
      <div :id="`favorite-${post.id}`">
        <FavoriteButton :post="post" @updated="onFavoriteUpdated" />
      </div>
    </div>

    <div v-if="post.photos.length" class="mb-4 grid gap-2 sm:grid-cols-2">
      <img v-for="photo in post.photos" :key="photo.url" :src="photo.thumb_url" class="w-full rounded-md" alt="投稿写真" />
    </div>

    <div class="mb-4">
      <p class="text-justify wrap-break-word whitespace-pre-wrap">{{ post.description }}</p>
    </div>

    <div v-if="embedUrl" class="relative mb-4 h-[65vh] w-full overflow-hidden rounded-md">
      <iframe
        class="absolute inset-0 h-full w-full border-0"
        referrerpolicy="no-referrer-when-downgrade"
        :src="embedUrl"
        allowfullscreen
      ></iframe>
    </div>
    <div v-else class="mb-4">
      <a :href="externalMapUrl" target="_blank" rel="noopener" class="text-primary inline-flex items-center gap-1 hover:underline">
        <MapPinIcon class="size-4" /> Google マップで場所を確認する
      </a>
    </div>

    <div class="flex justify-evenly">
      <template v-if="canModerate">
        <Button id="destroy-post" type="button" variant="destructive" @click="destroyPost">削除</Button>
        <Button v-if="isOwner" id="edit-post" as-child variant="outline">
          <router-link :to="{ name: 'post-edit', params: { id: post.id } }">編集</router-link>
        </Button>
      </template>
      <Button id="back" as-child variant="secondary">
        <router-link :to="{ name: 'posts' }">戻る</router-link>
      </Button>
    </div>
  </div>
</template>
