<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useFlashStore } from '../stores/flash'
import { postsApi } from '../api'
import { extractErrors } from '../api/errors'
import PostForm from '../components/PostForm.vue'

const router = useRouter()
const flash = useFlashStore()

const errors = ref<string[]>([])
const submitting = ref(false)

async function createPost(formData: FormData) {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await postsApi.create(formData)
    flash.notice(data.message)
    router.push({ name: 'posts' })
  } catch (error) {
    errors.value = extractErrors(error, '情報の登録に失敗しました')
    window.scrollTo({ top: 0 })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <h1>情報登録</h1>
    <div v-if="errors.length" class="alert alert-danger">
      <h2 class="alert-heading">情報の登録に失敗しました</h2>
      <ul>
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </div>
    <PostForm mode="new" :submitting="submitting" @submit="createPost" />
  </div>
</template>
