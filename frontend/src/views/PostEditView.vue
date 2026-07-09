<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { useFlashStore } from '../stores/flash'
import { postsApi } from '../api'
import { extractErrors } from '../api/errors'
import PostForm from '../components/PostForm.vue'
import type { Post } from '../types'

const props = defineProps<{ id: string }>()

const router = useRouter()
const flash = useFlashStore()

const post = ref<Post | null>(null)
const errors = ref<string[]>([])
const submitting = ref(false)

onMounted(async () => {
  const { data } = await postsApi.show(props.id)
  post.value = data.post
})

async function updatePost(formData: FormData) {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await postsApi.update(props.id, formData)
    flash.notice(data.message)
    router.push({ name: 'post-show', params: { id: props.id } })
  } catch (error) {
    errors.value = extractErrors(error, '情報の更新に失敗しました')
    window.scrollTo({ top: 0 })
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="mx-auto mt-10 w-full max-w-2xl px-4">
    <h1 class="mb-4 text-3xl font-bold">情報編集</h1>
    <Alert v-if="errors.length" variant="destructive" role="alert" class="mb-4">
      <AlertTitle>情報の更新に失敗しました</AlertTitle>
      <AlertDescription>
        <ul class="list-disc pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </AlertDescription>
    </Alert>
    <PostForm v-if="post" mode="edit" :initial-post="post" :submitting="submitting" @submit="updatePost" />
  </div>
</template>
