<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRoute, useRouter, type LocationQueryValue } from 'vue-router'
import { postsApi, type PostsIndexParams } from '../api'
import PostTimeline from '../components/PostTimeline.vue'
import type { PaginationMeta, Post } from '../types'

const route = useRoute()
const router = useRouter()

const posts = ref<Post[]>([])
const meta = ref<PaginationMeta>({ current_page: 1, total_pages: 1, total_count: 0, per_page: 0 })
const loading = ref(false)

function toArray(value: LocationQueryValue | LocationQueryValue[] | undefined): LocationQueryValue[] {
  if (value == null) return []
  return Array.isArray(value) ? value : [value]
}

// URL クエリ（keyword / region / prefs / genres / page）を Ransack のパラメータへ変換する
function buildParams(): PostsIndexParams {
  const query = route.query
  const params: PostsIndexParams = {}
  if (typeof query.page === 'string') params.page = query.page
  const q: Record<string, unknown> = {}
  if (typeof query.keyword === 'string' && query.keyword) q.title_or_description_cont = query.keyword
  if (typeof query.region === 'string' && query.region !== '') q.region_eq = query.region
  const prefectures = toArray(query.prefs)
  if (prefectures.length) q.prefecture_eq_any = prefectures
  const genres = toArray(query.genres)
  if (genres.length) q.genre_eq_any = genres
  if (Object.keys(q).length) params.q = q
  return params
}

async function fetchPosts() {
  loading.value = true
  try {
    const { data } = await postsApi.index(buildParams())
    posts.value = data.posts
    meta.value = data.meta
  } finally {
    loading.value = false
  }
}

watch(() => route.query, fetchPosts, { immediate: true })

function changePage(page: number) {
  router.push({ name: 'posts', query: { ...route.query, page } })
}
</script>

<template>
  <div class="mx-auto w-full max-w-5xl px-4 pt-6">
    <h2 class="mb-4 text-2xl font-semibold">投稿一覧</h2>
    <p v-if="!loading && posts.length === 0">投稿がありません</p>
    <PostTimeline :posts="posts" :meta="meta" @page-change="changePage" @deleted="fetchPosts" />
  </div>
</template>
