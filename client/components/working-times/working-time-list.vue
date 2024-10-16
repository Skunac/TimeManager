<script setup lang="ts">
import { ref, onMounted } from 'vue'

const router = useRouter();
const store = useWorkingTimesStore();
const workingTimes = useState<WorkingTime[]>('workingTimes', () => [])
const isLoading = useState<boolean>('isLoading', () => true)
const error = useState<string | null>('error', () => null)

onMounted(() => {
  setTimeout(async () => {
    try {
      const result = await store.getWorkingTimes();
      users.value = Array.isArray(result) ? result : [result];
      loading.value = false;
    } catch (err) {
      console.error("Erreur lors du chargement des utilisateurs:", err);
      error.value = "Impossible de charger les utilisateurs. Veuillez réessayer.";
    } finally {
      loading.value = false;
    }
  }, 0.1)
});

const columns = [{
  key: 'username',
  label: 'Username'
}, {
  key: 'email',
  label: 'Email'
}, {
  key: 'actions',
  label: 'Actions'
}];

const items = (row: User) => [
  [{
    label: 'View',
    icon: 'i-heroicons:eye',
    click: () => router.push(`/overview/${row.id}`)
  }, {
    label: 'Edit',
    icon: 'i-heroicons-pencil-square-20-solid',
    click: () => console.log('Edit', row.id)
  }], [{
    label: 'Delete',
    icon: 'i-heroicons-trash-20-solid',
    click: () => console.log('Delete', row.id)
  }]
];
</script>

<template>
  <UTable
      :rows="users"
      :columns="columns"
      :loading="loading"
  >
    <template #actions-data="{ row }">
      <UDropdown :items="items(row)">
        <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-horizontal-20-solid" />
      </UDropdown>
    </template>
  </UTable>
</template>
