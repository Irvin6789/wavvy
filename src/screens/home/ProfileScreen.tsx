import { Camera, ChevronRight, LogOut } from 'lucide-react'
import { CRIMSON, CRIMSON_LIGHT, DEEP, BG, FIELD_BG } from '@/constants/colors'
import { PROFILE_STATS, PROFILE_SECTIONS } from '@/data/profile'

export const ProfileScreen = () => (
  <div style={{ width: '100%', background: BG }}>
    {/* Avatar + name */}
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: 28, paddingBottom: 20 }}>
      <div style={{ position: 'relative', marginBottom: 14 }}>
        <div style={{ width: 80, height: 80, borderRadius: 26, background: `linear-gradient(135deg, ${CRIMSON_LIGHT}, ${CRIMSON})`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, fontWeight: 800, color: 'white', fontFamily: 'Zain, sans-serif' }}>
          YO
        </div>
        <div style={{ position: 'absolute', bottom: -3, right: -3, width: 24, height: 24, borderRadius: '50%', background: CRIMSON, border: '2px solid white', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Camera size={11} color="white" strokeWidth={2.5} />
        </div>
      </div>
      <div style={{ fontSize: 20, fontWeight: 800, color: DEEP, letterSpacing: -0.3 }}>Your Name</div>
      <div style={{ fontSize: 13, color: '#94A3B8', marginTop: 3 }}>@yourhandle</div>
    </div>

    {/* Stats */}
    <div style={{ display: 'flex', margin: '16px 20px', background: FIELD_BG, borderRadius: 18, overflow: 'hidden' }}>
      {PROFILE_STATS.map(({ label, value }, i) => (
        <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '14px 0', borderRight: i < PROFILE_STATS.length - 1 ? '1px solid #E4E8EF' : 'none' }}>
          <span style={{ fontSize: 20, fontWeight: 800, color: DEEP, letterSpacing: -0.5 }}>{value}</span>
          <span style={{ fontSize: 11, color: '#94A3B8', fontWeight: 400, marginTop: 2 }}>{label}</span>
        </div>
      ))}
    </div>

    {/* Edit profile */}
    <div style={{ padding: '0 20px 6px' }}>
      <button style={{ width: '100%', padding: '11px 0', background: `${CRIMSON}12`, border: `1.5px solid ${CRIMSON}30`, borderRadius: 14, fontSize: 14, fontWeight: 700, color: CRIMSON, fontFamily: 'Zain, sans-serif', cursor: 'pointer', letterSpacing: 0.2 }}>
        Edit Profile
      </button>
    </div>

    {/* Settings sections */}
    {PROFILE_SECTIONS.map(({ title, rows }) => (
      <div key={title} style={{ margin: '14px 20px 0' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', letterSpacing: 1.1, textTransform: 'uppercase', marginBottom: 8, paddingLeft: 2 }}>{title}</div>
        <div style={{ background: FIELD_BG, borderRadius: 16, overflow: 'hidden' }}>
          {rows.map(({ Icon, label, sub }, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '13px 16px', borderBottom: i < rows.length - 1 ? '1px solid rgba(0,0,0,0.05)' : 'none', cursor: 'pointer' }}>
              <div style={{ width: 36, height: 36, borderRadius: 11, background: `${CRIMSON}14`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Icon size={17} color={CRIMSON} strokeWidth={1.9} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: DEEP }}>{label}</div>
                <div style={{ fontSize: 12, color: '#94A3B8', fontWeight: 300, marginTop: 1 }}>{sub}</div>
              </div>
              <ChevronRight size={16} color="#C4CAD4" strokeWidth={2} />
            </div>
          ))}
        </div>
      </div>
    ))}

    {/* Log out */}
    <div style={{ margin: '14px 20px 100px' }}>
      <button style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, padding: '13px 0', background: '#FFF1F2', border: '1px solid #FECDD3', borderRadius: 16, fontSize: 14, fontWeight: 700, color: '#E11D48', fontFamily: 'Zain, sans-serif', cursor: 'pointer' }}>
        <LogOut size={16} color="#E11D48" strokeWidth={2} />
        Log out
      </button>
    </div>
  </div>
)
