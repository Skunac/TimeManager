<script setup lang="ts">
import ArrivalButton from "~/components/user/arrival-button.vue";
import DepartureButton from "~/components/user/departure-button.vue";

const userStore = useUserStore();

const currentUser = computed(() => userStore.currentUser)

const { isDesktop } = useDevice()
</script>

<template>
  <div class="w-full flex flex-col items-start gap-y-4 my-6 gap-x-10 md:flex-row">
    <ArrivalButton :user="currentUser"/>
    <DepartureButton :user="currentUser"/>
  </div>

  <div v-if="isDesktop" class="mt-6">
    <UserList />
  </div>
</template>
