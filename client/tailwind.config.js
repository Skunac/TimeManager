// tailwind.config.js
import { getIconCollections, iconsPlugin } from '@egoist/tailwindcss-icons'

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './components/**/*.{js,vue,ts}',
        './layouts/**/*.vue',
        './pages/**/*.vue',
        './plugins/**/*.{js,ts}',
        './app.vue',
        './error.vue',
        './node_modules/@nuxt/ui/dist/**/*.vue',
    ],
    theme: {
        extend: {},
    },
    plugins: [
        iconsPlugin({
            collections: getIconCollections(['heroicons']),
        }),
    ],
}