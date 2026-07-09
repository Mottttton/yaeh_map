<script setup lang="ts">
import { XIcon } from '@lucide/vue'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { useFlashStore } from '../stores/flash'

const flash = useFlashStore()
</script>

<template>
  <div v-if="flash.messages.length" class="mx-auto w-full max-w-5xl space-y-2 px-4 pt-3">
    <Alert
      v-for="message in flash.messages"
      :key="message.id"
      :variant="message.type === 'danger' ? 'destructive' : 'default'"
      role="alert"
      class="pr-10"
    >
      <AlertDescription>{{ message.text }}</AlertDescription>
      <button
        type="button"
        class="text-muted-foreground hover:text-foreground absolute top-2.5 right-2.5"
        aria-label="Close"
        @click="flash.remove(message.id)"
      >
        <XIcon class="size-4" />
      </button>
    </Alert>
  </div>
</template>
