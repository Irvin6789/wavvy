import { CRIMSON, CRIMSON_LIGHT } from '@/constants/colors'

type Props = { label: string; onClick?: () => void }

export const CTAButton = ({ label, onClick }: Props) => (
  <button
    onClick={onClick}
    style={{ width: '100%', padding: '10px 18px', background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, border: 'none', borderRadius: 12, color: 'white', fontSize: 15, fontWeight: 700, fontFamily: 'Zain, sans-serif', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, transition: 'opacity 0.15s' }}
    onMouseEnter={e => { (e.currentTarget as HTMLButtonElement).style.opacity = '0.88' }}
    onMouseLeave={e => { (e.currentTarget as HTMLButtonElement).style.opacity = '1' }}
  >
    {label}
  </button>
)
