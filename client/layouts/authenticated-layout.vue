<script setup lang="ts">
const links = [
  [{
    label: 'Overview',
    icon: 'i-heroicons-user',
  }, {
    label: 'Working Times',
    icon: 'i-heroicons-calendar',
  }, {
    label: 'Clock',
    icon: 'i-heroicons-clock',
  }]
]
</script>

<template>
  <main class="flex flex-col h-full">
    <UContainer class="w-full flex justify-between mt-6" :ui="{padding: 'lg:px-0'}">
      <div class="w-full mx-12">
        <slot/>
      </div>
    </UContainer>
  </main>
</template>
