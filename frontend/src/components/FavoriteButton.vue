<script setup lang="ts">
import { ThumbsUpIcon } from '@lucide/vue'
import { favoritesApi } from '../api'
import type { FavoriteState, Post } from '../types'

const props = defineProps<{ post: Post }>()
const emit = defineEmits<{ updated: [state: FavoriteState] }>()

async function toggle() {
  const request = props.post.favorited ? favoritesApi.destroy : favoritesApi.create
  try {
    const { data } = await request(props.post.id)
    emit('updated', { favorited: data.favorited, favorites_count: data.favorites_count })
  } catch {
    // 連打による重複いいね等は無視する
  }
}
</script>

<template>
  <button
    type="button"
    :id="`fav_link-${post.id}`"
    class="inline-flex cursor-pointer items-center gap-1 align-middle"
    @click="toggle"
  >
    <template v-if="post.favorited">
      <span>v(･∀･)yaeh!</span>
      <ThumbsUpIcon class="size-5 fill-amber-400 text-amber-400" />
    </template>
    <ThumbsUpIcon v-else class="size-5" />
  </button>
  <span :id="`num_of_fav-${post.id}`">
    {{ post.favorites_count }}
  </span>
</template>
