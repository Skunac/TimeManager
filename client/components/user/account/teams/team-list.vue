<script setup lang="ts">
const columns = [{
  key: "name",
  label: "Name"
}, {
  key: 'count_users',
  label: 'Users'
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
  <div class="w-full">
    <UTable
        :columns="columns"
        :loading="loading"
    >
      <template #actions-data="{ row }">
        <UDropdown :items="items(row)">
          <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-horizontal-20-solid" />
        </UDropdown>
      </template>
    </UTable>
  </div>
</template>
