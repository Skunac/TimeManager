export const useChartStore = defineStore('chart', {
    state: () => ({
        chartType: {"id": "bar", "label": "Bar"} as Chart,
    }),
    actions: {
        setChartType(chartType: ChartType) {
            this.chartType = chartType
        },
    },
    getters: {
        getChartType(): ChartType {
            return this.chartType
        }
    },
    persist: true
})