<script setup lang="ts">
definePageMeta({
  middleware: ['auth']
})

import TeamList from "~/components/user/account/teams/team-list.vue";
import EditUserModal from "~/components/user/account/edit-user-modal.vue";
import DeleteUserButton from "~/components/user/account/delete-user-button.vue";

const { isDesktop } = useDevice()

const layout = "authenticated-layout"

const userStore = useUserStore();

const currentUser: User = computed(() => userStore.currentUser)
</script>

<template>
  <NuxtLayout :name="layout">
    <section class="flex flex-col gap-y-12">
      <div>
        <h3 class="text-xl font-medium">My profile</h3>

        <div class="flex flex-col justify-between gap-y-5 mt-5 rounded-2xl py-4 md:flex-row md:items-center">
          <div class="flex items-center gap-x-4">
            <UAvatar
                src="https://ui.shadcn.com/avatars/02.png"
                alt="Avatar"
                size="2xl"
            />

            <div class="flex flex-col">
              <span class="font-semibold">{{ currentUser.username }}</span>

              <p class="text-xs font-light text-gray-500">{{ currentUser.email }}</p>

              <div class="mt-3">
                <span v-if="currentUser.role === 'general_manager'" class="text-xs font-medium text-primary">
                  General Manager
                </span>

                <span v-else-if="currentUser.role === 'manager'" class="text-xs font-medium text-primary">
                  Manager
                </span>
                <span v-else class="text-xs font-medium text-primary">
                  Employee
                </span>
              </div>
            </div>
          </div>

          <div class="max-w-52 flex flex-col gap-y-4 gap-x-3 md:flex-row">
            <EditUserModal/>

            <DeleteUserButton :user="currentUser"/>
          </div>
        </div>
      </div>

      <UDivider/>

      <div v-if="currentUser.role !== 'employee' && isDesktop">
        <h3 class="text-xl font-medium">My teams</h3>

        <div class="flex justify-between items-center mt-5 py-4">
          <TeamList class="w-full"/>
        </div>
      </div>
    </section>
  </NuxtLayout>
</template>
