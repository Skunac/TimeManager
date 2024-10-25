<script setup lang="ts">
import {useUserStore} from "~/stores/userStore";

definePageMeta({
  layout: false,
})

import type { FormError, FormSubmitEvent } from '#ui/types'
import {useRouter} from "#vue-router";
import useApiService from "~/services/api";

const toast = useToast();
const router = useRouter();

const userStore = useUserStore();

const state = reactive({
  email: "",
  password: ""
})

const validate = (state: any): FormError[] => {
  const errors = []
  if (!state.email) errors.push({ path: 'email', message: 'Email is required' })
  if (!state.password) errors.push({ path: 'password', message: 'Password is required' })
  return errors
}

const onSubmit = async (event: FormSubmitEvent<any>) => {
  try{
    const apiService = useApiService();

    const authenticationData: Omit<Authentication, 'username'> = {
      email: event.data.email,
      password: event.data.password
    }

    apiService.login(authenticationData).then(async (authenticatedUser) => {
      if(authenticatedUser) {
        toast.add({ title: 'Success', description: 'You are logged in' })
        await router.push('/')
      }else {
        toast.add({ title: 'Error', description: 'No user found' })
      }
    })
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
        <UFormGroup label="Email" name="email">
          <UInput v-model="state.email" />
        </UFormGroup>

        <UFormGroup label="Password" name="password">
          <UInput v-model="state.password" type="password" />
        </UFormGroup>

        <UButton block type="submit" label="Sign In"/>

        <UButton label="Create an account" variant="ghost" @click="navigateTo('sign-up')"/>
      </UForm>
    </div>
  </main>
</template>
