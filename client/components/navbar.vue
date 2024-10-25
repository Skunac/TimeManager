<script setup lang="ts">
import NaivgationMenu from "~/components/naivgation-menu.vue";

const { isDesktop, isMobile } = useDevice();

const links = [
  {
    label: 'Home',
    icon: 'i-heroicons-home',
    to: '/'
  },
  {
    label: 'Chart manager',
    icon: 'i-heroicons-chart-pie',
    to: '/chart-manager'
  }
]
</script>

<template>
  <nav>
    <div v-if="isMobile" class="mx-4 mt-14">
      <NaivgationMenu/>
    </div>

    <UContainer v-if="isDesktop" :ui="{ base: 'flex justify-between', padding: 'lg:px-0' }">
      <div class="flex items-center">
        <UserButton/>

        <UDivider orientation="vertical" class="mx-3"/>

        <UHorizontalNavigation :ui="{ icon: {inactive: 'group-hover:text-sky-500/80' }}" :links="links">
          <template #default="{ link }">
            <span class="text-xs group-hover:text-primary relative" @click="navigateTo(`${link.name}`)">{{ link.label }}</span>
          </template>
        </UHorizontalNavigation>
      </div>
    </UContainer>
  </nav>
</template>
