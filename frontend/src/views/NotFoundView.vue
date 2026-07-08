<template>
  <div class="container mt-5 text-center">
    <h1 class="display-4">404</h1>
    <p>お探しのページは見つかりませんでした。</p>
    <router-link :to="{ name: 'top' }" class="btn btn-primary">トップページへ</router-link>
  </div>
</template>
