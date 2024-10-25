<script setup lang="ts">
const route = useRoute();

const teamStore = useTeamStore();

const isLoading = useState<boolean>('isLoading', () => true)

const fetchTeamData = async () => {
  setTimeout(async () => {
    try {
      await teamStore.getTeamById(route.params.teamId);

      isLoading.value = false
    }catch (e) {
      console.error(e)
    }
  }, 0.1)
}

onMounted(() => {
  fetchTeamData();
})

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
    /*click: () => router.push(`/overview/${row.id}`)*/
  }], [{
    label: 'Promote',
    icon: 'i-heroicons-hand-thumb-up-16-solid',
  }], [{
    label: 'Delete',
    icon: 'i-heroicons-trash-20-solid',
    /*click: () => {
      loading.value = true;
      toast.add({ title: "Success", description: `User named ${row.username} with the id ${row.id} has been deleted` })
      api.deleteUser(row.id);
      fetchUsers();
    }*/
  }]
];
</script>

<template>
  <div>
    <h3 class="font-medium my-5 mx-3">User list of the team</h3>
  </div>

  <UTable
    :rows="teamStore.currentTeam.users"
    :columns="columns"
    :loading="isLoading"
    :empty-state="{
      label: 'No users',
    }"
  >

  </UTable>
</template>
