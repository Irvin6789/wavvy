import { CRIMSON, CRIMSON_LIGHT, DEEP } from '@/constants/colors'

export const AppIcon = ({ size = 56 }: { size?: number }) => {
  const s = size / 56
  return (
    <svg width={size} height={size} viewBox="0 0 56 56" fill="none">
      <defs>
        <linearGradient id="wg1" x1="0" y1="0" x2="56" y2="0" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stopColor={DEEP} /><stop offset="100%" stopColor={CRIMSON} />
        </linearGradient>
        <linearGradient id="wg2" x1="0" y1="0" x2="56" y2="0" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stopColor={CRIMSON} /><stop offset="60%" stopColor={CRIMSON_LIGHT} /><stop offset="100%" stopColor={DEEP} />
        </linearGradient>
        <linearGradient id="wg3" x1="0" y1="0" x2="56" y2="0" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stopColor={DEEP} /><stop offset="100%" stopColor={CRIMSON} />
        </linearGradient>
      </defs>
      <path d="M6 18 C12 11,20 11,28 18 C36 25,44 25,50 18" stroke="url(#wg1)" strokeWidth={4*s} strokeLinecap="round" fill="none" opacity="0.55" />
      <path d="M6 28 C12 21,20 21,28 28 C36 35,44 35,50 28" stroke="url(#wg2)" strokeWidth={5.5*s} strokeLinecap="round" fill="none" />
      <path d="M6 38 C12 31,20 31,28 38 C36 45,44 45,50 38" stroke="url(#wg3)" strokeWidth={4*s} strokeLinecap="round" fill="none" opacity="0.7" />
    </svg>
  )
}
