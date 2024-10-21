import { useFetch, UseFetchOptions } from '#app'

const useApiService = () => {
    const config = useRuntimeConfig()
    const baseURL = config.public.API_URL

    const xsrfToken = useCookie('XSRF-TOKEN')

    const apiFetch = async (endpoint: string, options: any = {}) => {
        try {
            const headers = {
                ...options.headers,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                ...(xsrfToken.value && { 'X-C-XSRF-Token': xsrfToken.value })
            }

            const response = await useFetch(endpoint, {
                baseURL,
                credentials: 'include',
                ...options,
                headers
            })

            if (response.error.value) {
                throw new Error(response.error.value?.statusMessage || 'An error occurred')
            }

            return response
        } catch (error) {
            console.error('API call failed:', error)
            throw error
        }
    }

    return {
        async login(authenticationData: Omit<Authentication, 'username'>): Promise<User> {
            const response = await apiFetch('/login', {
                method: 'POST',
                body: authenticationData
            })

            // Stocker le token XSRF si présent dans la réponse
            if (response.data.value && response.data.value.c_xsrf_token) {
                xsrfToken.value = response.data.value.c_xsrf_token
            }

            return response.data.value as User
        },

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
