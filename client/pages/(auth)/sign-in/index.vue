<script setup lang="ts">
import {useUserStore} from "~/stores/userStore";

definePageMeta({
  layout: false,
})

import type { FormError, FormSubmitEvent } from '#ui/types'
import {useRouter} from "#vue-router";

const isLoading = useState<boolean>('isLoading', () => true)

const toast = useToast();
const router = useRouter();

const userStore = useUserStore();

const state = reactive({
  username: "",
  email: ""
})

const validate = (state: any): FormError[] => {
  const errors = []
  if (!state.username) errors.push({ path: 'username', message: 'Username is required' })
  if (!state.email) errors.push({ path: 'email', message: 'Email is required' })
  return errors
}

const onSubmit = async (event: FormSubmitEvent<any>) => {
  try{
    const authenticatedUser = await userStore.getUser(1)
    if(authenticatedUser) {
      userStore.currentUser = authenticatedUser;

      toast.add({ title: 'Success', description: 'You are logged in' })
      await router.push('/')
    }else {
      toast.add({ title: 'Error', description: 'No user found' })
    }
  }catch (e) {
    console.error(e)
    toast.add({ title: 'Error', description: 'An error was occurred' })
  }
}
</script>

<template>
  <main class="h-screen mx-auto flex justify-center items-center">
    <div class="w-1/5">
      <UForm :validate="validate" :state="state" class="space-y-4" @submit="onSubmit">
        <UFormGroup label="Username" name="username">
          <UInput v-model="state.username" />
        </UFormGroup>

        <UFormGroup label="Email" name="email">
          <UInput v-model="state.email" type="email" />
        </UFormGroup>

        <UButton block type="submit">
          Sign In
        </UButton>
      </UForm>
    </div>
  </main>
</template>
