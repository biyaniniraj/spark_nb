<template>
  <div class="page-reports">
    <AppNav />
    <div class="page-hero">
      <div class="page-hero-inner">
        <h1>{{ t('reports.title') }}</h1>
        <p>{{ t('reports.sub') }}</p>
      </div>
    </div>

    <div class="page-body">
      <div class="report-card">
        <div class="report-card-header">
          <div>
            <div class="report-card-title">{{ t('reports.usage.title') }}</div>
            <div class="report-card-sub">{{ t('reports.usage.sub') }}</div>
          </div>
          <div class="report-total-badge">
            {{ t('reports.usage.total') }}: <strong>{{ totalMinutes }} min</strong>
          </div>
        </div>

        <div v-if="loading" class="report-loading">{{ t('reports.loading') }}</div>
        <div v-else class="chart-wrap">
          <Bar :data="chartData" :options="chartOptions" />
        </div>

        <div class="report-legend">
          <div v-for="(day, i) in days" :key="i" class="legend-item">
            <div class="legend-date">{{ day.label }}</div>
            <div class="legend-mins">{{ day.minutes }} min</div>
          </div>
        </div>
      </div>

      <div class="report-tip">
        💡 {{ t('reports.tip') }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Bar } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'
import AppNav from '@/components/layout/AppNav.vue'
import { useAuthStore } from '@/stores/auth'
import { useLangStore } from '@/stores/lang'
import { supabase } from '@/lib/supabase'

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend)

const auth = useAuthStore()
const { t } = useLangStore()

const loading = ref(true)
const days = ref([])

function getLast7Days() {
  const result = []
  for (let i = 6; i >= 0; i--) {
    const d = new Date()
    d.setDate(d.getDate() - i)
    result.push({
      date: d.toISOString().slice(0, 10),
      label: i === 0 ? 'Today' : d.toLocaleDateString('en-IN', { weekday: 'short', day: 'numeric' }),
      minutes: 0
    })
  }
  return result
}

onMounted(async () => {
  const last7 = getLast7Days()
  const since = last7[0].date + 'T00:00:00Z'

  if (!auth.user?.id) { days.value = last7; loading.value = false; return }

  const { data } = await supabase
    .from('user_sessions')
    .select('started_at, duration_seconds, last_heartbeat_at, ended_at')
    .eq('user_id', auth.user.id)
    .gte('started_at', since)
    .order('started_at', { ascending: true })

  if (data) {
    for (const session of data) {
      const dayStr = session.started_at.slice(0, 10)
      const dayEntry = last7.find(d => d.date === dayStr)
      if (!dayEntry) continue

      let secs = session.duration_seconds
      if (!secs) {
        // Still active or ended without clean logout — estimate from heartbeat
        const end = session.ended_at || session.last_heartbeat_at || session.started_at
        secs = Math.round((new Date(end) - new Date(session.started_at)) / 1000)
      }
      dayEntry.minutes += Math.round(secs / 60)
    }
  }

  days.value = last7
  loading.value = false
})

const totalMinutes = computed(() => days.value.reduce((s, d) => s + d.minutes, 0))

const chartData = computed(() => ({
  labels: days.value.map(d => d.label),
  datasets: [{
    label: 'Minutes on Spark',
    data: days.value.map(d => d.minutes),
    backgroundColor: days.value.map((_, i) =>
      i === 6 ? 'rgba(20,184,166,0.85)' : 'rgba(20,184,166,0.35)'
    ),
    borderColor: days.value.map((_, i) =>
      i === 6 ? '#14B8A6' : 'rgba(20,184,166,0.6)'
    ),
    borderWidth: 2,
    borderRadius: 6,
    borderSkipped: false,
  }]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: {
      callbacks: {
        label: ctx => ` ${ctx.parsed.y} min`
      }
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      grid: { color: 'rgba(226,232,240,0.5)' },
      ticks: {
        color: '#64748B',
        callback: v => `${v}m`
      }
    },
    x: {
      grid: { display: false },
      ticks: { color: '#64748B', font: { size: 12 } }
    }
  }
}
</script>

<style scoped>
.page-reports { min-height: 100vh; background: var(--off); }

.report-card {
  background: var(--white);
  border: 1px solid var(--lgray);
  border-radius: var(--radius);
  padding: 1.75rem;
  box-shadow: var(--shadow);
  margin-bottom: 1.25rem;
}
.report-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.report-card-title { font-size: 1.1rem; font-weight: 700; color: var(--dktext); }
.report-card-sub { font-size: 0.82rem; color: var(--muted); margin-top: 0.2rem; }
.report-total-badge {
  background: rgba(20,184,166,0.1);
  color: var(--teal);
  border: 1px solid rgba(20,184,166,0.3);
  border-radius: 20px;
  padding: 0.3rem 0.9rem;
  font-size: 0.82rem;
}
.report-total-badge strong { color: var(--teal); }

.report-loading { text-align: center; color: var(--muted); padding: 3rem 0; font-size: 0.9rem; }

.chart-wrap { height: 260px; position: relative; }

.report-legend {
  display: flex;
  justify-content: space-between;
  margin-top: 1.25rem;
  border-top: 1px solid var(--lgray);
  padding-top: 1rem;
  flex-wrap: wrap;
  gap: 0.5rem;
}
.legend-item { text-align: center; flex: 1; min-width: 60px; }
.legend-date { font-size: 0.72rem; color: var(--muted); }
.legend-mins { font-size: 0.85rem; font-weight: 600; color: var(--dktext); margin-top: 0.2rem; }

.report-tip {
  background: var(--amber-light);
  border-left: 3px solid var(--amber);
  padding: 0.85rem 1.1rem;
  border-radius: var(--radius-sm);
  font-size: 0.85rem;
  color: #78350F;
  line-height: 1.5;
}
</style>
