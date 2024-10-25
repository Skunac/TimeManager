import { useUserStore } from '@/stores/userStore'
import useApiService from "~/services/api";

export const useAuth = () => {
    const router = useRouter();

    const api = useApiService();
    const userStore = useUserStore()

    const isAuthenticated = computed(() => !!userStore.currentUser)

    const login = async (authenticationData: Omit<Authentication, 'username'>) => {
        try {
            await api.login(authenticationData)
            // La mise à jour du userStore est déjà gérée dans votre useApiService
            return true
        } catch (error) {
            console.error('Erreur de connexion:', error)
            return false
        }
    }

    const logout = async () => {
        try {
            await api.logout()
            // Redirection après déconnexion
            await router.replace('/sign-in')
        } catch (error) {
            console.error('Erreur de déconnexion:', error)
        }
    }

    return {
        isAuthenticated,
        login,
        logout
    }
}
