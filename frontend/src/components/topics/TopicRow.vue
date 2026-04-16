<template>
  <div class="topic-row" @click="$emit('select', topic.topic_id)">
    <div class="topic-num">{{ index + 1 }}</div>
    <div class="topic-info">
      <div class="topic-name">{{ lang.current === 'hi' && topic.name_hi ? topic.name_hi : topic.name }}</div>
    </div>
    <div class="topic-meta">
      <BadgePill variant="teal">Class {{ topic.grade }}</BadgePill>
    </div>
    <span class="topic-arrow">›</span>
  </div>
</template>

<script setup>
import BadgePill from '@/components/ui/BadgePill.vue'
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ topic: Object, index: Number })
defineEmits(['select'])
</script>
