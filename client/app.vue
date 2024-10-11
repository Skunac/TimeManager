<template>
  <NuxtLayout>
    <template v-if="pathIncludesUser">
      <h1 v-if="currentUser">{{ currentUser.email }}</h1>
      <h1 v-else>Utilisateur non trouvé</h1>

      <UContainer class="mt-5">
        <TabsCharts />
        <UserListUsers />
      </UContainer>
    </template>

    <template v-else>
      <h1>Page d'accueil</h1>
      <UContainer class="mt-5">
        <UserListUsers />
      </UContainer>
    </template>
  </NuxtLayout>
</template>

<script setup lang="ts">
import {useUserRouteLogic} from "~/composables/use-user";

const { pathIncludesUser, currentUser } = useUserRouteLogic();
</script>
