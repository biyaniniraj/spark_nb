<template>
  <div class="app-card">
    <div class="app-visual" :style="{ background: app.bg_color }">{{ app.icon }}</div>
    <div class="app-title">{{ lang.current === 'hi' && app.title_hi ? app.title_hi : app.title }}</div>
    <div class="app-desc">{{ lang.current === 'hi' && app.description_hi ? app.description_hi : app.description }}</div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ app: Object })
</script>
