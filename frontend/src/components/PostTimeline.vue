<script setup lang="ts">
import PostCard from './PostCard.vue'
import PaginationBar from './PaginationBar.vue'
import type { PaginationMeta, Post } from '../types'

defineProps<{ posts: Post[]; meta: PaginationMeta }>()
defineEmits<{ 'page-change': [page: number]; deleted: [id: number] }>()
</script>

<template>
  <div id="timeline" class="grid grid-cols-1 gap-4 md:grid-cols-2">
    <div v-for="post in posts" :key="post.id" :id="`post-${post.id}`">
      <PostCard :post="post" @deleted="$emit('deleted', $event)" />
    </div>
  </div>
  <div class="mt-4 flex justify-center">
    <PaginationBar :meta="meta" @change="$emit('page-change', $event)" />
  </div>
</template>
