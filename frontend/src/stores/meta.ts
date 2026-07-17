import { defineStore } from 'pinia'
import { metaApi } from '../api'
import type { MetaOption } from '../types'

// バックエンドの enum 定義（地域・都道府県・分類）を保持するストア
export const useMetaStore = defineStore('meta', {
  state: () => ({
    regions: [] as MetaOption[],
    prefectures: [] as MetaOption[],
    genres: [] as MetaOption[],
    locationAccuracies: [] as MetaOption<string>[],
    prefectureToRegion: {} as Record<string, string>,
    loaded: false
  }),
  actions: {
    async ensureLoaded() {
      if (this.loaded) return
      const { data } = await metaApi.fetch()
      this.regions = data.regions
      this.prefectures = data.prefectures
      this.genres = data.genres
      this.locationAccuracies = data.location_accuracies
      this.prefectureToRegion = data.prefecture_to_region
      this.loaded = true
    }
  }
})
