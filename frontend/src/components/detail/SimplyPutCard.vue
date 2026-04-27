<template>
  <div class="simply-put-card">
    <div class="sp-label">{{ t('detail.simply') }}</div>
    <div class="sp-title">{{ content.title }}</div>
    <div class="sp-video-wrap" v-if="content.video_url">
      <iframe
        class="sp-video"
        :src="embedUrl(content.video_url)"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      ></iframe>
    </div>
    <div class="sp-body" v-html="content.body"></div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const { t } = useLangStore()
defineProps({ content: Object })

function embedUrl(url) {
  if (!url) return ''
  // Convert YouTube watch URL to embed URL
  const yt = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})/)
  if (yt) return `https://www.youtube.com/embed/${yt[1]}`
  // Vimeo
  const vm = url.match(/vimeo\.com\/(\d+)/)
  if (vm) return `https://player.vimeo.com/video/${vm[1]}`
  return url
}
</script>

<style scoped>
.simply-put-card {
  background: linear-gradient(135deg,#0F2044 0%,#1a3a5c 100%);
  border-radius: var(--radius); padding: 2rem; color: var(--white); position: relative; overflow: hidden;
}
.sp-label  { font-size: 0.7rem; font-weight: 700; letter-spacing: 0.15em; text-transform: uppercase; color: var(--teal2); margin-bottom: 0.5rem; }
.sp-title  { font-family: var(--font-display); font-size: 1.4rem; color: var(--white); margin-bottom: 1.2rem; }
.sp-video-wrap { position: relative; width: 100%; padding-top: 56.25%; border-radius: var(--radius-sm); overflow: hidden; margin-bottom: 1.5rem; background: #000; }
.sp-video  { position: absolute; inset: 0; width: 100%; height: 100%; border: none; }
.sp-body   { font-size: 1rem; line-height: 1.85; color: #CBD5E1; }
</style>
