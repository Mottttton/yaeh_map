<script setup lang="ts">
import { MapPinIcon } from '@lucide/vue'
import { Button } from '@/components/ui/button'
import appExample from '../assets/app_example.png'
</script>

<template>
  <div class="border-b px-4 pt-12 pb-0 text-center">
    <h1 class="text-5xl font-bold">Yaeh Map</h1>
    <div class="mx-auto max-w-2xl">
      <p class="text-muted-foreground mt-4 mb-6 text-xl">仲間と情報をシェアしてツーリングをもっと楽しく安全に</p>
      <div class="mb-10 flex flex-col justify-center gap-2 sm:flex-row">
        <Button as-child size="lg" class="sign-up px-6">
          <router-link :to="{ name: 'signup' }">新規登録</router-link>
        </Button>
        <Button as-child size="lg" variant="outline" class="sign-in px-6">
          <router-link :to="{ name: 'login' }">ログイン</router-link>
        </Button>
      </div>
    </div>
    <div class="max-h-[65vh] overflow-hidden">
      <div class="mx-auto max-w-3xl px-5">
        <img
          :src="appExample"
          class="mb-4 w-full rounded-xl border shadow-lg"
          alt="top cover"
          width="700"
          height="500"
          loading="lazy"
        />
      </div>
    </div>
  </div>

  <div class="mx-auto w-full max-w-4xl px-4 py-10">
    <h2 class="border-b pb-2 text-3xl font-semibold">コンセプト</h2>
    <p class="mt-4 text-xl">
      Yaeh Mapはツーリングが好きなライダーのための情報共有SNSです。Yaeh(ヤエー)とはツーリングですれ違ったライダー同士の挨拶で、お互いの旅の安全を込めたハンドサインです。ユーザー同士で危険情報を共有することで少しでもオートバイの事故が減ることを願い、Yaeh Mapをつくりました。
    </p>
    <p class="mt-4 text-xl">
      注意情報だけでなくオススメのツーリングスポットやタイムリーな情報もシェアして楽しく安全にツーリングしてください！
    </p>
  </div>

  <div id="featured-3" class="mx-auto w-full max-w-4xl px-4 py-3">
    <h2 class="border-b pb-2 text-3xl font-semibold">機能紹介</h2>
    <div class="feature py-8">
      <div class="bg-primary text-primary-foreground mb-3 inline-flex size-14 items-center justify-center rounded-lg">
        <MapPinIcon class="size-7" />
      </div>
      <h3 class="text-2xl font-semibold">地図付きの情報投稿</h3>
      <ul class="mt-2 list-disc pl-6">
        <li>ツーリングスポットや危険情報を地図付きで投稿</li>
        <li>写真も添付可能(4枚まで)</li>
        <li>キーワードや都道府県で情報検索可能</li>
      </ul>
    </div>
  </div>

  <div class="mx-auto max-w-2xl px-4">
    <h2 class="mb-4 text-center text-xl font-bold">さっそく使ってみる</h2>
    <div class="mb-10 flex flex-col justify-center gap-2 sm:flex-row">
      <Button as-child size="lg" class="sign-up px-6">
        <router-link :to="{ name: 'signup' }">新規登録</router-link>
      </Button>
      <Button as-child size="lg" variant="outline" class="sign-in px-6">
        <router-link :to="{ name: 'login' }">ログイン</router-link>
      </Button>
    </div>
  </div>
</template>
