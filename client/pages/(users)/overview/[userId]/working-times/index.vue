<script setup lang="ts">
import WorkingTimeChart from "~/components/working-times/working-time-chart.vue";

const layout = "user-layout";

import {onUpdated} from "vue";

const store = useUserStore();
const route = useRoute()

const user = ref<User | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);

onUpdated(() => {
  setTimeout(async () => {
    try {
      user.value = await store.getUser(route.params.id);
      loading.value = false;
    } catch (err) {
      console.error("Erreur lors du chargement des utilisateurs:", err);
      error.value = "Impossible de charger les utilisateurs. Veuillez réessayer.";
    } finally {
      loading.value = false;
    }
  }, 0.1)
});
</script>

<template>
  <NuxtLayout :name="layout">
    <UContainer>
      <WorkingTimeChart/>
    </UContainer>
  </NuxtLayout>
</template>
