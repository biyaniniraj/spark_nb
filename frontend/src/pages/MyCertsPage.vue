<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <div class="page-hero"><div class="page-hero-inner">
      <h1>My Certificates</h1>
      <p>Your earned Spark certifications</p>
    </div></div>
    <div class="mycerts-body">
      <EmptyState v-if="!certs.length" icon="🏅" title="No certificates yet" sub="Complete a subject quiz to earn your first certificate" />
      <div v-else class="cert-badge-grid">
        <CertBadge v-for="c in certs" :key="c.cert_id" :cert="c" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppNav from '@/components/layout/AppNav.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import CertBadge from '@/components/certs/CertBadge.vue'
import { api } from '@/lib/api'

const certs = ref([])
onMounted(async () => { certs.value = await api.get('/certs') })
</script>

<style scoped>
.mycerts-body { max-width: 900px; margin: 0 auto; width: 100%; padding: 2rem; }
.cert-badge-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(190px,1fr)); gap: 1.2rem; }
</style>
