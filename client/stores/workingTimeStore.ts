import { defineStore } from 'pinia'
import useApiService from "~/services/api";

export const useWorkingTimesStore = defineStore('workingTimes', {
    state: () => ({
        workingTimes: [] as WorkingTime[],
    }),
    actions: {
        async getWorkingTimes(userId: number) {
            const { data, error } = await this.api.getWorkingTimes(userId)
            if (error.value) {
                throw new Error('Failed to get working times')
            }
            this.workingTimes = data.value
            return data.value
        },

        async getWorkingTime(userId: number, workingTimeId: number) {
            const { data, error } = await this.api.getWorkingTime(userId, workingTimeId)
            if (error.value) {
                throw new Error('Failed to get working time')
            }
            return data.value
        },

        async createWorkingTime(userId: number, workingTimeData: Omit<WorkingTime, 'id' | 'user'>) {
            const { data, error } = await this.api.createWorkingTime(userId, workingTimeData)
            if (error.value) {
                throw new Error('Failed to create working time')
            }
            this.workingTimes.push(data.value)
            return data.value
        },

        async updateWorkingTime(userId: number, workingTimeId: number, workingTimeData: Partial<WorkingTime>) {
            const { data, error } = await this.api.updateWorkingTime(userId, workingTimeId, workingTimeData)
            if (error.value) {
                throw new Error('Failed to update working time')
            }
            const index = this.workingTimes.findIndex(wt => wt.id === workingTimeId)
            if (index !== -1) {
                this.workingTimes[index] = { ...this.workingTimes[index], ...data.value }
            }
            return data.value
        },

        async deleteWorkingTime(userId: number) {
            const { error } = await this.api.deleteWorkingTime(userId, workingTimeId)
            if (error.value) {
                throw new Error('Failed to delete working time')
            }
            this.workingTimes = this.workingTimes.filter(wt => wt.id !== workingTimeId)
        },
    },
    getters: {
        api() {
            return useApiService();
        }
    }
})