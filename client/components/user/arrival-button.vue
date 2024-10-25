<script setup lang="ts">
const props = defineProps<{
  user: User
}>()

const clockStore = useClockStore();

const toast = useToast()

const addArrivalTime = async () => {
  if(props.user) {
    const allClocks = await clockStore.getClockByUserId(props.user.id)

    if(!allClocks && clockStore.clocks.length === 0) {
      await clockStore.createClock(props.user.id)

      toast.add({ title: 'Success', description: 'Arrival time added' })
    }else if(allClocks.clocks[0].status) {
      await clockStore.createClock(props.user.id)
      toast.add({ title: 'Success', description: 'Arrival time added' })
    }else {
      toast.add({ title: 'Error', description: 'You have already set an arrival time' })
    }
  }
}
</script>

<template>
  <div @click="addArrivalTime" class="w-full md:w-1/5 h-full flex flex-col rounded-xl p-5 py-6 border border-primary/30 gap-y-4 duration-300 hover:scale-[102%] hover:cursor-pointer hover:border-primary/100">
    <UIcon name="i-heroicons-clock-20-solid" class="w-8 h-8"/>
    <div class="space-y-1">
      <h6 class="font-semibold">Arrival time</h6>
      <p class="text-xs opacity-60">Add your arrival time</p>
    </div>
  </div>
</template>
