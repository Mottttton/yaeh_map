<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useFlashStore } from '../stores/flash'
import { postsApi } from '../api'
import PostForm from '../components/PostForm.vue'

const router = useRouter()
const flash = useFlashStore()

const errors = ref([])
const submitting = ref(false)

async function createPost(formData) {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await postsApi.create(formData)
    flash.notice(data.message)
    router.push({ name: 'posts' })
  } catch (error) {
    errors.value = error.response?.data?.errors || ['情報の登録に失敗しました']
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
