<template>
  <div class="page-landing">
    <LangToggle :on-dark="true" style="position:fixed;bottom:1.5rem;left:1.5rem;z-index:998" />
    <div class="landing-bg">
      <div class="bg-circle c1"></div><div class="bg-circle c2"></div><div class="bg-circle c3"></div>
    </div>
    <div class="landing-content">
      <div class="landing-eyebrow">{{ t('landing.eyebrow') }}</div>
      <h1 class="landing-headline" v-html="t('landing.headline.html')"></h1>
      <p class="landing-sub">{{ t('landing.sub') }}</p>
      <div class="landing-cta-row">
        <button class="btn btn-amber btn-lg" @click="router.push('/auth')">{{ t('landing.cta1') }}</button>
      </div>
      <div class="landing-stats">
        <div class="stat-item"><div class="stat-num">10</div><div class="stat-label">{{ t('stats.subjects') }}</div></div>
        <div class="stat-item"><div class="stat-num">100+</div><div class="stat-label">{{ t('stats.topics') }}</div></div>
        <div class="stat-item"><div class="stat-num">400+</div><div class="stat-label">{{ t('stats.careers') }}</div></div>
        <div class="stat-item"><div class="stat-num">CBSE</div><div class="stat-label">{{ t('stats.board') }}</div></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useLangStore } from '@/stores/lang'
import LangToggle from '@/components/ui/LangToggle.vue'
const router = useRouter()
const { t } = useLangStore()
</script>

<style scoped>
.page-landing { background: var(--navy); position: relative; overflow: hidden; display: flex; justify-content: center; align-items: center; text-align: center; padding: 2rem; min-height: 100vh; }
.landing-bg { position: absolute; inset: 0; overflow: hidden; pointer-events: none; }
.bg-circle { position: absolute; border-radius: 50%; opacity: 0.06; background: var(--teal2); }
.bg-circle.c1 { width: 600px; height: 600px; top: -200px; right: -150px; }
.bg-circle.c2 { width: 400px; height: 400px; bottom: -100px; left: -100px; }
.bg-circle.c3 { width: 200px; height: 200px; top: 40%; left: 10%; }
.landing-content { position: relative; z-index: 1; max-width: 640px; }
.landing-eyebrow { font-size: 0.8rem; font-weight: 500; color: var(--teal2); letter-spacing: 0.15em; text-transform: uppercase; margin-bottom: 1.2rem; }
.landing-headline { font-family: var(--font-display); font-size: clamp(2.4rem,6vw,4rem); color: var(--white); line-height: 1.15; margin-bottom: 1.5rem; white-space: nowrap; }
.landing-headline em { color: var(--amber); font-style: italic; }
.landing-sub { font-size: 1.05rem; color: var(--muted); line-height: 1.7; margin-bottom: 2.5rem; }
.landing-cta-row { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; }
.landing-stats { display: flex; gap: 2.5rem; justify-content: center; margin-top: 3.5rem; flex-wrap: wrap; }
.stat-num { font-family: var(--font-display); font-size: 2rem; color: var(--teal2); font-weight: 700; }
.stat-label { font-size: 0.75rem; color: var(--muted); margin-top: 0.2rem; }
</style>
