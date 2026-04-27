<template>
  <div class="pv-card">
    <div class="pv-video-wrap" v-if="voice.video_url">
      <iframe
        class="pv-video"
        :src="embedUrl(voice.video_url)"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      ></iframe>
    </div>
    <div class="pv-profession">
      {{ lang.current === 'hi' && voice.profession_title_hi ? voice.profession_title_hi : voice.profession_title }}
    </div>
    <blockquote class="pv-quote">
      "{{ lang.current === 'hi' && voice.quote_text_hi ? voice.quote_text_hi : voice.quote_text }}"
    </blockquote>
    <div class="pv-subtopic" v-if="voice.subtopic_link">{{ voice.subtopic_link }}</div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ voice: Object })

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
.pv-card { background: var(--white); border: 1px solid var(--lgray); border-radius: var(--radius); overflow: hidden; display: flex; flex-direction: column; }
.pv-video-wrap { position: relative; width: 100%; padding-top: 56.25%; background: #000; }
.pv-video { position: absolute; inset: 0; width: 100%; height: 100%; border: none; }
.pv-profession { font-size: 0.72rem; font-weight: 700; letter-spacing: 0.1em; text-transform: uppercase; color: var(--teal); padding: 1rem 1.2rem 0.4rem; }
.pv-quote { margin: 0; padding: 0 1.2rem 0.8rem; font-size: 0.9rem; line-height: 1.7; color: var(--dktext); font-style: italic; border: none; }
.pv-subtopic { margin: 0 1.2rem 1rem; font-size: 0.72rem; font-weight: 600; color: var(--amber); background: var(--amber-light); border-radius: 20px; padding: 0.25rem 0.75rem; display: inline-block; }
</style>
