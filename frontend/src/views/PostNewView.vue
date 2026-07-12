<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { useFlashStore } from '../stores/flash'
import { postsApi, type PostPayload } from '../api'
import { extractErrors } from '../api/errors'
import PostForm from '../components/PostForm.vue'

const router = useRouter()
const flash = useFlashStore()

const postForm = ref<InstanceType<typeof PostForm> | null>(null)
const errors = ref<string[]>([])
const submitting = ref(false)

async function createPost(payload: PostPayload) {
  submitting.value = true
  errors.value = []
  try {
    const { data } = await postsApi.create(payload)
    // 投稿が完了した時点で写真の保存が確定する（離脱ガードを解除）
    postForm.value?.markSaved()
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
  <div class="mx-auto mt-10 w-full max-w-2xl px-4">
    <h1 class="mb-4 text-3xl font-bold">情報登録</h1>
    <Alert v-if="errors.length" variant="destructive" role="alert" class="mb-4">
      <AlertTitle>情報の登録に失敗しました</AlertTitle>
      <AlertDescription>
        <ul class="list-disc pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </AlertDescription>
    </Alert>
    <PostForm ref="postForm" mode="new" :submitting="submitting" @submit="createPost" />
  </div>
</template>
