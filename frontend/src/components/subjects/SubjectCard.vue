<template>
  <div class="subject-card" :class="{ locked: subject.is_locked }" @click="!subject.is_locked && $emit('select', subject.subject_id)">
    <span class="subj-icon">{{ subject.is_locked ? '🔒' : subject.icon }}</span>
    <div class="subj-name">{{ lang.current === 'hi' && subject.name_hi ? subject.name_hi : subject.name }}</div>
    <div class="subj-count" v-if="!subject.is_locked">{{ subject.topic_count }} topics</div>
    <div class="subj-locked-label" v-else>Paid plan required</div>
  </div>
</template>

<script setup>
import { useLangStore } from '@/stores/lang'
const lang = useLangStore()
defineProps({ subject: Object })
defineEmits(['select'])
</script>

<style scoped>
.subject-card {
  background: var(--white); border: 1.5px solid var(--lgray);
  border-radius: var(--radius); padding: 1.5rem 1.2rem;
  cursor: pointer; transition: all var(--transition); text-align: center;
}
.subject-card:hover { border-color: var(--teal); box-shadow: var(--shadow); transform: translateY(-3px); }
.subject-card.locked { opacity: 0.55; cursor: not-allowed; }
.subject-card.locked:hover { border-color: var(--lgray); box-shadow: none; transform: none; }
.subj-icon   { font-size: 2rem; margin-bottom: 0.6rem; display: block; }
.subj-name   { font-size: 0.95rem; font-weight: 600; color: var(--dktext); margin-bottom: 0.3rem; }
.subj-count  { font-size: 0.75rem; color: var(--muted); }
.subj-locked-label { font-size: 0.72rem; color: var(--muted); }
</style>
