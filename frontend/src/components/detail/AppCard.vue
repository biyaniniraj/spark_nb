<template>
  <div class="app-card">
    <div class="app-video-wrap" v-if="app.video_url">
      <iframe
        class="app-video"
        :src="embedUrl(app.video_url)"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      ></iframe>
    </div>
    <div class="app-visual" v-else :style="{ background: app.bg_color }">{{ app.icon }}</div>
    <div class="app-title">{{ lang.current === 'hi' && app.title_hi ? app.title_hi : app.title }}</div>
    <div class="app-desc">{{ lang.current === 'hi' && app.description_hi ? app.description_hi : app.description }}</div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ app: Object })

function embedUrl(url) {
  if (!url) return ''
  const yt = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})/)
  if (yt) return `https://www.youtube.com/embed/${yt[1]}`
  const vm = url.match(/vimeo\.com\/(\d+)/)
  if (vm) return `https://player.vimeo.com/video/${vm[1]}`
  return url
}
</script>

<style scoped>
.app-card { display: flex; flex-direction: column; background: var(--white); border-right: 1px solid var(--lgray); padding: 1.2rem; gap: 0.6rem; }
.app-video-wrap { position: relative; width: 100%; padding-top: 56.25%; border-radius: var(--radius-sm); overflow: hidden; background: #000; margin-bottom: 0.4rem; }
.app-video { position: absolute; inset: 0; width: 100%; height: 100%; border: none; }
.app-visual { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; }
.app-title { font-size: 0.9rem; font-weight: 600; color: var(--dktext); }
.app-desc  { font-size: 0.8rem; color: var(--gray); line-height: 1.6; }
</style>
