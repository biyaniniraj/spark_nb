<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <div class="page-hero"><div class="page-hero-inner">
      <h1>{{ t('subjects.title') }}</h1>
      <p>{{ t('subjects.sub') }}</p>
    </div></div>
    <div class="page-body">
      <div class="subject-grid">
        <SubjectCard v-for="s in subjects" :key="s.subject_id" :subject="s" @select="go" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import SubjectCard from '@/components/subjects/SubjectCard.vue'
import { useLangStore } from '@/stores/lang'
import { api } from '@/lib/api'

const router = useRouter()
const { t } = useLangStore()
const subjects = ref([])

onMounted(async () => { subjects.value = await api.get('/subjects') })

function go(id) { router.push(`/subjects/${id}`) }
</script>

<style scoped>
.subject-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(175px,1fr)); gap: 1rem; }
</style>
