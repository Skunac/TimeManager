<script setup lang="ts">
import { useWorkingTimesStore } from "~/stores/workingTimeStore";
import { useUserStore } from "~/stores/userStore";
import { computed, watchEffect } from "vue";
import type { SeriesOptionsType } from 'highcharts';

const colorMode = useColorMode()

const isDark = computed({
  get () {
    return colorMode.value === 'dark'
  },
  set () {
    colorMode.preference = colorMode.value === 'dark' ? 'light' : 'dark'
  }
})

const route = useRoute();
const workingStore = useWorkingTimesStore();
const userStore = useUserStore();

const user = useState<User | null>('user', () => null);
const workingTimes = useState<WorkingTime[]>('workingTimes', () => []);
const loading = useState<boolean>('loading', () => true);
const error = useState<string | null>('error', () => null);

const fetchData = async () => {
  const userId = route.params.userId as string;
  if (!userId) return;

  loading.value = true;
  error.value = null;

  try {
    [user.value, workingTimes.value] = await Promise.all([
      userStore.getUser(userId),
      workingStore.getWorkingTimes(userId)
    ]);
  } catch (err) {
    console.error("Erreur lors du chargement des données:", err);
    error.value = "Impossible de charger les données. Veuillez réessayer.";
  } finally {
    loading.value = false;
  }
};

watchEffect(() => {
  if (route.params.userId) {
    fetchData();
  }
});

const chartData = computed<SeriesOptionsType[]>(() =>
    workingTimes.value.map(wt => ({
      x: new Date(wt.start).getTime(),
      y: (new Date(wt.end).getTime() - new Date(wt.start).getTime()) / (1000 * 60 * 60),
      name: new Date(wt.start).toLocaleDateString()
    }))
);

const options = computed(() => ({
  chart: {
    type: 'column',
    backgroundColor: "#00000000"
  },
  title: {
    text: `Working time for user ${user.value?.username}`,
    style: {
      color: isDark.value ? '#ffffff' : '#000000'
    }
  },
  xAxis: {
    type: 'datetime',
    title: {
      text: 'Date',
      style: {
        color: isDark.value ? '#cbd5e1' : '#64748b'
      },
    },
    labels: {
      style: {
        color: isDark.value ? '#cbd5e1' : '#64748b'
      }
    },
    lineColor: isDark.value ? '#475569' : '#cbd5e1'
  },
  yAxis: {
    title: {
      text: 'Duration (hours)',
      style: {
        color: isDark.value ? '#cbd5e1' : '#64748b'
      }
    },
    labels: {
      style: {
        color: isDark.value ? '#cbd5e1' : '#64748b'
      },
      formatter: function() {
        return this.value.toFixed(2) + 'h';
      }
    },
    tickInterval: 2
  },
  plotOptions: {
    column: {
      pointPadding: 0.3,
      borderWidth: 0
    }
  },
  series: [{
    name: 'Working Duration',
    data: chartData.value,
    color: isDark.value ? '#60a5fa' : '#3b82f6'
  }],
  tooltip: {
    backgroundColor: isDark.value ? '#334155' : '#ffffff',
    style: {
      color: isDark.value ? '#ffffff' : '#000000'
    },
    formatter: function() {
      return `<b>${this.point.name}</b><br/>Duration: ${this.y.toFixed(2)} hours`;
    }
  }
}));
</script>

<template>
  <UContainer>
    <div v-if="loading">Chargement...</div>
    <div v-else-if="error">{{ error }}</div>
    <highchart v-else-if="user && workingTimes.length" :options="options" />
    <div v-else>Aucune donnée disponible</div>
  </UContainer>
</template>
