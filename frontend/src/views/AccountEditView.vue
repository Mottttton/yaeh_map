<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useFlashStore } from '../stores/flash'
import { useMetaStore } from '../stores/meta'
import { accountsApi } from '../api'
import PortraitIcon from '../components/PortraitIcon.vue'

const props = defineProps({
  id: { type: String, required: true }
})

const router = useRouter()
const auth = useAuthStore()
const flash = useFlashStore()
const meta = useMetaStore()

const form = reactive({ nickname: '', region: '', self_introduction: '' })
const portraitUrl = ref(null)
const portraitFile = ref(null)
const errors = ref([])
const submitting = ref(false)

onMounted(async () => {
  // 他人のプロフィールは編集できない
  if (Number(props.id) !== auth.account?.id) {
    router.replace({ name: 'posts' })
    return
  }
  await meta.ensureLoaded()
  const { data } = await accountsApi.show(props.id)
  form.nickname = data.account.nickname
  form.region = data.account.region || ''
  form.self_introduction = data.account.self_introduction || ''
  portraitUrl.value = data.account.portrait_url
})

function onPortraitChange(event) {
  portraitFile.value = event.target.files[0] || null
}

async function updateProfile() {
  submitting.value = true
  errors.value = []
  const formData = new FormData()
  formData.append('account[nickname]', form.nickname)
  formData.append('account[region]', form.region)
  formData.append('account[self_introduction]', form.self_introduction)
  if (portraitFile.value) formData.append('account[portrait]', portraitFile.value)
  try {
    const { data } = await accountsApi.update(props.id, formData)
    flash.notice(data.message)
    router.push({ name: 'account-show', params: { id: props.id } })
  } catch (error) {
    errors.value = error.response?.data?.errors || ['更新に失敗しました']
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="container mt-5">
    <h1>プロフィール編集</h1>
    <div v-if="errors.length" class="alert alert-danger" role="alert">
      <ul class="mb-0">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </div>
    <form @submit.prevent="updateProfile">
      <div class="form-group mb-3">
        <div>
          <PortraitIcon :url="portraitUrl" size="profile" />
        </div>
        <label for="account-portrait">アイコン</label>
        <div class="input-group form-file">
          <input id="account-portrait" type="file" class="form-control form-control-sm" accept="image/png,image/jpeg" @change="onPortraitChange" />
        </div>
      </div>
      <div class="form-floating mb-3">
        <input id="account-nickname" v-model="form.nickname" type="text" class="form-control" placeholder="ニックネーム" />
        <label for="account-nickname">ニックネーム</label>
      </div>
      <div class="form-floating mb-3">
        <select id="account-region" v-model="form.region" class="form-select">
          <option value=""></option>
          <option v-for="region in meta.regions" :key="region.value" :value="region.label">{{ region.label }}</option>
        </select>
        <label for="account-region">地域</label>
      </div>
      <div class="form-floating mb-3">
        <textarea id="account-self-introduction" v-model="form.self_introduction" class="form-control" placeholder="自己紹介" style="height: 250px;"></textarea>
        <label for="account-self-introduction">自己紹介</label>
      </div>
      <div class="actions">
        <button id="update-profile" type="submit" class="btn btn-primary" :disabled="submitting">更新する</button>
      </div>
    </form>
    <hr />
    <div>
      <p>アカウント名、メールアドレス、パスワードの変更はこちら</p>
      <router-link id="edit-credentials" :to="{ name: 'credentials' }" class="btn btn-outline-primary">変更</router-link>
    </div>
  </div>
</template>
