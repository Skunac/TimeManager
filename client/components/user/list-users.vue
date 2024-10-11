<script setup lang="ts">
import type {User} from "~/utils/types/user";

const columns = [{
  key: 'username',
  label: 'Username'
}, {
  key: 'email',
  label: 'Email'
}, /*{
  key: 'role',
  label: 'Role'
},*/ {
  key: 'actions',
  label: 'Actions'
}]

const people: User[] = [{
  id: 1,
  username: 'Lindsay Walton',
  email: 'lindsay.walton@example.com',
  /*role: 'Manager'*/
}, {
  id: 2,
  username: 'Courtney Henry',
  email: 'courtney.henry@example.com',
  /*role: 'Employé'*/
}, {
  id: 3,
  username: 'Tom Cook',
  email: 'tom.cook@example.com',
  /*role: 'Employé'*/
}, {
  id: 4,
  username: 'Whitney Francis',
  email: 'whitney.francis@example.com',
  /*role: 'Employé'*/
}]

const items = (row) => [
  [ {
    label: 'View',
    icon: 'i-heroicons:eye',
    click: () => navigateTo(`/user/${people[row.id - 1].id}`)
  }, {
    label: 'Edit',
    icon: 'i-heroicons-pencil-square-20-solid',
    click: () => console.log('Edit', row.id)
  }], [{
    label: 'Delete',
    icon: 'i-heroicons-trash-20-solid'
  }]
]
</script>

<template>
  <UTable
      :loading-state="{ icon: 'i-heroicons-arrow-path-20-solid', label: 'Loading...' }"
      :progress="{ color: 'primary', animation: 'carousel' }"
      :rows="people"
      :columns="columns"
  >
    <template #actions-data="{ row }">
      <UDropdown :items="items(row)">
        <UButton color="gray" variant="ghost" icon="i-heroicons-ellipsis-horizontal-20-solid" />
      </UDropdown>
    </template>
  </UTable>
</template>
