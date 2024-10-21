<script setup lang="ts">
import Navbar from "~/components/navbar.vue";
</script>

<template>
  <Navbar/>

  <UContainer :ui="{padding: 'lg:px-0'}">
    <slot/>
  </UContainer>
</template>
