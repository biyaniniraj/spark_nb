<template>
  <div class="quiz-result">
    <span class="qr-medal">{{ result.passed ? '🏅' : '📚' }}</span>
    <div class="qr-title">{{ result.passed ? 'Congratulations!' : 'Keep Studying!' }}</div>
    <div class="qr-score-line">You scored <em>{{ result.score }} / {{ result.total }}</em></div>
    <div v-if="result.passed" class="qr-cert-box">
      <div class="qr-cert-icon">🎓</div>
      <div>
        <span class="qr-cert-title">Certificate Issued</span>
        <span class="qr-cert-sub">Your digital badge is ready to share</span>
      </div>
    </div>
    <div class="qr-actions">
      <button class="btn btn-primary" @click="$emit('done')">Back to Dashboard</button>
      <button class="btn btn-ghost" @click="$emit('retry')">Retake Quiz</button>
    </div>
  </div>
</template>

<script setup>
defineProps({ result: Object })
defineEmits(['done', 'retry'])
</script>
