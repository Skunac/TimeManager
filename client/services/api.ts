import { useFetch, UseFetchOptions } from '#app'
import { usePlatform } from "~/composables/usePlatform";
import { Capacitor, CapacitorHttp } from "@capacitor/core";
import { useUserStore } from '~/stores/userStore';

const useApiService = () => {
    const config = useRuntimeConfig()
    const { isAndroid } = usePlatform()
    const userStore = useUserStore()
    const toast = useToast()

    const baseURL = isAndroid ?
        'http://10.0.2.2:4000/api' :
        config.public.API_URL

    const xsrfToken = useCookie('XSRF-TOKEN')

    const apiFetch = async (endpoint: string, options: any = {}) => {
        try {
            const headers = {
                ...options.headers,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                ...(xsrfToken.value && { 'X-C-XSRF-Token': xsrfToken.value })
            }

            if (Capacitor.isNativePlatform()) {

                const response = await CapacitorHttp.request({
                    url: `${baseURL}${endpoint}`,
                    method: options.method || 'GET',
                    headers: headers,
                    // Ensure body is properly stringified for non-GET requests
                    data: options.method !== 'GET' ? JSON.stringify(options.body) : undefined,
                    webFetchExtra: {
                        credentials: 'include'
                    }
                });

                console.log('Native response:', response);

                let parsedData;
                try {
                    parsedData = typeof response.data === 'string' ?
                        JSON.parse(response.data) : response.data;
                } catch (e) {
                    console.error('Error parsing response:', e);
                    parsedData = response.data;
                }

                if (response.status >= 400) {
                    throw new Error(parsedData?.error || 'API call failed');
                }

                return { data: { value: parsedData } };
            } else {
                const response = await useFetch(endpoint, {
                    baseURL,
                    credentials: 'include',
                    ...options,
                    headers
                });

                if (response.error.value) {
                    if (userStore.currentUser && response.error.value.statusCode === 401) {
                        userStore.currentUser = null;
                        toast.add({ title: "Error", description: "You have been disconnected. Please reconnect you to access at dashboard" });
                        navigateTo('/sign-in');
                    }
                    throw new Error(response.error.value?.statusMessage || 'An error occurred');
                }

                return response;
            }
        } catch (error) {
            console.error('API call failed:', error);
            throw error;
        }
    }

    return {
        async login(authenticationData: Omit<Authentication, 'username'>): Promise<User> {
            try {
                console.log('Login attempt with:', authenticationData);
                const response = await apiFetch('/login', {
                    method: 'POST',
                    body: authenticationData
                });

                console.log('Login response:', response);

                if (response.data.value && response.data.value.c_xsrf_token) {
                    userStore.currentUser = response.data.value.user;
                    xsrfToken.value = response.data.value.c_xsrf_token;
                }

                return response.data.value as User;
            } catch (error) {
                console.error('Login failed:', error);
                throw error;
            }
        },

        async register(registerData: Authentication): Promise<User> {
            const response = await apiFetch('/register', {
                method: 'POST',
                body: registerData
            });

            return response.data.value as User;
        },

        logout() {
            userStore.currentUser = null;
            userStore.selectedUser = null;
            xsrfToken.value = null;
        },

        async createUser(userData: Omit<User, 'id'>) {
            return apiFetch('/users', {
                method: 'POST',
                body: userData,
            });
        },

        async updateUser(userId: number, userData: Omit<User, 'id'>) {
            return apiFetch(`/users/${userId}`, {
                method: 'PUT',
                body: userData,
            });
        },

        async getUser(userId?: number) {
            return apiFetch(userId ? `/users/${userId}` : '/users', {
                method: 'GET',
            });
        },

        async deleteUser(userId: number) {
            return apiFetch(`/users/${userId}`, {
                method: 'DELETE',
            });
        },

        async getWorkingTimes(userId: number) {
            return apiFetch(`/workingtime/${userId}`, {
                method: 'GET',
            });
        },

        async getWorkingTime(userId: number, workingTimeId: number) {
            return apiFetch(`/workingtime/${userId}/${workingTimeId}`, {
                method: 'GET',
            });
        },

        async createWorkingTime(userId: number, workingTimeData: Omit<WorkingTime, 'id' | 'user'>) {
            return apiFetch(`/workingtime/${userId}`, {
                method: 'POST',
                body: workingTimeData, // Removed JSON.stringify as apiFetch handles it
            });
        },

        async updateWorkingTime(workingTimeId: number, workingTimeData: Partial<WorkingTime>) {
            return apiFetch(`/workingtime/${workingTimeId}`, {
                method: 'PUT',
                body: workingTimeData, // Removed JSON.stringify as apiFetch handles it
            });
        },

        async deleteWorkingTime(workingTimeId: number) {
            return apiFetch(`/workingtime/${workingTimeId}`, {
                method: 'DELETE',
            });
        },

        async getAllClocks() {
            return apiFetch('/clocks', {
                method: 'GET',
            });
        },

        async getClockByUserId(userId: number) {
            return apiFetch(`/clocks/${userId}`, {
                method: 'GET',
            });
        },

        async createClock(userId: number, clockData: Omit<Clock, 'id' | 'user_id'>) {
            return apiFetch(`/clocks/${userId}`, {
                method: 'POST',
                body: clockData,
            });
        },

        async createTeam(teamName: string) {
            return apiFetch(`/teams`, {
                method: 'POST',
                body: { name: teamName }, // Wrapped in object with name property
            });
        },

        async getTeamsByUserId(userId: number): Promise<Team[]> {
            return apiFetch(`/teams/${userId}`, {
                method: 'GET',
            });
        },

        async getTeams(): Promise<Team[]> {
            return apiFetch(`/teams`, {
                method: 'GET',
            });
        },

        async getTeamById(teamId: number) {
            return apiFetch(`/teams/${teamId}`, {
                method: 'GET',
            });
        }
    }
}

export default useApiService;