<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { authApi } from '../api'
import SearchDropdown from './SearchDropdown.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()

const brandTo = computed(() => (auth.signedIn ? { name: 'posts' } : { name: 'top' }))
const showSearch = computed(() => route.name === 'posts')

async function logout() {
  const { data } = await authApi.logout()
  auth.clear()
  flash.notice(data.message || 'ログアウトしました')
  router.push({ name: 'login' })
}
</script>

<template>
  <nav class="navbar navbar-expand-lg bg-body-secondary fixed-top mb-5">
    <div class="container">
      <router-link :to="brandTo" class="navbar-brand">Yaeh Map</router-link>
      <button
        class="navbar-toggler ms-auto collapsed"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#navbarCollapse"
        aria-controls="navbarCollapse"
        aria-expanded="false"
        aria-label="Toggle navigation"
      >
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse bg-body-secondary" id="navbarCollapse">
        <ul class="navbar-nav navbar-nav-scroll px-3 container">
          <template v-if="auth.signedIn">
            <li class="nav-item">
              <router-link id="account-detail" class="nav-link" :to="{ name: 'account-show', params: { id: auth.account.id } }">アカウント</router-link>
            </li>
            <li class="nav-item">
              <router-link id="post-index" class="nav-link" :to="{ name: 'posts' }">情報一覧</router-link>
            </li>
            <li class="nav-item">
              <router-link id="new-post" class="nav-link" :to="{ name: 'post-new' }">情報を投稿する</router-link>
            </li>
            <li v-if="auth.isAdmin" class="nav-item">
              <router-link id="admin-index" class="nav-link" :to="{ name: 'admin' }">管理者用</router-link>
            </li>
            <li class="nav-item">
              <a id="sign-out" class="nav-link" href="#" @click.prevent="logout">ログアウト</a>
            </li>
          </template>
          <template v-else>
            <li class="nav-item">
              <router-link id="sign-up" class="nav-link" :to="{ name: 'signup' }">新規登録</router-link>
            </li>
            <li class="nav-item">
              <router-link id="sign-in" class="nav-link" :to="{ name: 'login' }">ログイン</router-link>
            </li>
          </template>
        </ul>
      </div>
      <SearchDropdown v-if="showSearch" />
    </div>
  </nav>
</template>
