<script setup lang="ts">
const items = [{
  key: 'working-time',
  label: 'Account',
  description: 'Make changes to your account here. Click save when you\'re done.'
}, {
  key: 'working-times',
  label: 'Password',
  description: 'Change your password here. After saving, you\'ll be logged out.'
}]
</script>

<template>
  <UTabs :items="items" class="w-full">
    <template #item="{ item }">
      <UCard @submit.prevent="() => onSubmit(item.key === 'account' ? accountForm : passwordForm)">
        <div v-if="item.key === 'working-time'" class="space-y-3">
          <ChartTest/>
        </div>

        <div v-else-if="item.key === 'working-times'" class="space-y-3">
          <ChartTest2/>
        </div>
      </UCard>
    </template>
  </UTabs>
</template>
