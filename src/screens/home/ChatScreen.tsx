import { useState, useRef, useEffect } from 'react'
import { ChevronLeft, Phone, Video, MoreVertical, Send, Smile, Paperclip, CheckCheck, Check } from 'lucide-react'
import { CRIMSON, CRIMSON_LIGHT, DEEP, FIELD_BG } from '@/constants/colors'
import { MOCK_MESSAGES, type Message, type ChatItem } from '@/data/chats'

const glass: React.CSSProperties = {
  background: 'rgba(255,255,255,0.72)',
  backdropFilter: 'blur(12px)',
  WebkitBackdropFilter: 'blur(12px)',
}

const StatusIcon = ({ status }: { status?: Message['status'] }) => {
  if (!status) return null
  if (status === 'read') return <CheckCheck size={13} color={CRIMSON} strokeWidth={2.5} />
  if (status === 'delivered') return <CheckCheck size={13} color="#B0B8C5" strokeWidth={2.5} />
  return <Check size={13} color="#B0B8C5" strokeWidth={2.5} />
}

type Props = { chat: ChatItem; onBack: () => void }

export const ChatScreen = ({ chat, onBack }: Props) => {
  const [input, setInput] = useState('')
  const [messages, setMessages] = useState<Message[]>(
    MOCK_MESSAGES[chat.name] ?? [
      { id: '0', text: chat.msg, mine: false, time: chat.time },
    ]
  )
  const [closing, setClosing] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const isMounted = useRef(false)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: isMounted.current ? 'smooth' : 'auto' })
    isMounted.current = true
  }, [messages])

  const handleBack = () => { setClosing(true); setTimeout(onBack, 260) }

  const send = () => {
    const text = input.trim()
    if (!text) return
    setMessages(prev => [...prev, {
      id: Date.now().toString(),
      text,
      mine: true,
      time: 'now',
      status: 'sent',
    }])
    setInput('')
    inputRef.current?.focus()
  }

  const onKey = (e: React.KeyboardEvent) => { if (e.key === 'Enter') send() }

  return (
    <div style={{ width: '100%', height: '100%', background: '#F7F8FC', position: 'relative', overflow: 'hidden', animation: `${closing ? 'chatSlideOut' : 'chatSlideIn'} 0.28s cubic-bezier(0.4,0,0.2,1) both` }}>
      {/* App bar */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10, ...glass, height: 62, display: 'flex', alignItems: 'center', padding: '0 12px 0 6px', gap: 10, borderBottom: '1px solid rgba(0,0,0,0.06)', borderRadius: '0 0 20px 20px' }}>
        {/* Back */}
        <button onClick={handleBack} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
          <ChevronLeft size={24} color={DEEP} strokeWidth={2.5} />
        </button>

        {/* Avatar */}
        <div style={{ position: 'relative', flexShrink: 0 }}>
          <div style={{ width: 38, height: 38, borderRadius: 12, background: `${CRIMSON}14`, color: CRIMSON, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 700, fontFamily: 'Zain, sans-serif' }}>
            {chat.initials}
          </div>
          {chat.online && !chat.group && (
            <div style={{ position: 'absolute', bottom: 0, right: 0, width: 10, height: 10, borderRadius: '50%', background: '#22C55E', border: '2px solid white' }} />
          )}
        </div>

        {/* Name + status */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 15, fontWeight: 800, color: DEEP, letterSpacing: -0.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{chat.name}</div>
          <div style={{ fontSize: 11, color: chat.online ? '#22C55E' : '#94A3B8', fontWeight: 500, marginTop: 1 }}>
            {chat.group ? `${chat.name === 'Weekend Squad' ? 4 : chat.name === 'Dev Team' ? 12 : chat.name === 'Design Crew' ? 7 : chat.name === 'Football Lads' ? 9 : 5} members` : chat.online ? 'Online' : 'Offline'}
          </div>
        </div>

        {/* Actions */}
        <div style={{ display: 'flex', gap: 2 }}>
          <button style={{ background: '#55555510', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
            <Phone size={17} color="#555" strokeWidth={2} />
          </button>
          <button style={{ background: '#55555510', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
            <Video size={17} color="#555" strokeWidth={2} />
          </button>
          <button style={{ background: `${CRIMSON}0D`, border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10 }}>
            <MoreVertical size={17} color={CRIMSON} strokeWidth={2} />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div style={{ position: 'absolute', inset: 0, overflowY: 'auto', paddingTop: 74, paddingBottom: 80, paddingLeft: 14, paddingRight: 14, display: 'flex', flexDirection: 'column', gap: 6 }}>
        {messages.map((m, i) => {
          const isFirst = i === 0 || messages[i - 1].mine !== m.mine
          return (
            <div key={m.id} style={{ display: 'flex', flexDirection: 'column', alignItems: m.mine ? 'flex-end' : 'flex-start', animation: 'msgIn 0.22s ease both' }}>
              <div style={{
                maxWidth: '72%',
                padding: '9px 13px',
                borderRadius: m.mine
                  ? isFirst ? '18px 18px 4px 18px' : '18px 4px 4px 18px'
                  : isFirst ? '18px 18px 18px 4px' : '4px 18px 18px 4px',
                background: m.mine
                  ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`
                  : 'white',
                color: m.mine ? 'white' : DEEP,
                fontSize: 14,
                fontWeight: 400,
                lineHeight: 1.45,
                boxShadow: m.mine ? `0 4px 14px ${CRIMSON}30` : '0 2px 8px rgba(0,0,0,0.06)',
                marginTop: isFirst ? 8 : 2,
              }}>
                {m.text}
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: 4, marginTop: 3 }}>
                  <span style={{ fontSize: 10, opacity: m.mine ? 0.75 : 0.45, fontWeight: 400 }}>{m.time}</span>
                  {m.mine && <StatusIcon status={m.status} />}
                </div>
              </div>
            </div>
          )
        })}
        <div ref={bottomRef} />
      </div>

      {/* Input bar */}
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 10, ...glass, borderTop: '1px solid rgba(0,0,0,0.06)', borderRadius: '20px 20px 0 0', padding: '10px 12px 18px', display: 'flex', alignItems: 'center', gap: 8 }}>
        <button style={{ background: FIELD_BG, border: 'none', cursor: 'pointer', padding: 9, display: 'flex', alignItems: 'center', borderRadius: 12, flexShrink: 0 }}>
          <Paperclip size={18} color="#94A3B8" strokeWidth={2} />
        </button>

        <div style={{ flex: 1, display: 'flex', alignItems: 'center', background: FIELD_BG, borderRadius: 16, padding: '0 12px', gap: 8 }}>
          <input
            ref={inputRef}
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={onKey}
            placeholder="Message…"
            style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 15, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 400, padding: '10px 0' }}
          />
          <button style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, display: 'flex', alignItems: 'center', flexShrink: 0 }}>
            <Smile size={18} color="#94A3B8" strokeWidth={2} />
          </button>
        </div>

        <button
          onClick={send}
          style={{ width: 42, height: 42, borderRadius: 14, background: input.trim() ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})` : FIELD_BG, border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, transition: 'background 0.2s ease' }}
        >
          <Send size={18} color={input.trim() ? 'white' : '#94A3B8'} strokeWidth={2} style={{ transform: 'translateX(1px)' }} />
        </button>
      </div>
    </div>
  )
}
