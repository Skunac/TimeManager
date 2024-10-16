<script setup lang="ts">

const clockStore = useClockStore();

const toast = useToast()

const addDepartureTime = async () => {
  const allClocks = await clockStore.getClockByUserId(2)

  if(allClocks.clocks[0].status) {
    await clockStore.createClock(2)
    toast.add({ title: 'Success', description: 'Departure time added' })
  }else {
    toast.add({ title: 'Error', description: 'You have already set a departure time' })
  }
}
</script>

<template>
  <ULandingCard
      class="max-w-xs duration-300 hover:scale-[102%] hover:cursor-pointer"
      @click="addDepartureTime"
      :ui="{description: 'text-xs'}"
      title="Departure time"
      description="Add your departure time"
      icon="i-heroicons-arrow-left-end-on-rectangle-20-solid"
      color="primary"
  />
</template>
