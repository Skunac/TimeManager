<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useUserStore } from "~/stores/userStore";
import {useAuth} from "~/composables/use-auth";
import useApiService from "~/services/api";

const router = useRouter();
const toast = useToast();

const store = useUserStore();
const api = useApiService();
const userStore = useUserStore();

const currentUser = computed(() => userStore.currentUser)

const users = useState<User | null>('users', () => []);
const loading = useState<boolean>('loading', () => true);
const error = useState<string>('error', () => '');

const fetchUsers = async () => {
  setTimeout(async () => {
    try {
      const result = await store.getUser();
      users.value = Array.isArray(result) ? result : [result];
      loading.value = false;
    } catch (err) {
      console.error("Erreur lors du chargement des utilisateurs:", err);
      error.value = "Impossible de charger les utilisateurs. Veuillez réessayer.";
    } finally {
      loading.value = false;
    }
  }, 0.1)
}

onMounted(() => {
  fetchUsers();
});

const columns = [{
  key: "avatar",
  label: "Avatar"
}, {
  key: 'username',
  label: 'Username'
}, {
  key: 'email',
  label: 'Email'
}, {
  key: 'role',
  label: 'Role'
}, {
  key: 'actions',
  label: 'Actions'
}];

const items = (row: User) => [
  [{
    label: 'View',
    icon: 'i-heroicons:eye',
    click: () => router.push(`/overview/${row.id}`)
  }], [{
    label: 'Promote',
    icon: 'i-heroicons-hand-thumb-up-16-solid',
  }], [{
    label: 'Delete',
    icon: 'i-heroicons-trash-20-solid',
    click: () => {
      loading.value = true;
      toast.add({ title: "Success", description: `User named ${row.username} with the id ${row.id} has been deleted` })
      api.deleteUser(row.id);
      fetchUsers();
    }
  }]
];
</script>

<template v-if="currentUser.role === 'general_manager'">
  <UTable
      :rows="users"
      :columns="columns"
      :loading="loading"
      :empty-state="{
        label: 'No users',
      }"
  >
    <template #avatar-data="{ row }">
      <UAvatar
          class="hover:cursor-pointer"
          src="https://ui.shadcn.com/avatars/02.png"
          alt="Avatar"
          @click="router.push(`/overview/${row.id}`)"
      />
    </template>

    <template #username-data="{ row }">
      <span class="hover:underline hover:cursor-pointer" @click="router.push(`/overview/${row.id}`)">{{ row.username }}</span>
    </template>

    <template #role-data="{ row }">
      <span v-if="row.role === 'general_manager' || row.role === 'administrator'" class="text-xs font-medium text-primary">General Manager</span>
      <span v-else-if="row.role === 'manager'" class="text-xs font-medium text-primary">Manager</span>
      <span v-else class="text-xs font-medium text-primary">Employee</span>
    </template>

    <template #actions-data="{ row }">
      <UDropdown :items="items(row)">
        <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-horizontal-20-solid" />
      </UDropdown>
    </template>
  </UTable>
</template>
