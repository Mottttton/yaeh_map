<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { accountsApi } from '../api'
import PortraitIcon from '../components/PortraitIcon.vue'
import PostTimeline from '../components/PostTimeline.vue'

const props = defineProps({
  id: { type: String, required: true }
})

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const account = ref(null)
const posts = ref([])
const meta = ref({ current_page: 1, total_pages: 1 })

const isOwn = computed(() => account.value && auth.account?.id === account.value.id)

async function fetchAccount() {
  const { data } = await accountsApi.show(props.id, { page: route.query.page })
  account.value = data.account
  posts.value = data.posts
  meta.value = data.meta
}

watch(() => [props.id, route.query.page], fetchAccount, { immediate: true })

function changePage(page) {
  router.push({ name: 'account-show', params: { id: props.id }, query: { page } })
}
</script>

<template>
  <template v-if="account">
    <div class="container mt-5">
      <h1>プロフィール詳細</h1>
      <div class="card p-3">
        <div class="d-flex justify-content-between text-align-center align-items-center">
          <div class="text-align-bottom">
            <span>
              <PortraitIcon :url="account.portrait_url" size="profile" />
            </span>
          </div>
          <router-link
            v-if="isOwn"
            id="edit-account"
            :to="{ name: 'account-edit', params: { id: account.id } }"
            class="btn btn-outline-primary"
          >プロフィール編集</router-link>
        </div>
        <span class="fs-4">{{ account.nickname }}(@{{ account.name }})</span>
        <div>
          <p>地域: {{ account.region }}</p>
        </div>
        <div>
          <p>自己紹介</p>
          <p style="white-space: pre-wrap;">{{ account.self_introduction }}</p>
        </div>
      </div>
    </div>
    <div class="container mt-3">
      <h2>投稿一覧</h2>
      <p v-if="posts.length === 0">まだ投稿はありません</p>
      <PostTimeline v-else :posts="posts" :meta="meta" @page-change="changePage" @deleted="fetchAccount" />
    </div>
  </template>
</template>
