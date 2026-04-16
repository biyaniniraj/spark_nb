<template>
  <div class="toast" :class="{ show: visible }">{{ message }}</div>
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)
const message = ref('')

function show(msg, duration = 2500) {
  message.value = msg
  visible.value = true
  setTimeout(() => visible.value = false, duration)
}

defineExpose({ show })
</script>
