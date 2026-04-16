<template>
  <div class="empty-state">
    <div class="empty-icon">{{ icon }}</div>
    <div class="empty-title">{{ title }}</div>
    <p v-if="sub">{{ sub }}</p>
    <slot />
  </div>
</template>

<script setup>
defineProps({ icon: String, title: String, sub: String })
</script>
