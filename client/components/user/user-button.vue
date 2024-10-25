<script setup lang="ts">
import useApiService from "~/services/api";
import {useAuth} from "~/composables/use-auth";

const router = useRouter();

const userStore = useUserStore();
const auth = useAuth();

const currentUser = computed(() => userStore.currentUser)

const logout = async () => {
  await auth.logout()
}

const items = [
  [{
    label: currentUser.value?.email || "",
    slot: 'account',
    role: currentUser.value?.role || "",
    disabled: true
  }],
  [{
    label: 'My account',
    icon: 'i-heroicons-adjustments-horizontal-16-solid',
    to: '/account'
  }, {
    label: 'Manage charts',
    icon: 'i-heroicons-chart-bar',
    to: '/chart-manager'
  }], [{
    label: 'Sign out',
    slot: 'sign-out',
    icon: 'i-heroicons-arrow-left-on-rectangle'
  }]
]
</script>

<template>
  <UDropdown v-if="currentUser" :items="items" :ui="{ item: { disabled: 'cursor-text select-text' } }" :popper="{ placement: 'bottom-start' }">
    <UButton class="hover:bg-gray-100" variant="ghost" color="gray" :label="currentUser.username" @click="isOpen = true" size="xs">
      <template #leading>
        <UAvatar
            class="mr-1"
            src="https://avatars.githubusercontent.com/u/739984?v=4"
        />
      </template>
    </UButton>

    <template #account="{ item }">
      <div class="text-left">
        <p>
          Signed in as
        </p>
        
        <p class="truncate text-xs font-light text-gray-900 dark:text-white">
          {{ item.label }}
        </p>

        <p v-if="currentUser.role === 'general_manager'" class="text-xs text-primary truncate font-semibold mt-1.5">
          General Manager
        </p>
        <p v-else-if="currentUser.role === 'manager'" class="text-xs text-primary truncate font-semibold mt-1.5">
          Manager
        </p>
        <p v-else class="text-xs text-primary truncate font-semibold mt-1.5">
          Employee
        </p>
      </div>
    </template>

    <template #item="{ item }">
      <span class="truncate text-xs">{{ item.label }}</span>

      <UIcon :name="item.icon" class="flex-shrink-0 h-4 w-4 text-gray-400 dark:text-gray-500 ms-auto" />
    </template>

    <template #sign-out="{ item }">
      <div class="w-full flex justify-between items-center" @click="logout">
        <span class="truncate text-xs">{{ item.label }}</span>

        <UIcon :name="item.icon" class="flex-shrink-0 h-4 w-4 text-gray-400 dark:text-gray-500 ms-auto" />
      </div>
    </template>
  </UDropdown>

  <UButton v-else-if="!currentUser" variant="outline" label="Sign in" @click="navigateTo('/sign-in')"/>
</template>
