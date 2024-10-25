<script setup lang="ts">
const toast = useToast();

const userStore = useUserStore();
const teamStore = useTeamStore();

const isLoading = useState<boolean>('isLoading', () => true)
const teams = useState<Team[] | []>('teams', () => [])

const fetchTeams = async () => {
  try {
    console.log(userStore.currentUser)
    /*teams.value = await userStore.currentUser.teams
    isLoading.value = false*/
  } catch (e) {
    /*toast.add({ title: 'Error', })
    isLoading.value = false*/
  }
}


onMounted(() => {
  setTimeout(() => {
    fetchTeams();
  }, 0.1)
})

const columns = [{
  key: "name",
  label: "Name"
}, {
  key: 'number_users',
  label: 'Number of users'
}, {
  key: 'actions',
  label: 'Actions'
}];

const items = (row: Team) => [
  [{
    label: 'View team',
    icon: 'i-heroicons:eye',
    click: () => navigateTo(`/team/${row.id}/overview`)
  }], [{
    label: 'Delete team',
    icon: 'i-heroicons-trash-20-solid',
  }]
];
</script>

<template>
  <div class="w-full">
    <UTable
        :rows="teams"
        :columns="columns"
        :loading="isLoading"
        :empty-state="{
          label: 'No team',
        }"
    >
      <template #name-data="{ row }">
        <span class="hover:underline hover:cursor-pointer uppercase" @click="navigateTo(`/team/${row.id}/overview`)">{{ row.name }}</span>
      </template>

      <template #number_users-data="{ row }">
        <span>{{ row.users.length }}</span>
      </template>

      <template #actions-data="{ row }">
        <UDropdown :items="items(row)">
          <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-horizontal-20-solid" />
        </UDropdown>
      </template>
    </UTable>
  </div>
</template>
