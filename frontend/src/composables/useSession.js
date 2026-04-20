import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

const sessionId = ref(null)
const startedAt = ref(null)
let heartbeatTimer = null

export function useSession() {
  async function startSession(userId) {
    if (!userId) return
    const { data } = await supabase
      .from('user_sessions')
      .insert({ user_id: userId })
      .select('id')
      .single()
    if (data) {
      sessionId.value = data.id
      startedAt.value = Date.now()
    }
  }

  async function heartbeat() {
    if (!sessionId.value) return
    await supabase
      .from('user_sessions')
      .update({ last_heartbeat_at: new Date().toISOString() })
      .eq('id', sessionId.value)
  }

  async function endSession() {
    if (!sessionId.value || !startedAt.value) return
    const duration = Math.round((Date.now() - startedAt.value) / 1000)
    await supabase
      .from('user_sessions')
      .update({ ended_at: new Date().toISOString(), duration_seconds: duration })
      .eq('id', sessionId.value)
    sessionId.value = null
    startedAt.value = null
  }

  function startHeartbeat() {
    if (heartbeatTimer) return
    heartbeatTimer = setInterval(heartbeat, 60_000)
  }

  function stopHeartbeat() {
    if (heartbeatTimer) clearInterval(heartbeatTimer)
    heartbeatTimer = null
  }

  return { startSession, endSession, startHeartbeat, stopHeartbeat }
}
