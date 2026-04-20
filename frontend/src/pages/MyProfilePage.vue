<template>
  <div class="page-profile">
    <AppNav />
    <div class="profile-wrap">
      <h1 class="profile-title">{{ t('profile.title') }}</h1>

      <div class="profile-card">
        <div class="profile-avatar">{{ initials }}</div>
        <div class="profile-info">
          <div class="profile-row">
            <span class="profile-label">{{ t('profile.name') }}</span>
            <span class="profile-value">{{ auth.user?.name || '—' }}</span>
          </div>
          <div class="profile-row">
            <span class="profile-label">{{ t('profile.email') }}</span>
            <span class="profile-value">{{ auth.user?.email }}</span>
          </div>
          <div class="profile-row">
            <span class="profile-label">{{ t('profile.role') }}</span>
            <span class="profile-value">{{ auth.user?.role }}</span>
          </div>
          <div class="profile-row">
            <span class="profile-label">{{ t('profile.plan') }}</span>
            <span class="profile-value">
              <span v-if="planLoading">{{ t('profile.plan.loading') }}</span>
              <span v-else-if="planName" class="plan-badge">{{ planName }}</span>
              <span v-else class="plan-badge plan-badge--none">{{ t('profile.plan.none') }}</span>
            </span>
          </div>
        </div>
      </div>

      <div v-if="showUpgrade" class="upgrade-card">
        <div class="upgrade-icon">⚡</div>
        <div class="upgrade-text">
          <div class="upgrade-title">{{ t('profile.upgrade.title') }}</div>
          <div class="upgrade-sub">{{ t('profile.upgrade.sub') }}</div>
        </div>
        <button class="btn btn-amber" @click="contactUpgrade">{{ t('profile.upgrade.cta') }}</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useLangStore } from '@/stores/lang'
import { supabase } from '@/lib/supabase'
import AppNav from '@/components/layout/AppNav.vue'

const auth = useAuthStore()
const { t } = useLangStore()

const planLoading = ref(true)
const planName = ref('')
const isPremium = ref(false)

const initials = computed(() => auth.user?.name?.split(' ').map(w => w[0]).slice(0,2).join('') || 'A')
const showUpgrade = computed(() => !planLoading.value && !isPremium.value)

onMounted(async () => {
  if (!auth.user?.id) return
  const { data } = await supabase
    .from('user_plan')
    .select('enrollment_plans(name, plan_type)')
    .eq('user_id', auth.user.id)
    .maybeSingle()

  if (data?.enrollment_plans) {
    planName.value = data.enrollment_plans.name
    isPremium.value = data.enrollment_plans.plan_type === 'FULL_ACCESS'
  }
  planLoading.value = false
})

function contactUpgrade() {
  window.open('mailto:hello@sparkapp.in?subject=Upgrade Plan', '_blank')
}
</script>

<style scoped>
.page-profile { min-height: 100vh; background: var(--off); }
.profile-wrap { max-width: 560px; margin: 0 auto; padding: 2rem 1.5rem 4rem; }
.profile-title { font-family: var(--font-display); font-size: 1.8rem; color: var(--navy); margin-bottom: 2rem; }

.profile-card { background: var(--white); border: 1px solid var(--lgray); border-radius: 14px; padding: 2rem; display: flex; gap: 1.5rem; align-items: flex-start; margin-bottom: 1.5rem; box-shadow: var(--shadow); }
.profile-avatar { width: 56px; height: 56px; border-radius: 50%; background: var(--teal2); color: var(--navy); font-weight: 700; font-size: 1.2rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.profile-info { flex: 1; display: flex; flex-direction: column; gap: 1rem; }
.profile-row { display: flex; justify-content: space-between; align-items: center; gap: 1rem; }
.profile-label { font-size: 0.8rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.05em; }
.profile-value { font-size: 0.95rem; color: var(--dktext); text-align: right; }

.plan-badge { background: rgba(94,234,212,0.12); color: var(--teal2); padding: 0.2rem 0.7rem; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
.plan-badge--none { background: rgba(255,255,255,0.06); color: var(--muted); }

.upgrade-card { background: linear-gradient(135deg, rgba(245,158,11,0.12), rgba(94,234,212,0.08)); border: 1px solid rgba(245,158,11,0.25); border-radius: 14px; padding: 1.5rem; display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; }
.upgrade-icon { font-size: 1.8rem; }
.upgrade-text { flex: 1; min-width: 180px; }
.upgrade-title { font-weight: 700; color: var(--navy); margin-bottom: 0.3rem; }
.upgrade-sub { font-size: 0.85rem; color: var(--gray); line-height: 1.5; }
</style>
