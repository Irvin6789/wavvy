import { useState, useRef } from 'react'
import { Search, X, ChevronDown, Users, MessageCircle, UserPlus, Link2, Plus } from 'lucide-react'
import { CRIMSON, CRIMSON_LIGHT, DEEP, BG, FIELD_BG, FI } from '@/constants/colors'
import { NEW_CHAT_ITEMS } from '@/data/chats'

const AV = { bg: `${CRIMSON}14`, text: CRIMSON }

const glass: React.CSSProperties = {
  background: 'rgba(255,255,255,0.55)',
  backdropFilter: 'blur(8px)',
  WebkitBackdropFilter: 'blur(8px)',
}

// ── Empty state ────────────────────────────────────────────────────────────
const EmptyState = () => (
  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', padding: '0 40px', animation: 'fadeIn 0.3s ease' }}>
    <svg width="120" height="115" viewBox="0 0 120 115" fill="none" style={{ marginBottom: 18 }}>
      {/* Shadow */}
      <ellipse cx="60" cy="108" rx="32" ry="5" fill={`${CRIMSON}12`} style={{ animation: 'magShadow 2.6s ease-in-out infinite', transformOrigin: '60px 108px' }} />
      {/* Whole magnifier floats */}
      <g style={{ animation: 'magFloat 2.6s ease-in-out infinite', transformOrigin: '60px 55px' }}>
        {/* Lens */}
        <circle cx="52" cy="48" r="26" fill="white" stroke={`${CRIMSON}25`} strokeWidth="2" />
        <circle cx="52" cy="48" r="18" fill={`${CRIMSON}08`} />
        {/* Cross pulses */}
        <line x1="44" y1="48" x2="60" y2="48" stroke={`${CRIMSON}55`} strokeWidth="2.5" strokeLinecap="round" style={{ animation: 'crossPulse 2s ease-in-out infinite' }} />
        <line x1="52" y1="40" x2="52" y2="56" stroke={`${CRIMSON}55`} strokeWidth="2.5" strokeLinecap="round" style={{ animation: 'crossPulse 2s ease-in-out infinite' }} />
        {/* Handle swings from lens center */}
        <g style={{ animation: 'magSwing 2.6s ease-in-out infinite', transformOrigin: '52px 48px' }}>
          <line x1="71" y1="67" x2="84" y2="82" stroke={CRIMSON} strokeWidth="5" strokeLinecap="round" />
        </g>
      </g>
    </svg>
    <div style={{ fontSize: 17, fontWeight: 800, color: DEEP, textAlign: 'center', marginBottom: 8 }}>No results found</div>
    <div style={{ fontSize: 13, color: '#94A3B8', fontWeight: 300, textAlign: 'center', lineHeight: 1.6 }}>
      {'Try a different name or\nuse the + button to start fresh.'}
    </div>
  </div>
)

// ── Shared popup wrapper ───────────────────────────────────────────────────
const Popup = ({ onClose, children }: { onClose: () => void; children: React.ReactNode }) => (
  <div
    style={{ position: 'absolute', inset: 0, zIndex: 50, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '0 24px', backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)', background: 'rgba(2,2,58,0.28)', animation: 'fadeIn 0.22s ease' }}
    onClick={onClose}
  >
    <div
      onClick={e => e.stopPropagation()}
      style={{ width: '100%', background: 'rgba(255,255,255,0.92)', borderRadius: 28, padding: '28px 24px 24px', boxShadow: '0 24px 60px rgba(0,95,146,0.18), 0 2px 8px rgba(0,0,0,0.06)', animation: 'popIn 0.28s cubic-bezier(0.34,1.3,0.64,1) both', position: 'relative' }}
    >
      {children}
    </div>
  </div>
)

// ── New Person modal ───────────────────────────────────────────────────────
const NewPersonModal = ({ onClose }: { onClose: () => void }) => {
  const [username, setUsername] = useState('')
  const [focused, setFocused] = useState(false)
  return (
    <Popup onClose={onClose}>
      {/* Close button */}
      <button onClick={onClose} style={{ position: 'absolute', top: 16, right: 16, width: 30, height: 30, borderRadius: '50%', background: '#F0F1F5', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <X size={15} color="#94A3B8" strokeWidth={2.5} />
      </button>

      {/* Icon */}
      <div style={{ width: 60, height: 60, borderRadius: 20, background: `${CRIMSON}12`, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
        <MessageCircle size={28} color={CRIMSON} strokeWidth={1.8} />
      </div>

      <h3 style={{ fontSize: 20, fontWeight: 800, color: DEEP, textAlign: 'center', margin: '0 0 6px', letterSpacing: -0.3 }}>New Conversation</h3>
      <p style={{ fontSize: 13, color: '#94A3B8', fontWeight: 300, textAlign: 'center', margin: '0 0 20px', lineHeight: 1.5 }}>Enter the username of who you want to chat with</p>

      <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: FIELD_BG, borderRadius: 14, padding: '13px 16px', border: focused ? `1.5px solid ${CRIMSON}` : '1.5px solid transparent', transition: 'border 0.2s', marginBottom: 14 }}>
        <span style={{ fontSize: 16, color: FI, fontWeight: 500 }}>@</span>
        <input
          autoFocus
          value={username}
          onChange={e => setUsername(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholder="username"
          style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 15, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 500 }}
        />
      </div>

      <div style={{ display: 'flex', gap: 10 }}>
        <button onClick={onClose} style={{ flex: 1, padding: '13px 0', borderRadius: 14, border: '1.5px solid #E2E8F0', background: 'transparent', fontSize: 14, fontWeight: 600, color: '#94A3B8', fontFamily: 'Zain, sans-serif', cursor: 'pointer' }}>
          Cancel
        </button>
        <button style={{ flex: 2, padding: '13px 0', borderRadius: 14, border: 'none', background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, color: 'white', fontSize: 14, fontWeight: 700, fontFamily: 'Zain, sans-serif', cursor: 'pointer', opacity: username.trim() ? 1 : 0.45, transition: 'opacity 0.2s' }}>
          Start Chat
        </button>
      </div>
    </Popup>
  )
}

// ── Join Group modal ───────────────────────────────────────────────────────
const JoinGroupModal = ({ onClose }: { onClose: () => void }) => {
  const [link, setLink] = useState('')
  const [focused, setFocused] = useState(false)
  return (
    <Popup onClose={onClose}>
      {/* Close button */}
      <button onClick={onClose} style={{ position: 'absolute', top: 16, right: 16, width: 30, height: 30, borderRadius: '50%', background: '#F0F1F5', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <X size={15} color="#94A3B8" strokeWidth={2.5} />
      </button>

      {/* Icon */}
      <div style={{ width: 60, height: 60, borderRadius: 20, background: `${CRIMSON}12`, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
        <Link2 size={28} color={CRIMSON} strokeWidth={1.8} />
      </div>

      <h3 style={{ fontSize: 20, fontWeight: 800, color: DEEP, textAlign: 'center', margin: '0 0 6px', letterSpacing: -0.3 }}>Join by Link</h3>
      <p style={{ fontSize: 13, color: '#94A3B8', fontWeight: 300, textAlign: 'center', margin: '0 0 20px', lineHeight: 1.5 }}>Paste an invite link to join a group instantly</p>

      <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: FIELD_BG, borderRadius: 14, padding: '13px 16px', border: focused ? `1.5px solid ${CRIMSON}` : '1.5px solid transparent', transition: 'border 0.2s', marginBottom: 14 }}>
        <Link2 size={16} color={FI} strokeWidth={1.8} />
        <input
          autoFocus
          value={link}
          onChange={e => setLink(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholder="wavvy.app/join/..."
          style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 15, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 500 }}
        />
        {link.trim() && (
          <button onClick={() => setLink('')} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 2, display: 'flex', alignItems: 'center' }}>
            <X size={15} color="#94A3B8" strokeWidth={2} />
          </button>
        )}
      </div>

      <div style={{ display: 'flex', gap: 10 }}>
        <button onClick={onClose} style={{ flex: 1, padding: '13px 0', borderRadius: 14, border: '1.5px solid #E2E8F0', background: 'transparent', fontSize: 14, fontWeight: 600, color: '#94A3B8', fontFamily: 'Zain, sans-serif', cursor: 'pointer' }}>
          Cancel
        </button>
        <button style={{ flex: 2, padding: '13px 0', borderRadius: 14, border: 'none', background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, color: 'white', fontSize: 14, fontWeight: 700, fontFamily: 'Zain, sans-serif', cursor: 'pointer', opacity: link.trim() ? 1 : 0.45, transition: 'opacity 0.2s' }}>
          Join Group
        </button>
      </div>
    </Popup>
  )
}

const FAB_OPTS = [
  { label: 'Join by Link', Icon: Link2,    modal: 'join'   as const },
  { label: 'New Person',   Icon: UserPlus, modal: 'person' as const },
]

// ── Main screen ────────────────────────────────────────────────────────────
export const NewChatScreen = ({ onBack }: { onBack: () => void }) => {
  const [searching, setSearching] = useState(false)
  const [query, setQuery] = useState('')
  const [closing, setClosing] = useState(false)
  const [fabOpen, setFabOpen] = useState(false)
  const [modal, setModal] = useState<'person' | 'join' | null>(null)
  const searchRef = useRef<HTMLInputElement>(null)

  const handleBack = () => { setClosing(true); setTimeout(onBack, 280) }
  const openSearch = () => { setSearching(true); setTimeout(() => searchRef.current?.focus(), 50) }
  const closeSearch = () => { setSearching(false); setQuery('') }

  const items = NEW_CHAT_ITEMS.filter(c =>
    query === '' || c.name.toLowerCase().includes(query.toLowerCase())
  )

  return (
    <div style={{ width: '100%', height: '100%', background: BG, position: 'relative', overflow: 'hidden', animation: `${closing ? 'slideOutToBottom' : 'slideInFromBottom'} 0.30s cubic-bezier(0.4,0,0.2,1) both` }}>
      {/* App bar */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10, ...glass, display: 'flex', alignItems: 'center', height: 62, padding: '0 16px', borderRadius: '0 0 20px 20px', borderBottom: '1px solid rgba(0,0,0,0.06)' }}>
        {searching ? (
          <div style={{ display: 'flex', alignItems: 'center', flex: 1, gap: 10, animation: 'fadeIn 0.2s ease' }}>
            <Search size={18} color={CRIMSON} strokeWidth={2} />
            <input ref={searchRef} value={query} onChange={e => setQuery(e.target.value)} placeholder="Search people & groups…" style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 16, fontFamily: 'inherit', color: DEEP, fontWeight: 500 }} />
            <button onClick={closeSearch} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 6, display: 'flex', alignItems: 'center', borderRadius: 8 }}>
              <X size={19} color="#888" strokeWidth={2} />
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', flex: 1, animation: 'fadeIn 0.2s ease' }}>
            <button onClick={handleBack} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10, marginLeft: -4, marginRight: 2 }}>
              <ChevronDown size={22} color={DEEP} strokeWidth={2.5} />
            </button>
            <span style={{ fontSize: 22, fontWeight: 800, color: DEEP, letterSpacing: -0.5, flex: 1 }}>New Chat</span>
            <button onClick={openSearch} style={{ background: '#55555510', border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
              <Search size={19} color="#555" strokeWidth={2} />
            </button>
          </div>
        )}
      </div>

      {/* List or empty state */}
      <div style={{ position: 'absolute', inset: 0, overflowY: 'auto', paddingTop: 64, paddingBottom: 100 }}>
        {items.length === 0
          ? <EmptyState />
          : items.map((c, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '11px 20px', borderBottom: i < items.length - 1 ? '1px solid #F4F6F9' : 'none', cursor: 'pointer' }}>
            <div style={{ position: 'relative', flexShrink: 0 }}>
              <div style={{ width: 50, height: 50, borderRadius: 16, background: AV.bg, color: AV.text, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 700, fontFamily: 'Zain, sans-serif' }}>
                {c.initials}
              </div>
              {c.group && (
                <div style={{ position: 'absolute', bottom: -3, right: -3, background: CRIMSON, borderRadius: 6, padding: '1px 4px', border: '2px solid white' }}>
                  <Users size={9} color="white" strokeWidth={2.5} />
                </div>
              )}
              {c.online && !c.group && <div style={{ position: 'absolute', bottom: 1, right: 1, width: 11, height: 11, borderRadius: '50%', background: '#22C55E', border: '2px solid white' }} />}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <span style={{ fontWeight: 700, fontSize: 15, color: DEEP, display: 'block', marginBottom: 3 }}>{c.name}</span>
              {c.group && (
                <span style={{ fontSize: 12, color: '#94A3B8', fontWeight: 300 }}>{c.msg}</span>
              )}
              {!c.group && c.online && (
                <span style={{ fontSize: 12, color: '#22C55E', fontWeight: 500 }}>Online</span>
              )}
              {!c.group && !c.online && (
                <span style={{ fontSize: 12, color: '#B0B8C5', fontWeight: 300 }}>Offline</span>
              )}
            </div>
            <div style={{ width: 34, height: 34, borderRadius: 11, background: `${CRIMSON}12`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              {c.group
                ? <UserPlus size={16} color={CRIMSON} strokeWidth={2} />
                : <MessageCircle size={16} color={CRIMSON} strokeWidth={2} />
              }
            </div>
          </div>
        ))}
      </div>

      {/* FAB */}
      <div style={{ position: 'absolute', bottom: 22, right: 22, display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 12, zIndex: 20 }}>
        {FAB_OPTS.map(({ label, Icon, modal: m }, i) => (
          <div key={i} onClick={() => { setFabOpen(false); setModal(m) }} style={{ display: 'flex', alignItems: 'center', gap: 10, opacity: fabOpen ? 1 : 0, transform: fabOpen ? 'translateY(0) scale(1)' : 'translateY(20px) scale(0.85)', transition: `opacity 0.25s ${i * 0.07}s ease, transform 0.28s ${i * 0.07}s cubic-bezier(0.34,1.4,0.64,1)`, pointerEvents: fabOpen ? 'auto' : 'none', cursor: 'pointer' }}>
            <span style={{ background: 'white', borderRadius: 10, padding: '5px 14px', fontSize: 13, fontWeight: 600, color: DEEP, fontFamily: 'Zain, sans-serif', border: '1px solid #EBEBF0' }}>{label}</span>
            <div style={{ width: 44, height: 44, borderRadius: '50%', background: BG, border: `1.5px solid ${CRIMSON}30`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon size={20} color={CRIMSON} strokeWidth={1.8} />
            </div>
          </div>
        ))}
        <button onClick={() => setFabOpen(v => !v)} style={{ width: 54, height: 54, borderRadius: '50%', background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'transform 0.3s cubic-bezier(0.34,1.4,0.64,1)', transform: fabOpen ? 'rotate(45deg)' : 'rotate(0deg)' }}>
          <Plus size={24} color="white" strokeWidth={2.5} />
        </button>
      </div>

      {/* FAB backdrop */}
      {fabOpen && <div onClick={() => setFabOpen(false)} style={{ position: 'absolute', inset: 0, zIndex: 15 }} />}

      {/* Modals */}
      {modal === 'person' && <NewPersonModal onClose={() => setModal(null)} />}
      {modal === 'join'   && <JoinGroupModal onClose={() => setModal(null)} />}
    </div>
  )
}
