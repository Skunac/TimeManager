<script setup lang="ts">
const props = defineProps<{
  user: User
}>()
const router = useRouter();
const userStore = useUserStore();

const alertIsOpen = useState<boolean>('alertIsOpen', () => false)

const toast = useToast();

const deleteMyAccount = async () => {
  try {
    await userStore.deleteUser(props.user.id)
    alertIsOpen.value = false
    await router.replace('/sign-up')
    toast.add({ title: 'Success', description: 'Your account has been deleted successfully' })
  }catch (e) {
    toast.add({ title: 'Error', description: 'An error was occurred' })
  }
}

</script>

<template>
  <UButton class="bg-primary text-zinc-800 font-normal" label="Delete my account" variant="flat" size="xs" icon="i-heroicons:trash-16-solid" @click="alertIsOpen = true"/>

  <template v-if="alertIsOpen">
    <div class="absolute z-50 inset-0 w-screen h-screen flex justify-center items-center bg-black/60 backdrop-blur-4">
      <UAlert
          class="w-3/5"
          :ui="{title: 'text-xl text-primary', description: 'text-white/50', actions: 'mt-5'}"
          :actions="[{ variant: 'solid', color: 'primary', label: 'Yes', click: () => deleteMyAccount() }, { variant: 'outline', color: 'primary', label: 'No', click: () => alertIsOpen = false }]"
          title="Delete your account"
          description="Are you sure you want to delete your account? This action cannot be undone."
      />
    </div>
  </template>
</template>
