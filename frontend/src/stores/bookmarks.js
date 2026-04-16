import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { api } from '@/lib/api'

export const useBookmarksStore = defineStore('bookmarks', () => {
  const list = ref([])
  const ids = computed(() => new Set(list.value.map(b => b.topic_id)))

  async function fetch() {
    const data = await api.get('/bookmarks')
    list.value = data.map(b => ({ ...b.topics, bookmark_id: b.bookmark_id }))
  }

  async function toggle(topicId) {
    if (ids.value.has(topicId)) {
      await api.delete(`/bookmarks/${topicId}`)
      list.value = list.value.filter(b => b.topic_id !== topicId)
    } else {
      await api.post('/bookmarks', { topic_id: topicId })
      await fetch()
    }
  }

  function has(topicId) {
    return ids.value.has(topicId)
  }

  return { list, fetch, toggle, has }
})
