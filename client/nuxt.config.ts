export default defineNuxtConfig({
  app: {
    baseURL: '/',
    head: {
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  },

  modules: [
    "@nuxt/ui",
    'nuxt-highcharts',
    '@pinia/nuxt',
    '@pinia-plugin-persistedstate/nuxt',
    '@nuxtjs/device',
    '@nuxtjs/tailwindcss'
  ],

  tailwindcss: {
    cssPath: '~/assets/css/tailwind.css',
    configPath: 'tailwind.config.js',
    exposeConfig: false,
    viewer: true,
  },

  colorMode: {
    preference: 'dark'
  },

  runtimeConfig: {
    public: {
      API_URL: process.env.NUXT_PUBLIC_API_URL || 'http://46.101.190.248:4000/api'
    }
  },

  ssr: false,

  pinia: {
    autoImports: ['defineStore', 'storeToRefs'],
  }
})