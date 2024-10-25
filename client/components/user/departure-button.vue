<script setup lang="ts">
const props = defineProps<{
  user: User
}>()

const userStore = useUserStore();
const clockStore = useClockStore();
const workingTimeStore = useWorkingTimesStore();

const toast = useToast()

const addDepartureTime = async () => {
  if(props.user) {
    const allClocks = await clockStore.getClockByUserId(props.user.id)

    if(!allClocks.clocks[0].status) {
      await clockStore.createClock(props.user.id)

      const workingTimeData = {
        start: allClocks.clocks[1].time,
        end: allClocks.clocks[0].time,
      }

      await workingTimeStore.createWorkingTime(props.user.id, workingTimeData)

      toast.add({ title: 'Success', description: 'Departure time added and working time set' })
    }else {
      toast.add({ title: 'Error', description: 'You don\'t have an arrival time yet' })
    }
  }
}
</script>

<template>
  <div @click="addDepartureTime" class="w-full md:w-1/5 h-full flex flex-col rounded-xl p-5 py-6 border border-primary/30 gap-y-4 duration-300 hover:scale-[102%] hover:cursor-pointer hover:border-primary/100">
    <UIcon name="i-heroicons-arrow-left-end-on-rectangle-20-solid" class="w-8 h-8"/>
    <div class="space-y-1">
      <h6 class="font-semibold">Departure time</h6>
      <p class="text-xs opacity-60">Add your departure time</p>
    </div>
  </div>
</template>
