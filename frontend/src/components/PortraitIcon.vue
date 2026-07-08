<script setup>
defineProps({
  url: { type: String, default: null },
  // 'timeline'(40px) | 'profile'(120px)
  size: { type: String, default: 'timeline' }
})
</script>

<template>
  <img
    v-if="url"
    :src="url"
    :class="size === 'profile' ? 'profile-portrait' : 'timeline-portrait'"
    class="rounded-circle"
    alt="portrait"
  />
  <i v-else class="bi bi-person-circle" :class="size === 'profile' ? 'fs-1' : 'fs-2'"></i>
</template>
