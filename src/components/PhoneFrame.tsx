import { BG, DEEP } from '@/constants/colors'

export const PhoneFrame = ({ children }: { children: React.ReactNode }) => (
  <div style={{ width: 375, height: 812, borderRadius: 36, background: DEEP, padding: 8, position: 'relative', flexShrink: 0 }}>
    <div style={{ position: 'absolute', left: -3, top: 110, width: 3, height: 28, background: '#020344', borderRadius: '2px 0 0 2px' }} />
    <div style={{ position: 'absolute', left: -3, top: 150, width: 3, height: 48, background: '#020344', borderRadius: '2px 0 0 2px' }} />
    <div style={{ position: 'absolute', left: -3, top: 210, width: 3, height: 48, background: '#020344', borderRadius: '2px 0 0 2px' }} />
    <div style={{ position: 'absolute', right: -3, top: 150, width: 3, height: 68, background: '#020344', borderRadius: '0 2px 2px 0' }} />
    <div style={{ width: '100%', height: '100%', borderRadius: 30, overflow: 'hidden', background: BG, position: 'relative' }}>
      {children}
    </div>
  </div>
)
