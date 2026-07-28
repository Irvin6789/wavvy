import { useEffect } from 'react'
import { AppIcon } from '@/components/AppIcon'
import { CRIMSON, DEEP, BG } from '@/constants/colors'

export const SplashScreen = ({ onDone }: { onDone: () => void }) => {
  useEffect(() => { const t = setTimeout(onDone, 2600); return () => clearTimeout(t) }, [onDone])
  return (
    <div style={{ width: '100%', height: '100%', background: BG, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', position: 'relative', overflow: 'hidden' }}>
      <div style={{ animation: 'popIn 0.65s cubic-bezier(0.34,1.56,0.64,1) both', marginBottom: 24 }}>
        <AppIcon size={80} />
      </div>
      <div style={{ textAlign: 'center', animation: 'fadeUp 0.7s 0.25s both' }}>
        <div style={{ fontSize: 48, fontWeight: 800, color: DEEP, letterSpacing: -1.5, lineHeight: 1 }}>Wavvy</div>
        <div style={{ fontSize: 16, fontWeight: 300, color: '#94A3B8', marginTop: 8, letterSpacing: 3 }}>CHAT DIFFERENTLY</div>
      </div>
      {[
        { top: '18%', left: '14%', size: 9,  color: `${CRIMSON}30`, delay: '0s',   dur: '3s'   },
        { top: '30%', right: '12%', size: 13, color: `${DEEP}20`,   delay: '1s',   dur: '4s'   },
        { bottom: '28%', left: '16%', size: 7, color: `${CRIMSON}20`, delay: '0.5s', dur: '3.5s' },
        { bottom: '20%', right: '18%', size: 10, color: `${DEEP}15`, delay: '1.5s', dur: '2.8s' },
      ].map((d, i) => (
        <div key={i} style={{ position: 'absolute', top: d.top, bottom: d.bottom, left: d.left, right: d.right, animation: `float ${d.dur} ${d.delay} ease-in-out infinite` }}>
          <div style={{ width: d.size, height: d.size, borderRadius: '50%', background: d.color }} />
        </div>
      ))}
      <div style={{ display: 'flex', gap: 7, marginTop: 52, animation: 'fadeUp 0.7s 0.5s both' }}>
        {[0, 1, 2].map(i => (
          <div key={i} style={{ width: 7, height: 7, borderRadius: '50%', background: CRIMSON, opacity: 0.35, animation: `pulse 1.2s ${i * 0.2}s ease-in-out infinite` }} />
        ))}
      </div>
    </div>
  )
}
