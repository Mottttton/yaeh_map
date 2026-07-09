<script setup lang="ts">
import { ChevronLeftIcon, ChevronRightIcon } from '@lucide/vue'
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationFirst,
  PaginationItem,
  PaginationLast,
  PaginationNext,
  PaginationPrevious
} from '@/components/ui/pagination'
import type { PaginationMeta } from '../types'

defineProps<{ meta: PaginationMeta }>()
const emit = defineEmits<{ change: [page: number] }>()
</script>

<template>
  <Pagination
    v-if="meta.total_pages > 1"
    v-slot="{ page }"
    :total="meta.total_count"
    :items-per-page="Math.max(meta.per_page, 1)"
    :page="meta.current_page"
    :sibling-count="2"
    show-edges
    aria-label="pagination"
    @update:page="emit('change', $event)"
  >
    <PaginationContent v-slot="{ items }">
      <PaginationFirst />
      <PaginationPrevious>
        <ChevronLeftIcon data-icon="inline-start" />
        <span class="hidden sm:block">前</span>
      </PaginationPrevious>
      <template v-for="(item, index) in items" :key="index">
        <PaginationItem v-if="item.type === 'page'" :value="item.value" :is-active="item.value === page">
          {{ item.value }}
        </PaginationItem>
        <PaginationEllipsis v-else :index="index" />
      </template>
      <PaginationNext>
        <span class="hidden sm:block">次</span>
        <ChevronRightIcon data-icon="inline-end" />
      </PaginationNext>
      <PaginationLast />
    </PaginationContent>
  </Pagination>
</template>
