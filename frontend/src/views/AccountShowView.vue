<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { useAuthStore } from '../stores/auth'
import { accountsApi } from '../api'
import PortraitIcon from '../components/PortraitIcon.vue'
import PostTimeline from '../components/PostTimeline.vue'
import type { AccountProfile, PaginationMeta, Post } from '../types'

const props = defineProps<{ id: string }>()

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const account = ref<AccountProfile | null>(null)
const posts = ref<Post[]>([])
const meta = ref<PaginationMeta>({ current_page: 1, total_pages: 1, total_count: 0, per_page: 0 })

const isOwn = computed(() => !!account.value && auth.account?.id === account.value.id)

async function fetchAccount() {
  const { data } = await accountsApi.show(props.id, { page: route.query.page })
  account.value = data.account
  posts.value = data.posts
  meta.value = data.meta
}

watch(() => [props.id, route.query.page], fetchAccount, { immediate: true })

function changePage(page: number) {
  router.push({ name: 'account-show', params: { id: props.id }, query: { page } })
}
</script>

<template>
  <template v-if="account">
    <div class="mx-auto mt-10 w-full max-w-4xl px-4">
      <h1 class="mb-4 text-3xl font-bold">プロフィール詳細</h1>
      <Card>
        <CardContent class="space-y-2">
          <div class="flex items-center justify-between">
            <PortraitIcon :url="account.portrait_url" size="profile" />
            <Button v-if="isOwn" id="edit-account" as-child variant="outline">
              <router-link :to="{ name: 'account-edit', params: { id: account.id } }">プロフィール編集</router-link>
            </Button>
          </div>
          <div class="text-xl">{{ account.nickname }}(@{{ account.name }})</div>
          <p>地域: {{ account.region }}</p>
          <div>
            <p>自己紹介</p>
            <p class="whitespace-pre-wrap">{{ account.self_introduction }}</p>
          </div>
        </CardContent>
      </Card>
    </div>
    <div class="mx-auto mt-6 w-full max-w-5xl px-4">
      <h2 class="mb-4 text-2xl font-semibold">投稿一覧</h2>
      <p v-if="posts.length === 0">まだ投稿はありません</p>
      <PostTimeline v-else :posts="posts" :meta="meta" @page-change="changePage" @deleted="fetchAccount" />
    </div>
  </template>
</template>
