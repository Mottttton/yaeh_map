<script setup lang="ts">
import NavBar from './components/NavBar.vue'
import FlashMessages from './components/FlashMessages.vue'
</script>

<template>
  <header>
    <NavBar />
  </header>
  <div id="notification">
    <FlashMessages />
  </div>
  <main>
    <router-view />
  </main>
  <div class="container">
    <footer class="py-3 my-4 border-top">
      <p class="text-center text-body-secondary">&copy; Mottttton</p>
    </footer>
  </div>
</template>
