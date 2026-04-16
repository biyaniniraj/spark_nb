<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="auth-logo">Sp<span>ark</span></div>
      <div class="auth-tagline">{{ t('auth.tagline') }}</div>
      <div class="auth-tabs">
        <div class="auth-tab" :class="{ active: tab === 'login' }" @click="tab = 'login'">{{ t('auth.signin') }}</div>
        <div class="auth-tab" :class="{ active: tab === 'register' }" @click="tab = 'register'">{{ t('auth.register') }}</div>
      </div>

      <!-- Login -->
      <div v-if="tab === 'login'">
        <div class="social-btns">
          <button class="social-btn" @click="socialLogin('google')">
            <div class="social-icon" style="background:#EA4335;color:white">G</div>{{ t('auth.google') }}
          </button>
          <button class="social-btn" @click="socialLogin('facebook')">
            <div class="social-icon" style="background:#1877F2;color:white">f</div>{{ t('auth.facebook') }}
          </button>
        </div>
        <div class="divider">{{ t('auth.divider') }}</div>
        <div class="form-group"><label class="form-label">{{ t('auth.email') }}</label><input class="form-input" type="email" v-model="email"></div>
        <div class="form-group"><label class="form-label">{{ t('auth.password') }}</label><input class="form-input" type="password" v-model="password"></div>
        <button class="btn btn-primary" style="width:100%;justify-content:center" @click="login">{{ t('auth.signin') }}</button>
      </div>

      <!-- Register -->
      <div v-else>
        <div class="form-group"><label class="form-label">{{ t('auth.fullname') }}</label><input class="form-input" v-model="name"></div>
        <div class="form-group"><label class="form-label">{{ t('auth.email') }}</label><input class="form-input" type="email" v-model="email"></div>
        <div class="form-group"><label class="form-label">{{ t('auth.password') }}</label><input class="form-input" type="password" v-model="password"></div>
        <button class="btn btn-primary" style="width:100%;justify-content:center" @click="register">{{ t('auth.create') }}</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useLangStore } from '@/stores/lang'

const router = useRouter()
const auth = useAuthStore()
const { t } = useLangStore()

const tab = ref('login')
const email = ref('')
const password = ref('')
const name = ref('')

async function login() {
  await auth.signIn(email.value, password.value)
  router.push('/role')
}
async function register() {
  await auth.signUp(email.value, password.value, name.value)
  router.push('/role')
}
async function socialLogin(provider) {
  await auth.signInWithProvider(provider)
  router.push('/role')
}
</script>

<style scoped>
.auth-page { background: var(--off); display: flex; align-items: center; justify-content: center; min-height: 100vh; padding: 2rem; }
.auth-tabs { display: flex; border-bottom: 2px solid var(--lgray); margin-bottom: 1.5rem; }
.auth-tab  { flex: 1; padding: 0.6rem; text-align: center; font-size: 0.875rem; font-weight: 500; color: var(--muted); cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all var(--transition); }
.auth-tab.active { color: var(--teal); border-bottom-color: var(--teal); }
.social-btns { display: flex; flex-direction: column; gap: 0.7rem; margin-bottom: 1.2rem; }
.social-btn  { display: flex; align-items: center; gap: 0.75rem; padding: 0.7rem 1rem; border: 1.5px solid var(--lgray); border-radius: var(--radius-sm); font-size: 0.875rem; font-weight: 500; cursor: pointer; background: var(--white); color: var(--dktext); transition: all var(--transition); }
.social-btn:hover { border-color: var(--teal); background: var(--teal-light); }
.social-icon { width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: 700; flex-shrink: 0; }
.divider { display: flex; align-items: center; gap: 0.8rem; margin: 1rem 0; color: var(--muted); font-size: 0.78rem; }
.divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--lgray); }
</style>
