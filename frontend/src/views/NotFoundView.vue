<script setup lang="ts">
import { Button } from '@/components/ui/button'
</script>

<template>
  <div class="mx-auto mt-10 w-full max-w-xl px-4 text-center">
    <h1 class="text-6xl font-bold">404</h1>
    <p class="my-4">お探しのページは見つかりませんでした。</p>
    <Button as-child>
      <router-link :to="{ name: 'top' }">トップページへ</router-link>
    </Button>
  </div>
</template>
