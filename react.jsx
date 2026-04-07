import React, { useState } from 'react';
import { base44 } from '@/api/base44Client';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Thermometer, Droplets, Plus, Activity, Clock } from 'lucide-react';
import { Button } from '@/components/ui/button';
import moment from 'moment';
import GaugeCard from '../components/dashboard/GaugeCard';
import ComparisonBar from '../components/dashboard/ComparisonBar';
import TrendChart from '../components/dashboard/TrendChart';
import StatusBadge from '../components/dashboard/StatusBadge';
import AddReadingModal from '../components/dashboard/AddReadingModal';
import NotificationBanner from '../components/dashboard/NotificationBanner';
export default function Dashboard() {
  const [showAddModal, setShowAddModal] = useState(false);
  const queryClient = useQueryClient();
  const { data: readings = [], isLoading } = useQuery({
    queryKey: ['sensorReadings'],
    queryFn: () => base44.entities.SensorReading.list('-created_date', 50),
  });
  const createMutation = useMutation({
    mutationFn: (data) => base44.entities.SensorReading.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sensorReadings'] });
      setShowAddModal(false);
    },
  });
  const latest = readings[0] || null;
  const recentReadings = readings.slice(0, 20).reverse();
  return (
<div className="min-h-screen bg-[#0a0a0f] text-white">
      {/* Subtle gradient background */}
<div className="fixed inset-0 bg-gradient-to-br from-amber-950/10 via-transparent to-cyan-950/10 pointer-events-none" />
<div className="fixed inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-white/[0.02] via-transparent to-transparent pointer-events-none" />
<div className="relative max-w-6xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
        {/* Header */}
<div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-10">
<div>
<div className="flex items-center gap-2 mb-2">
<Activity className="w-4 h-4 text-emerald-400" />
<span className="text-xs font-medium uppercase tracking-[0.2em] text-emerald-400/80">Live Monitor</span>
</div>
<h1 className="text-3xl sm:text-4xl font-extralight tracking-tight text-white/90">
              Sensor Dashboard
</h1>
            {latest && (
<p className="text-xs text-white/25 mt-2 flex items-center gap-1.5">
<Clock className="w-3 h-3" />
                Last reading: {moment(latest.timestamp || latest.created_date).fromNow()}
</p>
            )}
</div>
<Button
            onClick={() => setShowAddModal(true)}
            className="bg-white/[0.06] hover:bg-white/[0.1] border border-white/[0.08] text-white/70 hover:text-white rounded-xl px-5 transition-all"
>
<Plus className="w-4 h-4 mr-2" />
            New Reading
</Button>
</div>
        {isLoading ? (
<div className="flex items-center justify-center h-64">
<div className="w-8 h-8 border-2 border-white/10 border-t-white/40 rounded-full animate-spin" />
</div>
        ) : !latest ? (
<div className="text-center py-24">
<div className="w-16 h-16 mx-auto mb-6 rounded-2xl bg-white/[0.04] border border-white/[0.06] flex items-center justify-center">
<Thermometer className="w-7 h-7 text-white/20" />
</div>
<p className="text-white/30 text-lg font-light">No readings yet</p>
<p className="text-white/15 text-sm mt-2">Add your first sensor reading to get started</p>
<Button
              onClick={() => setShowAddModal(true)}
              className="mt-6 bg-white/[0.06] hover:bg-white/[0.1] border border-white/[0.08] text-white/60 rounded-xl"
>
<Plus className="w-4 h-4 mr-2" />
              Add Reading
</Button>
</div>
        ) : (
<div className="space-y-6">
            {/* Notification Banner */}
<NotificationBanner latestReading={latest} />
            {/* Status Badge */}
<StatusBadge
              bodyTemp={latest.body_temperature_f}
              sweatRH={latest.sweat_level_rh}
              outsideTemp={latest.outside_temperature_f}
              outsideRH={latest.outside_humidity_rh}
            />
            {/* Main Gauges */}
<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
<GaugeCard
                label="Body Temperature"
                value={latest.body_temperature_f}
                unit="°F"
                icon={Thermometer}
                min={90}
                max={110}
                color="amber"
                subLabel="Range"
                subValue="90–110 °F"
              />
<GaugeCard
                label="Sweat Level"
                value={latest.sweat_level_rh}
                unit="%RH"
                icon={Droplets}
                min={0}
                max={100}
                color="cyan"
                subLabel="Range"
                subValue="0–100 %RH"
              />
</div>
            {/* Comparison Bars */}
<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
<ComparisonBar
                bodyValue={latest.body_temperature_f}
                outsideValue={latest.outside_temperature_f}
                unit="°F"
                label="Temperature"
                color="amber"
              />
<ComparisonBar
                bodyValue={latest.sweat_level_rh}
                outsideValue={latest.outside_humidity_rh}
                unit="%RH"
                label="Humidity"
                color="cyan"
              />
</div>
            {/* Trend Charts */}
<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
<TrendChart data={recentReadings} type="temperature" />
<TrendChart data={recentReadings} type="humidity" />
</div>
            {/* Readings History */}
<div className="rounded-3xl p-6 backdrop-blur-xl border bg-gradient-to-br from-white/[0.05] to-white/[0.02] border-white/[0.06]">
<h3 className="text-xs font-medium uppercase tracking-widest text-white/30 mb-4">Recent Readings</h3>
<div className="overflow-x-auto">
<table className="w-full text-sm">
<thead>
<tr className="text-white/25 text-xs">
<th className="text-left py-2 font-medium">Time</th>
<th className="text-right py-2 font-medium">Body °F</th>
<th className="text-right py-2 font-medium">Sweat %RH</th>
<th className="text-right py-2 font-medium">Outside °F</th>
<th className="text-right py-2 font-medium">Outside %RH</th>
<th className="text-right py-2 font-medium">Δ Temp</th>
<th className="text-right py-2 font-medium">Δ Humidity</th>
</tr>
</thead>
<tbody>
                    {readings.slice(0, 10).map((r) => {
                      const tempDiff = r.body_temperature_f - r.outside_temperature_f;
                      const humDiff = r.sweat_level_rh - r.outside_humidity_rh;
                      return (
<tr key={r.id} className="border-t border-white/[0.04] text-white/50 hover:text-white/70 transition-colors">
<td className="py-3 text-white/30">
                            {moment(r.timestamp || r.created_date).format('MMM D, HH:mm')}
</td>
<td className="text-right py-3 text-amber-300/70 font-mono">
                            {r.body_temperature_f?.toFixed(1)}
</td>
<td className="text-right py-3 text-cyan-300/70 font-mono">
                            {r.sweat_level_rh?.toFixed(1)}
</td>
<td className="text-right py-3 font-mono">
                            {r.outside_temperature_f?.toFixed(1)}
</td>
<td className="text-right py-3 font-mono">
                            {r.outside_humidity_rh?.toFixed(1)}
</td>
<td className={`text-right py-3 font-mono ${tempDiff > 0 ? 'text-amber-400/60' : 'text-blue-400/60'}`}>
                            {tempDiff > 0 ? '+' : ''}{tempDiff.toFixed(1)}
</td>
<td className={`text-right py-3 font-mono ${humDiff > 0 ? 'text-cyan-400/60' : 'text-blue-400/60'}`}>
                            {humDiff > 0 ? '+' : ''}{humDiff.toFixed(1)}
</td>
</tr>
                      );
                    })}
</tbody>
</table>
</div>
</div>
</div>
        )}
</div>
<AddReadingModal
        open={showAddModal}
        onClose={() => setShowAddModal(false)}
        onSave={(data) => createMutation.mutate(data)}
        isSaving={createMutation.isPending}
      />
</div>
  );
}