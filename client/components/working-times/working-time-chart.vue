<script setup lang="ts">
import { useWorkingTimesStore } from "~/stores/workingTimeStore";
import { useUserStore } from "~/stores/userStore";
import { useChartStore } from "~/stores/chartStore";
import { computed, ref, watchEffect } from "vue";

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
const chartStore = useChartStore();

const user = useState<User | null>('user', () => null);
const workingTimes = useState<WorkingTime[]>('workingTimes', () => []);
const loading = useState<boolean>('loading', () => true);
const error = useState<string | null>('error', () => null);
const chartType = computed(() => chartStore.getChartType);
const viewType = ref('daily');

const viewOptions = [
  { label: 'Daily', value: 'daily' },
  { label: 'Weekly', value: 'weekly' }
];

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

const getWeekBounds = (date: Date) => {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() - d.getDay() + (d.getDay() === 0 ? -6 : 1)); // Set to Monday of the week
  const start = new Date(d);
  const end = new Date(d);
  end.setDate(end.getDate() + 6);
  return { start, end };
};

const formatDate = (date: Date) => {
  return date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' });
};

const chartData = computed(() => {
  if (viewType.value === 'daily') {
    return workingTimes.value.map(wt => ({
      name: new Date(wt.start).toLocaleDateString(),
      y: (new Date(wt.end).getTime() - new Date(wt.start).getTime()) / (1000 * 60 * 60)
    }));
  } else {
    const weeklyData = workingTimes.value.reduce((acc, wt) => {
      const date = new Date(wt.start);
      const { start, end } = getWeekBounds(date);
      const key = `${formatDate(start)} - ${formatDate(end)}`;
      const hours = (new Date(wt.end).getTime() - new Date(wt.start).getTime()) / (1000 * 60 * 60);

      if (!acc[key]) {
        acc[key] = { name: key, y: 0 };
      }
      acc[key].y += hours;
      return acc;
    }, {} as Record<string, { name: string, y: number }>);

    return Object.values(weeklyData);
  }
});

const formatHours = (hours: number): string => {
  const wholeHours = Math.floor(hours);
  const minutes = Math.round((hours - wholeHours) * 60);
  return `${wholeHours}h${minutes.toString().padStart(2, '0')}`;
};
const options = computed(() => ({
  chart: {
    type: chartType.value.id,
    backgroundColor: "#00000000"
  },
  title: {
    text: `${viewType.value === 'daily' ? 'Daily' : 'Weekly'} working time for user ${user.value?.username}`,
    style: {
      color: isDark.value ? '#ffffff' : '#000000'
    }
  },
  xAxis: {
    type: 'category',
    title: {
      text: viewType.value === 'daily' ? 'Date' : 'Week',
      style: {
        color: isDark.value ? '#cbd5e1' : '#64748b'
      },
    },
    labels: {
      style: {
        color: isDark.value ? '#cbd5e1' : '#64748b'
      },
      formatter: function() {
        if (viewType.value === 'weekly') {
          const [start, end] = this.value.split(' - ');
          return `${start}<br>${end}`;
        }
        return this.value;
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
        return formatHours(this.value);
      }
    },
    min: 0,
  },
  plotOptions: {
    series: {
      borderWidth: 0
    },
    pie: {
      allowPointSelect: true,
      cursor: 'pointer',
      dataLabels: {
        enabled: true,
        format: '<b>{point.name}</b>: {point.percentage:.1f} %'
      }
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
      return `<b>${this.point.name}</b><br/>Duration: ${formatHours(this.y)}`;
    }
  }
}));
watch(chartType, () => {
  nextTick(() => {
    if (chartRef.value) {
      chartRef.value.chart.update({
        chart: { type: chartType.value }
      });
    }
  });
});
</script>

<template>
  <UContainer>
    <div v-if="loading">Chargement...</div>
    <div v-else-if="error">{{ error }}</div>
    <div v-else-if="user && workingTimes.length">
      <div class="flex space-x-4 mb-4">
        <USelect
            v-model="viewType"
            :options="viewOptions"
            class="w-48"
        />
      </div>
      <highchart :options="options" ref="chartRef" />
      <UButton class="mt-4" @click="$router.push('/chart-manager')">w²
        Change Chart Type
      </UButton>
    </div>
    <div v-else>Aucune donnée disponible</div>
  </UContainer>
</template>