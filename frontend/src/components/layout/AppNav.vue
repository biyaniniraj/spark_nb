<template>
  <nav>
    <div class="nav-logo" @click="goHome">Sp<span>ark</span></div>
    <div class="nav-links">
      <RouterLink v-for="link in links" :key="link.to" :to="link.to" :class="{ active: route.path.startsWith(link.to) }">
        {{ t(link.label) }}
      </RouterLink>
    </div>
    <div class="nav-right">
      <LangToggle />
      <div class="nav-avatar-wrap" ref="wrapRef">
        <div class="nav-avatar" @click="open = !open">{{ initials }}</div>
        <div v-if="open" class="nav-dropdown" @click.stop>
          <div class="nav-dropdown-header">
            <div class="nav-dropdown-name">{{ auth.user?.name || auth.user?.email }}</div>
            <div class="nav-dropdown-role">{{ auth.user?.role }}</div>
          </div>
          <div class="nav-dropdown-divider"></div>
          <button class="nav-dropdown-item" @click="goProfile">{{ t('nav.profile') }}</button>
          <button class="nav-dropdown-item nav-dropdown-logout" @click="logout">{{ t('nav.logout') }}</button>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useLangStore } from '@/stores/lang'
import LangToggle from '@/components/ui/LangToggle.vue'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const lang = useLangStore()
const { t } = lang

const open = ref(false)
const wrapRef = ref(null)

const initials = computed(() => auth.user?.name?.split(' ').map(w => w[0]).slice(0,2).join('') || 'A')

const links = computed(() => auth.user?.role === 'Teacher'
  ? [{ to: '/certify', label: 'nav.certify' }, { to: '/certs', label: 'nav.certs' }, { to: '/reports', label: 'nav.reports' }]
  : [{ to: '/subjects', label: 'nav.subjects' }, { to: '/bookmarks', label: 'nav.bookmarks' }, { to: '/reports', label: 'nav.reports' }]
)

function goHome() {
  if (auth.user?.role === 'Teacher') router.push('/certify')
  else router.push('/subjects')
}

function goProfile() {
  open.value = false
  router.push('/profile')
}

async function logout() {
  open.value = false
  await auth.signOut()
  router.push('/')
}

function onOutsideClick(e) {
  if (wrapRef.value && !wrapRef.value.contains(e.target)) open.value = false
}

onMounted(() => document.addEventListener('click', onOutsideClick))
onUnmounted(() => document.removeEventListener('click', onOutsideClick))
</script>

<style scoped>
.nav-avatar-wrap { position: relative; }
.nav-dropdown {
  position: absolute;
  top: calc(100% + 0.5rem);
  right: 0;
  min-width: 200px;
  background: var(--white);
  border: 1px solid var(--lgray);
  border-radius: 10px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.35);
  z-index: 999;
  overflow: hidden;
}
.nav-dropdown-header { padding: 0.85rem 1rem 0.75rem; }
.nav-dropdown-name { font-weight: 600; font-size: 0.9rem; color: var(--dktext); }
.nav-dropdown-role { font-size: 0.75rem; color: var(--gray); margin-top: 0.2rem; }
.nav-dropdown-divider { height: 1px; background: var(--lgray); }
.nav-dropdown-item {
  display: block;
  width: 100%;
  padding: 0.7rem 1rem;
  background: none;
  border: none;
  text-align: left;
  font-size: 0.875rem;
  color: var(--dktext);
  cursor: pointer;
  transition: background 0.15s;
}
.nav-dropdown-item:hover { background: var(--off); }
.nav-dropdown-logout { color: #f87171; }
</style>
