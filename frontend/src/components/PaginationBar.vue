<script setup lang="ts">
import { computed } from 'vue'
import type { PaginationMeta } from '../types'

const props = defineProps<{ meta: PaginationMeta }>()
const emit = defineEmits<{ change: [page: number] }>()

const pages = computed(() => {
  const current = props.meta.current_page
  const total = props.meta.total_pages
  const windowSize = 2
  const result: number[] = []
  for (let page = Math.max(1, current - windowSize); page <= Math.min(total, current + windowSize); page++) {
    result.push(page)
  }
  return result
})

function goTo(page: number) {
  if (page < 1 || page > props.meta.total_pages || page === props.meta.current_page) return
  emit('change', page)
}
</script>

<template>
  <nav v-if="meta.total_pages > 1" aria-label="pagination">
    <ul class="pagination">
      <li class="page-item" :class="{ disabled: meta.current_page === 1 }">
        <a class="page-link" href="#" @click.prevent="goTo(1)">&laquo; 最初</a>
      </li>
      <li class="page-item" :class="{ disabled: meta.current_page === 1 }">
        <a class="page-link" href="#" @click.prevent="goTo(meta.current_page - 1)">&lsaquo; 前</a>
      </li>
      <li v-for="page in pages" :key="page" class="page-item" :class="{ active: page === meta.current_page }">
        <a class="page-link" href="#" @click.prevent="goTo(page)">{{ page }}</a>
      </li>
      <li class="page-item" :class="{ disabled: meta.current_page === meta.total_pages }">
        <a class="page-link" href="#" @click.prevent="goTo(meta.current_page + 1)">次 &rsaquo;</a>
      </li>
      <li class="page-item" :class="{ disabled: meta.current_page === meta.total_pages }">
        <a class="page-link" href="#" @click.prevent="goTo(meta.total_pages)">最後 &raquo;</a>
      </li>
    </ul>
  </nav>
</template>
