import { defineStore } from 'pinia'
import { ref } from 'vue'
import en from '@/i18n/en'
import hi from '@/i18n/hi'

const translations = { en, hi }

export const useLangStore = defineStore('lang', () => {
  const current = ref(localStorage.getItem('spark_lang') || 'en')

  function toggle() {
    current.value = current.value === 'en' ? 'hi' : 'en'
    localStorage.setItem('spark_lang', current.value)
  }

  function t(key) {
    return translations[current.value]?.[key] ?? translations.en[key] ?? key
  }

  return { current, toggle, t }
})
