<script setup>
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { postsApi } from '../api'
import PostTimeline from '../components/PostTimeline.vue'

const route = useRoute()
const router = useRouter()

const posts = ref([])
const meta = ref({ current_page: 1, total_pages: 1, total_count: 0 })
const loading = ref(false)

function toArray(value) {
  if (value == null) return []
  return Array.isArray(value) ? value : [value]
}

// URL クエリ（keyword / region / prefs / genres / page）を Ransack のパラメータへ変換する
function buildParams() {
  const query = route.query
  const params = {}
  if (query.page) params.page = query.page
  const q = {}
  if (query.keyword) q.title_or_description_cont = query.keyword
  if (query.region != null && query.region !== '') q.region_eq = query.region
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

function changePage(page) {
  router.push({ name: 'posts', query: { ...route.query, page } })
}
</script>

<template>
  <div class="container">
    <h2>投稿一覧</h2>
    <p v-if="!loading && posts.length === 0">投稿がありません</p>
    <PostTimeline :posts="posts" :meta="meta" @page-change="changePage" @deleted="fetchPosts" />
  </div>
</template>
