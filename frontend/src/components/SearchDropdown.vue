<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { useRoute, useRouter, type LocationQueryRaw, type LocationQueryValue } from 'vue-router'
import { useMetaStore } from '../stores/meta'

const route = useRoute()
const router = useRouter()
const meta = useMetaStore()

interface SearchForm {
  keyword: string
  region: number | string
  prefectures: number[]
  genres: number[]
}

const form = reactive<SearchForm>({
  keyword: '',
  region: '',
  prefectures: [],
  genres: []
})

onMounted(async () => {
  await meta.ensureLoaded()
  // URL のクエリから検索条件を復元する
  form.keyword = typeof route.query.keyword === 'string' ? route.query.keyword : ''
  form.region = typeof route.query.region === 'string' ? route.query.region : ''
  form.prefectures = toArray(route.query.prefs).map(Number)
  form.genres = toArray(route.query.genres).map(Number)
})

function toArray(value: LocationQueryValue | LocationQueryValue[] | undefined): LocationQueryValue[] {
  if (value == null) return []
  return Array.isArray(value) ? value : [value]
}

function submit() {
  const query: LocationQueryRaw = {}
  if (form.keyword) query.keyword = form.keyword
  if (form.region !== '' && form.region != null) query.region = form.region
  if (form.prefectures.length) query.prefs = form.prefectures
  if (form.genres.length) query.genres = form.genres
  router.push({ name: 'posts', query })
}
</script>

<template>
  <div class="nav-item dropdown nav-search px-3">
    <a class="nav-link" role="button" href="#" id="navSearch" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
      <i class="bi bi-search fs-4"> </i>
    </a>
    <div class="dropdown-menu dropdown-menu-end navbar-nav-scroll shadow rounded p-2" aria-labelledby="navSearch">
      <form @submit.prevent="submit">
        <div class="mb-3">
          <label for="search-keyword" class="form-label">キーワード</label>
          <input id="search-keyword" v-model="form.keyword" type="search" class="form-control" />
        </div>
        <div class="mb-3">
          <label for="search-region">地域</label>
          <select id="search-region" v-model="form.region" class="form-select">
            <option value=""></option>
            <option v-for="region in meta.regions" :key="region.value" :value="region.value">{{ region.label }}</option>
          </select>
        </div>
        <div class="mb-3">
          <div>都道府県</div>
          <div v-for="prefecture in meta.prefectures" :key="prefecture.value" class="form-check form-check-inline">
            <input
              :id="`search-pref-${prefecture.value}`"
              v-model="form.prefectures"
              type="checkbox"
              class="form-check-input"
              :value="prefecture.value"
            />
            <label :for="`search-pref-${prefecture.value}`" class="form-check-label">{{ prefecture.label }}</label>
          </div>
        </div>
        <div class="mb-3">
          <div>分類</div>
          <div v-for="genre in meta.genres" :key="genre.value" class="form-check form-check-inline">
            <input
              :id="`search-genre-${genre.value}`"
              v-model="form.genres"
              type="checkbox"
              class="form-check-input"
              :value="genre.value"
            />
            <label :for="`search-genre-${genre.value}`" class="form-check-label">{{ genre.label }}</label>
          </div>
        </div>
        <div class="d-flex justify-content-start">
          <button type="submit" class="btn btn-secondary">検索</button>
        </div>
      </form>
    </div>
  </div>
</template>
