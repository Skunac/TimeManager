import { defineStore } from 'pinia'
import useApiService from "~/services/api";

export const useClockStore = defineStore('clock', {
    state: () => ({
        clocks: [] as Clock[],
        currentClock: null as Clock | null,
    }),
    actions: {
        async getAllClocks() {
            const { data, error } = await this.api.getAllClocks()
            if (error.value) {
                throw new Error('Failed to get all clocks')
            }
            this.clocks = data.value
            return data.value
        },

        async getClockByUserId(userId: number) {
            const { data, error } = await this.api.getClockByUserId(userId)
            if (error.value) {
                throw new Error('Failed to get clock for user')
            }
            this.currentClock = data.value
            return data.value
        },

        async createClock(userId: number, clockData: Omit<Clock, 'id' | 'user_id'>) {
            const { data, error } = await this.api.createClock(userId, clockData)
            if (error.value) {
                throw new Error('Failed to create clock')
            }
            if (data.value) {
                this.clocks.push(data.value)
                this.currentClock = data.value
            }
            return data.value
        },

        // Since the backend doesn't provide update and delete endpoints for clocks,
        // we'll implement local updates to the store

        updateClock(clockId: number, clockData: Partial<Clock>) {
            const index = this.clocks.findIndex(c => c.id === clockId)
            if (index !== -1) {
                this.clocks[index] = { ...this.clocks[index], ...clockData }
                if (this.currentClock?.id === clockId) {
                    this.currentClock = this.clocks[index]
                }
            }
        },

        deleteClock(clockId: number) {
            this.clocks = this.clocks.filter(c => c.id !== clockId)
            if (this.currentClock?.id === clockId) {
                this.currentClock = null
            }
        },
    },
    getters: {
        api() {
            return useApiService();
        }
    }
})