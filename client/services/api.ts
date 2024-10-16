import { useFetch, UseFetchOptions } from '#app'

const useApiService = () => {
    const config = useRuntimeConfig()
    const baseURL = 'http://46.101.190.248:4000/api'

    const apiFetch = (endpoint: string, options: UseFetchOptions<any> = {}) => {
        return useFetch(endpoint, {
            baseURL,
            ...options,
        })
    }

    return {
        async createUser(userData: Omit<User, 'id'>) {
            return apiFetch('/users', {
                method: 'POST',
                body: userData,
            })
        },

        async updateUser(userId: number, userData: Omit<User, 'id'>) {
            return apiFetch(`/users/${userId}`, {
                method: 'PUT',
                body: userData,
            })
        },

        async getUser(userId?: number) {
            return apiFetch(userId ? `/users/${userId}` : '/users', {
                method: 'GET',
            })
        },

        async deleteUser(userId: number) {
            return apiFetch(`/users/${userId}`, {
                method: 'DELETE',
            })
        },

        async getWorkingTimes(userId: number) {
            return apiFetch(`/workingtime/${userId}`, {
                method: 'GET',
            })
        },

        async getWorkingTime(userId: number, workingTimeId: number) {
            return apiFetch(`/workingtime/${userId}/${workingTimeId}`, {
                method: 'GET',
            })
        },

        async createWorkingTime(userId: number, workingTimeData: Omit<WorkingTime, 'id' | 'user'>) {
            return apiFetch(`/workingtime/${userId}`, {
                method: 'POST',
                body: JSON.stringify(workingTimeData),
            })
        },

        async updateWorkingTime(workingTimeId: number, workingTimeData: Partial<WorkingTime>) {
            return apiFetch(`/workingtime/${workingTimeId}`, {
                method: 'PUT',
                body: JSON.stringify(workingTimeData),
            })
        },

        async deleteWorkingTime(workingTimeId: number) {
            return apiFetch(`/workingtime/${workingTimeId}`, {
                method: 'DELETE',
            })
        },

        async getAllClocks() {
            return apiFetch('/clocks', {
                method: 'GET',
            })
        },

        async getClockByUserId(userId: number) {
            return apiFetch(`/clocks/${userId}`, {
                method: 'GET',
            })
        },

        async createClock(userId: number, clockData: Omit<Clock, 'id' | 'user_id'>) {
            return apiFetch(`/clocks/${userId}`, {
                method: 'POST',
                body: clockData,
            })
        },
    }
}

export default useApiService