<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <Breadcrumb :crumbs="[
      { label: t('nav.subjects'), to: '/subjects' },
      { label: subject?.name, to: `/subjects/${subject?.subject_id}` },
      { label: topic?.name, to: '' }
    ]" />
    <div class="detail-hero" v-if="topic">
      <div class="detail-hero-inner">
        <div class="detail-eyebrow">{{ subject?.name }} · Class {{ topic.grade }}</div>
        <h1 class="detail-title">{{ lang.current === 'hi' && topic.name_hi ? topic.name_hi : topic.name }}</h1>
        <div class="detail-meta">
          <BadgePill variant="teal">Class {{ topic.grade }}</BadgePill>
          <BadgePill variant="navy">{{ subject?.name }}</BadgePill>
        </div>
        <div class="expert-badge" v-if="expert">
          <div class="expert-avatar">{{ expert.initials }}</div>
          <div class="expert-info">
            <strong>{{ expert.name }}</strong><br>
            <span>{{ expert.role }}</span>
          </div>
        </div>
        <button class="bookmark-btn" @click="toggleBookmark">
          {{ bookmarked ? '🔖 ' + t('detail.bookmarked') : '🔖 ' + t('detail.bookmark') }}
        </button>
      </div>
    </div>
    <div class="detail-body" v-if="content">
      <SimplyPutCard :content="content" />
      <div class="apps-section" v-if="apps.length">
        <div class="section-header">
          <div class="section-icon-wrap" style="background:#D1FAE5">🌍</div>
          <div><div class="section-title">{{ t('detail.apps.title') }}</div></div>
        </div>
        <div class="apps-grid">
          <AppCard v-for="app in apps" :key="app.id" :app="app" />
        </div>
      </div>
      <div class="careers-section" v-if="careers.length">
        <div class="section-header">
          <div class="section-icon-wrap" style="background:#FEF3C7">💼</div>
          <div><div class="section-title">{{ t('detail.careers.title') }}</div></div>
        </div>
        <div class="career-grid">
          <CareerCard v-for="c in careers" :key="c.career_id" :career="c" @select="router.push(`/careers/${c.career_id}`)" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import Breadcrumb from '@/components/layout/Breadcrumb.vue'
import BadgePill from '@/components/ui/BadgePill.vue'
import SimplyPutCard from '@/components/detail/SimplyPutCard.vue'
import AppCard from '@/components/detail/AppCard.vue'
import CareerCard from '@/components/detail/CareerCard.vue'
import { useLangStore } from '@/stores/lang'
import { useBookmarksStore } from '@/stores/bookmarks'
import { api } from '@/lib/api'

const router = useRouter()
const route = useRoute()
const lang = useLangStore()
const { t } = lang
const bm = useBookmarksStore()

const topic = ref(null)
const subject = ref(null)
const expert = ref(null)
const apps = ref([])
const careers = ref([])
const allContent = ref([])

const content = computed(() => {
  const row = allContent.value.find(c => c.lang === lang.current) || allContent.value[0]
  return row
})

const bookmarked = computed(() => bm.has(route.params.topicId))

onMounted(async () => {
  const id = route.params.topicId
  topic.value = await api.get(`/topics/${id}`)
  subject.value = await api.get(`/subjects/${topic.value.subject_id}`)
  allContent.value = await api.get(`/topics/${id}/content`)
  apps.value = await api.get(`/topics/${id}/apps`)
  careers.value = await api.get(`/careers/by-topic/${id}`)
  expert.value = await api.get(`/topics/${id}/expert`).catch(() => null)
})

async function toggleBookmark() {
  await bm.toggle(route.params.topicId)
}
</script>

<style scoped>
.detail-hero { background: var(--navy); padding: 2.5rem 2rem 2rem; }
.detail-hero-inner { max-width: 960px; margin: 0 auto; }
.detail-eyebrow { font-size: 0.75rem; color: var(--teal2); font-weight: 600; letter-spacing: 0.1em; text-transform: uppercase; margin-bottom: 0.6rem; }
.detail-title { font-family: var(--font-display); color: var(--white); font-size: 2rem; margin-bottom: 0.8rem; }
.detail-meta { display: flex; gap: 0.6rem; flex-wrap: wrap; margin-bottom: 1rem; }
.expert-badge { display: flex; align-items: center; gap: 0.6rem; background: rgba(245,158,11,0.12); border: 1px solid rgba(245,158,11,0.3); border-radius: var(--radius-sm); padding: 0.5rem 0.9rem; max-width: fit-content; margin-bottom: 1rem; }
.expert-avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--amber); color: var(--navy); font-size: 0.7rem; font-weight: 700; display: flex; align-items: center; justify-content: center; }
.expert-info { font-size: 0.78rem; line-height: 1.4; color: var(--muted); }
.expert-info strong { color: var(--amber); }
.bookmark-btn { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; border-radius: var(--radius-sm); border: 1.5px solid rgba(255,255,255,0.2); background: transparent; color: var(--muted); font-size: 0.82rem; font-weight: 500; cursor: pointer; transition: all var(--transition); }
.bookmark-btn:hover { background: rgba(245,158,11,0.15); border-color: var(--amber); color: var(--amber); }
.detail-body { max-width: 960px; margin: 0 auto; width: 100%; padding: 2rem; display: flex; flex-direction: column; gap: 1.5rem; }
.apps-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(210px,1fr)); gap: 1px; background: var(--lgray); }
.career-grid { display: grid; grid-template-columns: repeat(auto-fill,minmax(200px,1fr)); gap: 1rem; padding: 1.2rem 1.5rem; }
.section-header { padding: 1.2rem 1.5rem; border-bottom: 1px solid var(--lgray); display: flex; align-items: center; gap: 0.75rem; }
.section-icon-wrap { width: 38px; height: 38px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; }
.section-title { font-size: 1rem; font-weight: 600; color: var(--dktext); }
.apps-section, .careers-section { background: var(--white); border-radius: var(--radius); border: 1px solid var(--lgray); overflow: hidden; }
</style>
