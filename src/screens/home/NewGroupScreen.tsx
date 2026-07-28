import { useState, useRef } from 'react'
import { Search, X, ChevronDown, ChevronLeft, Users, Check, Camera, Lock, Globe } from 'lucide-react'
import { CRIMSON, CRIMSON_LIGHT, DEEP, BG, FIELD_BG, FI } from '@/constants/colors'
import { NEW_CHAT_ITEMS } from '@/data/chats'

const glass: React.CSSProperties = {
  background: 'rgba(255,255,255,0.82)',
  backdropFilter: 'blur(14px)',
  WebkitBackdropFilter: 'blur(14px)',
}

const CONTACTS = NEW_CHAT_ITEMS.filter(c => !c.group)

// ── Selected member chip ────────────────────────────────────────────────────
const MemberChip = ({ name, initials, onRemove }: { name: string; initials: string; onRemove: () => void }) => (
  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5, animation: 'popIn 0.22s cubic-bezier(0.34,1.4,0.64,1) both', flexShrink: 0 }}>
    <div style={{ position: 'relative' }}>
      <div style={{ width: 46, height: 46, borderRadius: 15, background: `${CRIMSON}18`, color: CRIMSON, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 800, fontFamily: 'Zain, sans-serif' }}>
        {initials}
      </div>
      <button
        onClick={onRemove}
        style={{ position: 'absolute', top: -4, right: -4, width: 18, height: 18, borderRadius: '50%', background: CRIMSON, border: '2px solid white', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', padding: 0 }}
      >
        <X size={9} color="white" strokeWidth={3} />
      </button>
    </div>
    <span style={{ fontSize: 10.5, fontWeight: 600, color: DEEP, maxWidth: 50, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', textAlign: 'center' }}>
      {name.split(' ')[0]}
    </span>
  </div>
)

// ── Step 1 — pick members ───────────────────────────────────────────────────
type Step1Props = {
  selected: typeof CONTACTS
  onToggle: (c: typeof CONTACTS[0]) => void
  onNext: () => void
  onBack: () => void
}

const Step1 = ({ selected, onToggle, onNext, onBack }: Step1Props) => {
  const [query, setQuery] = useState('')
  const searchRef = useRef<HTMLInputElement>(null)

  const filtered = CONTACTS.filter(c =>
    query === '' || c.name.toLowerCase().includes(query.toLowerCase())
  )
  const isSelected = (name: string) => selected.some(s => s.name === name)

  return (
    <div style={{ width: '100%', height: '100%', background: BG, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
      {/* App bar */}
      <div style={{ ...glass, flexShrink: 0, height: 64, display: 'flex', alignItems: 'center', padding: '0 16px', gap: 8, borderBottom: '1px solid rgba(0,0,0,0.06)', borderRadius: '0 0 20px 20px', zIndex: 10 }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10, flexShrink: 0, marginLeft: -4 }}>
          <ChevronDown size={22} color={DEEP} strokeWidth={2.5} />
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 19, fontWeight: 800, color: DEEP, letterSpacing: -0.4 }}>New Group</div>
          <div style={{ fontSize: 11, color: '#94A3B8', fontWeight: 500, marginTop: 1 }}>Step 1 of 2 · Add members</div>
        </div>
        {selected.length > 0 && (
          <button
            onClick={onNext}
            style={{ background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, border: 'none', cursor: 'pointer', padding: '8px 16px', borderRadius: 12, color: 'white', fontSize: 13, fontWeight: 700, fontFamily: 'Zain, sans-serif', animation: 'popIn 0.2s cubic-bezier(0.34,1.4,0.64,1)' }}
          >
            Next
          </button>
        )}
      </div>

      {/* Sticky glass shell: search + chips */}
      <div style={{ flexShrink: 0, ...glass, borderBottom: '1px solid rgba(0,0,0,0.06)', zIndex: 5 }}>
        {/* Search bar */}
        <div style={{ padding: '12px 16px 12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: 'rgba(0,0,0,0.05)', borderRadius: 14, padding: '10px 14px' }}>
            <Search size={16} color={FI} strokeWidth={2} />
            <input
              ref={searchRef}
              value={query}
              onChange={e => setQuery(e.target.value)}
              placeholder="Search contacts…"
              style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 14, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 400 }}
            />
            {query && (
              <button onClick={() => setQuery('')} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 2, display: 'flex' }}>
                <X size={14} color={FI} strokeWidth={2} />
              </button>
            )}
          </div>
        </div>

        {/* Selected chips */}
        {selected.length > 0 && (
          <div style={{ padding: '0 16px 12px', animation: 'slideInFromBottom 0.22s ease' }}>
            <div style={{ overflowX: 'auto', display: 'flex', gap: 12, paddingTop: 8, paddingBottom: 4 }}>
              {selected.map(c => (
                <MemberChip key={c.name} name={c.name} initials={c.initials} onRemove={() => onToggle(c)} />
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Section label */}
      <div style={{ flexShrink: 0, padding: '10px 20px 4px' }}>
        <span style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', letterSpacing: 0.6, textTransform: 'uppercase' }}>
          {filtered.length} Contact{filtered.length !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Contact list */}
      <div style={{ flex: 1, minHeight: 0, overflowY: 'auto' }}>
        {filtered.map((c, i) => {
          const sel = isSelected(c.name)
          return (
            <div
              key={c.name}
              onClick={() => onToggle(c)}
              style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '10px 20px', borderBottom: i < filtered.length - 1 ? '1px solid #F4F6F9' : 'none', cursor: 'pointer', transition: 'background 0.12s ease', background: sel ? `${CRIMSON}05` : 'transparent' }}
            >
              {/* Avatar */}
              <div style={{ position: 'relative', flexShrink: 0 }}>
                <div style={{ width: 48, height: 48, borderRadius: 15, background: sel ? `${CRIMSON}20` : `${CRIMSON}12`, color: CRIMSON, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 800, fontFamily: 'Zain, sans-serif', transition: 'background 0.15s ease', border: sel ? `2px solid ${CRIMSON}40` : '2px solid transparent' }}>
                  {c.initials}
                </div>
                {c.online && (
                  <div style={{ position: 'absolute', bottom: 1, right: 1, width: 11, height: 11, borderRadius: '50%', background: '#22C55E', border: '2px solid white' }} />
                )}
              </div>

              {/* Info */}
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 15, fontWeight: 700, color: DEEP }}>{c.name}</div>
                <div style={{ fontSize: 12, color: c.online ? '#22C55E' : '#B0B8C5', fontWeight: c.online ? 500 : 300, marginTop: 1 }}>
                  {c.online ? 'Online' : 'Offline'}
                </div>
              </div>

              {/* Checkbox */}
              <div style={{
                width: 26, height: 26, borderRadius: 9, flexShrink: 0,
                background: sel ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})` : 'transparent',
                border: sel ? 'none' : `2px solid #D1D5DB`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                transition: 'all 0.18s cubic-bezier(0.34,1.4,0.64,1)',
                transform: sel ? 'scale(1.1)' : 'scale(1)',
              }}>
                {sel && <Check size={14} color="white" strokeWidth={2.8} />}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

// ── Step 2 — group info ─────────────────────────────────────────────────────
type Step2Props = {
  selected: typeof CONTACTS
  onBack: () => void
  onCreate: () => void
}

const Step2 = ({ selected, onBack, onCreate }: Step2Props) => {
  const [name, setName] = useState('')
  const [desc, setDesc] = useState('')
  const [isPublic, setIsPublic] = useState(false)
  const [nameFocused, setNameFocused] = useState(false)
  const [descFocused, setDescFocused] = useState(false)

  const initials = name.trim()
    ? name.trim().split(/\s+/).slice(0, 2).map(w => w[0].toUpperCase()).join('')
    : '?'

  const canCreate = name.trim().length > 0

  return (
    <div style={{ width: '100%', height: '100%', background: BG, display: 'flex', flexDirection: 'column', overflow: 'hidden', isolation: 'isolate' }}>
      {/* App bar — solid white so Step 1 beneath doesn't bleed through */}
      <div style={{ flexShrink: 0, height: 64, background: 'white', display: 'flex', alignItems: 'center', padding: '0 16px', gap: 8, borderBottom: '1px solid rgba(0,0,0,0.06)', borderRadius: '0 0 20px 20px', zIndex: 10 }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, display: 'flex', alignItems: 'center', borderRadius: 10, flexShrink: 0, marginLeft: -4 }}>
          <ChevronLeft size={22} color={DEEP} strokeWidth={2.5} />
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 19, fontWeight: 800, color: DEEP, letterSpacing: -0.4 }}>Group Info</div>
          <div style={{ fontSize: 11, color: '#94A3B8', fontWeight: 500, marginTop: 1 }}>Step 2 of 2 · {selected.length} member{selected.length !== 1 ? 's' : ''} added</div>
        </div>
      </div>

      <div style={{ flex: 1, minHeight: 0, overflowY: 'auto' }}>
        {/* Group avatar */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '28px 24px 20px' }}>
          <div style={{ position: 'relative', marginBottom: 10 }}>
            <div style={{
              width: 88, height: 88, borderRadius: 28,
              background: name.trim() ? `${CRIMSON}18` : FIELD_BG,
              color: name.trim() ? CRIMSON : '#B0B8C5',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: name.trim() ? 30 : 26, fontWeight: 800, fontFamily: 'Zain, sans-serif',
              transition: 'all 0.2s ease',
              border: `3px solid ${name.trim() ? `${CRIMSON}25` : '#E8EBF0'}`,
            }}>
              {name.trim() ? initials : <Users size={32} color="#B0B8C5" strokeWidth={1.5} />}
            </div>
            <button style={{
              position: 'absolute', bottom: -4, right: -4,
              width: 28, height: 28, borderRadius: 10,
              background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`,
              border: '2.5px solid white',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              cursor: 'pointer',
            }}>
              <Camera size={13} color="white" strokeWidth={2} />
            </button>
          </div>
          <span style={{ fontSize: 12, color: '#94A3B8', fontWeight: 400 }}>Tap to change photo</span>
        </div>

        {/* Fields */}
        <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 12 }}>
          {/* Group name */}
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Group Name *</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, background: FIELD_BG, borderRadius: 14, padding: '13px 16px', border: nameFocused ? `1.5px solid ${CRIMSON}` : '1.5px solid transparent', transition: 'border 0.2s' }}>
              <input
                autoFocus
                value={name}
                onChange={e => setName(e.target.value.slice(0, 50))}
                onFocus={() => setNameFocused(true)}
                onBlur={() => setNameFocused(false)}
                placeholder="e.g. Team Lunch 🍕"
                style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none', fontSize: 15, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 500 }}
              />
              <span style={{ fontSize: 11, color: name.length > 40 ? CRIMSON : '#B0B8C5', fontWeight: 500, flexShrink: 0 }}>{name.length}/50</span>
            </div>
          </div>

          {/* Description */}
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Description <span style={{ fontWeight: 400, textTransform: 'none', letterSpacing: 0 }}>(optional)</span></div>
            <div style={{ background: FIELD_BG, borderRadius: 14, padding: '13px 16px', border: descFocused ? `1.5px solid ${CRIMSON}` : '1.5px solid transparent', transition: 'border 0.2s' }}>
              <textarea
                value={desc}
                onChange={e => setDesc(e.target.value.slice(0, 200))}
                onFocus={() => setDescFocused(true)}
                onBlur={() => setDescFocused(false)}
                placeholder="What's this group about?"
                rows={3}
                style={{ width: '100%', border: 'none', background: 'transparent', outline: 'none', resize: 'none', fontSize: 14, fontFamily: 'Zain, sans-serif', color: DEEP, fontWeight: 400, lineHeight: 1.5 }}
              />
            </div>
          </div>

          {/* Privacy toggle */}
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Privacy</div>
            <div style={{ display: 'flex', background: FIELD_BG, borderRadius: 14, padding: 4, gap: 4 }}>
              {[
                { label: 'Private', Icon: Lock, val: false },
                { label: 'Public', Icon: Globe, val: true },
              ].map(({ label, Icon, val }) => {
                const active = isPublic === val
                return (
                  <button
                    key={label}
                    onClick={() => setIsPublic(val)}
                    style={{
                      flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7,
                      padding: '10px 0', borderRadius: 11, border: 'none', cursor: 'pointer',
                      background: active ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})` : 'transparent',
                      color: active ? 'white' : '#94A3B8',
                      fontSize: 13, fontWeight: 700, fontFamily: 'Zain, sans-serif',
                      transition: 'all 0.2s cubic-bezier(0.34,1.2,0.64,1)',
                    }}
                  >
                    <Icon size={14} strokeWidth={2.2} />
                    {label}
                  </button>
                )
              })}
            </div>
            <div style={{ fontSize: 12, color: '#94A3B8', fontWeight: 300, marginTop: 8, lineHeight: 1.5, padding: '0 4px' }}>
              {isPublic
                ? 'Anyone can find and join this group via search or link.'
                : 'Only people with an invite link can join this group.'}
            </div>
          </div>

          {/* Members preview */}
          <div>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>
              Members · {selected.length}
            </div>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {selected.map(c => (
                <div key={c.name} style={{ display: 'flex', alignItems: 'center', gap: 8, background: FIELD_BG, borderRadius: 12, padding: '7px 12px 7px 8px' }}>
                  <div style={{ width: 28, height: 28, borderRadius: 9, background: `${CRIMSON}15`, color: CRIMSON, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 10, fontWeight: 800, fontFamily: 'Zain, sans-serif' }}>
                    {c.initials}
                  </div>
                  <span style={{ fontSize: 13, fontWeight: 600, color: DEEP }}>{c.name.split(' ')[0]}</span>
                </div>
              ))}
            </div>
          </div>

          <div style={{ height: 20 }} />
        </div>
      </div>

      {/* Create button */}
      <div style={{ flexShrink: 0, padding: '12px 20px 28px', ...glass, borderTop: '1px solid rgba(0,0,0,0.06)' }}>
        <button
          onClick={canCreate ? onCreate : undefined}
          style={{
            width: '100%', padding: '15px 0', borderRadius: 18, border: 'none', cursor: canCreate ? 'pointer' : 'default',
            background: canCreate ? `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})` : FIELD_BG,
            color: canCreate ? 'white' : '#B0B8C5',
            fontSize: 16, fontWeight: 800, fontFamily: 'Zain, sans-serif', letterSpacing: -0.2,
            transition: 'all 0.2s ease',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          }}
        >
          <Users size={18} strokeWidth={2.2} />
          Create Group
        </button>
      </div>
    </div>
  )
}

// ── Main export ─────────────────────────────────────────────────────────────
export const NewGroupScreen = ({ onBack }: { onBack: () => void }) => {
  const [step, setStep] = useState<1 | 2>(1)
  const [selected, setSelected] = useState<typeof CONTACTS>([])
  const [closing, setClosing] = useState(false)

  const handleBack = () => { setClosing(true); setTimeout(onBack, 280) }

  const toggle = (c: typeof CONTACTS[0]) => {
    setSelected(prev =>
      prev.some(s => s.name === c.name)
        ? prev.filter(s => s.name !== c.name)
        : [...prev, c]
    )
  }

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative', overflow: 'hidden', animation: `${closing ? 'slideOutToBottom' : 'slideInFromBottom'} 0.30s cubic-bezier(0.4,0,0.2,1) both` }}>
      {/* Step 1 always stays mounted so Step 2 slides in over it with no flash */}
      <div style={{ position: 'absolute', inset: 0 }}>
        <Step1
          selected={selected}
          onToggle={toggle}
          onNext={() => setStep(2)}
          onBack={handleBack}
        />
      </div>

      {step === 2 && (
        <div style={{ position: 'absolute', inset: 0, animation: 'slideInFromRight 0.26s cubic-bezier(0.4,0,0.2,1) both' }}>
          <Step2
            selected={selected}
            onBack={() => setStep(1)}
            onCreate={handleBack}
          />
        </div>
      )}
    </div>
  )
}
