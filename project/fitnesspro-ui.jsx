// FitnessPro — Shared UI components
const { useState, useEffect, useRef } = React;

const C = {
  bg: '#0C0C14', surface: '#141420', surface2: '#1C1C2A',
  border: '#252538', accent: '#C1FF4D', accentDark: '#8FCC1F',
  orange: '#FF6B35', text: '#F0F0F8', muted: '#5A5A78',
  muted2: '#8A8AAA', red: '#FF4F4F', green: '#4ADE80', blue: '#60A5FA',
  purple: '#A78BFA',
};

function FPBtn({ children, onClick, style, variant='primary', disabled, small }) {
  const base = {
    width:'100%', padding: small ? '10px 16px' : '14px',
    borderRadius:12, border:'none', cursor: disabled ? 'not-allowed' : 'pointer',
    fontSize: small ? 13 : 15, fontWeight:700, letterSpacing:0.3,
    transition:'opacity 0.15s, transform 0.1s', opacity: disabled ? 0.4 : 1,
    fontFamily:"'Space Grotesk', sans-serif", ...style
  };
  const variants = {
    primary:   { background: C.accent, color:'#0C0C14' },
    secondary: { background: C.surface2, color: C.text, border:`1px solid ${C.border}` },
    ghost:     { background:'transparent', color: C.muted2, border:`1px solid ${C.border}` },
    danger:    { background:'#FF4F4F22', color: C.red, border:`1px solid #FF4F4F33` },
    orange:    { background: C.orange, color:'#fff' },
  };
  return (
    <button style={{...base,...variants[variant]}} onClick={onClick} disabled={disabled}
      onMouseDown={e=>{ if(!disabled) e.currentTarget.style.transform='scale(0.97)'; }}
      onMouseUp={e=>{ e.currentTarget.style.transform='scale(1)'; }}
      onMouseLeave={e=>{ e.currentTarget.style.transform='scale(1)'; }}>
      {children}
    </button>
  );
}

function FPBottomNav({ screen, setScreen }) {
  const tabs = [
    { id:'dashboard', label:'Accueil', icon: (a) => (
      <svg width={22} height={22} viewBox="0 0 24 24" fill={a?C.accent:'none'} stroke={a?C.accent:C.muted} strokeWidth={a?2.5:1.8}>
        <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
        <polyline points="9,22 9,12 15,12 15,22" stroke={a?'#0C0C14':C.muted} strokeWidth={a?2:1.8} fill="none"/>
      </svg>)},
    { id:'ai', label:'Coach IA', icon: (a) => (
      <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={a?C.accent:C.muted} strokeWidth={a?2.5:1.8}>
        <rect x="3" y="3" width="18" height="14" rx="4"/><path d="M8 17v2m8-2v2m-5 0h4"/><circle cx="9" cy="10" r="1.2" fill={a?C.accent:C.muted}/><circle cx="15" cy="10" r="1.2" fill={a?C.accent:C.muted}/>
      </svg>)},
    { id:'food', label:'Scanner', icon: (a) => (
      <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={a?C.accent:C.muted} strokeWidth={a?2.5:1.8}>
        <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/>
        <circle cx="12" cy="13" r="4"/>
      </svg>)},
    { id:'exercises', label:'Exercices', icon: (a) => (
      <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={a?C.accent:C.muted} strokeWidth={a?2.5:1.8}>
        <path d="M4 8h2m0 0v8m0-8a2 2 0 012-2h8a2 2 0 012 2m-12 0v8m12-8v8m0 0h2m-2 0a2 2 0 01-2 2H8a2 2 0 01-2-2m0 0V8"/>
      </svg>)},
    { id:'workouts', label:'Séances', icon: (a) => (
      <svg width={22} height={22} viewBox="0 0 24 24" fill="none" stroke={a?C.accent:C.muted} strokeWidth={a?2.5:1.8}>
        <rect x="3" y="4" width="18" height="18" rx="3"/><path d="M16 2v4M8 2v4M3 10h18"/>
        <path d="M8 14h.01M12 14h.01M16 14h.01M8 18h.01M12 18h.01" strokeWidth={2.5} strokeLinecap="round"/>
      </svg>)},
  ];
  return (
    <div style={{ display:'flex', background:C.surface, borderTop:`1px solid ${C.border}`, padding:'6px 0 8px', flexShrink:0 }}>
      {tabs.map(t => {
        const active = screen === t.id;
        return (
          <button key={t.id} onClick={()=>setScreen(t.id)} style={{
            flex:1, background:'none', border:'none', cursor:'pointer',
            display:'flex', flexDirection:'column', alignItems:'center', gap:3,
            color: active ? C.accent : C.muted, padding:'4px 0',
            fontFamily:"'Space Grotesk', sans-serif",
          }}>
            {t.icon(active)}
            <span style={{ fontSize:10, fontWeight: active ? 700 : 500 }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

function ProgressBar({ value, max, color=C.accent, height=6, animated }) {
  const pct = Math.min(100, (value/max)*100);
  return (
    <div style={{ background:C.surface2, borderRadius:999, height, overflow:'hidden' }}>
      <div style={{ width:`${pct}%`, height:'100%', background:color, borderRadius:999, transition: animated ? 'width 0.5s ease' : undefined }} />
    </div>
  );
}

function BackHeader({ title, onBack, rightEl, transparent }) {
  return (
    <div style={{
      display:'flex', alignItems:'center', padding:'12px 16px',
      borderBottom: transparent ? 'none' : `1px solid ${C.border}`,
      flexShrink:0, gap:12, background: transparent ? 'transparent' : C.bg,
    }}>
      <button onClick={onBack} style={{
        background:C.surface2, border:`1px solid ${C.border}`, cursor:'pointer',
        color:C.text, borderRadius:10, width:36, height:36,
        display:'flex', alignItems:'center', justifyContent:'center',
      }}>
        <svg width={18} height={18} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.2}>
          <path d="M19 12H5M12 5l-7 7 7 7"/>
        </svg>
      </button>
      <span style={{ flex:1, fontWeight:700, fontSize:16, color:C.text }}>{title}</span>
      {rightEl}
    </div>
  );
}

function Chip({ label, color=C.accent }) {
  return (
    <span style={{
      display:'inline-block', padding:'3px 10px', borderRadius:999,
      fontSize:11, fontWeight:700, background:`${color}22`, color,
      letterSpacing:0.5, whiteSpace:'nowrap',
    }}>{label}</span>
  );
}

function DifficultyChip({ level }) {
  const colors = { Débutant:C.green, Intermédiaire:C.orange, Avancé:C.red };
  return <Chip label={level} color={colors[level] || C.muted2} />;
}

function Card({ children, style, onClick }) {
  return (
    <div onClick={onClick} style={{
      background:C.surface, borderRadius:16, padding:16,
      border:`1px solid ${C.border}`, marginBottom:12,
      cursor: onClick ? 'pointer' : undefined,
      ...style
    }}>{children}</div>
  );
}

function SectionTitle({ children }) {
  return <div style={{ fontSize:12, fontWeight:700, color:C.muted2, letterSpacing:1, textTransform:'uppercase', marginBottom:10, marginTop:4 }}>{children}</div>;
}

function Divider() {
  return <div style={{ height:1, background:C.border, margin:'12px 0' }} />;
}

Object.assign(window, { C, FPBtn, FPBottomNav, ProgressBar, BackHeader, Chip, DifficultyChip, Card, SectionTitle, Divider });
