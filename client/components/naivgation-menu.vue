<script setup lang="ts">
const isOpen = ref(false)
</script>

<template>
  <div>
    <UButton @click="isOpen = true" variant="ghost">
      <UIcon name="i-heroicons:queue-list" class="w-7 h-7" />
    </UButton>

    <USlideover v-model="isOpen" side="left" prevent-close>
      <UCard class="flex flex-col flex-1" :ui="{ body: { base: 'flex-1' }, ring: '', divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
        <template #header>
          <div class="flex items-center justify-between pt-14">
            <h3 class="text-base font-semibold leading-6 text-gray-900 dark:text-white">
              Slideover
            </h3>
            <UButton color="gray" variant="ghost" icon="i-heroicons-x-mark-20-solid" class="-my-1" @click="isOpen = false" />
          </div>
        </template>

        <template #default>
          <UButton variant="outline" label="Sign in" @click="navigateTo('/sign-in')"/>
        </template>
      </UCard>
    </USlideover>
  </div>
</template>

