import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { setOnUnauthorized } from '../api/client'
import TopView from '../views/TopView.vue'

const routes = [
  { path: '/', name: 'top', component: TopView, meta: { public: true } },
  { path: '/login', name: 'login', component: () => import('../views/LoginView.vue'), meta: { public: true, guestOnly: true } },
  { path: '/signup', name: 'signup', component: () => import('../views/SignupView.vue'), meta: { public: true, guestOnly: true } },
  { path: '/password/forgot', name: 'password-forgot', component: () => import('../views/PasswordForgotView.vue'), meta: { public: true } },
  { path: '/password/reset', name: 'password-reset', component: () => import('../views/PasswordResetView.vue'), meta: { public: true } },
  { path: '/posts', name: 'posts', component: () => import('../views/PostsIndexView.vue') },
  { path: '/posts/new', name: 'post-new', component: () => import('../views/PostNewView.vue') },
  { path: '/posts/:id(\\d+)', name: 'post-show', component: () => import('../views/PostShowView.vue'), props: true },
  { path: '/posts/:id(\\d+)/edit', name: 'post-edit', component: () => import('../views/PostEditView.vue'), props: true },
  { path: '/accounts/:id(\\d+)', name: 'account-show', component: () => import('../views/AccountShowView.vue'), props: true },
  { path: '/accounts/:id(\\d+)/edit', name: 'account-edit', component: () => import('../views/AccountEditView.vue'), props: true },
  { path: '/account/credentials', name: 'credentials', component: () => import('../views/CredentialsView.vue') },
  { path: '/admin', name: 'admin', component: () => import('../views/AdminAccountsView.vue'), meta: { adminOnly: true } },
  { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('../views/NotFoundView.vue'), meta: { public: true } }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  if (!auth.initialized) {
    await auth.fetchSession()
  }
  if (to.meta.guestOnly && auth.signedIn) {
    return { name: 'posts' }
  }
  if (!to.meta.public && !auth.signedIn) {
    const flash = useFlashStore()
    flash.alert('ログインしてください')
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  if (to.meta.adminOnly && !auth.isAdmin) {
    const flash = useFlashStore()
    flash.alert('アクセス権限がありません')
    return { name: 'posts' }
  }
})

// API がセッション切れ（401）を返したらログイン画面へ誘導する
setOnUnauthorized(() => {
  const auth = useAuthStore()
  if (auth.signedIn) {
    auth.clear()
    const flash = useFlashStore()
    flash.alert('ログインしてください')
    router.push({ name: 'login' })
  }
})

export default router
