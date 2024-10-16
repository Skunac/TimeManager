// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  colorMode: {
    preference: 'dark'
  },
  runtimeConfig: {
    public: {
      API_URL: process.env.API_BASE_URL || 'http://localhost:4000/api'
    }
  },
  devtools: { enabled: true },
  extends: ['@nuxt/ui-pro'],
  modules: ["@nuxt/ui", 'nuxt-highcharts', // With options
    ['nuxt-highcharts', { /* module options */ }], '@pinia/nuxt'],
  compatibilityDate: "2024-10-08",
})
