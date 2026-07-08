import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'
// Collapse / Dropdown / Carousel などの data 属性 API を有効化
import 'bootstrap'
import './styles/app.css'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')
