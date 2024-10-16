<script setup lang="ts">
const clockStore = useClockStore();
const workingTimeStore = useWorkingTimesStore();

const toast = useToast()

const addArrivalTime = async () => {
  const allClocks = await clockStore.getClockByUserId(2)

  if(!allClocks.clocks[0].status) {
    await clockStore.createClock(2)

    const workingTimeData = {
      start: allClocks.clocks[1].time,
      end: allClocks.clocks[0].time,
    }

    await workingTimeStore.createWorkingTime(2, workingTimeData)
    toast.add({ title: 'Success', description: 'Arrival time added' })
  }else {
    toast.add({ title: 'Error', description: 'You don\'t have a departure time yet' })
  }
}
</script>

<template>
  <ULandingCard
      class="max-w-xs duration-300 hover:scale-[102%] hover:cursor-pointer"
      @click="addArrivalTime"
      :ui="{description: 'text-xs'}"
      title="Arrival time"
      description="Add your arrival time"
      icon="i-heroicons-clock-20-solid"
      color="primary"
  />
</template>
