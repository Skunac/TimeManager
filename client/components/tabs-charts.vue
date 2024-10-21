<script setup lang="ts">

const items = [{
  key: 'working-time',
  label: 'Working Time',
}]
</script>

<template>
  <UTabs :items="items" class="w-full">
    <template #item="{ item }">
      <UCard v-if="item.key === 'working-time'">
        <WorkingTimeChart/>
      </UCard>
      <UCard v-else>
        <ChartTest2/>
      </UCard>
    </template>
  </UTabs>
</template>
