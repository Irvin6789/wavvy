import { useState } from 'react'
import { PhoneFrame } from '@/components/PhoneFrame'
import { SplashScreen } from '@/screens/SplashScreen'
import { OnboardingScreen } from '@/screens/OnboardingScreen'
import { SignInScreen } from '@/screens/auth/SignInScreen'
import { SignUpScreen } from '@/screens/auth/SignUpScreen'
import { HomeScreen } from '@/screens/home/HomeScreen'

type Screen = 'splash' | 'onboarding' | 'signin' | 'signup' | 'home'

const slideStyle = (dir: 'left' | 'right' | null): React.CSSProperties => ({
  width: '100%',
  height: '100%',
  animation: dir === 'left'
    ? 'authSlideLeft 0.3s cubic-bezier(0.4,0,0.2,1) both'
    : dir === 'right'
    ? 'authSlideRight 0.3s cubic-bezier(0.4,0,0.2,1) both'
    : 'none',
})

export default function App() {
  const [screen, setScreen] = useState<Screen>('splash')
  const [authAnim, setAuthAnim] = useState<'left' | 'right' | null>(null)

  const goTo = (next: Screen, dir: 'left' | 'right' | null = null) => {
    setAuthAnim(dir)
    setScreen(next)
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#F0F1F5' }}>
      <PhoneFrame>
        {screen === 'splash' && (
          <SplashScreen onDone={() => goTo('onboarding')} />
        )}

        {screen === 'onboarding' && (
          <OnboardingScreen onDone={() => goTo('signin', 'left')} />
        )}

        {(screen === 'signin' || screen === 'signup') && (
          <div key={screen} style={slideStyle(authAnim)}>
            {screen === 'signin' && (
              <SignInScreen
                onSignUp={() => goTo('signup', 'left')}
                onHome={() => goTo('home')}
              />
            )}
            {screen === 'signup' && (
              <SignUpScreen
                onBack={() => goTo('signin', 'right')}
                onHome={() => goTo('home')}
              />
            )}
          </div>
        )}

        {screen === 'home' && (
          <HomeScreen />
        )}
      </PhoneFrame>
    </div>
  )
}
