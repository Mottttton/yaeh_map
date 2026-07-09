<script setup lang="ts">
import { CircleUserRoundIcon } from '@lucide/vue'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'

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
  <Avatar class="align-middle" :class="size === 'profile' ? 'size-30' : 'size-10'">
    <AvatarImage v-if="url" :src="url" alt="portrait" class="object-cover" />
    <AvatarFallback class="bg-transparent">
      <CircleUserRoundIcon
        class="text-muted-foreground"
        :class="size === 'profile' ? 'size-16' : 'size-8'"
      />
    </AvatarFallback>
  </Avatar>
</template>
