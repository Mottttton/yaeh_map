<script setup lang="ts">
import NavBar from './components/NavBar.vue'
import FlashMessages from './components/FlashMessages.vue'
</script>

<template>
  <NavBar />
  <!-- 固定ヘッダー(h-14)ぶんの余白を確保する -->
  <div class="pt-14">
    <div id="notification">
      <FlashMessages />
    </div>
    <main>
      <router-view />
    </main>
    <div class="mx-auto w-full max-w-5xl px-4">
      <footer class="my-4 border-t py-3">
        <p class="text-muted-foreground text-center">&copy; Mottttton</p>
      </footer>
    </div>
  </div>
</template>
