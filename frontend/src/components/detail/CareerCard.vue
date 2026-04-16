<template>
  <div class="career-card" @click="$emit('select', career.career_id)">
    <div class="career-icon-wrap" :style="{ background: career.bg_color }">{{ career.icon }}</div>
    <div class="career-name">{{ lang.current === 'hi' && career.name_hi ? career.name_hi : career.name }}</div>
    <div class="career-task">{{ lang.current === 'hi' && career.task_hi ? career.task_hi : career.task }}</div>
    <div class="career-link">{{ t('detail.career.link') }}</div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
const { t } = lang
defineProps({ career: Object })
defineEmits(['select'])
</script>
