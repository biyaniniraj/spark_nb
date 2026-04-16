import { useAuthStore } from '@/stores/auth'

const BASE = '/api'

async function request(method, path, body) {
  const auth = useAuthStore()
  const headers = { 'Content-Type': 'application/json' }
  if (auth.user?.id) headers['x-user-id'] = auth.user.id

  const res = await fetch(`${BASE}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  })
  if (!res.ok) throw new Error(`${method} ${path} → ${res.status}`)
  return res.json()
}

export const api = {
  get:    (path)        => request('GET',    path),
  post:   (path, body)  => request('POST',   path, body),
  delete: (path)        => request('DELETE', path),
}
