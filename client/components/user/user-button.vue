<script setup lang="ts">
const items = [
  [{
    label: 'reverssecole@gmail.com',
    slot: 'account',
    role: "Manager",
    disabled: true
  }],
  [{
    label: 'My account',
    icon: 'i-heroicons-adjustments-horizontal-16-solid',
    to: '/account'
  }, {
    label: 'Manage charts',
    icon: 'i-heroicons-chart-bar',
    to: '/chart-manager'
  }], [{
    label: 'Sign out',
    icon: 'i-heroicons-arrow-left-on-rectangle'
  }]
]
</script>

<template>
<UDropdown :items="items" :ui="{ item: { disabled: 'cursor-text select-text' } }" :popper="{ placement: 'bottom-start' }">
  <UButton class="hover:bg-gray-100" variant="ghost" color="gray" label="REVERSS" @click="isOpen = true" size="xs">
    <template #leading>
      <UAvatar
          class="mr-1"
          src="https://avatars.githubusercontent.com/u/739984?v=4"
      />
    </template>
  </UButton>

  <template #account="{ item }">
    <div class="text-left">
      <p>
        Signed in as
      </p>
      <p class="truncate font-medium text-gray-900 dark:text-white">
        {{ item.label }}
      </p>
      <p class="text-xs text-primary truncate font-semibold mt-1.5">
        {{ item.role }}
      </p>
    </div>
  </template>

  <template #item="{ item }">
    <span class="truncate text-xs">{{ item.label }}</span>

    <UIcon :name="item.icon" class="flex-shrink-0 h-4 w-4 text-gray-400 dark:text-gray-500 ms-auto" />
  </template>
</UDropdown>
</template>
