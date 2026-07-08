<script setup>
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useFlashStore } from '../stores/flash'
import { adminApi } from '../api'
import PaginationBar from '../components/PaginationBar.vue'

const route = useRoute()
const router = useRouter()
const flash = useFlashStore()

const accounts = ref([])
const meta = ref({ current_page: 1, total_pages: 1 })

async function fetchAccounts() {
  const { data } = await adminApi.accounts({ page: route.query.page })
  accounts.value = data.accounts
  meta.value = data.meta
}

watch(() => route.query.page, fetchAccounts, { immediate: true })

function changePage(page) {
  router.push({ name: 'admin', query: { page } })
}

async function destroyAccount(account) {
  if (!window.confirm(`アカウント「@${account.name}」を削除しますか？投稿・いいねも全て削除されます。`)) return
  const { data } = await adminApi.destroyAccount(account.id)
  flash.notice(data.message)
  fetchAccounts()
}

function formatDate(iso) {
  return new Date(iso).toLocaleDateString('ja-JP')
}
</script>

<template>
  <div class="container mt-5">
    <h1>管理者用: アカウント管理</h1>
    <p class="text-body-secondary">投稿の削除は各投稿の「削除」ボタンから行えます（管理者は全ての投稿を削除できます）。</p>
    <div class="table-responsive">
      <table class="table table-striped align-middle">
        <thead>
          <tr>
            <th>ID</th>
            <th>アカウント名</th>
            <th>ニックネーム</th>
            <th>メールアドレス</th>
            <th>地域</th>
            <th>管理者</th>
            <th>投稿数</th>
            <th>登録日</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="account in accounts" :key="account.id">
            <td>{{ account.id }}</td>
            <td>
              <router-link :to="{ name: 'account-show', params: { id: account.id } }">@{{ account.name }}</router-link>
            </td>
            <td>{{ account.nickname }}</td>
            <td>{{ account.email }}</td>
            <td>{{ account.region }}</td>
            <td>{{ account.admin ? '✓' : '' }}</td>
            <td>{{ account.posts_count }}</td>
            <td>{{ formatDate(account.created_at) }}</td>
            <td>
              <button type="button" class="btn btn-sm btn-outline-danger" @click="destroyAccount(account)">削除</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="d-flex justify-content-center mt-3">
      <PaginationBar :meta="meta" @change="changePage" />
    </div>
  </div>
</template>
