<script setup lang="ts">
import { useFlashStore } from '../stores/flash'

const flash = useFlashStore()
</script>

<template>
  <div
    v-for="message in flash.messages"
    :key="message.id"
    :class="`alert alert-${message.type}`"
    role="alert"
  >
    {{ message.text }}
    <button type="button" class="btn-close float-end" aria-label="Close" @click="flash.remove(message.id)"></button>
  </div>
</template>
