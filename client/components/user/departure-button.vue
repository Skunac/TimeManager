<script setup lang="ts">

const clockStore = useClockStore();

const toast = useToast()

const addDepartureTime = async () => {
  const allClocks = await clockStore.getClockByUserId(2)

  if(!allClocks.clocks[0].status) {
    await clockStore.createClock(2)
    toast.add({ title: 'Success', description: 'Departure time added' })
  }else {
    toast.add({ title: 'Error', description: 'You don\'t have an arrival time yet' })
  }
}
</script>

<template>
  <div @click="addDepartureTime" class="w-1/5 h-full flex flex-col rounded-xl p-5 py-6 border border-primary/30 gap-y-4 duration-300 hover:scale-[102%] hover:cursor-pointer hover:border-primary/100">
    <UIcon name="i-heroicons-arrow-left-end-on-rectangle-20-solid" class="w-8 h-8"/>
    <div class="space-y-1">
      <h6 class="font-semibold">Departure time</h6>
      <p class="text-xs opacity-60">Add your departure time</p>
    </div>
  </div>
</template>
