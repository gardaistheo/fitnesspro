// FitnessPro — Landing, Signup, Quiz, Onboarding screens
const { useState: useStateA, useEffect: useEffectA } = React;

/* ─── LANDING ─── */
function LandingScreen({ onCTA }) {
  const features = [
    { icon:'⚡', text:'Programme personnalisé par IA' },
    { icon:'📊', text:'Suivi calorique & hydratation' },
    { icon:'🧠', text:'Coach IA disponible 24h/24' },
    { icon:'📷', text:'Scan alimentaire instantané' },
  ];
  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', overflowY:'auto', fontFamily:"'Space Grotesk',sans-serif" }}>
      {/* Hero */}
      <div style={{ padding:'40px 24px 24px', textAlign:'center', position:'relative' }}>
        <div style={{ position:'absolute', top:0, left:'50%', transform:'translateX(-50%)', width:300, height:300, borderRadius:'50%', background:`radial-gradient(circle, ${C.accent}18 0%, transparent 70%)`, pointerEvents:'none' }} />
        <div style={{ fontSize:11, fontWeight:700, letterSpacing:3, color:C.accent, marginBottom:16, textTransform:'uppercase' }}>Votre coach personnel</div>
        <div style={{ fontSize:36, fontWeight:900, lineHeight:1.1, marginBottom:8, letterSpacing:-1 }}>
          Transformez<br/>votre corps<br/><span style={{ color:C.accent }}>dès aujourd'hui.</span>
        </div>
        <div style={{ fontSize:15, color:C.muted2, marginTop:12, lineHeight:1.6 }}>
          Le programme de musculation intelligent<br/>qui s'adapte à vous.
        </div>
      </div>
      {/* Pricing card */}
      <div style={{ margin:'0 20px', background:C.surface, borderRadius:20, padding:24, border:`1px solid ${C.border}`, position:'relative', overflow:'hidden' }}>
        <div style={{ position:'absolute', top:-30, right:-30, width:120, height:120, borderRadius:'50%', background:`${C.accent}10` }} />
        <div style={{ fontSize:11, fontWeight:700, letterSpacing:2, color:C.accent, marginBottom:8, textTransform:'uppercase' }}>Accès illimité</div>
        <div style={{ display:'flex', alignItems:'flex-end', gap:4, marginBottom:4 }}>
          <span style={{ fontSize:48, fontWeight:900, color:C.text, lineHeight:1 }}>9,99</span>
          <span style={{ fontSize:18, fontWeight:700, color:C.muted2, marginBottom:6 }}>€</span>
          <span style={{ fontSize:14, color:C.muted, marginBottom:8 }}>/mois</span>
        </div>
        <div style={{ fontSize:13, color:C.muted2, marginBottom:20 }}>Sans engagement · Résiliable à tout moment</div>
        {features.map((f,i) => (
          <div key={i} style={{ display:'flex', alignItems:'center', gap:10, marginBottom:10 }}>
            <span style={{ fontSize:18 }}>{f.icon}</span>
            <span style={{ fontSize:14, color:C.muted2 }}>{f.text}</span>
            <span style={{ marginLeft:'auto', color:C.accent }}>
              <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={3}><polyline points="20,6 9,17 4,12"/></svg>
            </span>
          </div>
        ))}
      </div>
      {/* CTA */}
      <div style={{ padding:'24px 20px 32px' }}>
        <FPBtn onClick={onCTA}>Commencer mon essai gratuit →</FPBtn>
        <div style={{ textAlign:'center', fontSize:12, color:C.muted, marginTop:12 }}>7 jours gratuits · Pas de CB requise</div>
      </div>
    </div>
  );
}

/* ─── SIGNUP ─── */
function SignupScreen({ onBack, onDone }) {
  const [step, setStep] = useStateA('form'); // 'form' | 'payment'
  const [form, setForm] = useStateA({ name:'', email:'', password:'' });
  const [card, setCard] = useStateA({ number:'', expiry:'', cvc:'' });
  const [loading, setLoading] = useStateA(false);

  function handlePay() {
    setLoading(true);
    setTimeout(() => { setLoading(false); onDone(); }, 1800);
  }

  const inputStyle = {
    width:'100%', background:C.surface2, border:`1px solid ${C.border}`,
    borderRadius:12, padding:'13px 14px', color:C.text, fontSize:15,
    fontFamily:"'Space Grotesk',sans-serif", boxSizing:'border-box', marginBottom:12,
  };

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <BackHeader title={step==='form' ? 'Créer un compte' : 'Paiement'} onBack={step==='payment' ? ()=>setStep('form') : onBack} />
      <div style={{ flex:1, overflowY:'auto', padding:'24px 20px' }}>
        {step === 'form' ? (
          <>
            <div style={{ fontSize:13, color:C.muted2, marginBottom:24 }}>Rejoignez des milliers d'athlètes qui transforment leur corps avec FitnessPro.</div>
            <input style={inputStyle} placeholder="Prénom et nom" value={form.name} onChange={e=>setForm({...form,name:e.target.value})} />
            <input style={inputStyle} placeholder="Adresse e-mail" type="email" value={form.email} onChange={e=>setForm({...form,email:e.target.value})} />
            <input style={inputStyle} placeholder="Mot de passe" type="password" value={form.password} onChange={e=>setForm({...form,password:e.target.value})} />
            <FPBtn onClick={()=>setStep('payment')} disabled={!form.name||!form.email||!form.password}>Continuer vers le paiement →</FPBtn>
          </>
        ) : (
          <>
            <div style={{ background:C.surface, borderRadius:16, padding:16, border:`1px solid ${C.border}`, marginBottom:20 }}>
              <div style={{ fontSize:12, color:C.muted2, marginBottom:4 }}>Récapitulatif</div>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
                <span style={{ fontWeight:700 }}>FitnessPro Premium</span>
                <span style={{ color:C.accent, fontWeight:700 }}>9,99 €/mois</span>
              </div>
              <div style={{ fontSize:12, color:C.muted, marginTop:4 }}>7 jours d'essai gratuit inclus</div>
            </div>
            <div style={{ fontSize:12, color:C.muted2, marginBottom:6, fontWeight:700, letterSpacing:0.5 }}>NUMÉRO DE CARTE</div>
            <input style={inputStyle} placeholder="1234 5678 9012 3456" value={card.number} onChange={e=>setCard({...card,number:e.target.value})} />
            <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12, marginBottom:12 }}>
              <input style={{...inputStyle,marginBottom:0}} placeholder="MM/AA" value={card.expiry} onChange={e=>setCard({...card,expiry:e.target.value})} />
              <input style={{...inputStyle,marginBottom:0}} placeholder="CVC" value={card.cvc} onChange={e=>setCard({...card,cvc:e.target.value})} />
            </div>
            <FPBtn onClick={handlePay} disabled={loading||!card.number||!card.expiry||!card.cvc}>
              {loading ? '⏳ Traitement...' : '🔒 Démarrer mon essai gratuit'}
            </FPBtn>
            <div style={{ textAlign:'center', fontSize:11, color:C.muted, marginTop:10 }}>Paiement sécurisé · Sans engagement · Résiliable à tout moment</div>
          </>
        )}
      </div>
    </div>
  );
}

/* ─── QUIZ ─── */
function QuizScreen({ onDone }) {
  const days = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
  const equipmentOptions = ['Haltères','Barre + disques','Banc','Barre de traction','Kettlebell','Élastiques','TRX','Vélo/Rameur'];

  const [step, setStep] = useStateA(0);
  const [data, setData] = useStateA({
    level: null, goal: null, currentWeight:'75', targetWeight:'70',
    availableDays:['Lundi','Mercredi','Vendredi'], hoursPerDay:1.5,
    location: null, equipment:[], caloriesIn:2000, caloriesOut:400,
  });

  function set(key, val) { setData(d => ({...d, [key]:val})); }
  function toggleArr(key, val) {
    setData(d => ({...d, [key]: d[key].includes(val) ? d[key].filter(x=>x!==val) : [...d[key],val]}));
  }

  // Build steps dynamically
  const steps = [
    { title:'Quel est ton niveau ?', subtitle:'Sois honnête, cela personnalisera ton programme.' },
    { title:'Quel est ton objectif ?', subtitle:'Définis ton poids actuel et ton objectif.' },
    { title:'Tes disponibilités', subtitle:'Quand es-tu disponible pour t\'entraîner ?' },
    { title:'Où t\'entraînes-tu ?', subtitle:'L\'endroit influence le type d\'exercices proposés.' },
    ...(data.location === 'Maison' ? [{ title:'Ton matériel', subtitle:'Sélectionne le matériel disponible chez toi.' }] : []),
    { title:'Apports caloriques', subtitle:'Combien de calories ingères-tu en moyenne par jour ?' },
    { title:'Dépenses caloriques', subtitle:'Estimation de tes dépenses journalières hors sport.' },
  ];

  const totalSteps = steps.length;
  const s = steps[step];

  const canNext = () => {
    if (step === 0) return !!data.level;
    if (step === 1) return !!data.goal && data.currentWeight && data.targetWeight;
    if (step === 2) return data.availableDays.length > 0;
    if (step === 3) return !!data.location;
    return true;
  };

  function handleNext() {
    if (step < totalSteps - 1) setStep(s => s+1);
    else onDone(data);
  }
  function handleBack() { if (step > 0) setStep(s => s-1); }

  const btnSel = (active) => ({
    flex:1, padding:'12px 8px', borderRadius:12, border:`2px solid ${active ? C.accent : C.border}`,
    background: active ? `${C.accent}18` : C.surface2, color: active ? C.accent : C.muted2,
    cursor:'pointer', fontWeight:700, fontSize:14, textAlign:'center',
    fontFamily:"'Space Grotesk',sans-serif", transition:'all 0.15s',
  });

  const inputStyle = {
    background:C.surface2, border:`1px solid ${C.border}`, borderRadius:12,
    padding:'13px 14px', color:C.text, fontSize:15, fontFamily:"'Space Grotesk',sans-serif",
    boxSizing:'border-box', width:'100%',
  };

  function renderStep() {
    if (step === 0) {
      return (
        <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
          {['Débutant','Intermédiaire','Avancé'].map(l => (
            <button key={l} onClick={()=>set('level',l)} style={{
              padding:'18px', borderRadius:14, border:`2px solid ${data.level===l ? C.accent : C.border}`,
              background: data.level===l ? `${C.accent}18` : C.surface2, cursor:'pointer',
              textAlign:'left', fontFamily:"'Space Grotesk',sans-serif",
            }}>
              <div style={{ fontWeight:700, fontSize:16, color: data.level===l ? C.accent : C.text }}>
                {l === 'Débutant' ? '🌱 ' : l==='Intermédiaire' ? '💪 ' : '🔥 '}{l}
              </div>
              <div style={{ fontSize:13, color:C.muted2, marginTop:3 }}>
                {l==='Débutant' ? 'Moins de 6 mois de pratique' : l==='Intermédiaire' ? '6 mois à 2 ans de pratique' : 'Plus de 2 ans, maîtrise des bases'}
              </div>
            </button>
          ))}
        </div>
      );
    }
    if (step === 1) {
      return (
        <div>
          <div style={{ display:'flex', gap:8, marginBottom:20 }}>
            {['Perdre du poids','Maintenir','Prendre de la masse'].map(g => (
              <button key={g} onClick={()=>set('goal',g)} style={{
                ...btnSel(data.goal===g), flex:'unset',
                padding:'10px 12px', fontSize:12,
              }}>{g}</button>
            ))}
          </div>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
            <div>
              <div style={{ fontSize:12, color:C.muted2, marginBottom:6, fontWeight:600 }}>Poids actuel (kg)</div>
              <input style={inputStyle} type="number" value={data.currentWeight} onChange={e=>set('currentWeight',e.target.value)} placeholder="75" />
            </div>
            <div>
              <div style={{ fontSize:12, color:C.muted2, marginBottom:6, fontWeight:600 }}>Poids cible (kg)</div>
              <input style={inputStyle} type="number" value={data.targetWeight} onChange={e=>set('targetWeight',e.target.value)} placeholder="70" />
            </div>
          </div>
        </div>
      );
    }
    if (step === 2) {
      return (
        <div>
          <div style={{ display:'flex', flexWrap:'wrap', gap:8, marginBottom:20 }}>
            {days.map(d => {
              const sel = data.availableDays.includes(d);
              return (
                <button key={d} onClick={()=>toggleArr('availableDays',d)} style={{
                  padding:'8px 14px', borderRadius:10, border:`2px solid ${sel ? C.accent : C.border}`,
                  background: sel ? `${C.accent}18` : C.surface2, color: sel ? C.accent : C.muted2,
                  cursor:'pointer', fontWeight:700, fontSize:13, fontFamily:"'Space Grotesk',sans-serif",
                }}>{d.slice(0,3)}</button>
              );
            })}
          </div>
          <div style={{ fontSize:13, color:C.muted2, marginBottom:8, fontWeight:600 }}>
            Heures disponibles par séance : <span style={{ color:C.accent }}>{data.hoursPerDay}h</span>
          </div>
          <input type="range" min={0.5} max={3} step={0.5} value={data.hoursPerDay}
            onChange={e=>set('hoursPerDay', parseFloat(e.target.value))}
            style={{ width:'100%', accentColor:C.accent }} />
          <div style={{ display:'flex', justifyContent:'space-between', fontSize:11, color:C.muted }}>
            <span>30 min</span><span>3h</span>
          </div>
        </div>
      );
    }
    if (step === 3) {
      const locs = [
        { id:'Maison', icon:'🏠', desc:'Je m\'entraîne depuis chez moi' },
        { id:'Salle', icon:'🏋️', desc:'J\'ai accès à une salle équipée' },
        { id:'Extérieur', icon:'🌳', desc:'Parcs, stades, espaces publics' },
      ];
      return (
        <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
          {locs.map(l => (
            <button key={l.id} onClick={()=>set('location',l.id)} style={{
              padding:'16px', borderRadius:14, border:`2px solid ${data.location===l.id ? C.accent : C.border}`,
              background: data.location===l.id ? `${C.accent}18` : C.surface2,
              cursor:'pointer', textAlign:'left', fontFamily:"'Space Grotesk',sans-serif",
              display:'flex', alignItems:'center', gap:14,
            }}>
              <span style={{ fontSize:28 }}>{l.icon}</span>
              <div>
                <div style={{ fontWeight:700, fontSize:15, color: data.location===l.id ? C.accent : C.text }}>{l.id}</div>
                <div style={{ fontSize:13, color:C.muted2 }}>{l.desc}</div>
              </div>
            </button>
          ))}
        </div>
      );
    }
    // Equipment step (only if location=Maison)
    if (data.location === 'Maison' && step === 4) {
      return (
        <div>
          <div style={{ fontSize:13, color:C.muted2, marginBottom:16 }}>Sélectionne tout le matériel dont tu disposes (plusieurs choix possibles).</div>
          <div style={{ display:'flex', flexWrap:'wrap', gap:8 }}>
            {equipmentOptions.map(eq => {
              const sel = data.equipment.includes(eq);
              return (
                <button key={eq} onClick={()=>toggleArr('equipment',eq)} style={{
                  padding:'9px 14px', borderRadius:10, border:`2px solid ${sel ? C.accent : C.border}`,
                  background: sel ? `${C.accent}18` : C.surface2, color: sel ? C.accent : C.muted2,
                  cursor:'pointer', fontWeight:600, fontSize:13, fontFamily:"'Space Grotesk',sans-serif",
                }}>{eq}</button>
              );
            })}
          </div>
          <button onClick={()=>setData(d=>({...d,equipment:[]}))} style={{
            marginTop:16, background:'none', border:'none', color:C.muted, cursor:'pointer',
            fontSize:12, fontFamily:"'Space Grotesk',sans-serif",
          }}>Aucun matériel (poids du corps uniquement)</button>
        </div>
      );
    }
    // Calories in
    const calStep = data.location === 'Maison' ? 5 : 4;
    if (step === calStep) {
      const examples = [
        { label:'Léger', cal:1500, desc:'Repas simples, peu de snacks' },
        { label:'Modéré', cal:2000, desc:'3 repas équilibrés' },
        { label:'Élevé', cal:2500, desc:'3 repas + collations' },
        { label:'Très élevé', cal:3000, desc:'Prises de masse actives' },
      ];
      return (
        <div>
          <div style={{ textAlign:'center', marginBottom:16 }}>
            <span style={{ fontSize:40, fontWeight:900, color:C.accent }}>{data.caloriesIn.toLocaleString('fr-FR')}</span>
            <span style={{ fontSize:18, color:C.muted2 }}> kcal</span>
          </div>
          <input type="range" min={1200} max={4000} step={50} value={data.caloriesIn}
            onChange={e=>set('caloriesIn', parseInt(e.target.value))}
            style={{ width:'100%', accentColor:C.accent, marginBottom:20 }} />
          <div style={{ fontSize:12, color:C.muted2, marginBottom:10, fontWeight:700, letterSpacing:0.5 }}>EXEMPLES DE RÉFÉRENCE</div>
          {examples.map(ex => (
            <button key={ex.cal} onClick={()=>set('caloriesIn', ex.cal)} style={{
              display:'flex', width:'100%', alignItems:'center', justifyContent:'space-between',
              padding:'10px 14px', borderRadius:10, border:`1px solid ${data.caloriesIn===ex.cal ? C.accent : C.border}`,
              background: data.caloriesIn===ex.cal ? `${C.accent}12` : 'transparent',
              cursor:'pointer', marginBottom:8, fontFamily:"'Space Grotesk',sans-serif",
            }}>
              <div style={{ textAlign:'left' }}>
                <div style={{ fontWeight:700, fontSize:14, color: data.caloriesIn===ex.cal ? C.accent : C.text }}>{ex.label}</div>
                <div style={{ fontSize:12, color:C.muted }}>{ex.desc}</div>
              </div>
              <span style={{ fontWeight:700, color:C.muted2 }}>{ex.cal} kcal</span>
            </button>
          ))}
        </div>
      );
    }
    // Calories out
    const calOutStep = data.location === 'Maison' ? 6 : 5;
    if (step === calOutStep) {
      const examples = [
        { label:'Sédentaire', cal:200, desc:'Bureau, peu de déplacements' },
        { label:'Modérément actif', cal:400, desc:'Marche quotidienne, tâches ménagères' },
        { label:'Actif', cal:600, desc:'Travail physique ou sport quotidien' },
        { label:'Très actif', cal:900, desc:'Sport intense, travail manuel' },
      ];
      return (
        <div>
          <div style={{ fontSize:13, color:C.muted2, marginBottom:12, lineHeight:1.5 }}>
            Dépenses <strong style={{color:C.text}}>hors activité sportive</strong>. Une personne moyenne brûle entre 300 et 600 kcal/jour au repos actif.
          </div>
          <div style={{ textAlign:'center', marginBottom:16 }}>
            <span style={{ fontSize:40, fontWeight:900, color:C.orange }}>{data.caloriesOut.toLocaleString('fr-FR')}</span>
            <span style={{ fontSize:18, color:C.muted2 }}> kcal</span>
          </div>
          <input type="range" min={100} max={1200} step={50} value={data.caloriesOut}
            onChange={e=>set('caloriesOut', parseInt(e.target.value))}
            style={{ width:'100%', accentColor:C.orange, marginBottom:20 }} />
          {examples.map(ex => (
            <button key={ex.cal} onClick={()=>set('caloriesOut', ex.cal)} style={{
              display:'flex', width:'100%', alignItems:'center', justifyContent:'space-between',
              padding:'10px 14px', borderRadius:10, border:`1px solid ${data.caloriesOut===ex.cal ? C.orange : C.border}`,
              background: data.caloriesOut===ex.cal ? `${C.orange}12` : 'transparent',
              cursor:'pointer', marginBottom:8, fontFamily:"'Space Grotesk',sans-serif",
            }}>
              <div style={{ textAlign:'left' }}>
                <div style={{ fontWeight:700, fontSize:14, color: data.caloriesOut===ex.cal ? C.orange : C.text }}>{ex.label}</div>
                <div style={{ fontSize:12, color:C.muted }}>{ex.desc}</div>
              </div>
              <span style={{ fontWeight:700, color:C.muted2 }}>{ex.cal} kcal</span>
            </button>
          ))}
        </div>
      );
    }
    return null;
  }

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      {/* Progress */}
      <div style={{ padding:'16px 20px 12px', flexShrink:0 }}>
        <div style={{ display:'flex', justifyContent:'space-between', marginBottom:8 }}>
          <span style={{ fontSize:12, color:C.muted2, fontWeight:600 }}>Étape {step+1} sur {totalSteps}</span>
          {step > 0 && (
            <button onClick={handleBack} style={{ background:'none', border:'none', color:C.muted2, cursor:'pointer', fontSize:13, fontFamily:"'Space Grotesk',sans-serif" }}>← Retour</button>
          )}
        </div>
        <ProgressBar value={step+1} max={totalSteps} animated />
      </div>
      {/* Content */}
      <div style={{ flex:1, overflowY:'auto', padding:'8px 20px 20px' }}>
        <div style={{ marginBottom:6, fontWeight:900, fontSize:22, lineHeight:1.2 }}>{s.title}</div>
        <div style={{ fontSize:14, color:C.muted2, marginBottom:24, lineHeight:1.5 }}>{s.subtitle}</div>
        {renderStep()}
      </div>
      {/* CTA */}
      <div style={{ padding:'12px 20px 20px', flexShrink:0, borderTop:`1px solid ${C.border}` }}>
        <FPBtn onClick={handleNext} disabled={!canNext()}>
          {step === totalSteps-1 ? 'Créer mon programme →' : 'Continuer →'}
        </FPBtn>
      </div>
    </div>
  );
}

/* ─── ONBOARDING ─── */
function OnboardingScreen({ quizData, onDone }) {
  const [step, setStep] = useStateA(0);
  const slides = [
    { emoji:'🎉', title:'Ton programme est prêt !', body:`Basé sur ton profil de sportif ${quizData?.level || 'Intermédiaire'}, nous avons créé un programme sur mesure pour atteindre ton objectif : ${quizData?.goal || 'prendre de la masse'}.` },
    { emoji:'📊', title:'Ton dashboard personnel', body:'Retrouve toutes tes métriques en un coup d\'œil : prochain entraînement, calories, hydratation et ton streak.' },
    { emoji:'🧠', title:'Ton Coach IA', body:'Pose toutes tes questions à ton coach personnel disponible 24h/24. Nutrition, technique, motivation — il est là pour toi.' },
    { emoji:'📷', title:'Scanner ton alimentation', body:'Prends en photo ton repas et l\'IA calcule automatiquement les calories. Saisie manuelle disponible si besoin.' },
  ];
  const s = slides[step];
  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif", alignItems:'center', justifyContent:'center', padding:'32px 24px', textAlign:'center', boxSizing:'border-box' }}>
      <div style={{ fontSize:72, marginBottom:24 }}>{s.emoji}</div>
      <div style={{ fontSize:26, fontWeight:900, marginBottom:16, lineHeight:1.2 }}>{s.title}</div>
      <div style={{ fontSize:15, color:C.muted2, lineHeight:1.7, maxWidth:280 }}>{s.body}</div>
      <div style={{ display:'flex', gap:8, margin:'32px 0 24px' }}>
        {slides.map((_,i) => (
          <div key={i} style={{ width: i===step ? 24 : 8, height:8, borderRadius:999, background: i===step ? C.accent : C.surface2, transition:'all 0.3s' }} />
        ))}
      </div>
      <div style={{ width:'100%', maxWidth:320 }}>
        {step < slides.length-1
          ? <FPBtn onClick={()=>setStep(s=>s+1)}>Suivant →</FPBtn>
          : <FPBtn onClick={onDone}>Accéder à mon espace →</FPBtn>}
      </div>
      {step < slides.length-1 && (
        <button onClick={onDone} style={{ marginTop:14, background:'none', border:'none', color:C.muted, cursor:'pointer', fontSize:13, fontFamily:"'Space Grotesk',sans-serif" }}>Passer</button>
      )}
    </div>
  );
}

Object.assign(window, { LandingScreen, SignupScreen, QuizScreen, OnboardingScreen });
