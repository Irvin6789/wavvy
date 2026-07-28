import { useState, useRef, useEffect } from 'react'
import {
  ChevronLeft, MoreVertical, Send, Smile,
  Paperclip, CheckCheck, Check, Mic,
} from 'lucide-react'
import { CRIMSON, CRIMSON_LIGHT, DEEP, FIELD_BG } from '@/constants/colors'
import { MOCK_MESSAGES, type Message, type ChatItem } from '@/data/chats'

const glass: React.CSSProperties = {
  background: 'rgba(255,255,255,0.82)',
  backdropFilter: 'blur(14px)',
  WebkitBackdropFilter: 'blur(14px)',
}

const REACTIONS = ['👍', '❤️', '😂', '😮', '😢', '🔥']

const StatusIcon = ({ status }: { status?: Message['status'] }) => {
  if (!status) return null
  if (status === 'read') return <CheckCheck size={13} color={CRIMSON} strokeWidth={2.5} />
  if (status === 'delivered') return <CheckCheck size={13} color="#B0B8C5" strokeWidth={2.5} />
  return <Check size={13} color="#B0B8C5" strokeWidth={2.5} />
}

const TypingIndicator = () => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '11px 16px', background: 'white', borderRadius: '18px 18px 18px 10px', boxShadow: '0 2px 8px rgba(0,0,0,0.06)', width: 64, marginTop: 8 }}>
    {[0, 1, 2].map(i => (
      <div key={i} style={{ width: 7, height: 7, borderRadius: '50%', background: `${CRIMSON}70`, animation: `typingDot 1.2s ${i * 0.2}s ease-in-out infinite` }} />
    ))}
  </div>
)

type ReactionTrayProps = { msgId: string; onReact: (id: string, e: string) => void; onClose: () => void; isMine: boolean }
const ReactionTray = ({ msgId, onReact, onClose, isMine }: ReactionTrayProps) => (
  <div
    onClick={e => e.stopPropagation()}
    style={{ position: 'absolute', bottom: '100%', [isMine ? 'right' : 'left']: 0, marginBottom: 6, background: 'white', borderRadius: 24, padding: '6px 10px', display: 'flex', gap: 4, boxShadow: '0 4px 20px rgba(0,0,0,0.14)', zIndex: 30, animation: 'reactionTray 0.2s cubic-bezier(0.34,1.4,0.64,1) both' }}
  >
    {REACTIONS.map(emoji => (
      <button key={emoji} onClick={() => { onReact(msgId, emoji); onClose() }} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: 22, padding: 2, borderRadius: 8 }}>
        {emoji}
      </button>
    ))}
  </div>
)

type Props = { chat: ChatItem; onBack: () => void }

export const DirectChatScreen = ({ chat, onBack }: Props) => {
  const initialMessages = MOCK_MESSAGES[chat.name] ?? [{ id: '0', text: chat.msg, mine: false, time: chat.time }]
  const initialIds = useRef(new Set(initialMessages.map(m => m.id)))

  const [input, setInput] = useState('')
  const [messages, setMessages] = useState<Message[]>(initialMessages)
  const [closing, setClosing] = useState(false)
  const [typing, setTyping] = useState(false)
  const [activeReaction, setActiveReaction] = useState<string | null>(null)
  const [reactions, setReactions] = useState<Record<string, string>>({})

  const msgsRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const isMounted = useRef(false)

  useEffect(() => {
    const el = msgsRef.current
    if (!el) return
    if (!isMounted.current) { el.scrollTop = el.scrollHeight; isMounted.current = true; return }
    el.scrollTo({ top: el.scrollHeight, behavior: 'smooth' })
  }, [messages])

  useEffect(() => {
    const t = setTimeout(() => setTyping(true), 1800)
    const t2 = setTimeout(() => setTyping(false), 5200)
    return () => { clearTimeout(t); clearTimeout(t2) }
  }, [])

  const handleBack = () => { setClosing(true); setTimeout(onBack, 260) }

  const send = () => {
    const text = input.trim()
    if (!text) return
    const id = Date.now().toString()
    setMessages(prev => [...prev, { id, text, mine: true, time: 'now', status: 'sent' }])
    setInput('')
    inputRef.current?.focus()
    setTimeout(() => {
      setTyping(true)
      setTimeout(() => {
        setTyping(false)
        setMessages(prev => [...prev, { id: (Date.now() + 1).toString(), text: '😊', mine: false, time: 'now' }])
      }, 2000)
    }, 800)
  }

  const onKey = (e: React.KeyboardEvent) => { if (e.key === 'Enter') send() }
  const addReaction = (msgId: string, emoji: string) => setReactions(prev => ({ ...prev, [msgId]: emoji }))

  return (
    <div
      onClick={() => setActiveReaction(null)}
      style={{
        width: '100%', height: '100%',
        background: '#F7F9FC',
        display: 'flex', flexDirection: 'column',
        overflow: 'hidden',
        animation: `${closing ? 'chatSlideOut' : 'chatSlideIn'} 0.28s cubic-bezier(0.4,0,0.2,1) both`,
        position: 'relative',
      }}
    >
      {/* Decorative blobs — behind everything */}
      <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 0 }}>
        <div style={{ position: 'absolute', bottom: -40, left: -60, width: 280, height: 280, borderRadius: '50%', background: `${CRIMSON}06` }} />
        <div style={{ position: 'absolute', top: 80, right: -80, width: 220, height: 220, borderRadius: '50%', background: `${CRIMSON_LIGHT}06` }} />
      </div>

      {/* ── App bar ── */}
      <div style={{ ...glass, flexShrink: 0, height: 64, display: 'flex', alignItems: 'center', padding: '0 12px 0 4px', gap: 8, borderBottom: '1px solid rgba(0,0,0,0.06)', borderRadius: '0 0 20px 20px', zIndex: 10 }}>
        <button onClick={handleBack} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10, flexShrink: 0 }}>
          <ChevronLeft size={24} color={DEEP} strokeWidth={2.5} />
        </button>

        <div style={{ position: 'relative', flexShrink: 0 }}>
          <div style={{ width: 40, height: 40, borderRadius: 13, background: `${CRIMSON}14`, color: CRIMSON, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 800, fontFamily: 'Zain, sans-serif' }}>
            {chat.initials}
          </div>
          {chat.online && <div style={{ position: 'absolute', bottom: 0, right: 0, width: 11, height: 11, borderRadius: '50%', background: '#22C55E', border: '2.5px solid white' }} />}
        </div>

        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 800, color: DEEP, letterSpacing: -0.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{chat.name}</div>
          <div style={{ fontSize: 11, fontWeight: 500, marginTop: 1, color: typing ? CRIMSON : chat.online ? '#22C55E' : '#94A3B8', transition: 'color 0.3s ease' }}>
            {typing ? 'typing…' : chat.online ? 'Online' : 'Last seen recently'}
          </div>
        </div>

        <button style={{ background: `${CRIMSON}0D`, border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 10, flexShrink: 0 }}>
          <MoreVertical size={17} color={CRIMSON} strokeWidth={2} />
        </button>
      </div>

      {/* ── Messages ── */}
      <div ref={msgsRef} style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '8px 14px 12px', display: 'flex', flexDirection: 'column', gap: 2, zIndex: 1 }}>
        {messages.map((m, i) => {
          const isFirst = i === 0 || messages[i - 1].mine !== m.mine
          const showTime = i === messages.length - 1 || messages[i + 1].mine !== m.mine
          const rxn = reactions[m.id]
          const isNew = !initialIds.current.has(m.id)

          const R = (tl: number, tr: number, br: number, bl: number) => `${tl}px ${tr}px ${br}px ${bl}px`
          const bubbleRadius = m.mine
            ? isFirst ? R(18, 18, 10, 18) : R(18, 10, 10, 18)
            : isFirst ? R(18, 18, 18, 10) : R(10, 18, 18, 10)

          return (
            <div
              key={m.id}
              style={{ display: 'flex', flexDirection: 'column', alignItems: m.mine ? 'flex-end' : 'flex-start', marginTop: isFirst ? 10 : 2, animation: isNew ? 'msgIn 0.22s ease both' : 'none' }}
            >
              <div style={{ position: 'relative' }} onDoubleClick={() => setActiveReaction(activeReaction === m.id ? null : m.id)}>
                {activeReaction === m.id && (
                  <ReactionTray msgId={m.id} onReact={addReaction} onClose={() => setActiveReaction(null)} isMine={m.mine} />
                )}

                <div style={{
                  maxWidth: 260,
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

                {rxn && (
                  <div style={{ position: 'absolute', bottom: -10, [m.mine ? 'right' : 'left']: 8, background: 'white', borderRadius: 20, padding: '1px 6px', fontSize: 14, boxShadow: '0 2px 8px rgba(0,0,0,0.12)', animation: 'reactionPop 0.3s cubic-bezier(0.34,1.4,0.64,1)', border: '1.5px solid rgba(0,0,0,0.06)' }}>
                    {rxn}
                  </div>
                )}
              </div>

              {showTime && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 3, padding: '0 4px' }}>
                  <span style={{ fontSize: 10.5, color: '#94A3B8', fontWeight: 400 }}>{m.time}</span>
                  {m.mine && <StatusIcon status={m.status} />}
                </div>
              )}
            </div>
          )
        })}

        {typing && (
          <div style={{ display: 'flex', alignItems: 'flex-start', marginTop: 10, animation: 'msgIn 0.22s ease' }}>
            <TypingIndicator />
          </div>
        )}
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
            placeholder="Message…"
            style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 15, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 400, padding: '10px 0', minWidth: 0 }}
          />
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
    </div>
  )
}
