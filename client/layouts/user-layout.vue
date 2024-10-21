<script setup lang="ts">

import {onMounted} from "vue";

const store = useUserStore();
const route = useRoute()

const user = useState<User | null>('user', () => null)
const isLoading = useState<boolean>('isLoading', () => true)
const error = useState<string | null>('error', () => null)

onMounted(() => {
  setTimeout(async () => {
    try {
      user.value = await store.getUser(route.params.userId);
      isLoading.value = false;
    } catch (err) {
      console.error("Erreur lors du chargement des utilisateurs:", err);
      error.value = "Impossible de charger les utilisateurs. Veuillez réessayer.";
    } finally {
      isLoading.value = false;
    }
  }, 0.1)
});

const links = [
  [{
    label: 'Overview',
    icon: 'i-heroicons-user',
    to: `/overview/${route.params.userId}`
  }, {
    label: 'Working Times',
    icon: 'i-heroicons-calendar',
    to: `/overview/${route.params.userId}/working-times`
  }]
]
</script>

<template>
  <main class="flex flex-col h-full">
    <UContainer :ui="{padding: 'lg:px-0'}" class="w-full flex justify-end items-center py-5 pt-8">
      <USkeleton v-if="isLoading" class="h-4 w-[250px] rounded-sm" />
      <h3 v-else class="text-sm font-light">You are watching user: <span class="font-medium" v-if="!isLoading && user">{{ user.username }}</span></h3>
    </UContainer>
    <UContainer class="w-full flex justify-between" :ui="{padding: 'lg:px-0'}">
      <UVerticalNavigation class="w-1/6" :links="links"/>

      <div class="w-4/5">
        <USkeleton v-if="isLoading" class="w-full h-64 rounded-sm" />

        <slot v-else/>
      </div>
    </UContainer>
  </main>
</template>
