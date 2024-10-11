import type {User} from "~/utils/types/user";

const people: User[] = [{
    id: 1,
    username: 'Lindsay Walton',
    email: 'lindsay.walton@example.com',
    /*role: 'Manager'*/
}, {
    id: 2,
    username: 'Courtney Henry',
    email: 'courtney.henry@example.com',
    /*role: 'Employé'*/
}, {
    id: 3,
    username: 'Tom Cook',
    email: 'tom.cook@example.com',
    /*role: 'Employé'*/
}, {
    id: 4,
    username: 'Whitney Francis',
    email: 'whitney.francis@example.com',
    /*role: 'Employé'*/
}]

export function useUserRouteLogic() {
    const route = useRoute()
    const randomUser = ref<User>(people[0])

    const pathIncludesUser = computed<boolean>(() => {
        return route.fullPath?.includes('/user/') ?? false
    })

    const getRandomUser = () => {
        const randomIndex = Math.floor(Math.random() * people.length)
        randomUser.value = people[randomIndex]
    }

    watch(() => route.fullPath, () => {
        getRandomUser()
    })

    const currentUser = computed<User>(() => {
        return randomUser.value
    })

    return {
        pathIncludesUser,
        currentUser
    }
}
