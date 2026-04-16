import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)

  async function init() {
    const { data } = await supabase.auth.getUser()
    if (data.user) user.value = { ...data.user, role: data.user.user_metadata?.role }
  }

  async function signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    user.value = { ...data.user, role: data.user.user_metadata?.role }
  }

  async function signUp(email, password, name) {
    const { data, error } = await supabase.auth.signUp({ email, password, options: { data: { name } } })
    if (error) throw error
    user.value = data.user
  }

  async function signInWithProvider(provider) {
    await supabase.auth.signInWithOAuth({ provider })
  }

  async function signOut() {
    await supabase.auth.signOut()
    user.value = null
  }

  function setRole(role) {
    if (user.value) user.value.role = role
  }

  return { user, init, signIn, signUp, signInWithProvider, signOut, setRole }
})
