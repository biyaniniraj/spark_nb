<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <div class="career-detail-hero" v-if="career">
      <div class="career-detail-inner">
        <div class="career-big-icon" :style="{ background: career.bg_color + '33' }">{{ career.icon }}</div>
        <h1 class="career-detail-title">{{ lang.current === 'hi' && career.name_hi ? career.name_hi : career.name }}</h1>
        <div class="career-detail-sub">{{ lang.current === 'hi' && career.task_hi ? career.task_hi : career.task }}</div>
      </div>
    </div>
    <div class="career-detail-body" v-if="career">
      <div class="cd-desc-card">
        <div class="cd-desc-label">{{ t('career.desc.label') }}</div>
        <div class="cd-desc-text" v-html="lang.current === 'hi' && career.description_hi ? career.description_hi : career.description"></div>
      </div>
      <ExpertVideoCard v-if="video" :video="video" @play="openVideo" />
      <div class="cd-skills" v-if="skills.length">
        <div class="skills-label">{{ t('career.skills') }}</div>
        <div class="skills-list">
          <SkillPill v-for="s in skills" :key="s.id" :skill="s.skill" />
        </div>
      </div>
      <button class="btn btn-ghost" @click="router.back()">{{ t('career.back') }}</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import ExpertVideoCard from '@/components/career/ExpertVideoCard.vue'
import SkillPill from '@/components/career/SkillPill.vue'
import { useLangStore } from '@/stores/lang'
import { api } from '@/lib/api'

const router = useRouter()
const route = useRoute()
const lang = useLangStore()
const { t } = lang

const career = ref(null)
const skills = ref([])
const video = ref(null)

onMounted(async () => {
  const id = route.params.careerId
  career.value = await api.get(`/careers/${id}`)
  skills.value = await api.get(`/careers/${id}/skills`)
  video.value = await api.get(`/careers/${id}/video`).catch(() => null)
})

function openVideo() {
  if (video.value?.video_url) window.open(video.value.video_url, '_blank')
}
</script>

<style scoped>
.career-detail-hero { background: var(--navy); padding: 2.5rem 2rem 2rem; }
.career-detail-inner { max-width: 960px; margin: 0 auto; }
.career-big-icon { width: 64px; height: 64px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 2rem; margin-bottom: 1rem; }
.career-detail-title { font-family: var(--font-display); color: var(--white); font-size: 1.8rem; margin-bottom: 0.4rem; }
.career-detail-sub { color: var(--muted); font-size: 0.9rem; }
.career-detail-body { max-width: 960px; margin: 0 auto; width: 100%; padding: 2rem; display: flex; flex-direction: column; gap: 1.2rem; }
.cd-desc-card { background: var(--white); border-radius: var(--radius); border: 1px solid var(--lgray); padding: 1.8rem; }
.cd-desc-label { font-size: 0.7rem; font-weight: 700; letter-spacing: 0.12em; text-transform: uppercase; color: var(--teal); margin-bottom: 0.8rem; }
.cd-desc-text { font-size: 1rem; line-height: 1.85; color: var(--gray); }
.cd-skills { background: var(--white); border-radius: var(--radius); border: 1px solid var(--lgray); padding: 1.5rem; }
.skills-label { font-size: 0.7rem; font-weight: 700; letter-spacing: 0.12em; text-transform: uppercase; color: var(--gray); margin-bottom: 0.9rem; }
.skills-list { display: flex; flex-wrap: wrap; gap: 0.5rem; }
</style>
