import { useState } from 'react'
import { CTAButton } from '@/components/ui/CTAButton'
import { BackButton } from '@/components/ui/BackButton'
import { CRIMSON, DEEP, BG } from '@/constants/colors'
import { ONBOARDING_SLIDES } from '@/data/onboarding'

export const OnboardingScreen = ({ onDone }: { onDone: () => void }) => {
  const [step, setStep] = useState(0)
  const [animating, setAnimating] = useState(false)
  const slide = ONBOARDING_SLIDES[step]
  const isLast = step === ONBOARDING_SLIDES.length - 1

  const next = () => {
    if (animating) return
    if (isLast) { onDone(); return }
    setAnimating(true)
    setTimeout(() => { setStep(s => s + 1); setAnimating(false) }, 240)
  }
  const back = () => {
    if (animating || step === 0) return
    setAnimating(true)
    setTimeout(() => { setStep(s => s - 1); setAnimating(false) }, 240)
  }

  return (
    <div style={{ width: '100%', height: '100%', background: BG, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      {/* Top row: back + skip */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px 20px 0' }}>
        <BackButton onClick={back} invisible={step === 0} />
        <button onClick={onDone} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: 15, fontWeight: 500, color: '#94A3B8', fontFamily: 'Zain, sans-serif', padding: '4px 2px' }}>Skip</button>
      </div>

      {/* Icon + text */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', opacity: animating ? 0 : 1, transform: animating ? 'translateY(12px)' : 'translateY(0)', transition: 'opacity 0.22s, transform 0.22s' }}>
        <div style={{ width: 120, height: 120, borderRadius: '50%', background: `${CRIMSON}14`, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 40 }}>
          <slide.Icon size={52} color={CRIMSON} strokeWidth={1.5} />
        </div>
        <h1 style={{ fontSize: 26, fontWeight: 800, color: DEEP, textAlign: 'center', margin: '0 0 14px', lineHeight: 1.25, letterSpacing: -0.4 }}>{slide.title}</h1>
        <p style={{ fontSize: 15, fontWeight: 300, color: '#64748B', textAlign: 'center', lineHeight: 1.65, margin: 0 }}>{slide.subtitle}</p>
      </div>

      {/* Dots + button */}
      <div style={{ padding: '0 24px 36px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 28 }}>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          {ONBOARDING_SLIDES.map((_, i) => (
            <div
              key={i}
              onClick={() => !animating && setStep(i)}
              style={{ width: i === step ? 24 : 8, height: 8, borderRadius: 4, background: i === step ? CRIMSON : '#D1D5DB', transition: 'width 0.3s ease, background 0.25s', cursor: 'pointer' }}
            />
          ))}
        </div>
        <CTAButton label={isLast ? 'Get Started' : 'Next'} onClick={next} />
      </div>
    </div>
  )
}
