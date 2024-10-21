<script setup lang="ts">
import { useChartStore } from "~/stores/chartStore";

const chartStore = useChartStore();

const chartTypes = [
  { id: 'bar', label: 'Bar' },
  { id: 'column', label: 'Column' },
  { id: 'area', label: 'Area' },
  { id: 'line', label: 'Line' },
  { id: 'spline', label: 'Spline' },
  { id: 'areaspline', label: 'Area Spline' },
  { id: 'scatter', label: 'Scatter' },
  { id: 'pie', label: 'Pie' }
];

const selected = computed({
  get: () => chartStore.getChartType,
  set: (value: string) => chartStore.setChartType(value as ChartType)
});
</script>

<template>
  <UContainer>
    <h1 class="text-2xl font-bold mb-4">Select Chart Type</h1>
    <section class="mt-5">
      <div class="w-1/5">
        <USelectMenu v-model="selected" :options="chartTypes" />
      </div>
    </section>
  </UContainer>
</template>