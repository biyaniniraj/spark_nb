<template>
  <div class="cert-badge">
    <div class="cb-ribbon">CERTIFIED</div>
    <span class="cb-medal">🏅</span>
    <div class="cb-subj">{{ cert.subject_name }}</div>
    <div class="cb-title">Spark Certified Teacher</div>
    <div class="cb-date">{{ new Date(cert.issued_at).toLocaleDateString('en-IN', { day:'numeric', month:'short', year:'numeric' }) }}</div>
    <div class="cb-score">⭐ {{ cert.score }}/10</div>
  </div>
</template>

<script setup>
defineProps({ cert: Object })
</script>
