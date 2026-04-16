<template>
  <div class="simply-put-card">
    <div class="sp-label">{{ t('detail.simply') }}</div>
    <div class="sp-title">{{ content.title }}</div>
    <div class="sp-body" v-html="content.body"></div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const { t } = useLangStore()
defineProps({ content: Object })
</script>

<style scoped>
.simply-put-card {
  background: linear-gradient(135deg,#0F2044 0%,#1a3a5c 100%);
  border-radius: var(--radius); padding: 2rem; color: var(--white); position: relative; overflow: hidden;
}
.sp-label  { font-size: 0.7rem; font-weight: 700; letter-spacing: 0.15em; text-transform: uppercase; color: var(--teal2); margin-bottom: 0.5rem; }
.sp-title  { font-family: var(--font-display); font-size: 1.4rem; color: var(--white); margin-bottom: 1.2rem; }
.sp-body   { font-size: 1rem; line-height: 1.85; color: #CBD5E1; }
</style>
