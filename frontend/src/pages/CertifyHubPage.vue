<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <div class="page-hero"><div class="page-hero-inner">
      <h1>Spark Certification Programme</h1>
      <p>Become a Spark Certified Teacher</p>
    </div></div>
    <div class="certify-body">
      <div class="cert-subject-grid">
        <CertSubjectCard
          v-for="s in subjects" :key="s.subject_id"
          :subject="s"
          :certified="certifiedIds.has(s.subject_id)"
          @start="router.push(`/quiz/${s.subject_id}`)"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import CertSubjectCard from '@/components/certs/CertSubjectCard.vue'
import { api } from '@/lib/api'

const router = useRouter()
const subjects = ref([])
const certifiedIds = ref(new Set())

onMounted(async () => {
  subjects.value = await api.get('/subjects')
  const certs = await api.get('/certs')
  certifiedIds.value = new Set(certs.map(c => c.subject_id))
})
</script>

<style scoped>
.certify-body { max-width: 900px; margin: 0 auto; width: 100%; padding: 2rem; }
.cert-subject-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(240px,1fr)); gap: 1rem; }
</style>
