<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <Breadcrumb :crumbs="[{ label: t('nav.subjects'), to: '/subjects' }, { label: subject?.name, to: '' }]" />
    <div class="topics-toolbar">
      <div class="search-wrap" style="flex:1;min-width:200px;max-width:360px">
        <span class="search-icon">🔍</span>
        <input class="form-input" type="text" :placeholder="t('topics.search')" v-model="search">
      </div>
      <div class="grade-filter">
        <button class="grade-btn" :class="{ active: grade === 'all' }" @click="grade='all'">{{ t('topics.allgrades') }}</button>
        <button class="grade-btn" :class="{ active: grade === '9' }" @click="grade='9'">{{ t('topics.class9') }}</button>
        <button class="grade-btn" :class="{ active: grade === '10' }" @click="grade='10'">{{ t('topics.class10') }}</button>
      </div>
      <select class="sort-select" v-model="sortOrder">
        <option value="default">{{ t('topics.sort.default') }}</option>
        <option value="az">{{ t('topics.sort.az') }}</option>
        <option value="za">{{ t('topics.sort.za') }}</option>
      </select>
    </div>
    <div class="topic-list">
      <TopicRow
        v-for="(topic, i) in filtered"
        :key="topic.topic_id"
        :topic="topic"
        :index="i"
        @select="router.push(`/topics/${topic.topic_id}`)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import Breadcrumb from '@/components/layout/Breadcrumb.vue'
import TopicRow from '@/components/topics/TopicRow.vue'
import { useLangStore } from '@/stores/lang'
import { api } from '@/lib/api'

const router = useRouter()
const route = useRoute()
const { t } = useLangStore()

const subject = ref(null)
const topics = ref([])
const search = ref('')
const grade = ref('all')
const sortOrder = ref('default')

onMounted(async () => {
  const id = route.params.subjectId
  subject.value = await api.get(`/subjects/${id}`)
  topics.value = await api.get(`/topics?subject_id=${id}`)
})

const filtered = computed(() => {
  let list = topics.value
    .filter(t => grade.value === 'all' || t.grade === grade.value)
    .filter(t => t.name.toLowerCase().includes(search.value.toLowerCase()))
  if (sortOrder.value === 'az') list = [...list].sort((a, b) => a.name.localeCompare(b.name))
  if (sortOrder.value === 'za') list = [...list].sort((a, b) => b.name.localeCompare(a.name))
  return list
})
</script>

<style scoped>
.topics-toolbar { background: var(--white); border-bottom: 1px solid var(--lgray); padding: 1rem 2rem; display: flex; gap: 1rem; align-items: center; flex-wrap: wrap; }
.grade-filter { display: flex; gap: 0.4rem; }
.grade-btn { padding: 0.45rem 1rem; border-radius: 20px; border: 1.5px solid var(--lgray); font-size: 0.8rem; font-weight: 500; cursor: pointer; background: var(--white); color: var(--gray); transition: all var(--transition); }
.grade-btn.active { background: var(--navy); color: var(--white); border-color: var(--navy); }
</style>
