<template>
  <div class="topic-row" :class="{ locked: topic.is_locked }" @click="!topic.is_locked && $emit('select', topic.topic_id)">
    <div class="topic-num">{{ String(index + 1).padStart(2, '0') }}</div>
    <div class="topic-info">
      <div class="topic-name">{{ lang.current === 'hi' && topic.name_hi ? topic.name_hi : topic.name }}</div>
      <div v-if="topic.is_locked" class="topic-preview lock-label">Upgrade to access</div>
      <div v-else-if="topic.simply_put_title" class="topic-preview">{{ topic.simply_put_title }}</div>
    </div>
    <div class="topic-meta">
      <span class="badge badge-teal">{{ lang.current === 'hi' ? 'कक्षा' : 'Class' }} {{ topic.grade }}</span>
      <span class="topic-arrow">{{ topic.is_locked ? '🔒' : '›' }}</span>
    </div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ topic: Object, index: Number })
defineEmits(['select'])
</script>

<style scoped>
.topic-row.locked { opacity: 0.55; cursor: not-allowed; }
.topic-row.locked:hover { border-color: var(--lgray); box-shadow: none; transform: none; }
.lock-label { font-size: 0.72rem; color: var(--muted); margin-top: 2px; }
</style>
