<template>
  <span class="skill-pill">{{ skill }}</span>
</template>

<script setup>
defineProps({ skill: String })
</script>

<style scoped>
.skill-pill { padding: 0.35rem 0.85rem; border-radius: 20px; font-size: 0.8rem; font-weight: 500; background: var(--teal-light); color: #0369A1; }
</style>
