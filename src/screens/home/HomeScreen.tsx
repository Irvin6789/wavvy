import { useState, useRef } from 'react'
import { Search, X, MoreVertical, Plus, Users, MessageCircle, Compass, CircleUser, RotateCcw, Pencil, SlidersHorizontal } from 'lucide-react'
import { ProfileScreen } from './ProfileScreen'
import { NewChatScreen } from './NewChatScreen'
import { NewGroupScreen } from './NewGroupScreen'
import { DirectChatScreen } from './DirectChatScreen'
import { GroupChatScreen } from './GroupChatScreen'
import { CRIMSON, CRIMSON_LIGHT, DEEP, BG } from '@/constants/colors'
import { CHATS, type ChatItem } from '@/data/chats'

const EmptyChats = ({ filter }: { filter: string }) => (
  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', padding: '0 40px', animation: 'fadeIn 0.4s ease' }}>
    <svg width="130" height="120" viewBox="0 0 130 120" fill="none" style={{ marginBottom: 20 }}>
      {/* Shadow */}
      <ellipse cx="65" cy="108" rx="42" ry="7" fill={`${CRIMSON}12`} style={{ animation: 'shadowPulse 2.8s ease-in-out infinite' }} />
      {/* Back bubble — floats down slightly */}
      <g style={{ animation: 'emptyFloatBack 2.8s ease-in-out infinite', transformOrigin: '69px 44px' }}>
        <rect x="34" y="18" width="70" height="52" rx="18" fill={`${CRIMSON}0C`} />
        <rect x="34" y="18" width="70" height="52" rx="18" stroke={`${CRIMSON}22`} strokeWidth="1.5" />
        <path d="M48 70 L42 82 L58 72" fill={`${CRIMSON}0C`} stroke={`${CRIMSON}22`} strokeWidth="1.5" strokeLinejoin="round" />
      </g>
      {/* Front bubble — floats up */}
      <g style={{ animation: 'emptyFloat 2.8s ease-in-out infinite', transformOrigin: '55px 34px' }}>
        <rect x="22" y="10" width="66" height="48" rx="16" fill="white" />
        <rect x="22" y="10" width="66" height="48" rx="16" stroke={`${CRIMSON}30`} strokeWidth="1.5" />
        <path d="M80 58 L87 70 L72 60" fill="white" stroke={`${CRIMSON}30`} strokeWidth="1.5" strokeLinejoin="round" />
        {/* Animated dots */}
        <circle cx="44" cy="34" r="4" fill={`${CRIMSON}50`} style={{ animation: 'dotPop1 1.6s ease-in-out infinite', transformOrigin: '44px 34px' }} />
        <circle cx="55" cy="34" r="4" fill={`${CRIMSON}80`} style={{ animation: 'dotPop2 1.6s ease-in-out infinite', transformOrigin: '55px 34px' }} />
        <circle cx="66" cy="34" r="4" fill={CRIMSON}       style={{ animation: 'dotPop3 1.6s ease-in-out infinite', transformOrigin: '66px 34px' }} />
      </g>
    </svg>
    <div style={{ fontSize: 18, fontWeight: 800, color: DEEP, letterSpacing: -0.3, textAlign: 'center', marginBottom: 8 }}>
      {filter === 'Unread' ? 'All caught up!' : filter === 'Groups' ? 'No groups yet' : filter === 'Online' ? 'Nobody online' : 'No conversations'}
    </div>
    <div style={{ fontSize: 13, color: '#94A3B8', fontWeight: 300, textAlign: 'center', lineHeight: 1.6 }}>
      {filter === 'Unread'
        ? "You've read all your messages.\nGreat job staying on top of things."
        : filter === 'Groups'
        ? 'Tap + to create a new group\nand start chatting together.'
        : filter === 'Online'
        ? 'None of your contacts\nare online right now.'
        : 'Start a new conversation\nby tapping the + button.'}
    </div>
  </div>
)

const EmptyDiscover = () => (
  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', padding: '0 40px', animation: 'fadeIn 0.4s ease' }}>
    <svg width="130" height="125" viewBox="0 0 130 125" fill="none" style={{ marginBottom: 20 }}>
      <ellipse cx="65" cy="112" rx="38" ry="6" fill={`${CRIMSON}0E`} />
      {/* Body floats */}
      <g style={{ animation: 'compassFloat 3s ease-in-out infinite', transformOrigin: '65px 58px' }}>
        <circle cx="65" cy="58" r="36" fill="white" stroke={`${CRIMSON}25`} strokeWidth="1.5" />
        <circle cx="65" cy="58" r="28" fill={`${CRIMSON}08`} stroke={`${CRIMSON}18`} strokeWidth="1" />
        {/* Needle swings */}
        <g style={{ animation: 'compassLoop 2.4s ease-in-out infinite', transformOrigin: '65px 58px' }}>
          <path d="M65 58 L58 36 L65 42 Z" fill={CRIMSON} />
          <path d="M65 58 L72 80 L65 74 Z" fill={`${CRIMSON}45`} />
        </g>
        <circle cx="65" cy="58" r="4" fill="white" stroke={CRIMSON} strokeWidth="1.5" />
        <text x="63" y="27" fill={CRIMSON} fontSize="8" fontWeight="700" fontFamily="sans-serif">N</text>
        <text x="63" y="95" fill={`${CRIMSON}60`} fontSize="7" fontFamily="sans-serif">S</text>
        <text x="24" y="61" fill={`${CRIMSON}60`} fontSize="7" fontFamily="sans-serif">W</text>
        <text x="98" y="61" fill={`${CRIMSON}60`} fontSize="7" fontFamily="sans-serif">E</text>
      </g>
    </svg>
    <div style={{ fontSize: 18, fontWeight: 800, color: DEEP, letterSpacing: -0.3, textAlign: 'center', marginBottom: 8 }}>Coming soon</div>
    <div style={{ fontSize: 13, color: '#94A3B8', fontWeight: 300, textAlign: 'center', lineHeight: 1.6 }}>
      Discover new people and groups{'\n'}will be available in a future update.
    </div>
  </div>
)

const AV = { bg: `${CRIMSON}14`, text: CRIMSON }

const FILTERS = ['All', 'Unread', 'Groups', 'Online'] as const
type Filter = typeof FILTERS[number]

const FAB_OPTIONS = [
  { label: 'New Group', Icon: Users },
  { label: 'New Chat',  Icon: MessageCircle },
]

const NAV_TABS = [
  { label: 'Chats',    Icon: MessageCircle },
  { label: 'Discover', Icon: Compass       },
  { label: 'Profile',  Icon: CircleUser    },
]

const glass: React.CSSProperties = {
  background: 'rgba(255,255,255,0.55)',
  backdropFilter: 'blur(8px)',
  WebkitBackdropFilter: 'blur(8px)',
}

export const HomeScreen = () => {
  const [activeTab, setActiveTab]       = useState(0)
  const [slideDir, setSlideDir]         = useState<'left' | 'right' | null>(null)
  const [fabOpen, setFabOpen]           = useState(false)
  const [searching, setSearching]       = useState(false)
  const [searchQuery, setSearchQuery]   = useState('')
  const [activeFilter, setActiveFilter] = useState<Filter>('All')
  const [filterOpen, setFilterOpen]     = useState(false)
  const [subScreen, setSubScreen]       = useState<'newChat' | 'newGroup' | null>(null)
  const [openChat, setOpenChat]         = useState<ChatItem | null>(null)
  const searchRef = useRef<HTMLInputElement>(null)

  const goTo = (i: number) => {
    if (i === activeTab) return
    setSlideDir(i > activeTab ? 'left' : 'right')
    setActiveTab(i)
    setSearching(false)
    setSearchQuery('')
    setFilterOpen(false)
  }

  const openSearch = () => { setSearching(true); setFilterOpen(false); setTimeout(() => searchRef.current?.focus(), 50) }
  const closeSearch = () => { setSearching(false); setSearchQuery('') }

  const isFiltered = activeFilter !== 'All'

  const filteredChats = CHATS.filter(c => {
    if (activeFilter === 'Unread') return c.unread > 0
    if (activeFilter === 'Groups') return c.group
    if (activeFilter === 'Online') return c.online
    return true
  }).filter(c =>
    searchQuery === '' ||
    c.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    c.msg.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <div style={{ width: '100%', height: '100%', background: BG, position: 'relative', overflow: 'hidden' }}
      onClick={() => { if (filterOpen) setFilterOpen(false) }}
    >

      {/* Top bar */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10, ...glass, display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 62, padding: '0 20px', borderRadius: '0 0 20px 20px', borderBottom: '1px solid rgba(0,0,0,0.06)' }}>
        {activeTab === 0 && searching ? (
          <div style={{ display: 'flex', alignItems: 'center', flex: 1, gap: 10, animation: 'fadeIn 0.2s ease' }}>
            <Search size={18} color={CRIMSON} strokeWidth={2} />
            <input ref={searchRef} value={searchQuery} onChange={e => setSearchQuery(e.target.value)} placeholder="Search conversations…" style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 16, fontFamily: 'inherit', color: DEEP, fontWeight: 500 }} />
            <button onClick={closeSearch} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 6, display: 'flex', alignItems: 'center', borderRadius: 8 }}>
              <X size={19} color="#888" strokeWidth={2} />
            </button>
          </div>
        ) : activeTab === 0 && filterOpen ? (
          /* ── Morphed filter pill ── */
          <div style={{ display: 'flex', alignItems: 'center', flex: 1, gap: 6, animation: 'titleMorph 0.22s cubic-bezier(0.34,1.2,0.64,1) both' }} onClick={e => e.stopPropagation()}>
            {FILTERS.map(f => {
              const on = activeFilter === f
              return (
                <button
                  key={f}
                  onClick={() => { setActiveFilter(f); setFilterOpen(false) }}
                  style={{ flex: 1, padding: '7px 0', borderRadius: 20, border: 'none', background: on ? CRIMSON : `${CRIMSON}10`, color: on ? 'white' : '#64748B', fontSize: 12, fontWeight: on ? 700 : 500, fontFamily: 'Zain, sans-serif', cursor: 'pointer', transition: 'all 0.18s ease' }}
                >
                  {f}
                </button>
              )
            })}
          </div>
        ) : (
          <>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              {/* Tappable title */}
              <button
                onClick={e => { e.stopPropagation(); if (activeTab === 0) setFilterOpen(v => !v) }}
                style={{ background: 'none', border: 'none', cursor: activeTab === 0 ? 'pointer' : 'default', padding: 0, display: 'flex', alignItems: 'center', gap: 6 }}
              >
                <span style={{ fontSize: 22, fontWeight: 800, color: DEEP, letterSpacing: -0.5 }}>
                  {activeTab === 2 ? 'Profile' : activeTab === 1 ? 'Discover' : 'Wavvy Chat'}
                </span>
                {/* Active filter dot */}
                {activeTab === 0 && isFiltered && (
                  <span style={{ width: 7, height: 7, borderRadius: '50%', background: CRIMSON, display: 'inline-block', marginBottom: 10, animation: 'fadeIn 0.2s ease' }} />
                )}
              </button>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              {activeTab === 0 && <>
                <button onClick={openSearch} style={{ background: '#55555510', border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
                  <Search size={19} color="#555" strokeWidth={2} />
                </button>
                {/* Filter icon — highlights when a filter is active */}
                <button
                  onClick={e => { e.stopPropagation(); setFilterOpen(v => !v) }}
                  style={{ background: isFiltered ? `${CRIMSON}15` : '#55555510', border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10, position: 'relative' }}
                >
                  <SlidersHorizontal size={18} color={isFiltered ? CRIMSON : '#555'} strokeWidth={2} />
                  {isFiltered && (
                    <span style={{ position: 'absolute', top: 6, right: 6, width: 6, height: 6, borderRadius: '50%', background: CRIMSON, border: '1.5px solid white' }} />
                  )}
                </button>
                <button style={{ background: `${CRIMSON}0D`, border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
                  <MoreVertical size={19} color={CRIMSON} strokeWidth={2} />
                </button>
              </>}
              {activeTab === 1 && (
                <button style={{ background: '#55555510', border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
                  <RotateCcw size={18} color="#555" strokeWidth={2} />
                </button>
              )}
              {activeTab === 2 && (
                <button style={{ background: `${CRIMSON}0D`, border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
                  <Pencil size={17} color={CRIMSON} strokeWidth={2} />
                </button>
              )}
            </div>
          </>
        )}
      </div>

      {/* Sliding tab content — top pad is always 62 now, no chip row */}
      <div
        key={activeTab}
        style={{ position: 'absolute', inset: 0, overflowY: 'auto', paddingTop: 64, paddingBottom: 90, animation: slideDir === 'left' ? 'slideInFromRight 0.28s cubic-bezier(0.4,0,0.2,1)' : slideDir === 'right' ? 'slideInFromLeft 0.28s cubic-bezier(0.4,0,0.2,1)' : 'none' }}
      >
        {activeTab === 2 && <ProfileScreen />}
        {activeTab === 1 && <EmptyDiscover />}
        {activeTab === 0 && filteredChats.length === 0 && <EmptyChats filter={activeFilter} />}
        {activeTab === 0 && filteredChats.map((c, i) => (
          <div key={i} onClick={() => setOpenChat(c)} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '11px 20px', borderBottom: i < filteredChats.length - 1 ? '1px solid #F4F6F9' : 'none', cursor: 'pointer' }}>
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
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 3 }}>
                <span style={{ fontWeight: 700, fontSize: 15, color: DEEP }}>{c.name}</span>
                <span style={{ fontSize: 11, color: c.unread ? CRIMSON : '#B0B8C5', fontWeight: c.unread ? 600 : 400, flexShrink: 0 }}>{c.time}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: 13, color: '#94A3B8', fontWeight: 300, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: 200 }}>{c.msg}</span>
                {c.unread > 0 && (
                  <div style={{ background: CRIMSON, color: 'white', borderRadius: 20, minWidth: 20, height: 20, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, padding: '0 5px', flexShrink: 0 }}>{c.unread}</div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* FAB */}
      <div style={{ position: 'absolute', bottom: 84, right: 22, display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 12, opacity: activeTab === 0 ? 1 : 0, pointerEvents: activeTab === 0 ? 'auto' : 'none', transition: 'opacity 0.2s', zIndex: 12 }}>
        {FAB_OPTIONS.map(({ label, Icon }, i) => (
          <div key={i} onClick={() => { setFabOpen(false); if (label === 'New Chat') setSubScreen('newChat'); if (label === 'New Group') setSubScreen('newGroup') }} style={{ display: 'flex', alignItems: 'center', gap: 10, opacity: fabOpen ? 1 : 0, transform: fabOpen ? 'translateY(0) scale(1)' : 'translateY(24px) scale(0.85)', transition: `opacity 0.28s ${i * 0.07}s ease, transform 0.32s ${i * 0.07}s cubic-bezier(0.34,1.4,0.64,1)`, pointerEvents: fabOpen ? 'auto' : 'none', cursor: 'pointer' }}>
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

      {fabOpen && <div onClick={() => setFabOpen(false)} style={{ position: 'absolute', inset: 0, zIndex: 11 }} />}

      {/* Nav bar */}
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 10, ...glass, display: 'flex', height: 72, alignItems: 'center', paddingBottom: 12, borderRadius: '20px 20px 0 0', borderTop: '1px solid rgba(0,0,0,0.06)' }}>
        {NAV_TABS.map(({ label, Icon }, i) => {
          const active = i === activeTab
          return (
            <button key={i} onClick={() => goTo(i)} style={{ flex: 1, background: 'none', border: 'none', cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 3, height: '100%' }}>
              <span style={{ display: 'flex', animation: active ? 'navBounce 0.4s cubic-bezier(0.34,1.56,0.64,1)' : 'none' }}>
                <Icon size={24} color={active ? CRIMSON : '#B0B8C5'} strokeWidth={active ? 2.5 : 1.6} fill={active ? `${CRIMSON}18` : 'none'} />
              </span>
              <span style={{ fontSize: 11, fontFamily: 'Zain, sans-serif', fontWeight: 700, color: CRIMSON, letterSpacing: 0.2, maxHeight: active ? 16 : 0, opacity: active ? 1 : 0, overflow: 'hidden', transition: 'max-height 0.25s ease, opacity 0.2s ease' }}>
                {label}
              </span>
            </button>
          )
        })}
      </div>


      {/* New Chat overlay */}
      {subScreen === 'newChat' && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 20 }}>
          <NewChatScreen onBack={() => { setSubScreen(null); setSlideDir(null) }} />
        </div>
      )}

      {/* New Group overlay */}
      {subScreen === 'newGroup' && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 20 }}>
          <NewGroupScreen onBack={() => { setSubScreen(null); setSlideDir(null) }} />
        </div>
      )}

      {/* Chat Screen overlay */}
      {openChat && (
        <div style={{ position: 'absolute', inset: 0, zIndex: 25, overflow: 'hidden' }}>
          {openChat.group
            ? <GroupChatScreen chat={openChat} onBack={() => setOpenChat(null)} />
            : <DirectChatScreen chat={openChat} onBack={() => setOpenChat(null)} />
          }
        </div>
      )}
    </div>
  )
}
