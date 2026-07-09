<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { useFlashStore } from '../stores/flash'
import { adminApi } from '../api'
import PaginationBar from '../components/PaginationBar.vue'
import type { AdminAccount, PaginationMeta } from '../types'

const route = useRoute()
const router = useRouter()
const flash = useFlashStore()

const accounts = ref<AdminAccount[]>([])
const meta = ref<PaginationMeta>({ current_page: 1, total_pages: 1, total_count: 0, per_page: 0 })

async function fetchAccounts() {
  const { data } = await adminApi.accounts({ page: route.query.page })
  accounts.value = data.accounts
  meta.value = data.meta
}

watch(() => route.query.page, fetchAccounts, { immediate: true })

function changePage(page: number) {
  router.push({ name: 'admin', query: { page } })
}

async function destroyAccount(account: AdminAccount) {
  if (!window.confirm(`アカウント「@${account.name}」を削除しますか？投稿・いいねも全て削除されます。`)) return
  const { data } = await adminApi.destroyAccount(account.id)
  flash.notice(data.message)
  fetchAccounts()
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('ja-JP')
}
</script>

<template>
  <div class="mx-auto mt-10 w-full max-w-5xl px-4">
    <h1 class="mb-2 text-3xl font-bold">管理者用: アカウント管理</h1>
    <p class="text-muted-foreground mb-4">投稿の削除は各投稿の「削除」ボタンから行えます（管理者は全ての投稿を削除できます）。</p>
    <div class="overflow-x-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>ID</TableHead>
            <TableHead>アカウント名</TableHead>
            <TableHead>ニックネーム</TableHead>
            <TableHead>メールアドレス</TableHead>
            <TableHead>地域</TableHead>
            <TableHead>管理者</TableHead>
            <TableHead>投稿数</TableHead>
            <TableHead>登録日</TableHead>
            <TableHead></TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="account in accounts" :key="account.id">
            <TableCell>{{ account.id }}</TableCell>
            <TableCell>
              <router-link class="text-primary hover:underline" :to="{ name: 'account-show', params: { id: account.id } }">
                @{{ account.name }}
              </router-link>
            </TableCell>
            <TableCell>{{ account.nickname }}</TableCell>
            <TableCell>{{ account.email }}</TableCell>
            <TableCell>{{ account.region }}</TableCell>
            <TableCell>{{ account.admin ? '✓' : '' }}</TableCell>
            <TableCell>{{ account.posts_count }}</TableCell>
            <TableCell>{{ formatDate(account.created_at) }}</TableCell>
            <TableCell>
              <Button type="button" variant="destructive" size="sm" @click="destroyAccount(account)">削除</Button>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
    <div class="mt-4 flex justify-center">
      <PaginationBar :meta="meta" @change="changePage" />
    </div>
  </div>
</template>
