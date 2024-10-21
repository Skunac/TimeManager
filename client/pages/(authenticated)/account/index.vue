<script setup lang="ts">
import TeamList from "~/components/user/account/teams/team-list.vue";
import EditUserModal from "~/components/user/account/edit-user-modal.vue";
import DeleteUserButton from "~/components/user/account/delete-user-button.vue";
import {ca} from "cronstrue/dist/i18n/locales/ca";

const layout = "authenticated-layout"

const userStore = useUserStore();

const currentUser: User = computed(() => userStore.currentUser)
</script>

<template>
  <NuxtLayout :name="layout">
    <section class="flex flex-col gap-y-12">
      <div>
        <h3 class="text-xl font-medium">My profile</h3>

        <div class="flex justify-between items-center mt-5 rounded-2xl py-4">
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
                <span class="text-xs font-medium text-primary">{{ currentUser.role }}</span>
              </div>
            </div>
          </div>

          <div class="flex gap-x-3">
            <EditUserModal/>
            <DeleteUserButton/>
          </div>
        </div>
      </div>

      <UDivider/>

      <div>
        <h3 class="text-xl font-medium">My teams</h3>

        <div class="flex justify-between items-center mt-5 py-4">
          <TeamList class="w-full"/>
        </div>
      </div>
    </section>
  </NuxtLayout>
</template>
