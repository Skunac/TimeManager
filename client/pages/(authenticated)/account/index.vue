<script setup lang="ts">
import TeamList from "~/components/user/account/teams/team-list.vue";
import EditUserModal from "~/components/user/edit-user-modal.vue";

const layout = "authenticated-layout"

const userStore = useUserStore();

onMounted(async () => {
  console.log(userStore.currentUser)
})
</script>

<template>
  <NuxtLayout :name="layout">
    <section class="flex flex-col gap-y-12">
      <div>
        <h3 class="text-xl font-medium">My profile</h3>

        <div class="flex justify-between items-center mt-5 border rounded-2xl p-4 py-5">
          <div class="flex items-center gap-x-4">
            <UAvatar
                src="https://ui.shadcn.com/avatars/02.png"
                alt="Avatar"
                size="2xl"
            />

            <div class="flex flex-col">
              <span class="font-semibold">REVERSS</span>
              <p class="text-xs font-light text-gray-500">john@example.com</p>

              <div class="mt-3">
                <span class="text-xs font-medium text-primary">Manager</span>
              </div>
            </div>
          </div>

          <EditUserModal/>
        </div>
      </div>

      <div>
        <h3 class="text-xl font-medium">My teams</h3>

        <div class="flex justify-between items-center mt-5 border rounded-2xl p-4 py-5">
          <TeamList/>
        </div>
      </div>
    </section>
  </NuxtLayout>
</template>
