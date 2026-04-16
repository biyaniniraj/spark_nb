<template>
  <div class="role-page">
    <div class="role-wrap">
      <div class="role-eyebrow">{{ t('role.welcome') }}</div>
      <h2 class="role-title">{{ t('role.title') }}</h2>
      <p class="role-sub">{{ t('role.sub') }}</p>
      <div class="role-cards">
        <div class="role-card" @click="pick('Student')">
          <div class="role-icon">🎒</div>
          <div class="role-name">{{ t('role.student') }}</div>
          <div class="role-desc">{{ t('role.student.desc') }}</div>
        </div>
        <div class="role-card" @click="pick('Teacher')">
          <div class="role-icon">👩‍🏫</div>
          <div class="role-name">{{ t('role.teacher') }}</div>
          <div class="role-desc">{{ t('role.teacher.desc') }}</div>
        </div>
        <div class="role-card coming-soon">
          <div class="coming-label">{{ t('role.soon') }}</div>
          <div class="role-icon">👨‍👩‍👧</div>
          <div class="role-name">{{ t('role.parent') }}</div>
          <div class="role-desc">{{ t('role.parent.desc') }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useLangStore } from '@/stores/lang'

const router = useRouter()
const auth = useAuthStore()
const { t } = useLangStore()

function pick(role) {
  auth.setRole(role)
  router.push(role === 'Teacher' ? '/teacher' : '/subjects')
}
</script>

<style scoped>
.role-page { background: var(--navy); display: flex; align-items: center; justify-content: center; min-height: 100vh; padding: 2rem; }
.role-wrap { max-width: 700px; width: 100%; text-align: center; }
.role-eyebrow { font-size: 0.8rem; color: var(--teal2); letter-spacing: 0.12em; text-transform: uppercase; margin-bottom: 0.8rem; }
.role-title { font-family: var(--font-display); color: var(--white); font-size: 2.2rem; margin-bottom: 0.6rem; }
.role-sub { color: var(--muted); font-size: 0.95rem; margin-bottom: 3rem; }
.role-cards { display: grid; grid-template-columns: repeat(3,1fr); gap: 1.2rem; }
.role-card { background: rgba(255,255,255,0.05); border: 1.5px solid rgba(255,255,255,0.1); border-radius: var(--radius); padding: 2rem 1.2rem; cursor: pointer; transition: all var(--transition); position: relative; }
.role-card:hover { background: rgba(14,165,160,0.12); border-color: var(--teal); transform: translateY(-4px); }
.role-card.coming-soon { cursor: default; opacity: 0.5; }
.role-card.coming-soon:hover { transform: none; background: rgba(255,255,255,0.05); }
.coming-label { position: absolute; top: 0.7rem; right: 0.7rem; background: var(--amber); color: var(--navy); font-size: 0.65rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 20px; }
.role-icon { font-size: 2.5rem; margin-bottom: 1rem; }
.role-name { font-size: 1.1rem; font-weight: 600; color: var(--white); margin-bottom: 0.4rem; }
.role-desc { font-size: 0.8rem; color: var(--muted); line-height: 1.5; }
</style>
