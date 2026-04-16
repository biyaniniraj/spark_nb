<template>
  <div style="display:flex;flex-direction:column;min-height:100vh;background:var(--navy)">
    <AppNav />
    <div class="teacher-hero">
      <div class="teacher-hero-inner">
        <div class="teacher-tag">Teacher Dashboard</div>
        <div class="teacher-name-h">Welcome, {{ auth.user?.name }}</div>
        <div class="tstat-row">
          <div class="tstat"><div class="tstat-num">{{ certCount }}</div><div class="tstat-lbl">Spark certifications</div></div>
        </div>
      </div>
    </div>
    <div class="teacher-quick">
      <div class="tq-card" @click="router.push('/certify')">
        <div class="tqc-icon">🎓</div>
        <div class="tqc-title">Get Certified</div>
        <div class="tqc-desc">Explore content and take the certification test</div>
      </div>
      <div class="tq-card" @click="router.push('/certs')">
        <div class="tqc-icon">📜</div>
        <div class="tqc-title">My Certificates</div>
        <div class="tqc-desc">View and share your earned Spark certifications</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import { useAuthStore } from '@/stores/auth'
import { api } from '@/lib/api'

const router = useRouter()
const auth = useAuthStore()
const certCount = ref(0)
onMounted(async () => {
  const certs = await api.get('/certs')
  certCount.value = certs.length
})
</script>

<style scoped>
.teacher-hero { background: linear-gradient(135deg,#0F2044 0%,#1a3a5c 100%); padding: 3rem 2rem 2.5rem; }
.teacher-hero-inner { max-width: 900px; margin: 0 auto; }
.teacher-tag { font-size: 0.7rem; font-weight: 700; letter-spacing: 0.15em; text-transform: uppercase; color: var(--teal2); margin-bottom: 0.8rem; }
.teacher-name-h { font-family: var(--font-display); font-size: 1.9rem; color: var(--white); margin-bottom: 1.5rem; }
.tstat-row { display: flex; gap: 1rem; flex-wrap: wrap; }
.tstat { background: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; padding: 0.65rem 1.1rem; text-align: center; }
.tstat-num { font-size: 1.3rem; font-weight: 800; color: var(--teal2); }
.tstat-lbl { font-size: 0.65rem; color: var(--muted); margin-top: 1px; }
.teacher-quick { max-width: 900px; margin: 2rem auto; width: 100%; padding: 0 2rem; display: grid; grid-template-columns: repeat(auto-fill,minmax(195px,1fr)); gap: 1rem; }
.tq-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: var(--radius); padding: 1.3rem; cursor: pointer; transition: all var(--transition); }
.tq-card:hover { background: rgba(14,165,160,0.1); border-color: var(--teal); }
.tqc-icon { font-size: 1.6rem; margin-bottom: 0.6rem; }
.tqc-title { font-size: 0.88rem; font-weight: 700; color: var(--white); margin-bottom: 0.3rem; }
.tqc-desc { font-size: 0.73rem; color: var(--muted); line-height: 1.5; }
</style>
