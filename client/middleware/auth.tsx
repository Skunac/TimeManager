export default defineNuxtRouteMiddleware(() => {
    const userStore = useUserStore()

    if (!userStore.currentUser) {
        return navigateTo({
            path: '/sign-in',
        })
    }
})
