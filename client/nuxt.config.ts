// nuxt.config.ts
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
      API_URL: process.env.NUXT_PUBLIC_API_URL ||
          (process.env.CAPACITOR_PLATFORM === 'android' ?
              'http://10.0.2.2:4000/api' :
              'http://localhost:4000/api')
    }
  },

  ssr: false,

  pinia: {
    autoImports: ['defineStore', 'storeToRefs'],
  },

  nitro: {
    preset: 'static'
  }
})