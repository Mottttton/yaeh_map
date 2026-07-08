<script setup lang="ts">
withDefaults(
  defineProps<{
    url?: string | null
    // 'timeline'(40px) | 'profile'(120px)
    size?: 'timeline' | 'profile'
  }>(),
  {
    url: null,
    size: 'timeline'
  }
)
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
