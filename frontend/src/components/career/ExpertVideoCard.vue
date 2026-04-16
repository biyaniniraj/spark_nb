<template>
  <div class="expert-video-card" @click="$emit('play')">
    <div class="video-thumb"><div class="play-btn">▶</div></div>
    <div class="video-info">
      <div class="video-label">{{ t('career.video.label') }}</div>
      <div class="video-title">{{ video.expert_name }} — {{ video.expert_role }}</div>
      <div class="video-desc">{{ video.quote }}</div>
    </div>
    <div class="video-arrow">›</div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const { t } = useLangStore()
defineProps({ video: Object })
defineEmits(['play'])
</script>
