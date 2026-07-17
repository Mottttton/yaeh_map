<script setup lang="ts">
import { computed } from 'vue'
import { MapPinIcon } from '@lucide/vue'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from '@/components/ui/carousel'
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
const isApproximate = computed(() => props.post.location_accuracy === 'approximate')
// 位置なしは地図なし（MapPin フォールバック）。おおまかは丸め座標のため zoom を落として精度誤認を防ぐ
const mapImage = computed(() =>
  props.post.latitude != null && props.post.longitude != null
    ? staticMapUrl(props.post.latitude, props.post.longitude, { zoom: isApproximate.value ? 13 : 16 })
    : null
)

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
  <Card class="post gap-0 overflow-hidden py-0 shadow-sm">
    <h3 class="truncate border-b px-4 py-3 text-lg font-semibold">{{ post.title }}</h3>

    <!-- 写真スライド + 最後に地図（写真がない場合は地図のみ） -->
    <Carousel class="post_map w-full">
      <CarouselContent class="ml-0">
        <CarouselItem v-for="photo in post.photos" :key="photo.url" class="pl-0">
          <img class="aspect-4/3 w-full object-cover" :src="photo.thumb_url" alt="投稿写真" />
        </CarouselItem>
        <CarouselItem class="pl-0">
          <img v-if="mapImage" class="aspect-4/3 w-full object-cover" :src="mapImage" alt="地図" />
          <div v-else class="bg-muted text-muted-foreground flex aspect-4/3 flex-col items-center justify-center">
            <MapPinIcon class="size-10" />
            <span>{{ post.prefecture || post.region }}</span>
          </div>
        </CarouselItem>
      </CarouselContent>
      <template v-if="post.photos.length">
        <CarouselPrevious class="left-2" />
        <CarouselNext class="right-2" />
      </template>
    </Carousel>

    <CardContent class="post_content px-4 py-4">
      <div class="mb-2 flex items-end justify-between">
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
        <small class="text-muted-foreground shrink-0">{{ timeAgoInWords(post.created_at) }}</small>
      </div>

      <div class="mb-3 flex flex-wrap gap-1">
        <Badge>{{ post.genre }}</Badge>
        <Badge>{{ post.region }}</Badge>
        <Badge v-if="post.prefecture">{{ post.prefecture }}</Badge>
        <Badge v-if="isApproximate" variant="secondary">おおまか</Badge>
      </div>

      <!-- 本文は高さを制限し、下端をぼかして「もっと見る」を重ねる -->
      <div class="relative mb-8">
        <div class="max-h-24 overflow-hidden">
          <p class="text-justify wrap-break-word whitespace-pre-wrap">{{ post.description }}</p>
        </div>
        <div class="from-card absolute inset-x-0 bottom-0 h-12 bg-linear-to-t to-transparent"></div>
        <div class="absolute inset-x-0 -bottom-4 flex justify-center">
          <Button as-child class="show-post w-1/2">
            <router-link :to="{ name: 'post-show', params: { id: post.id } }">もっと見る</router-link>
          </Button>
        </div>
      </div>

      <div class="flex items-center justify-between">
        <div :id="`favorite-${post.id}`">
          <FavoriteButton :post="post" @updated="onFavoriteUpdated" />
        </div>
        <div v-if="canModerate" class="flex gap-2">
          <Button type="button" variant="destructive" size="sm" class="destroy-post" @click="destroyPost">削除</Button>
          <Button v-if="isOwner" as-child variant="outline" size="sm" class="edit-post">
            <router-link :to="{ name: 'post-edit', params: { id: post.id } }">編集</router-link>
          </Button>
        </div>
      </div>
    </CardContent>
  </Card>
</template>
