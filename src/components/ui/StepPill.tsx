import { CRIMSON } from '@/constants/colors'

export const StepPill = ({ label }: { label: string }) => (
  <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: `${CRIMSON}15`, color: CRIMSON, borderRadius: 20, padding: '3px 11px', fontSize: 11, fontWeight: 700, letterSpacing: 1.2, textTransform: 'uppercase' as const }}>
    <div style={{ width: 5, height: 5, borderRadius: '50%', background: CRIMSON }} />
    {label}
  </div>
)
