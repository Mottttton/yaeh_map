<script setup>
import { favoritesApi } from '../api'

const props = defineProps({
  post: { type: Object, required: true }
})
const emit = defineEmits(['updated'])

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
  <a class="favorite-link" :id="`fav_link-${post.id}`" href="#" @click.prevent="toggle">
    <template v-if="post.favorited">
      <span class="text-black">v(･∀･)yaeh!</span>
      <i class="bi bi-hand-thumbs-up-fill favorited"></i>
    </template>
    <i v-else class="bi bi-hand-thumbs-up unfavorited"></i>
  </a>
  <span :id="`num_of_fav-${post.id}`">
    {{ post.favorites_count }}
  </span>
</template>
