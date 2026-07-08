import { defineStore } from 'pinia'

let nextId = 1

// 旧 Rails の flash メッセージ相当（成功: success / 失敗: danger）
export const useFlashStore = defineStore('flash', {
  state: () => ({
    messages: []
  }),
  actions: {
    push(type, text) {
      const id = nextId++
      this.messages.push({ id, type, text })
      setTimeout(() => this.remove(id), 5000)
    },
    notice(text) {
      this.push('success', text)
    },
    alert(text) {
      this.push('danger', text)
    },
    remove(id) {
      this.messages = this.messages.filter((message) => message.id !== id)
    }
  }
})
