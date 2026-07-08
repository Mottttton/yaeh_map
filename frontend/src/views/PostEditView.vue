<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useFlashStore } from '../stores/flash'
import { postsApi } from '../api'
import PostForm from '../components/PostForm.vue'

const props = defineProps({
  id: { type: String, required: true }
})

const router = useRouter()
const flash = useFlashStore()

const post = ref(null)
const errors = ref([])
const submitting = ref(false)

onMounted(async () => {
  const { data } = await postsApi.show(props.id)
  post.value = data.post
})

async function updatePost(formData) {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await postsApi.update(props.id, formData)
    flash.notice(data.message)
    router.push({ name: 'post-show', params: { id: props.id } })
  } catch (error) {
    errors.value = error.response?.data?.errors || ['情報の更新に失敗しました']
    window.scrollTo({ top: 0 })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <h1>情報編集</h1>
    <div v-if="errors.length" class="alert alert-danger">
      <h2 class="alert-heading">情報の更新に失敗しました</h2>
      <ul>
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </div>
    <PostForm v-if="post" mode="edit" :initial-post="post" :submitting="submitting" @submit="updatePost" />
  </div>
</template>
