<script setup lang="ts">
const isOpen = ref(false)

const links = [
  {
    name: '/chart-manager',
    label: 'Manage charts',
    icon: 'i-heroicons-chart-bar',
  }
]
</script>

<template>
  <nav>
    <UContainer :ui="{ base: 'flex border-b border-gray-200', padding: 'py-1 lg:px-0' }">
      <UButton class="hover:bg-gray-100" variant="ghost" color="gray" label="REVERSS" @click="isOpen = true" size="xs">
        <template #leading>
          <UAvatar
              class="mr-1"
              src="https://avatars.githubusercontent.com/u/739984?v=4"
          />
        </template>
      </UButton>

      <UDivider orientation="vertical" class="mx-3"/>

      <UHorizontalNavigation :ui="{ container: 'gap-x-5', label: 'text-xs', icon: {inactive: 'group-hover:text-sky-500/80'}}" :links="links">
        <template #default="{ link }">
          <span class="group-hover:text-sky-500/80 relative" @click="navigateTo(`${link.name}/2`)">{{ link.label }}</span>
        </template>
      </UHorizontalNavigation>
    </UContainer>
  </nav>

  <UserModal :is-open="isOpen"/>
</template>
