<template>
  <div style="display:flex;flex-direction:column;min-height:100vh;background:var(--navy)">
    <AppNav />
    <div class="quiz-wrap">
      <!-- Result screen -->
      <QuizResult v-if="result" :result="result" @done="router.push('/teacher')" @retry="restart" />

      <!-- Quiz screen -->
      <template v-else-if="questions.length">
        <div class="quiz-header">
          <div class="quiz-subj-tag">{{ subject?.name }}</div>
          <div class="quiz-title">Spark Certification Quiz</div>
          <div class="quiz-prog-row">
            <div class="quiz-prog-bar"><div class="quiz-prog-fill" :style="{ width: ((current+1)/questions.length*100)+'%' }"></div></div>
            <div class="quiz-count">{{ current+1 }} / {{ questions.length }}</div>
          </div>
        </div>
        <div class="quiz-card">
          <div class="quiz-q">{{ questions[current].question_text }}</div>
          <div class="quiz-opts">
            <QuizOption
              v-for="(opt, i) in currentOptions"
              :key="opt.option_id"
              :text="opt.option_text"
              :index="i"
              :state="optionState(i)"
              @pick="pick(i)"
            />
          </div>
          <div class="quiz-fb" v-if="answered">{{ questions[current].feedback_text }}</div>
        </div>
        <div class="quiz-nav">
          <button class="btn btn-primary btn-sm" v-if="answered" @click="next">
            {{ current < questions.length - 1 ? 'Next →' : 'Submit' }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import QuizOption from '@/components/quiz/QuizOption.vue'
import QuizResult from '@/components/quiz/QuizResult.vue'
import { api } from '@/lib/api'

const router = useRouter()
const route = useRoute()

const subject = ref(null)
const questions = ref([])
const options = ref({})   // question_id → [options]
const answers = ref([])   // selected option index per question
const current = ref(0)
const answered = ref(false)
const result = ref(null)

const currentOptions = computed(() => options.value[questions.value[current.value]?.question_id] || [])

function optionState(i) {
  if (!answered.value) return null
  const q = questions.value[current.value]
  if (i === q.correct_option_index) return 'correct'
  if (i === answers.value[current.value]) return 'wrong'
  return null
}

function pick(i) {
  if (answered.value) return
  answers.value[current.value] = i
  answered.value = true
}

async function next() {
  if (current.value < questions.value.length - 1) {
    current.value++
    answered.value = false
  } else {
    result.value = await api.post(`/quiz/${route.params.subjectId}/submit`, { subject_id: route.params.subjectId, answers: answers.value })
  }
}

function restart() {
  current.value = 0
  answers.value = []
  answered.value = false
  result.value = null
}

onMounted(async () => {
  const id = route.params.subjectId
  subject.value = await api.get(`/subjects/${id}`)
  questions.value = await api.get(`/quiz/${id}/questions`)
  for (const q of questions.value) {
    options.value[q.question_id] = await api.get(`/quiz/options/${q.question_id}`)
  }
  answers.value = new Array(questions.value.length).fill(null)
})
</script>

<style scoped>
.quiz-wrap { max-width: 660px; margin: 0 auto; width: 100%; padding: 2rem; }
.quiz-header { text-align: center; margin-bottom: 2rem; }
.quiz-subj-tag { font-size: 0.68rem; font-weight: 700; letter-spacing: 0.12em; text-transform: uppercase; color: var(--teal2); margin-bottom: 0.5rem; }
.quiz-title { font-family: var(--font-display); font-size: 1.5rem; color: var(--white); margin-bottom: 1rem; }
.quiz-prog-row { display: flex; align-items: center; gap: 1rem; }
.quiz-prog-bar { flex: 1; height: 5px; background: rgba(255,255,255,0.12); border-radius: 3px; overflow: hidden; }
.quiz-prog-fill { height: 100%; background: var(--teal); border-radius: 3px; transition: width 0.4s ease; }
.quiz-count { font-size: 0.75rem; color: var(--muted); white-space: nowrap; }
.quiz-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: var(--radius); padding: 1.6rem 1.5rem 1.2rem; margin: 1.2rem 0; }
.quiz-q { font-size: 1rem; font-weight: 600; color: var(--white); line-height: 1.6; margin-bottom: 1.3rem; }
.quiz-opts { display: flex; flex-direction: column; gap: 0.65rem; }
.quiz-fb { font-size: 0.8rem; color: #94A3B8; line-height: 1.6; margin-top: 0.75rem; padding: 0.75rem 1rem; background: rgba(255,255,255,0.04); border-radius: var(--radius-sm); border-left: 3px solid var(--teal); }
.quiz-nav { display: flex; justify-content: flex-end; margin-top: 0.75rem; }
</style>
