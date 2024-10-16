<script setup lang="ts">
const people = [{
  id: 'bar',
  label: 'Bar',
}, {
  id: 'column',
  label: 'Column',
}, {
  id: 'area',
  label: 'Area',
}]

const selected = useState<string>('selected', () => people[0])
</script>

<template>
  <section class="mt-5">
    <div class="w-1/5">
      <USelectMenu v-model="selected" :options="people" />
    </div>
  </section>
</template>
