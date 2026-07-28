import { Bell, Moon, Shield, Lock, Link } from 'lucide-react'

export const PROFILE_STATS = [
  { label: 'Friends', value: '248'  },
  { label: 'Groups',  value: '14'   },
  { label: 'Media',   value: '1.2k' },
]

export const PROFILE_SECTIONS = [
  {
    title: 'Account',
    rows: [
      { Icon: Bell,   label: 'Notifications',   sub: 'Mentions & messages' },
      { Icon: Moon,   label: 'Appearance',       sub: 'Dark mode, themes'   },
      { Icon: Link,   label: 'Linked devices',   sub: '2 active sessions'   },
    ],
  },
  {
    title: 'Privacy',
    rows: [
      { Icon: Shield, label: 'Privacy & safety', sub: 'Blocked, visibility' },
      { Icon: Lock,   label: 'Two-step verify',  sub: 'Enabled'             },
    ],
  },
]
