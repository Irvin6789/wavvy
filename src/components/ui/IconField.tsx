import { useState } from 'react'
import { Lock, Eye, EyeOff } from 'lucide-react'
import { CRIMSON, FIELD_BG, FI } from '@/constants/colors'

export type IconFieldProps = {
  icon: React.ReactNode
  type?: string
  value: string
  onChange: (v: string) => void
  placeholder: string
  focused: boolean
  onFocus: () => void
  onBlur: () => void
  rightSlot?: React.ReactNode
  extraStyle?: React.CSSProperties
}

export const IconField = ({ icon, type = 'text', value, onChange, placeholder, focused, onFocus, onBlur, rightSlot, extraStyle }: IconFieldProps) => (
  <div style={{ display: 'flex', alignItems: 'center', background: FIELD_BG, borderRadius: 12, border: focused ? `1.5px solid ${CRIMSON}` : '1.5px solid transparent', transition: 'border-color 0.2s', ...extraStyle }}>
    <div style={{ paddingLeft: 12, display: 'flex', alignItems: 'center', flexShrink: 0 }}>{icon}</div>
    <input
      type={type}
      value={value}
      onChange={e => onChange(e.target.value)}
      onFocus={onFocus}
      onBlur={onBlur}
      placeholder={placeholder}
      style={{ flex: 1, padding: '10px 10px', border: 'none', background: 'transparent', fontSize: 14, fontFamily: 'Zain, sans-serif', fontWeight: 400, color: '#1A1A2E', outline: 'none', minWidth: 0 }}
    />
    {rightSlot && <div style={{ paddingRight: 10, display: 'flex', alignItems: 'center' }}>{rightSlot}</div>}
  </div>
)

export const PasswordField = ({ value, onChange, placeholder, focused, onFocus, onBlur, icon }: Omit<IconFieldProps, 'type' | 'rightSlot' | 'icon'> & { icon?: React.ReactNode }) => {
  const [show, setShow] = useState(false)
  return (
    <IconField
      icon={icon ?? <Lock size={16} color={FI} strokeWidth={1.8} />}
      type={show ? 'text' : 'password'}
      value={value}
      onChange={onChange}
      placeholder={placeholder}
      focused={focused}
      onFocus={onFocus}
      onBlur={onBlur}
      rightSlot={
        <button onClick={() => setShow(v => !v)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 2, display: 'flex', alignItems: 'center' }}>
          {show ? <Eye size={16} color={FI} strokeWidth={2} /> : <EyeOff size={16} color={FI} strokeWidth={2} />}
        </button>
      }
    />
  )
}
