import { ChevronLeft } from 'lucide-react'
import { DEEP } from '@/constants/colors'

type Props = { onClick: () => void; invisible?: boolean }

export const BackButton = ({ onClick, invisible }: Props) => (
  <button
    onClick={onClick}
    style={{ background: 'none', border: 'none', cursor: invisible ? 'default' : 'pointer', padding: 0, display: 'flex', alignItems: 'center', opacity: invisible ? 0 : 1, transition: 'opacity 0.2s', pointerEvents: invisible ? 'none' : 'auto' }}
  >
    <ChevronLeft size={20} color={DEEP} strokeWidth={2.5} />
  </button>
)
