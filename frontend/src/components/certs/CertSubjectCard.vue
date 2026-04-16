<template>
  <div class="cert-subj-card">
    <div class="csc-top">
      <div class="csc-icon" :style="{ background: subject.color_hex + '22' }">{{ subject.icon }}</div>
      <div>
        <div class="csc-name">{{ subject.name }}</div>
        <div class="csc-topics">{{ subject.topic_count }} topics</div>
      </div>
    </div>
    <div class="csc-prog">
      <div class="prog-track"><div class="prog-fill" :style="{ width: progress + '%', background: subject.color_hex }"></div></div>
      <div class="prog-txt"><span>Progress</span><span>{{ progress }}%</span></div>
    </div>
    <div class="csc-foot">
      <span class="csc-status" :style="{ color: certified ? '#059669' : 'var(--muted)' }">
        {{ certified ? '✓ Certified' : 'Not certified' }}
      </span>
      <button class="csc-action" @click="$emit('start')">{{ certified ? 'Retake →' : 'Start →' }}</button>
    </div>
  </div>
</template>

<script setup>
defineProps({ subject: Object, progress: { type: Number, default: 0 }, certified: Boolean })
defineEmits(['start'])
</script>
