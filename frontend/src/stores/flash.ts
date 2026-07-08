import { defineStore } from 'pinia'
import type { FlashMessage, FlashType } from '../types'

let nextId = 1

// 旧 Rails の flash メッセージ相当（成功: success / 失敗: danger）
export const useFlashStore = defineStore('flash', {
  state: () => ({
    messages: [] as FlashMessage[]
  }),
  actions: {
    push(type: FlashType, text: string) {
      const id = nextId++
      this.messages.push({ id, type, text })
      setTimeout(() => this.remove(id), 5000)
    },
    notice(text: string) {
      this.push('success', text)
    },
    alert(text: string) {
      this.push('danger', text)
    },
    remove(id: number) {
      this.messages = this.messages.filter((message) => message.id !== id)
    }
  }
})
