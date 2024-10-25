<script setup lang="ts">
import type { FormError, FormSubmitEvent } from '#ui/types'

const props = defineProps<{
  user: User
  isOpen: boolean
}>()

/*const user = useState<User | null>('user', () => null)*/
const isLoading = useState<boolean>('isLoading', () => true)

const toast = useToast();

const userStore = useUserStore();

const state = reactive({
  username: "",
  email: ""
})

const setData = async () => {
  try {
    state.username = props.user?.username
    state.email = props.user?.email

    isLoading.value = false
  } catch (err) {
    console.error("Erreur lors du chargement des utilisateurs:", err);
    isLoading.value = false
  }
}

watchEffect(() => {
  if (props.isOpen && props.user) {
    setData()
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
    await userStore.updateUser(props.user.id, formatUpdateData)
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

          <UButton label="Modify" size="xs" disabled/>
        </div>
      </UFormGroup>

      <UFormGroup label="Username" name="username">
        <UInput v-model="state.username" />
      </UFormGroup>

      <UFormGroup label="Email" name="email">
        <UInput v-model="state.email" type="email" />
      </UFormGroup>

      <UFormGroup label="Role">
        <UInput v-if="props.user.role === 'general_manager' || props.user.role === 'administrator'" placeholder="General Manager" disabled />
        <UInput v-else-if="props.user.role === 'manager'" placeholder="Manager" disabled />
        <UInput v-else placeholder="Employee" disabled />
      </UFormGroup>

      <UButton type="submit" size="xs">
        Update
      </UButton>
    </UForm>
  </div>
</template>
