import { useState, useRef, useEffect } from 'react'
import {
  ChevronLeft, MoreVertical, Send, Smile,
  Paperclip, CheckCheck, Check, Mic, Users, Pin, X, AtSign,
} from 'lucide-react'
import { CRIMSON, CRIMSON_LIGHT, DEEP, FIELD_BG } from '@/constants/colors'
import { MOCK_MESSAGES, type Message, type ChatItem } from '@/data/chats'

const glass: React.CSSProperties = {
  background: 'rgba(255,255,255,0.82)',
  backdropFilter: 'blur(14px)',
  WebkitBackdropFilter: 'blur(14px)',
}

const PALETTE = ['#0077B6', '#0096C7', '#7B2D8B', '#2D8B5A', '#C77B00', '#8B2D2D', '#00796B']
const colorMap: Record<string, string> = {}
let palIdx = 0
const senderColor = (name: string) => {
  if (!colorMap[name]) colorMap[name] = PALETTE[palIdx++ % PALETTE.length]
  return colorMap[name]
}

const GROUP_MEMBERS: Record<string, Array<{ name: string; initials: string; role?: 'admin' }>> = {
  'Weekend Squad': [
    { name: 'You', initials: 'ME' },
    { name: 'Maya Khan', initials: 'MK', role: 'admin' },
    { name: 'Ryan J', initials: 'RJ' },
    { name: 'Sara Lee', initials: 'SL' },
  ],
  'Dev Team': [
    { name: 'You', initials: 'ME' },
    { name: 'Alex Liu', initials: 'AL', role: 'admin' },
    { name: 'Nora S', initials: 'NS' },
    { name: 'Layla', initials: 'LA' },
    { name: '+ 8 more', initials: '…' },
  ],
  'Design Crew': [
    { name: 'You', initials: 'ME' },
    { name: 'Layla', initials: 'LA', role: 'admin' },
    { name: 'Nora S', initials: 'NS' },
    { name: 'James B', initials: 'JB' },
    { name: '+ 3 more', initials: '…' },
  ],
  'Football Lads': [
    { name: 'You', initials: 'ME' },
    { name: 'Omar', initials: 'OM', role: 'admin' },
    { name: 'Khalid R', initials: 'KR' },
    { name: '+ 6 more', initials: '…' },
  ],
}

const PINNED: Record<string, string> = {
  'Dev Team': 'Sprint ends Friday. All PRs in by Thursday 5pm 📌',
  'Design Crew': 'New brand kit shared in Files tab — review by Monday',
  'Football Lads': 'Training moved to 8am this Saturday ⚽',
}

const StatusIcon = ({ status }: { status?: Message['status'] }) => {
  if (!status) return null
  if (status === 'read') return <CheckCheck size={13} color={CRIMSON} strokeWidth={2.5} />
  if (status === 'delivered') return <CheckCheck size={13} color="#B0B8C5" strokeWidth={2.5} />
  return <Check size={13} color="#B0B8C5" strokeWidth={2.5} />
}

type MembersPanelProps = { members: Array<{ name: string; initials: string; role?: 'admin' }>; onClose: () => void }
const MembersPanel = ({ members, onClose }: MembersPanelProps) => (
  <div
    style={{ position: 'absolute', inset: 0, zIndex: 30, background: 'rgba(0,0,0,0.25)', backdropFilter: 'blur(4px)', WebkitBackdropFilter: 'blur(4px)', display: 'flex', alignItems: 'flex-end' }}
    onClick={onClose}
  >
    <div
      style={{ width: '100%', background: 'white', borderRadius: '24px 24px 0 0', padding: '0 0 28px', animation: 'membersPanelIn 0.32s cubic-bezier(0.34,1.2,0.64,1)', maxHeight: '65%', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}
      onClick={e => e.stopPropagation()}
    >
      <div style={{ display: 'flex', justifyContent: 'center', padding: '14px 0 6px' }}>
        <div style={{ width: 36, height: 4, borderRadius: 4, background: '#E2E8F0' }} />
      </div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 20px 14px' }}>
        <span style={{ fontSize: 17, fontWeight: 800, color: DEEP, letterSpacing: -0.3 }}>Members</span>
        <button onClick={onClose} style={{ background: `${CRIMSON}10`, border: 'none', cursor: 'pointer', padding: 7, borderRadius: 10, display: 'flex' }}>
          <X size={15} color={CRIMSON} strokeWidth={2.5} />
        </button>
      </div>
      <div style={{ overflowY: 'auto', flex: 1, padding: '0 8px' }}>
        {members.map((m, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px', borderRadius: 14 }}>
            <div style={{ width: 42, height: 42, borderRadius: 14, flexShrink: 0, background: m.name === 'You' ? `${CRIMSON}18` : m.name.startsWith('+') ? '#F0F1F5' : `${senderColor(m.name)}18`, color: m.name === 'You' ? CRIMSON : m.name.startsWith('+') ? '#94A3B8' : senderColor(m.name), display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 800, fontFamily: 'Zain, sans-serif' }}>
              {m.initials}
            </div>
            <span style={{ flex: 1, fontSize: 14, fontWeight: 700, color: DEEP }}>{m.name}</span>
            {m.role === 'admin' && (
              <span style={{ fontSize: 11, fontWeight: 700, color: CRIMSON, background: `${CRIMSON}14`, padding: '3px 8px', borderRadius: 8, flexShrink: 0 }}>Admin</span>
            )}
          </div>
        ))}
      </div>
    </div>
  </div>
)

type Props = { chat: ChatItem; onBack: () => void }

export const GroupChatScreen = ({ chat, onBack }: Props) => {
  const initialMessages = MOCK_MESSAGES[chat.name] ?? [{ id: '0', text: chat.msg, mine: false, time: chat.time, sender: 'Someone', senderInitials: '?' }]
  const initialIds = useRef(new Set(initialMessages.map(m => m.id)))

  const [input, setInput] = useState('')
  const [messages, setMessages] = useState<Message[]>(initialMessages)
  const [closing, setClosing] = useState(false)
  const [showMembers, setShowMembers] = useState(false)
  const [pinDismissed, setPinDismissed] = useState(false)

  const msgsRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const isMounted = useRef(false)

  const members = GROUP_MEMBERS[chat.name] ?? [{ name: 'You', initials: 'ME' }]
  const memberCount = chat.name === 'Dev Team' ? 12 : chat.name === 'Design Crew' ? 7 : chat.name === 'Football Lads' ? 9 : 4
  const pinnedMsg = PINNED[chat.name]
  const hasPinBanner = !!pinnedMsg && !pinDismissed

  useEffect(() => {
    const el = msgsRef.current
    if (!el) return
    if (!isMounted.current) { el.scrollTop = el.scrollHeight; isMounted.current = true; return }
    el.scrollTo({ top: el.scrollHeight, behavior: 'smooth' })
  }, [messages])

  const handleBack = () => { setClosing(true); setTimeout(onBack, 260) }

  const send = () => {
    const text = input.trim()
    if (!text) return
    const id = Date.now().toString()
    setMessages(prev => [...prev, { id, text, mine: true, time: 'now', status: 'sent' }])
    setInput('')
    inputRef.current?.focus()
  }

  const onKey = (e: React.KeyboardEvent) => { if (e.key === 'Enter') send() }

  const R = (tl: number, tr: number, br: number, bl: number) => `${tl}px ${tr}px ${br}px ${bl}px`

  return (
    <div
      style={{
        width: '100%', height: '100%',
        background: '#F7F9FC',
        display: 'flex', flexDirection: 'column',
        overflow: 'hidden',
        animation: `${closing ? 'chatSlideOut' : 'chatSlideIn'} 0.28s cubic-bezier(0.4,0,0.2,1) both`,
        position: 'relative',
      }}
    >
      {/* Decorative blobs */}
      <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 0 }}>
        <div style={{ position: 'absolute', bottom: -60, right: -60, width: 260, height: 260, borderRadius: '50%', background: `${CRIMSON}05` }} />
        <div style={{ position: 'absolute', top: 100, left: -80, width: 200, height: 200, borderRadius: '50%', background: `${CRIMSON_LIGHT}05` }} />
      </div>

      {/* ── App bar ── */}
      <div style={{ ...glass, flexShrink: 0, height: 64, display: 'flex', alignItems: 'center', padding: '0 12px 0 4px', gap: 8, borderBottom: '1px solid rgba(0,0,0,0.06)', borderRadius: '0 0 20px 20px', zIndex: 10 }}>
        <button onClick={handleBack} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10, flexShrink: 0 }}>
          <ChevronLeft size={24} color={DEEP} strokeWidth={2.5} />
        </button>

        <button onClick={() => setShowMembers(true)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, position: 'relative', width: 40, height: 40, flexShrink: 0 }}>
          <div style={{ width: 40, height: 40, borderRadius: 13, background: `${CRIMSON}18`, color: CRIMSON, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 800, fontFamily: 'Zain, sans-serif' }}>
            {chat.initials}
          </div>
          <div style={{ position: 'absolute', bottom: -2, right: -2, background: CRIMSON, borderRadius: 6, padding: '1px 3px', border: '2px solid white' }}>
            <Users size={8} color="white" strokeWidth={2.5} />
          </div>
        </button>

        <button onClick={() => setShowMembers(true)} style={{ flex: 1, minWidth: 0, background: 'none', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'left' }}>
          <div style={{ fontSize: 15, fontWeight: 800, color: DEEP, letterSpacing: -0.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{chat.name}</div>
          <div style={{ fontSize: 11, color: '#94A3B8', fontWeight: 500, marginTop: 1 }}>{memberCount} members · tap to view</div>
        </button>

        <button style={{ background: `${CRIMSON}0D`, border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10, flexShrink: 0 }}>
          <MoreVertical size={17} color={CRIMSON} strokeWidth={2} />
        </button>
      </div>

      {/* ── Pinned banner ── */}
      {hasPinBanner && (
        <div style={{ flexShrink: 0, background: `${CRIMSON}0C`, borderBottom: `1px solid ${CRIMSON}18`, display: 'flex', alignItems: 'center', gap: 8, padding: '7px 14px 7px 10px', animation: 'pinBanner 0.3s ease', zIndex: 9 }}>
          <Pin size={13} color={CRIMSON} strokeWidth={2.5} style={{ flexShrink: 0 }} />
          <span style={{ flex: 1, fontSize: 12, fontWeight: 500, color: DEEP, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{pinnedMsg}</span>
          <button onClick={() => setPinDismissed(true)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 3, display: 'flex', flexShrink: 0 }}>
            <X size={13} color={`${DEEP}80`} strokeWidth={2} />
          </button>
        </div>
      )}

      {/* ── Messages ── */}
      <div ref={msgsRef} style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '8px 14px 12px', display: 'flex', flexDirection: 'column', gap: 2, zIndex: 1 }}>
        {messages.map((m, i) => {
          if (m.system) {
            return (
              <div key={m.id} style={{ display: 'flex', justifyContent: 'center', margin: '10px 0', animation: 'sysMsg 0.3s ease' }}>
                <div style={{ background: `${CRIMSON}0C`, borderRadius: 20, padding: '5px 14px', fontSize: 11.5, fontWeight: 500, color: `${DEEP}90`, textAlign: 'center' }}>
                  {m.text}
                </div>
              </div>
            )
          }

          const prevMsg = messages[i - 1]
          const nextMsg = messages[i + 1]
          const isFirst = !prevMsg || prevMsg.system || prevMsg.mine !== m.mine || prevMsg.sender !== m.sender
          const isLast  = !nextMsg || nextMsg.system || nextMsg.mine !== m.mine || nextMsg.sender !== m.sender
          const color = m.sender ? senderColor(m.sender) : CRIMSON
          const isNew = !initialIds.current.has(m.id)

          const bubbleRadius = m.mine
            ? isFirst ? R(18, 18, 10, 18) : R(18, 10, 10, 18)
            : isFirst ? R(18, 18, 18, 10) : R(10, 18, 18, 10)

          return (
            <div key={m.id} style={{ display: 'flex', flexDirection: 'column', alignItems: m.mine ? 'flex-end' : 'flex-start', marginTop: isFirst ? 10 : 2, animation: isNew ? 'msgIn 0.22s ease both' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, flexDirection: m.mine ? 'row-reverse' : 'row' }}>
                {/* Sender avatar column */}
                {!m.mine && (
                  <div style={{ width: 28, flexShrink: 0, alignSelf: 'flex-end' }}>
                    {isLast
                      ? <div style={{ width: 28, height: 28, borderRadius: 10, background: `${color}18`, color, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 10, fontWeight: 800, fontFamily: 'Zain, sans-serif' }}>{m.senderInitials ?? '?'}</div>
                      : <div style={{ width: 28 }} />
                    }
                  </div>
                )}

                <div style={{ maxWidth: 230, display: 'flex', flexDirection: 'column', alignItems: m.mine ? 'flex-end' : 'flex-start', gap: 1 }}>
                  {!m.mine && isFirst && m.sender && (
                    <span style={{ fontSize: 11, fontWeight: 700, color, marginLeft: 4, marginBottom: 1 }}>{m.sender}</span>
                  )}

                  <div style={{
                    padding: '9px 13px',
                    borderRadius: bubbleRadius,
                    background: m.mine ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})` : 'white',
                    color: m.mine ? 'white' : DEEP,
                    fontSize: 14.5,
                    fontWeight: 400,
                    lineHeight: 1.45,
                    wordBreak: 'break-word',
                    overflowWrap: 'anywhere',
                    boxShadow: m.mine ? `0 4px 14px ${CRIMSON}30` : '0 2px 8px rgba(0,0,0,0.06)',
                  }}>
                    {m.text}
                  </div>

                  {isLast && (
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 3, padding: '0 4px' }}>
                      <span style={{ fontSize: 10.5, color: '#94A3B8', fontWeight: 400 }}>{m.time}</span>
                      {m.mine && <StatusIcon status={m.status} />}
                    </div>
                  )}
                </div>
              </div>
            </div>
          )
        })}
        <div />
      </div>

      {/* ── Input bar ── */}
      <div style={{ ...glass, flexShrink: 0, borderTop: '1px solid rgba(0,0,0,0.06)', borderRadius: '20px 20px 0 0', padding: '10px 12px 18px', display: 'flex', alignItems: 'center', gap: 8, zIndex: 10 }}>
        <button style={{ background: FIELD_BG, border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 12, flexShrink: 0 }}>
          <Paperclip size={18} color="#94A3B8" strokeWidth={2} />
        </button>

        <div style={{ flex: 1, display: 'flex', alignItems: 'center', background: FIELD_BG, borderRadius: 16, padding: '0 10px 0 14px', gap: 6, minWidth: 0 }}>
          <input
            ref={inputRef}
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={onKey}
            placeholder="Message group…"
            style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 15, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 400, padding: '10px 0', minWidth: 0 }}
          />
          <button style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, display: 'flex', alignItems: 'center', flexShrink: 0 }}>
            <AtSign size={16} color="#94A3B8" strokeWidth={2} />
          </button>
          <button style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, display: 'flex', alignItems: 'center', flexShrink: 0 }}>
            <Smile size={18} color="#94A3B8" strokeWidth={2} />
          </button>
        </div>

        <button
          onClick={send}
          style={{ width: 42, height: 42, borderRadius: 14, background: input.trim() ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})` : FIELD_BG, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, transition: 'background 0.18s ease' }}
        >
          {input.trim()
            ? <Send size={18} color="white" strokeWidth={2} style={{ transform: 'translateX(1px)' }} />
            : <Mic size={18} color="#94A3B8" strokeWidth={2} />
          }
        </button>
      </div>

      {showMembers && <MembersPanel members={members} onClose={() => setShowMembers(false)} />}
    </div>
  )
}
