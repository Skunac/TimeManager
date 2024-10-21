import { defineStore } from 'pinia'
import useApiService from "~/services/api";

export const useUserStore = defineStore('user', {
    state: () => {
        return {
            currentUser: null as User | null,
            selectedUser: null as User | null,
        }
    },

    actions: {
        async createUser(userData: Omit<User, 'id'>) {
            const { data, error } = await this.api.createUser(userData)
            if (error.value) {
                throw new Error('Failed to create user')
            }
            this.currentUser = data.value
            return data.value
        },

        async updateUser(userID: number, userData: Partial<User>) {
            const { data, error } = await this.api.updateUser(userID, userData)
            if (error.value) {
                throw new Error('Failed to update user')
            }
            return data.value
        },

        async getUser(userId?: number) {
            const { data, error } = userId ? await this.api.getUser(userId) : await this.api.getUser()
            if (error.value) {
                throw new Error('Failed to get user')
            }
            if (!userId) {
                this.selectedUser = data.value
            }
            return data.value
        },

        async deleteUser(userID: number) {
            const { error } = await this.api.deleteUser(userID)
            if (error.value) {
                throw new Error('Failed to delete user')
            }
            if (this.currentUser?.id === userID) {
                this.currentUser = null
            }
        },
    },
    getters: {
        api() {
            return useApiService();
        },
        getCurrentUser(): User {
            return this.currentUser
        },
    },
    persist: true
})