<template>
  <button
    class="quiz-opt"
    :class="{ correct: state === 'correct', wrong: state === 'wrong' }"
    :disabled="!!state"
    @click="$emit('pick', index)"
  >
    <div class="opt-circle">{{ ['A','B','C','D'][index] }}</div>
    {{ text }}
  </button>
</template>

<script setup>
defineProps({ text: String, index: Number, state: String }) // state: null | 'correct' | 'wrong'
defineEmits(['pick'])
</script>
