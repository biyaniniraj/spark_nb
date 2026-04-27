import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)

  function _applySession(session) {
    if (session?.user) {
      user.value = { ...session.user, role: session.user.user_metadata?.role, name: session.user.user_metadata?.name }
    } else {
      user.value = null
    }
  }

  async function init() {
    const { data } = await supabase.auth.getSession()
    _applySession(data.session)
    supabase.auth.onAuthStateChange((_event, session) => {
      _applySession(session)
    })
  }

  async function signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    user.value = { ...data.user, role: data.user.user_metadata?.role, name: data.user.user_metadata?.name }
  }

  async function signUp(email, password, name) {
    const { data, error } = await supabase.auth.signUp({ email, password, options: { data: { name } } })
    if (error) throw error
    user.value = { ...data.user, name }
  }

  async function signInWithProvider(provider) {
    await supabase.auth.signInWithOAuth({ provider })
  }

  async function signOut() {
    const { endSession, stopHeartbeat } = await import('@/composables/useSession').then(m => m.useSession())
    stopHeartbeat()
    await endSession()
    await supabase.auth.signOut()
    user.value = null
  }

  function setRole(role) {
    if (user.value) user.value.role = role
  }

  return { user, init, signIn, signUp, signInWithProvider, signOut, setRole }
})
