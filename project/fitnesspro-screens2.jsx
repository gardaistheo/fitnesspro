// FitnessPro — Dashboard, AI Chat, Food Scan screens
const { useState: useState2, useEffect: useEffect2, useRef: useRef2 } = React;

/* ─── DASHBOARD ─── */
function DashboardScreen({ quizData, planning, setScreen, setDetailTarget }) {
  const caloriesIn = quizData?.caloriesIn || 2200;
  const caloriesBase = quizData?.caloriesOut || 400;
  const calorieSport = 320;
  const caloriesLeft = caloriesIn - (caloriesBase - calorieSport);
  const pct = Math.max(0, Math.min(100, (caloriesLeft / caloriesIn) * 100));

  const [hydration, setHydration] = useState2(1.25);
  const hydrationGoal = 2.5;

  const nextWorkout = planning && planning.length > 0 ? planning[0] : null;

  function formatDate(dateStr) {
    if (!dateStr) return '';
    const d = new Date(dateStr + 'T00:00:00');
    return d.toLocaleDateString('fr-FR', { weekday:'long', day:'numeric', month:'long' });
  }

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      {/* Header */}
      <div style={{ padding:'16px 20px 12px', flexShrink:0 }}>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
          <div>
            <div style={{ fontSize:12, color:C.muted2, fontWeight:600 }}>Bonjour 👋</div>
            <div style={{ fontSize:22, fontWeight:900 }}>Mon tableau de bord</div>
          </div>
          <div style={{ background:`${C.accent}22`, borderRadius:12, padding:'6px 12px', border:`1px solid ${C.accent}44` }}>
            <span style={{ fontSize:11, fontWeight:700, color:C.accent }}>🔥 12 jours</span>
          </div>
        </div>
      </div>

      <div style={{ flex:1, overflowY:'auto', padding:'0 16px 16px' }}>
        {/* Streak */}
        <Card style={{ background:`linear-gradient(135deg, ${C.accent}22 0%, ${C.surface} 60%)`, border:`1px solid ${C.accent}44` }}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
            <div>
              <div style={{ fontSize:11, color:C.accent, fontWeight:700, letterSpacing:1, textTransform:'uppercase', marginBottom:4 }}>Streak d'entraînement</div>
              <div style={{ fontSize:36, fontWeight:900, color:C.text, lineHeight:1 }}>12 <span style={{ fontSize:16, color:C.muted2, fontWeight:500 }}>jours consécutifs</span></div>
              <div style={{ fontSize:13, color:C.muted2, marginTop:4 }}>Continue comme ça ! 🚀</div>
            </div>
            <div style={{ fontSize:52 }}>🔥</div>
          </div>
        </Card>

        {/* Next workout */}
        <SectionTitle>Prochaine séance</SectionTitle>
        {nextWorkout ? (
          <Card onClick={() => { setDetailTarget('planning'); setScreen('planning'); }} style={{ cursor:'pointer' }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', marginBottom:12 }}>
              <div>
                <div style={{ fontSize:11, color:C.muted2, marginBottom:4 }}>{formatDate(nextWorkout.date)} · {nextWorkout.time}</div>
                <div style={{ fontSize:18, fontWeight:800 }}>{nextWorkout.workoutName}</div>
                <div style={{ fontSize:13, color:C.muted2, marginTop:2 }}>{nextWorkout.muscles}</div>
              </div>
              <Chip label={`${nextWorkout.duration} min`} color={C.blue} />
            </div>
            <FPBtn small style={{ width:'auto', padding:'8px 20px' }} onClick={e => { e.stopPropagation(); setDetailTarget('planning'); setScreen('planning'); }}>
              Voir le planning →
            </FPBtn>
          </Card>
        ) : (
          <Card>
            <div style={{ textAlign:'center', padding:'12px 0' }}>
              <div style={{ fontSize:32, marginBottom:8 }}>📅</div>
              <div style={{ color:C.muted2, fontSize:14 }}>Aucune séance planifiée</div>
              <FPBtn small style={{ marginTop:12, width:'auto', padding:'8px 20px' }} onClick={() => setScreen('workouts')}>Ajouter une séance</FPBtn>
            </div>
          </Card>
        )}

        {/* Hydration */}
        <SectionTitle>Hydratation du jour</SectionTitle>
        <Card>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:10 }}>
            <div>
              <div style={{ fontSize:11, color:C.blue, fontWeight:700, letterSpacing:1, textTransform:'uppercase', marginBottom:2 }}>Eau bue</div>
              <div style={{ fontSize:24, fontWeight:800 }}>{hydration.toFixed(2).replace('.',',')} <span style={{ fontSize:14, color:C.muted2, fontWeight:500 }}>/ {hydrationGoal} L</span></div>
            </div>
            <div style={{ fontSize:36 }}>💧</div>
          </div>
          <ProgressBar value={hydration} max={hydrationGoal} color={C.blue} height={8} animated />
          <div style={{ display:'flex', gap:8, marginTop:12 }}>
            {[0.25, 0.5].map(amt => (
              <button key={amt} onClick={() => setHydration(h => Math.min(hydrationGoal, h + amt))} style={{
                flex:1, padding:'8px', borderRadius:10, border:`1px solid ${C.border}`,
                background:C.surface2, color:C.blue, cursor:'pointer', fontWeight:700, fontSize:13,
                fontFamily:"'Space Grotesk',sans-serif",
              }}>+ {amt === 0.25 ? '250 ml' : '500 ml'}</button>
            ))}
            <button onClick={() => setHydration(0)} style={{
              padding:'8px 12px', borderRadius:10, border:`1px solid ${C.border}`,
              background:C.surface2, color:C.muted, cursor:'pointer', fontSize:13,
              fontFamily:"'Space Grotesk',sans-serif",
            }}>↺</button>
          </div>
        </Card>

        {/* Calories */}
        <SectionTitle>Suivi calorique</SectionTitle>
        <Card>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:10 }}>
            <div>
              <div style={{ fontSize:11, color:C.orange, fontWeight:700, letterSpacing:1, textTransform:'uppercase', marginBottom:2 }}>Calories restantes</div>
              <div style={{ fontSize:28, fontWeight:900, color: caloriesLeft < 200 ? C.red : C.text }}>
                {caloriesLeft.toLocaleString('fr-FR')} <span style={{ fontSize:14, color:C.muted2, fontWeight:500 }}>kcal</span>
              </div>
            </div>
            <div style={{ fontSize:36 }}>🥗</div>
          </div>
          <ProgressBar value={caloriesLeft} max={caloriesIn} color={caloriesLeft < 300 ? C.red : C.orange} height={8} animated />
          {/* Formula breakdown */}
          <div style={{ marginTop:14, background:C.surface2, borderRadius:10, padding:'10px 12px', fontSize:12 }}>
            <div style={{ color:C.muted2, marginBottom:6, fontWeight:700, letterSpacing:0.5 }}>DÉTAIL DU CALCUL</div>
            <div style={{ display:'flex', justifyContent:'space-between', marginBottom:4 }}>
              <span style={{ color:C.muted2 }}>Apports cibles</span>
              <span style={{ color:C.green, fontWeight:700 }}>+{caloriesIn.toLocaleString('fr-FR')} kcal</span>
            </div>
            <div style={{ display:'flex', justifyContent:'space-between', marginBottom:4 }}>
              <span style={{ color:C.muted2 }}>Dépenses journalières</span>
              <span style={{ color:C.red, fontWeight:700 }}>−{caloriesBase} kcal</span>
            </div>
            <div style={{ display:'flex', justifyContent:'space-between', marginBottom:6 }}>
              <span style={{ color:C.muted2 }}>Sport du jour</span>
              <span style={{ color:C.accent, fontWeight:700 }}>+{calorieSport} kcal</span>
            </div>
            <div style={{ borderTop:`1px solid ${C.border}`, paddingTop:6, display:'flex', justifyContent:'space-between', fontWeight:800 }}>
              <span style={{ color:C.text }}>= Restant</span>
              <span style={{ color:C.orange }}>{caloriesLeft.toLocaleString('fr-FR')} kcal</span>
            </div>
          </div>
          <FPBtn small variant="ghost" style={{ marginTop:10 }} onClick={() => setScreen('food')}>📷 Scanner un repas</FPBtn>
        </Card>
      </div>
    </div>
  );
}

/* ─── AI CHAT ─── */
function AIScreen() {
  const [messages, setMessages] = useState2(FP_INITIAL_CHAT);
  const [input, setInput] = useState2('');
  const [loading, setLoading] = useState2(false);
  const [showHistory, setShowHistory] = useState2(false);
  const endRef = useRef2(null);

  const history = [
    { id:1, preview:'Quels exercices pour gagner du dos ?', date:'Aujourd\'hui' },
    { id:2, preview:'Programme perdre du poids débutant', date:'Hier' },
    { id:3, preview:'Comment bien manger avant un entraînement ?', date:'22 avr.' },
  ];

  useEffect2(() => {
    if (endRef.current) endRef.current.parentElement.scrollTop = endRef.current.parentElement.scrollHeight;
  }, [messages]);

  async function send() {
    if (!input.trim() || loading) return;
    const userMsg = { role:'user', text: input };
    setMessages(m => [...m, userMsg]);
    setInput('');
    setLoading(true);
    try {
      const reply = await window.claude.complete({
        messages: [
          { role:'user', content:`Tu es CoachAI, un expert en musculation et nutrition sportive. Tu réponds en français, de façon concise, précise et encourageante. Question : ${input}` }
        ]
      });
      setMessages(m => [...m, { role:'assistant', text: reply }]);
    } catch {
      setMessages(m => [...m, { role:'assistant', text:'Désolé, je rencontre un problème. Réessaie dans un instant !' }]);
    }
    setLoading(false);
  }

  function renderText(text) {
    return text.split('\n').map((line, i) => {
      const bold = line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
      return <div key={i} style={{ marginBottom: line === '' ? 6 : 0 }} dangerouslySetInnerHTML={{ __html: bold }} />;
    });
  }

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      {/* Header */}
      <div style={{ padding:'14px 16px', borderBottom:`1px solid ${C.border}`, flexShrink:0, display:'flex', alignItems:'center', gap:12 }}>
        <div style={{ width:38, height:38, borderRadius:12, background:`${C.purple}22`, border:`1px solid ${C.purple}44`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:20 }}>🧠</div>
        <div style={{ flex:1 }}>
          <div style={{ fontWeight:800, fontSize:15 }}>Coach IA</div>
          <div style={{ fontSize:11, color:C.green }}>● En ligne</div>
        </div>
        <button onClick={()=>setShowHistory(true)} style={{ background:C.surface2, border:`1px solid ${C.border}`, borderRadius:10, padding:'6px 12px', color:C.muted2, cursor:'pointer', fontSize:12, fontFamily:"'Space Grotesk',sans-serif", fontWeight:600 }}>
          Historique
        </button>
      </div>

      {/* Messages */}
      <div style={{ flex:1, overflowY:'auto', padding:'16px' }}>
        {messages.map((m, i) => (
          <div key={i} style={{ display:'flex', justifyContent: m.role==='user' ? 'flex-end' : 'flex-start', marginBottom:12 }}>
            {m.role === 'assistant' && (
              <div style={{ width:28, height:28, borderRadius:8, background:`${C.purple}22`, display:'flex', alignItems:'center', justifyContent:'center', marginRight:8, flexShrink:0, fontSize:14 }}>🧠</div>
            )}
            <div style={{
              maxWidth:'82%', padding:'10px 14px', borderRadius: m.role==='user' ? '16px 16px 4px 16px' : '16px 16px 16px 4px',
              background: m.role==='user' ? C.accent : C.surface2,
              color: m.role==='user' ? '#0C0C14' : C.text,
              fontSize:14, lineHeight:1.6, fontWeight: m.role==='user' ? 600 : 400,
            }}>
              {renderText(m.text)}
            </div>
          </div>
        ))}
        {loading && (
          <div style={{ display:'flex', gap:8, marginBottom:12 }}>
            <div style={{ width:28, height:28, borderRadius:8, background:`${C.purple}22`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:14 }}>🧠</div>
            <div style={{ background:C.surface2, borderRadius:'16px 16px 16px 4px', padding:'12px 16px', display:'flex', gap:5 }}>
              {[0,1,2].map(i=>(
                <div key={i} style={{ width:7, height:7, borderRadius:'50%', background:C.muted2, animation:`pulse${i} 1s ease-in-out infinite`, animationDelay:`${i*0.2}s` }} />
              ))}
            </div>
          </div>
        )}
        <div ref={endRef} />
      </div>

      {/* Suggestions */}
      <div style={{ padding:'0 16px 8px', display:'flex', gap:8, overflowX:'auto', flexShrink:0 }}>
        {['Programme débutant ?','Nutrition avant sport','Récupération musculaire'].map(s => (
          <button key={s} onClick={()=>setInput(s)} style={{
            whiteSpace:'nowrap', padding:'6px 14px', borderRadius:999, background:C.surface2,
            border:`1px solid ${C.border}`, color:C.muted2, cursor:'pointer', fontSize:12, fontWeight:600,
            fontFamily:"'Space Grotesk',sans-serif",
          }}>{s}</button>
        ))}
      </div>

      {/* Input */}
      <div style={{ padding:'8px 16px 16px', flexShrink:0, display:'flex', gap:10 }}>
        <input value={input} onChange={e=>setInput(e.target.value)}
          onKeyDown={e=>{ if(e.key==='Enter') send(); }}
          placeholder="Pose ta question au coach..."
          style={{ flex:1, background:C.surface2, border:`1px solid ${C.border}`, borderRadius:12, padding:'12px 14px', color:C.text, fontSize:14, fontFamily:"'Space Grotesk',sans-serif" }} />
        <button onClick={send} disabled={!input.trim()||loading} style={{
          background: input.trim() ? C.accent : C.surface2, border:'none', borderRadius:12,
          width:46, height:46, cursor: input.trim() ? 'pointer' : 'default',
          display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0,
        }}>
          <svg width={18} height={18} viewBox="0 0 24 24" fill="none" stroke={input.trim() ? '#0C0C14' : C.muted} strokeWidth={2.5}>
            <line x1="22" y1="2" x2="11" y2="13"/><polygon points="22,2 15,22 11,13 2,9"/>
          </svg>
        </button>
      </div>

      {/* History modal */}
      {showHistory && (
        <div style={{ position:'absolute', inset:0, background:'rgba(0,0,0,0.7)', display:'flex', alignItems:'flex-end', zIndex:50 }} onClick={()=>setShowHistory(false)}>
          <div style={{ width:'100%', background:C.surface, borderRadius:'20px 20px 0 0', padding:'20px', boxSizing:'border-box' }} onClick={e=>e.stopPropagation()}>
            <div style={{ fontWeight:800, fontSize:16, marginBottom:16 }}>Conversations précédentes</div>
            {history.map(h => (
              <div key={h.id} onClick={()=>setShowHistory(false)} style={{
                padding:'12px 14px', borderRadius:12, background:C.surface2, border:`1px solid ${C.border}`,
                marginBottom:8, cursor:'pointer',
              }}>
                <div style={{ fontWeight:600, fontSize:14, marginBottom:2 }}>{h.preview}</div>
                <div style={{ fontSize:11, color:C.muted }}>{h.date}</div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

/* ─── FOOD SCAN ─── */
function FoodScreen({ onCaloriesLogged }) {
  const [phase, setPhase] = useState2('camera'); // camera | scanning | result | manual | logged
  const [manualCals, setManualCals] = useState2('');
  const [scannedFood, setScannedFood] = useState2(null);

  const mockFoods = [
    { name:'Poulet grillé + riz', cals:520, protein:45, carbs:52, fat:8 },
    { name:'Salade César', cals:340, protein:22, carbs:18, fat:22 },
    { name:'Pâtes bolognaise', cals:680, protein:38, carbs:72, fat:24 },
  ];

  function handleScan() {
    setPhase('scanning');
    setTimeout(() => {
      setScannedFood(mockFoods[Math.floor(Math.random()*mockFoods.length)]);
      setPhase('result');
    }, 2200);
  }

  function handleLog(cals) {
    onCaloriesLogged && onCaloriesLogged(cals);
    setPhase('logged');
    setTimeout(() => setPhase('camera'), 2500);
  }

  const numpadKeys = ['1','2','3','4','5','6','7','8','9','.','0','⌫'];

  function numpadPress(key) {
    if (key === '⌫') setManualCals(v => v.slice(0,-1));
    else if (key === '.' && manualCals.includes('.')) return;
    else if (manualCals.length < 5) setManualCals(v => v + key);
  }

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <div style={{ padding:'14px 16px', borderBottom:`1px solid ${C.border}`, flexShrink:0, display:'flex', alignItems:'center', gap:12 }}>
        <div style={{ fontSize:20 }}>📷</div>
        <div style={{ fontWeight:800, fontSize:16 }}>Scanner alimentaire</div>
        {phase !== 'manual' ? (
          <button onClick={()=>setPhase('manual')} style={{ marginLeft:'auto', background:'none', border:`1px solid ${C.border}`, borderRadius:8, padding:'5px 12px', color:C.muted2, cursor:'pointer', fontSize:12, fontFamily:"'Space Grotesk',sans-serif" }}>Saisie manuelle</button>
        ) : (
          <button onClick={()=>setPhase('camera')} style={{ marginLeft:'auto', background:'none', border:`1px solid ${C.border}`, borderRadius:8, padding:'5px 12px', color:C.muted2, cursor:'pointer', fontSize:12, fontFamily:"'Space Grotesk',sans-serif" }}>Scanner</button>
        )}
      </div>

      <div style={{ flex:1, overflow:'hidden', display:'flex', flexDirection:'column' }}>
        {phase === 'camera' && (
          <div style={{ flex:1, display:'flex', flexDirection:'column' }}>
            {/* Viewfinder */}
            <div style={{ flex:1, background:'#050508', position:'relative', display:'flex', alignItems:'center', justifyContent:'center' }}>
              <div style={{ position:'absolute', inset:0, backgroundImage:`repeating-linear-gradient(0deg, transparent, transparent 39px, #ffffff06 39px, #ffffff06 40px), repeating-linear-gradient(90deg, transparent, transparent 39px, #ffffff06 39px, #ffffff06 40px)` }} />
              <div style={{ position:'relative', textAlign:'center' }}>
                <div style={{ width:220, height:180, border:`2px solid ${C.accent}`, borderRadius:16, margin:'0 auto', position:'relative' }}>
                  <div style={{ position:'absolute', top:-2, left:-2, width:20, height:20, borderTop:`3px solid ${C.accent}`, borderLeft:`3px solid ${C.accent}`, borderRadius:'4px 0 0 0' }} />
                  <div style={{ position:'absolute', top:-2, right:-2, width:20, height:20, borderTop:`3px solid ${C.accent}`, borderRight:`3px solid ${C.accent}`, borderRadius:'0 4px 0 0' }} />
                  <div style={{ position:'absolute', bottom:-2, left:-2, width:20, height:20, borderBottom:`3px solid ${C.accent}`, borderLeft:`3px solid ${C.accent}`, borderRadius:'0 0 0 4px' }} />
                  <div style={{ position:'absolute', bottom:-2, right:-2, width:20, height:20, borderBottom:`3px solid ${C.accent}`, borderRight:`3px solid ${C.accent}`, borderRadius:'0 0 4px 0' }} />
                  <div style={{ position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center', flexDirection:'column', gap:8 }}>
                    <div style={{ fontSize:36 }}>🍽️</div>
                    <div style={{ fontSize:12, color:`${C.accent}99` }}>Centrez votre assiette</div>
                  </div>
                </div>
                <div style={{ fontSize:11, color:C.muted2, marginTop:16 }}>Powered by Passio AI</div>
              </div>
            </div>
            <div style={{ padding:'20px 24px', flexShrink:0, textAlign:'center' }}>
              <button onClick={handleScan} style={{
                width:70, height:70, borderRadius:'50%', background:C.accent,
                border:'4px solid #ffffff22', cursor:'pointer',
                display:'flex', alignItems:'center', justifyContent:'center', margin:'0 auto',
              }}>
                <svg width={28} height={28} viewBox="0 0 24 24" fill="none" stroke="#0C0C14" strokeWidth={2.5}>
                  <circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="3" fill="#0C0C14"/>
                </svg>
              </button>
              <div style={{ fontSize:12, color:C.muted, marginTop:10 }}>Appuyez pour scanner</div>
            </div>
          </div>
        )}

        {phase === 'scanning' && (
          <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:16 }}>
            <div style={{ width:80, height:80, borderRadius:'50%', border:`4px solid ${C.accent}33`, borderTopColor:C.accent, animation:'spin 1s linear infinite' }} />
            <div style={{ fontWeight:700, fontSize:16 }}>Analyse en cours…</div>
            <div style={{ fontSize:13, color:C.muted2 }}>Identification des aliments par IA</div>
          </div>
        )}

        {phase === 'result' && scannedFood && (
          <div style={{ flex:1, overflowY:'auto', padding:'20px 16px' }}>
            <div style={{ background:`${C.accent}18`, border:`1px solid ${C.accent}44`, borderRadius:16, padding:16, marginBottom:16 }}>
              <div style={{ fontSize:11, color:C.accent, fontWeight:700, letterSpacing:1, marginBottom:6 }}>✓ REPAS IDENTIFIÉ</div>
              <div style={{ fontWeight:800, fontSize:20, marginBottom:4 }}>{scannedFood.name}</div>
              <div style={{ fontSize:32, fontWeight:900, color:C.accent }}>{scannedFood.cals} <span style={{ fontSize:16, color:C.muted2, fontWeight:500 }}>kcal</span></div>
            </div>
            <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:10, marginBottom:20 }}>
              {[['Protéines',scannedFood.protein,'g',C.blue],['Glucides',scannedFood.carbs,'g',C.orange],['Lipides',scannedFood.fat,'g',C.purple]].map(([label,val,unit,color])=>(
                <div key={label} style={{ background:C.surface2, borderRadius:12, padding:'12px 10px', textAlign:'center', border:`1px solid ${C.border}` }}>
                  <div style={{ fontSize:20, fontWeight:800, color }}>{val}{unit}</div>
                  <div style={{ fontSize:11, color:C.muted2, marginTop:2 }}>{label}</div>
                </div>
              ))}
            </div>
            <FPBtn onClick={()=>handleLog(scannedFood.cals)}>Ajouter au suivi calorique</FPBtn>
            <FPBtn variant="ghost" style={{ marginTop:10 }} onClick={()=>setPhase('camera')}>Rescanner</FPBtn>
            <FPBtn variant="ghost" style={{ marginTop:8 }} onClick={()=>setPhase('manual')}>Saisie manuelle</FPBtn>
          </div>
        )}

        {phase === 'logged' && (
          <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:12, padding:24 }}>
            <div style={{ width:70, height:70, borderRadius:'50%', background:`${C.green}22`, border:`2px solid ${C.green}`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:32 }}>✓</div>
            <div style={{ fontWeight:800, fontSize:18 }}>Repas enregistré !</div>
            <div style={{ fontSize:14, color:C.muted2 }}>Le suivi calorique a été mis à jour.</div>
          </div>
        )}

        {phase === 'manual' && (
          <div style={{ flex:1, display:'flex', flexDirection:'column' }}>
            <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding:'16px 24px' }}>
              <div style={{ fontSize:13, color:C.muted2, marginBottom:8 }}>Calories à ajouter</div>
              <div style={{ fontSize:56, fontWeight:900, color: manualCals ? C.text : C.muted, minHeight:72, lineHeight:1 }}>
                {manualCals || '0'}
              </div>
              <div style={{ fontSize:16, color:C.muted2, marginTop:4 }}>kcal</div>
              <div style={{ display:'flex', gap:10, marginTop:16, flexWrap:'wrap', justifyContent:'center' }}>
                {[{label:'Snack léger',cal:150},{label:'Repas complet',cal:600},{label:'Collation',cal:250}].map(p=>(
                  <button key={p.cal} onClick={()=>setManualCals(String(p.cal))} style={{
                    padding:'6px 12px', borderRadius:999, background:C.surface2, border:`1px solid ${C.border}`,
                    color:C.muted2, cursor:'pointer', fontSize:12, fontWeight:600, fontFamily:"'Space Grotesk',sans-serif",
                  }}>{p.label} ({p.cal})</button>
                ))}
              </div>
            </div>
            {/* Numpad */}
            <div style={{ padding:'0 16px 8px', flexShrink:0 }}>
              <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:8, marginBottom:10 }}>
                {numpadKeys.map(k=>(
                  <button key={k} onClick={()=>numpadPress(k)} style={{
                    padding:'14px', borderRadius:12, background:C.surface2, border:`1px solid ${C.border}`,
                    color:C.text, fontSize:18, fontWeight:700, cursor:'pointer', fontFamily:"'Space Grotesk',sans-serif",
                  }}>{k}</button>
                ))}
              </div>
              <FPBtn onClick={()=>handleLog(parseInt(manualCals)||0)} disabled={!manualCals||manualCals==='0'}>
                Enregistrer {manualCals ? `(${manualCals} kcal)` : ''}
              </FPBtn>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { DashboardScreen, AIScreen, FoodScreen });
