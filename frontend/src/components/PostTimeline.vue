<script setup lang="ts">
import PostCard from './PostCard.vue'
import PaginationBar from './PaginationBar.vue'
import type { PaginationMeta, Post } from '../types'

defineProps<{ posts: Post[]; meta: PaginationMeta }>()
defineEmits<{ 'page-change': [page: number]; deleted: [id: number] }>()
</script>

<template>
  <div id="timeline" class="row row-cols-1 row-cols-md-2 g-4">
    <div v-for="post in posts" :key="post.id" :id="`post-${post.id}`" class="col">
      <PostCard :post="post" @deleted="$emit('deleted', $event)" />
    </div>
  </div>
  <div class="d-flex justify-content-center mt-3">
    <PaginationBar :meta="meta" @change="$emit('page-change', $event)" />
  </div>
</template>
