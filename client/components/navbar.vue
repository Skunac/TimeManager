<script setup lang="ts">
const links = [
  {
    label: 'Home',
    icon: 'i-heroicons-home',
    to: '/'
  },
  {
    label: 'Chart manager',
    icon: 'i-heroicons-chart-pie',
    to: '/chart-manager'
  }
]
</script>

<template>
  <nav>
    <UContainer :ui="{ base: 'flex justify-between', padding: 'lg:px-0' }">
      <div class="flex items-center">
        <UserButton/>

        <UDivider orientation="vertical" class="mx-3"/>

        <UHorizontalNavigation :ui="{ icon: {inactive: 'group-hover:text-sky-500/80' }}" :links="links">
          <template #default="{ link }">
            <span class="text-xs group-hover:text-primary relative" @click="navigateTo(`${link.name}/2`)">{{ link.label }}</span>
          </template>
        </UHorizontalNavigation>
      </div>
    </UContainer>
  </nav>
</template>
