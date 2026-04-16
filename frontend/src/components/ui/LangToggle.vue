<template>
  <button class="lang-btn" :class="{ 'on-dark': onDark }" @click="lang.toggle()">
    <span class="lang-icon">🌐</span>
    <span class="lang-label">{{ lang.current === 'en' ? 'हिंदी' : 'English' }}</span>
  </button>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ onDark: Boolean })
</script>

<style scoped>
.lang-btn {
  display: flex; align-items: center; gap: 7px;
  padding: 0.5rem 1rem; border-radius: 30px; border: none; cursor: pointer;
  font-family: var(--font-body); font-size: 0.8rem; font-weight: 700;
  background: var(--white); color: var(--navy);
  box-shadow: 0 4px 20px rgba(0,0,0,0.18);
  transition: all 0.22s ease;
}
.lang-btn:hover { background: var(--teal); color: var(--white); transform: translateY(-2px); }
.lang-btn.on-dark { background: rgba(255,255,255,0.12); color: var(--white); border: 1px solid rgba(255,255,255,0.2); }
</style>
