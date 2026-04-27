<template>
  <div class="upgrade-page">
    <AppNav />
    <div class="upgrade-hero">
      <Breadcrumb :crumbs="[{ label: t('nav.subjects'), to: '/subjects' }, { label: t('nav.upgrade') }]" />
      <h1>{{ t('upgrade.title') }}</h1>
      <p class="upgrade-sub">{{ t('upgrade.sub') }}</p>
    </div>

    <div class="upgrade-body">
      <div v-if="pageLoading" class="loading-text">{{ t('upgrade.loading') }}</div>

      <!-- ── PAID_FULL: no next plan, only cancel ── -->
      <template v-else-if="currentPlan === 'PAID_FULL'">
        <div class="status-card">
          <div class="status-icon">🚀</div>
          <div>
            <div class="status-title">{{ t('upgrade.status.full') }}</div>
            <div class="status-desc">{{ t('upgrade.status.full_desc') }}</div>
          </div>
        </div>
        <div class="cancel-section">
          <span class="cancel-label">{{ t('upgrade.cancel.label') }}</span>
          <button class="btn-cancel" :disabled="saving" @click="cancelPlan">
            {{ saving ? t('upgrade.saving') : t('upgrade.cancel.cta') }}
          </button>
        </div>
        <div v-if="errorMsg" class="upgrade-error">{{ errorMsg }}</div>
      </template>

      <!-- ── PAID_LIMITED: upgrade to full or cancel ── -->
      <template v-else-if="currentPlan === 'PAID_LIMITED'">
        <div class="status-card">
          <div class="status-icon">⭐</div>
          <div>
            <div class="status-title">{{ t('upgrade.status.limited') }}</div>
            <div class="status-desc">{{ t('upgrade.status.limited_desc') }}</div>
          </div>
        </div>

        <h3 class="next-plan-heading">{{ t('upgrade.next_plan') }}</h3>
        <div class="plan-grid plan-grid--single">
          <div class="plan-card selected">
            <div class="plan-icon">🚀</div>
            <h2>{{ t('upgrade.plan.full.name') }}</h2>
            <p class="plan-desc">{{ t('upgrade.plan.full.desc') }}</p>
            <ul class="plan-perks">
              <li>✓ {{ t('upgrade.plan.full.perk1') }}</li>
              <li>✓ {{ t('upgrade.plan.full.perk2') }}</li>
            </ul>
          </div>
        </div>

        <div class="upgrade-cta">
          <button class="btn-confirm" :disabled="saving" @click="upgradeTo('PAID_FULL')">
            {{ saving ? t('upgrade.saving') : t('upgrade.confirm_full') }}
          </button>
        </div>

        <div class="cancel-section">
          <span class="cancel-label">{{ t('upgrade.cancel.label') }}</span>
          <button class="btn-cancel" :disabled="saving" @click="cancelPlan">
            {{ t('upgrade.cancel.cta') }}
          </button>
        </div>
        <div v-if="errorMsg" class="upgrade-error">{{ errorMsg }}</div>
      </template>

      <!-- ── FREE / no plan: choose from all 3 plans ── -->
      <template v-else>
        <div class="plan-grid">
          <div
            v-for="plan in plans"
            :key="plan.code"
            class="plan-card"
            :class="{ selected: selectedPlan === plan.code }"
            @click="selectPlan(plan.code)"
          >
            <div class="plan-icon">{{ plan.icon }}</div>
            <h2>{{ t(plan.nameKey) }}</h2>
            <p class="plan-desc">{{ t(plan.descKey) }}</p>
            <ul class="plan-perks">
              <li v-for="perk in plan.perks" :key="perk">✓ {{ t(perk) }}</li>
            </ul>
          </div>
        </div>

        <!-- Subject selection for PAID_LIMITED -->
        <div v-if="selectedPlan === 'PAID_LIMITED'" class="subject-select-section">
          <h3>{{ t('upgrade.choose_subjects') }}</h3>
          <p class="subject-select-hint">{{ t('upgrade.choose_subjects_hint') }}</p>
          <div v-if="loadingSubjects" class="loading-text">{{ t('upgrade.loading') }}</div>
          <div v-else class="subject-grid">
            <label v-for="sub in allSubjects" :key="sub.subject_id" class="subject-checkbox">
              <input type="checkbox" :value="sub.subject_id" v-model="chosenSubjectIds" />
              <span>{{ lang.current === 'hi' ? sub.name_hi || sub.name : sub.name }}</span>
            </label>
          </div>
        </div>

        <div class="upgrade-cta">
          <button
            class="btn-confirm"
            :disabled="saving || (selectedPlan === 'PAID_LIMITED' && chosenSubjectIds.length === 0)"
            @click="confirmUpgrade"
          >
            {{ saving ? t('upgrade.saving') : t('upgrade.confirm') }}
          </button>
          <div v-if="errorMsg" class="upgrade-error">{{ errorMsg }}</div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/lib/api'
import { useLangStore } from '@/stores/lang'
import AppNav from '@/components/layout/AppNav.vue'
import Breadcrumb from '@/components/layout/Breadcrumb.vue'

const router = useRouter()
const lang = useLangStore()
const { t } = lang

const plans = [
  {
    code: 'FREE_LIMITED',
    icon: '📖',
    nameKey: 'upgrade.plan.free.name',
    descKey: 'upgrade.plan.free.desc',
    perks: ['upgrade.plan.free.perk1', 'upgrade.plan.free.perk2'],
  },
  {
    code: 'PAID_LIMITED',
    icon: '⭐',
    nameKey: 'upgrade.plan.limited.name',
    descKey: 'upgrade.plan.limited.desc',
    perks: ['upgrade.plan.limited.perk1', 'upgrade.plan.limited.perk2'],
  },
  {
    code: 'PAID_FULL',
    icon: '🚀',
    nameKey: 'upgrade.plan.full.name',
    descKey: 'upgrade.plan.full.desc',
    perks: ['upgrade.plan.full.perk1', 'upgrade.plan.full.perk2'],
  },
]

const currentPlan = ref(null)
const selectedPlan = ref('FREE_LIMITED')
const chosenSubjectIds = ref([])
const allSubjects = ref([])
const loadingSubjects = ref(false)
const pageLoading = ref(true)
const saving = ref(false)
const errorMsg = ref('')

async function selectPlan(code) {
  selectedPlan.value = code
  if (code === 'PAID_LIMITED' && allSubjects.value.length === 0) {
    loadingSubjects.value = true
    try {
      allSubjects.value = await api.get('/subjects')
    } catch {
      errorMsg.value = t('upgrade.error_load')
    } finally {
      loadingSubjects.value = false
    }
  }
}

async function confirmUpgrade() {
  saving.value = true
  errorMsg.value = ''
  try {
    await api.post('/users/me/plan', {
      plan_code: selectedPlan.value,
      subject_ids: selectedPlan.value === 'PAID_LIMITED' ? chosenSubjectIds.value : [],
    })
    router.push('/subjects')
  } catch {
    errorMsg.value = t('upgrade.error_save')
    saving.value = false
  }
}

async function upgradeTo(code) {
  saving.value = true
  errorMsg.value = ''
  try {
    await api.post('/users/me/plan', { plan_code: code, subject_ids: [] })
    router.push('/subjects')
  } catch {
    errorMsg.value = t('upgrade.error_save')
    saving.value = false
  }
}

async function cancelPlan() {
  saving.value = true
  errorMsg.value = ''
  try {
    await api.post('/users/me/plan', { plan_code: 'FREE_LIMITED', subject_ids: [] })
    router.push('/subjects')
  } catch {
    errorMsg.value = t('upgrade.error_save')
    saving.value = false
  }
}

onMounted(async () => {
  try {
    const current = await api.get('/users/me/plan')
    currentPlan.value = current.plan_code || null
    chosenSubjectIds.value = current.selected_subject_ids || []
    if (!currentPlan.value || currentPlan.value === 'FREE_LIMITED') {
      selectedPlan.value = 'FREE_LIMITED'
    }
    if (currentPlan.value === 'FREE_LIMITED' || !currentPlan.value) {
      // Pre-load subjects if previously had PAID_LIMITED selections
      if (chosenSubjectIds.value.length > 0) {
        allSubjects.value = await api.get('/subjects')
        selectedPlan.value = 'PAID_LIMITED'
      }
    }
  } catch {
    // Ignore
  } finally {
    pageLoading.value = false
  }
})
</script>

<style scoped>
.upgrade-page { min-height: 100vh; background: var(--off); }

.upgrade-hero {
  background: var(--navy);
  color: var(--white);
  padding: 2.5rem 5vw 2rem;
}
.upgrade-hero h1 { font-family: 'Playfair Display', serif; font-size: 2rem; margin: 0.5rem 0; }
.upgrade-sub { color: rgba(255,255,255,0.7); font-size: 1rem; margin: 0; }

.upgrade-body { padding: 2.5rem 5vw; max-width: 1000px; }

/* ── Plan grid — always 3 columns ── */
.plan-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.25rem;
  margin-bottom: 2rem;
}
.plan-grid--single {
  grid-template-columns: minmax(0, 360px);
  margin-bottom: 1.5rem;
}

@media (max-width: 640px) {
  .plan-grid { grid-template-columns: 1fr; }
}

.plan-card {
  background: var(--white);
  border: 2px solid var(--lgray);
  border-radius: 14px;
  padding: 1.5rem;
  cursor: pointer;
  transition: border-color 0.15s, box-shadow 0.15s;
}
.plan-card:hover { border-color: var(--teal); }
.plan-card.selected {
  border-color: var(--teal);
  box-shadow: 0 0 0 4px rgba(14,165,160,0.12);
}
.plan-grid--single .plan-card { cursor: default; }

.plan-icon { font-size: 2rem; margin-bottom: 0.5rem; }
.plan-card h2 { font-size: 1.1rem; margin: 0 0 0.4rem; color: var(--navy); }
.plan-desc { font-size: 0.875rem; color: var(--gray); margin: 0 0 1rem; line-height: 1.5; }
.plan-perks { list-style: none; padding: 0; margin: 0; font-size: 0.85rem; color: var(--dktext); }
.plan-perks li { margin-bottom: 0.35rem; }

/* ── Already on paid plan ── */
.status-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: var(--white);
  border: 1px solid var(--lgray);
  border-radius: 14px;
  padding: 1.25rem 1.5rem;
  margin-bottom: 1.75rem;
}
.status-icon { font-size: 2rem; flex-shrink: 0; }
.status-title { font-weight: 700; color: var(--navy); font-size: 1rem; margin-bottom: 0.25rem; }
.status-desc { font-size: 0.875rem; color: var(--gray); }

.next-plan-heading { color: var(--navy); margin: 0 0 1rem; font-size: 1rem; font-weight: 600; }

.cancel-section {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--lgray);
}
.cancel-label { font-size: 0.875rem; color: var(--gray); }
.btn-cancel {
  background: none;
  border: 1px solid #f87171;
  color: #f87171;
  padding: 0.5rem 1.25rem;
  border-radius: 8px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: background 0.12s;
}
.btn-cancel:hover:not(:disabled) { background: rgba(248,113,113,0.08); }
.btn-cancel:disabled { opacity: 0.5; cursor: not-allowed; }

/* ── Subject selection ── */
.subject-select-section { background: var(--white); border-radius: 14px; padding: 1.5rem; margin-bottom: 1.75rem; }
.subject-select-section h3 { margin: 0 0 0.25rem; color: var(--navy); }
.subject-select-hint { color: var(--gray); font-size: 0.875rem; margin: 0 0 1rem; }
.loading-text { color: var(--gray); font-size: 0.9rem; }

.subject-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 0.6rem; }
.subject-checkbox {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  cursor: pointer;
  padding: 0.45rem 0.65rem;
  border-radius: 8px;
  border: 1px solid var(--lgray);
  background: var(--off);
  transition: background 0.12s;
}
.subject-checkbox input[type="checkbox"] { accent-color: var(--teal); width: 16px; height: 16px; flex-shrink: 0; }
.subject-checkbox:hover { background: rgba(14,165,160,0.07); }

/* ── CTA ── */
.upgrade-cta { display: flex; flex-direction: column; align-items: flex-start; gap: 0.75rem; margin-bottom: 1rem; }
.btn-confirm {
  background: var(--teal);
  color: var(--white);
  border: none;
  padding: 0.8rem 2.25rem;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.15s;
}
.btn-confirm:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-confirm:not(:disabled):hover { opacity: 0.88; }
.upgrade-error { color: #f87171; font-size: 0.875rem; }
</style>
