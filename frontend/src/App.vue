<template>
  <RouterView />
  <Toast />
</template>

<script setup>
import { watch, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useSession } from '@/composables/useSession'
import Toast from '@/components/layout/Toast.vue'

const auth = useAuthStore()
const { startSession, endSession, startHeartbeat, stopHeartbeat } = useSession()

watch(() => auth.user, async (user, prev) => {
  if (user && !prev) {
    await startSession(user.id)
    startHeartbeat()
  } else if (!user && prev) {
    stopHeartbeat()
  }
}, { immediate: false })

async function onBeforeUnload() {
  stopHeartbeat()
  await endSession()
}

onMounted(() => window.addEventListener('beforeunload', onBeforeUnload))
onUnmounted(() => window.removeEventListener('beforeunload', onBeforeUnload))
</script>
