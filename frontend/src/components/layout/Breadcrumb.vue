<template>
  <div class="breadcrumb">
    <template v-for="(crumb, i) in crumbs" :key="i">
      <span v-if="i < crumbs.length - 1" @click="router.push(crumb.to)">{{ crumb.label }}</span>
      <span v-else class="current">{{ crumb.label }}</span>
      <span v-if="i < crumbs.length - 1" class="sep">›</span>
    </template>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
const router = useRouter()
defineProps({ crumbs: Array })
</script>
