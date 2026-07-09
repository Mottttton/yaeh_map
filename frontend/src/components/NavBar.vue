<script setup lang="ts">
import { computed, ref } from 'vue'
import { MenuIcon } from '@lucide/vue'
import { useRoute, useRouter } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Sheet, SheetClose, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '@/components/ui/sheet'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'
import SearchDropdown from './SearchDropdown.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()

const menuOpen = ref(false)

const brandTo = computed(() => (auth.signedIn ? { name: 'posts' } : { name: 'top' }))
const showSearch = computed(() => route.name === 'posts')

// メニュー項目は PC（インライン）とモバイル（Sheet）で共通
const links = computed(() =>
  auth.account
    ? [
        { id: 'account-detail', label: 'アカウント', to: { name: 'account-show', params: { id: auth.account.id } } },
        { id: 'post-index', label: '情報一覧', to: { name: 'posts' } },
        { id: 'new-post', label: '情報を投稿する', to: { name: 'post-new' } },
        ...(auth.isAdmin ? [{ id: 'admin-index', label: '管理者用', to: { name: 'admin' } }] : [])
      ]
    : [
        { id: 'sign-up', label: '新規登録', to: { name: 'signup' } },
        { id: 'sign-in', label: 'ログイン', to: { name: 'login' } }
      ]
)

async function logout() {
  menuOpen.value = false
  const { data } = await authApi.logout()
  auth.clear()
  flash.notice(data.message || 'ログアウトしました')
  router.push({ name: 'login' })
}
</script>

<template>
  <header class="bg-secondary fixed inset-x-0 top-0 z-50 border-b">
    <nav class="mx-auto flex h-14 w-full max-w-5xl items-center gap-4 px-4">
      <router-link :to="brandTo" class="text-lg font-semibold">Yaeh Map</router-link>

      <!-- PC: インラインメニュー -->
      <ul class="hidden flex-1 items-center gap-1 lg:flex">
        <li v-for="link in links" :key="link.id">
          <Button as-child variant="ghost">
            <router-link :id="link.id" :to="link.to">{{ link.label }}</router-link>
          </Button>
        </li>
        <li v-if="auth.signedIn">
          <Button id="sign-out" variant="ghost" @click="logout">ログアウト</Button>
        </li>
      </ul>

      <div class="ml-auto flex items-center gap-1">
        <SearchDropdown v-if="showSearch" />

        <!-- モバイル: Sheet メニュー -->
        <Sheet v-model:open="menuOpen">
          <SheetTrigger as-child>
            <Button variant="ghost" size="icon" class="lg:hidden" aria-label="Toggle navigation">
              <MenuIcon />
            </Button>
          </SheetTrigger>
          <SheetContent side="right" class="w-64">
            <SheetHeader>
              <SheetTitle>メニュー</SheetTitle>
            </SheetHeader>
            <ul class="flex flex-col gap-1 px-4">
              <li v-for="link in links" :key="link.id">
                <SheetClose as-child>
                  <router-link :to="link.to" class="hover:bg-muted block rounded-md px-3 py-2">
                    {{ link.label }}
                  </router-link>
                </SheetClose>
              </li>
              <li v-if="auth.signedIn">
                <button
                  type="button"
                  class="hover:bg-muted block w-full rounded-md px-3 py-2 text-left"
                  @click="logout"
                >
                  ログアウト
                </button>
              </li>
            </ul>
          </SheetContent>
        </Sheet>
      </div>
    </nav>
  </header>
</template>
