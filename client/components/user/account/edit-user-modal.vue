<script setup lang="ts">
import ModifyFormUser from "~/components/user/account/modify-form-user.vue";

const isOpen = useState<boolean>('isOpen', () => false)

const userStore = useUserStore();

const currentUser = computed(() => userStore.currentUser)
</script>

<template>
  <UButton class="font-normal" label="Edit" variant="outline" size="xs" icon="i-heroicons:pencil-square" @click="isOpen = true"/>

  <UModal v-model="isOpen">
    <UCard :ui="{ ring: '', divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
      <ModifyFormUser :user="currentUser" :is-open="isOpen"/>
    </UCard>
  </UModal>
</template>
