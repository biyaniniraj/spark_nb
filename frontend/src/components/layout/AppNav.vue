<template>
  <nav>
    <div class="nav-logo" @click="router.push('/')">Sp<span>ark</span></div>
    <div class="nav-links">
      <RouterLink v-for="link in links" :key="link.to" :to="link.to" :class="{ active: route.path.startsWith(link.to) }">
        {{ t(link.label) }}
      </RouterLink>
    </div>
    <div class="nav-right">
      <LangToggle />
      <div class="nav-avatar" @click="router.push('/role')">{{ initials }}</div>
    </div>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useLangStore } from '@/stores/lang'
import LangToggle from '@/components/ui/LangToggle.vue'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const lang = useLangStore()
const { t } = lang

const initials = computed(() => auth.user?.name?.split(' ').map(w => w[0]).slice(0,2).join('') || 'A')

const links = computed(() => auth.user?.role === 'Teacher'
  ? [{ to: '/certify', label: 'nav.certify' }, { to: '/certs', label: 'nav.certs' }]
  : [{ to: '/subjects', label: 'nav.subjects' }, { to: '/bookmarks', label: 'nav.bookmarks' }]
)
</script>
