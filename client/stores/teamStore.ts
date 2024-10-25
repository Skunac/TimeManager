import { defineStore } from 'pinia'
import useApiService from "~/services/api";

export const useTeamStore = defineStore('teamStore', {
    state: () => ({
        teams: [] as Team[],
        currentTeam: null as Team | null,
    }),
    actions: {
        async createTeam(teamName: string) {
            const { data, error } = await this.api.createTeam(teamName)
            if (error.value) {
                throw new Error('Failed to create team')
            }
            this.teams.push(data.value)
            return data.value
        },


        async getTeamsByUserId(userId: number) {
            const { data, error } = await this.api.getTeamsByUserId(userId)
            if (error.value) {
                throw new Error('Failed to get teams by user id')
            }
            this.teams = data.value
            return data.value
        },

        async getTeams() {
            const { data, error } = await this.api.getTeams()
            if (error.value) {
                throw new Error('Failed to get all teams')
            }
            this.teams = data.value
            return data.value
        },

        async getTeamById(teamId: number) {
            const { data, error } = await this.api.getTeamById(teamId)
            if (error.value) {
                throw new Error('Failed to get team by id')
            }
            this.currentTeam = data.value
            return data.value
        }
    },
    getters: {
        api() {
            return useApiService();
        }
    },
    persist: true
})
