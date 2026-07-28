import { useState } from 'react'
import { AtSign } from 'lucide-react'
import { AppIcon } from '@/components/AppIcon'
import { CTAButton } from '@/components/ui/CTAButton'
import { IconField, PasswordField } from '@/components/ui/IconField'
import { CRIMSON, DEEP, BG, FI } from '@/constants/colors'

type Props = { onSignUp: () => void; onHome: () => void }

export const SignInScreen = ({ onSignUp, onHome }: Props) => {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [focused, setFocused] = useState<string | null>(null)

  return (
    <div style={{ width: '100%', height: '100%', background: BG, display: 'flex', flexDirection: 'column', justifyContent: 'center', overflow: 'hidden' }}>
      <div style={{ padding: '0 24px', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
        <AppIcon size={68} />
        <h1 style={{ fontSize: 28, fontWeight: 800, color: DEEP, margin: '12px 0 4px', lineHeight: 1.2 }}>Welcome back</h1>
        <p style={{ fontSize: 15, fontWeight: 300, color: '#64748B', margin: 0 }}>Sign in to continue to Wavvy</p>
      </div>

      <div style={{ padding: '28px 24px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <IconField
          icon={<AtSign size={16} color={FI} strokeWidth={1.8} />}
          value={username}
          onChange={setUsername}
          placeholder="Username"
          focused={focused === 'username'}
          onFocus={() => setFocused('username')}
          onBlur={() => setFocused(null)}
        />
        <PasswordField
          value={password}
          onChange={setPassword}
          placeholder="Password"
          focused={focused === 'password'}
          onFocus={() => setFocused('password')}
          onBlur={() => setFocused(null)}
        />
        <div style={{ textAlign: 'right' }}>
          <span style={{ fontSize: 13, color: CRIMSON, fontWeight: 600, cursor: 'pointer' }}>Forgot password?</span>
        </div>
        <div style={{ marginTop: 24 }}>
          <CTAButton label="Sign In" onClick={onHome} />
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ flex: 1, height: 1, background: '#E2E8F0' }} />
          <span style={{ fontSize: 12, color: '#94A3B8' }}>OR</span>
          <div style={{ flex: 1, height: 1, background: '#E2E8F0' }} />
        </div>
        <div style={{ textAlign: 'center' }}>
          <span style={{ fontSize: 14, color: '#64748B', fontWeight: 300 }}>{"Don't have an account? "}</span>
          <span onClick={onSignUp} style={{ fontSize: 14, color: CRIMSON, fontWeight: 700, cursor: 'pointer' }}>Create one</span>
        </div>
      </div>
    </div>
  )
}
