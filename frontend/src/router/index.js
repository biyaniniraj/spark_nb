import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  { path: '/',                   name: 'landing',       component: () => import('@/pages/LandingPage.vue') },
  { path: '/auth',               name: 'auth',          component: () => import('@/pages/AuthPage.vue') },
  { path: '/role',               name: 'role',          component: () => import('@/pages/RolePage.vue'),          meta: { requiresAuth: true } },
  { path: '/subjects',           name: 'subjects',      component: () => import('@/pages/SubjectsPage.vue'),      meta: { requiresAuth: true } },
  { path: '/subjects/:subjectId',name: 'topics',        component: () => import('@/pages/TopicsPage.vue'),        meta: { requiresAuth: true } },
  { path: '/topics/:topicId',    name: 'topic-detail',  component: () => import('@/pages/TopicDetailPage.vue'),   meta: { requiresAuth: true } },
  { path: '/careers/:careerId',  name: 'career-detail', component: () => import('@/pages/CareerDetailPage.vue'),  meta: { requiresAuth: true } },
  { path: '/bookmarks',          name: 'bookmarks',     component: () => import('@/pages/BookmarksPage.vue'),     meta: { requiresAuth: true } },
  { path: '/teacher',            name: 'teacher',       component: () => import('@/pages/TeacherHomePage.vue'),   meta: { requiresAuth: true, role: 'Teacher' } },
  { path: '/certify',            name: 'certify',       component: () => import('@/pages/CertifyHubPage.vue'),    meta: { requiresAuth: true, role: 'Teacher' } },
  { path: '/certs',              name: 'my-certs',      component: () => import('@/pages/MyCertsPage.vue'),       meta: { requiresAuth: true, role: 'Teacher' } },
  { path: '/quiz/:subjectId',    name: 'quiz',          component: () => import('@/pages/QuizPage.vue'),          meta: { requiresAuth: true, role: 'Teacher' } },
  { path: '/profile',            name: 'profile',       component: () => import('@/pages/MyProfilePage.vue'),     meta: { requiresAuth: true } },
  { path: '/reports',            name: 'reports',       component: () => import('@/pages/ReportsPage.vue'),       meta: { requiresAuth: true } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.user) return { name: 'auth' }
  if (to.meta.role && auth.user?.role !== to.meta.role) return { name: 'subjects' }
})

export default router
