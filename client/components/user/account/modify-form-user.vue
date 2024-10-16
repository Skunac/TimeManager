<script setup lang="ts">
import type { FormError, FormSubmitEvent } from '#ui/types'

const props = defineProps<{
  userId: number
  isOpen: boolean
}>()

const user = useState<User | null>('user', () => null)
const isLoading = useState<boolean>('isLoading', () => true)

const toast = useToast();

const userStore = useUserStore();

const state = reactive({
  username: "",
  email: ""
})

const fetchUserData = async () => {
  try {
    user.value = await userStore.getUser(1);
    state.username = user.value?.username
    state.email = user.value?.email

    isLoading.value = false
  } catch (err) {
    console.error("Erreur lors du chargement des utilisateurs:", err);
    isLoading.value = false
  }
}

watchEffect(() => {
  if (props.isOpen && props.userId) {
    fetchUserData()
  }
})

const validate = (state: any): FormError[] => {
  const errors = []
  if (!state.username) errors.push({ path: 'username' })
  if (!state.email) errors.push({ path: 'email' })
  return errors
}

const onSubmit = async (event: FormSubmitEvent<any>) => {
  const formatUpdateData = {
    user: {
      username: event.data.username,
      email: event.data.email
    }
  }

  try {
    await userStore.updateUser(props.userId, formatUpdateData)
    toast.add({ title: 'Success', description: 'Your account has been updated' })
  }catch (e) {
    console.error(e)
    toast.add({ title: 'Error', description: 'An error was occurred' })
  }
}
</script>

<template>
  <NuxtLoadingIndicator />
  <div v-if="isLoading">Loading...</div>
  <div v-else>
    <UForm :validate="validate" :state="state" class="space-y-4" @submit="onSubmit">
      <UFormGroup label="Avatar">
        <div class="flex justify-between items-center my-2">
          <UAvatar
              src="https://ui.shadcn.com/avatars/02.png"
              alt="Avatar"
              size="2xl"
          />

          <UButton label="Modify" size="xs"/>
        </div>
      </UFormGroup>

      <UFormGroup label="Username" name="username">
        <UInput v-model="state.username" />
      </UFormGroup>

      <UFormGroup label="Email" name="email">
        <UInput v-model="state.email" type="email" />
      </UFormGroup>

      <UFormGroup label="Role">
        <USelectMenu placeholder="Manager" disabled />
      </UFormGroup>

      <UButton type="submit" size="xs">
        Update
      </UButton>
    </UForm>
  </div>
</template>
