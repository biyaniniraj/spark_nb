<template>
  <div style="display:flex;flex-direction:column;min-height:100vh">
    <AppNav />
    <div class="page-hero"><div class="page-hero-inner">
      <h1>{{ t('bookmarks.title') }}</h1>
      <p>{{ t('bookmarks.sub') }}</p>
    </div></div>
    <div class="page-body">
      <EmptyState v-if="!bm.list.length" icon="🔖" :title="t('bookmarks.empty.title')" :sub="t('bookmarks.empty.sub')">
        <button class="btn btn-primary" style="margin-top:1.5rem" @click="router.push('/subjects')">{{ t('bookmarks.explore') }}</button>
      </EmptyState>
      <div v-else class="topic-list">
        <TopicRow v-for="(item, i) in bm.list" :key="item.topic_id" :topic="item" :index="i"
          @select="router.push(`/topics/${item.topic_id}`)" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import TopicRow from '@/components/topics/TopicRow.vue'
import { useLangStore } from '@/stores/lang'
import { useBookmarksStore } from '@/stores/bookmarks'

const router = useRouter()
const { t } = useLangStore()
const bm = useBookmarksStore()
onMounted(() => bm.fetch())
</script>

<style scoped>
.topic-list { display: flex; flex-direction: column; gap: 0.75rem; }
</style>
