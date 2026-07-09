<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { SearchIcon } from '@lucide/vue'
import { useRoute, useRouter, type LocationQueryRaw, type LocationQueryValue } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { useMetaStore } from '../stores/meta'

const route = useRoute()
const router = useRouter()
const meta = useMetaStore()

const open = ref(false)

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

// チェックボックス群（複数選択）の値をトグルする
function toggleValue(list: number[], value: number, checked: boolean) {
  const index = list.indexOf(value)
  if (checked && index === -1) list.push(value)
  if (!checked && index !== -1) list.splice(index, 1)
}

function submit() {
  const query: LocationQueryRaw = {}
  if (form.keyword) query.keyword = form.keyword
  if (form.region !== '' && form.region != null) query.region = form.region
  if (form.prefectures.length) query.prefs = form.prefectures
  if (form.genres.length) query.genres = form.genres
  open.value = false
  router.push({ name: 'posts', query })
}
</script>

<template>
  <Popover v-model:open="open">
    <PopoverTrigger as-child>
      <Button id="navSearch" variant="ghost" size="icon" aria-label="検索">
        <SearchIcon class="size-5" />
      </Button>
    </PopoverTrigger>
    <PopoverContent align="end" class="max-h-[80vh] w-80 overflow-y-auto">
      <form class="space-y-4" @submit.prevent="submit">
        <div class="space-y-2">
          <Label for="search-keyword">キーワード</Label>
          <Input id="search-keyword" v-model="form.keyword" type="search" />
        </div>
        <div class="space-y-2">
          <Label for="search-region">地域</Label>
          <select id="search-region" v-model="form.region" class="native-select">
            <option value=""></option>
            <option v-for="region in meta.regions" :key="region.value" :value="region.value">{{ region.label }}</option>
          </select>
        </div>
        <div class="space-y-2">
          <div class="text-sm font-medium">都道府県</div>
          <div class="flex flex-wrap gap-x-4 gap-y-2">
            <div v-for="prefecture in meta.prefectures" :key="prefecture.value" class="flex items-center gap-2">
              <Checkbox
                :id="`search-pref-${prefecture.value}`"
                :model-value="form.prefectures.includes(prefecture.value)"
                @update:model-value="(v) => toggleValue(form.prefectures, prefecture.value, v === true)"
              />
              <Label :for="`search-pref-${prefecture.value}`" class="font-normal">{{ prefecture.label }}</Label>
            </div>
          </div>
        </div>
        <div class="space-y-2">
          <div class="text-sm font-medium">分類</div>
          <div class="flex flex-wrap gap-x-4 gap-y-2">
            <div v-for="genre in meta.genres" :key="genre.value" class="flex items-center gap-2">
              <Checkbox
                :id="`search-genre-${genre.value}`"
                :model-value="form.genres.includes(genre.value)"
                @update:model-value="(v) => toggleValue(form.genres, genre.value, v === true)"
              />
              <Label :for="`search-genre-${genre.value}`" class="font-normal">{{ genre.label }}</Label>
            </div>
          </div>
        </div>
        <div class="flex justify-start">
          <Button type="submit" variant="secondary">検索</Button>
        </div>
      </form>
    </PopoverContent>
  </Popover>
</template>
