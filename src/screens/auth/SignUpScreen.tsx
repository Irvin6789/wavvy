import { useState } from 'react'
import { Mail, Lock, User, AtSign, ShieldCheck, Cake } from 'lucide-react'
import { CTAButton } from '@/components/ui/CTAButton'
import { BackButton } from '@/components/ui/BackButton'
import { StepPill } from '@/components/ui/StepPill'
import { IconField, PasswordField } from '@/components/ui/IconField'
import { CRIMSON, CRIMSON_LIGHT, DEEP, BG, FIELD_BG, FI } from '@/constants/colors'

const SIGNUP_STEPS = [
  { label: 'Account',     title: 'Create your\naccount',  subtitle: 'Start with your email and birthday' },
  { label: 'Credentials', title: 'Choose your\nidentity', subtitle: 'Pick a username and set a password' },
  { label: 'Profile',     title: "You're almost\nthere",  subtitle: "How will your friends see you?"      },
]

const StepIllustration = ({ step }: { step: number }) => {
  const configs = [
    { bg: `${CRIMSON}12`, icon: <Mail size={38} color={CRIMSON} strokeWidth={1.5} /> },
    { bg: `${DEEP}12`,    icon: <Lock size={38} color={DEEP}    strokeWidth={1.5} /> },
    { bg: `${CRIMSON}12`, icon: <User size={38} color={CRIMSON} strokeWidth={1.5} /> },
  ]
  const c = configs[step]
  return (
    <div style={{ width: 80, height: 80, borderRadius: 24, background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {c.icon}
    </div>
  )
}

type Props = { onBack: () => void; onHome: () => void }

export const SignUpScreen = ({ onBack, onHome }: Props) => {
  const [step, setStep] = useState(0)
  const [focused, setFocused] = useState<string | null>(null)
  const [email, setEmail] = useState('')
  const [birthday, setBirthday] = useState('')
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [displayName, setDisplayName] = useState('')

  const isFirst = step === 0
  const isLast  = step === SIGNUP_STEPS.length - 1
  const current = SIGNUP_STEPS[step]

  const goBack = () => { if (isFirst) { onBack(); return }; setStep(s => s - 1) }
  const goNext = () => { if (!isLast) { setStep(s => s + 1); return }; onHome() }

  const foc = (k: string) => focused === k
  const fo  = (k: string) => () => setFocused(k)
  const fb  = () => setFocused(null)

  return (
    <div style={{ width: '100%', height: '100%', background: BG, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      {/* Top bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 20px 0' }}>
        <BackButton onClick={goBack} />
        <div style={{ display: 'flex', gap: 5 }}>
          {SIGNUP_STEPS.map((_, i) => (
            <div key={i} style={{ width: i === step ? 20 : 6, height: 6, borderRadius: 3, background: i <= step ? CRIMSON : '#E2E8F0', transition: 'width 0.35s, background 0.3s' }} />
          ))}
        </div>
      </div>

      {/* Hero */}
      <div style={{ padding: '24px 24px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <StepIllustration step={step} />
        <div>
          <StepPill label={current.label} />
          <h2 style={{ fontSize: 26, fontWeight: 800, color: DEEP, margin: '8px 0 4px', lineHeight: 1.2, whiteSpace: 'pre-line' }}>{current.title}</h2>
          <p style={{ fontSize: 14, fontWeight: 300, color: '#64748B', margin: 0 }}>{current.subtitle}</p>
        </div>
      </div>

      {/* Fields */}
      <div style={{ flex: 1, padding: '22px 24px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {step === 0 && <>
          <IconField icon={<Mail size={16} color={FI} strokeWidth={1.8} />} type="email" value={email} onChange={setEmail} placeholder="Email address" focused={foc('email')} onFocus={fo('email')} onBlur={fb} />
          <IconField icon={<Cake size={16} color={FI} strokeWidth={1.8} />} type="date" value={birthday} onChange={setBirthday} placeholder="Birthday" focused={foc('birthday')} onFocus={fo('birthday')} onBlur={fb} extraStyle={{ colorScheme: 'light' } as React.CSSProperties} />
        </>}
        {step === 1 && <>
          <IconField icon={<AtSign size={16} color={FI} strokeWidth={1.8} />} value={username} onChange={setUsername} placeholder="Username" focused={foc('username')} onFocus={fo('username')} onBlur={fb} />
          <PasswordField icon={<Lock size={16} color={FI} strokeWidth={1.8} />} value={password} onChange={setPassword} placeholder="Password" focused={foc('password')} onFocus={fo('password')} onBlur={fb} />
          <PasswordField icon={<ShieldCheck size={16} color={FI} strokeWidth={1.8} />} value={confirmPassword} onChange={setConfirmPassword} placeholder="Confirm password" focused={foc('confirm')} onFocus={fo('confirm')} onBlur={fb} />
        </>}
        {step === 2 && <>
          <IconField icon={<User size={16} color={FI} strokeWidth={1.8} />} value={displayName} onChange={setDisplayName} placeholder="Display name" focused={foc('displayName')} onFocus={fo('displayName')} onBlur={fb} />
          {displayName.trim() && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: FIELD_BG, borderRadius: 12, padding: '10px 14px', marginTop: 2 }}>
              <div style={{ width: 36, height: 36, borderRadius: '50%', background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontWeight: 700, fontSize: 14, flexShrink: 0 }}>
                {displayName.trim().split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()}
              </div>
              <div>
                <div style={{ fontSize: 14, fontWeight: 700, color: DEEP }}>{displayName.trim()}</div>
                <div style={{ fontSize: 12, color: '#94A3B8', fontWeight: 300 }}>Preview</div>
              </div>
            </div>
          )}
          <p style={{ fontSize: 12, color: '#94A3B8', margin: '4px 0 0', fontWeight: 300 }}>You can change this later in settings.</p>
        </>}
      </div>

      {/* CTA */}
      <div style={{ padding: '16px 24px 28px' }}>
        <CTAButton label={isLast ? 'Create Account' : 'Continue'} onClick={goNext} />
      </div>
    </div>
  )
}
