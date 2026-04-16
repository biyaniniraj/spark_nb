<template>
  <span class="badge" :class="`badge-${variant}`"><slot /></span>
</template>

<script setup>
defineProps({ variant: { type: String, default: 'teal' } })
</script>
