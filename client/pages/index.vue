<template>
  <div class="flex flex-col items-start my-6 gap-x-10 md:flex-row">
    <DepartureButton/>

    <ArrivalButton/>
  </div>

  <div class="mt-6">
    <UserList />
  </div>
</template>
<script setup lang="ts">
import DepartureButton from "~/components/user/departure-button.vue";
import ArrivalButton from "~/components/user/arrival-button.vue";
</script>
