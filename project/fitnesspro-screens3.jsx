// FitnessPro — Exercises, Workouts, Planning screens
const { useState: useState3, useEffect: useEffect3 } = React;

/* ─── EXERCISES ─── */
function ExercisesScreen() {
  const [search, setSearch] = useState3('');
  const [filterCat, setFilterCat] = useState3('Tous');
  const [selected, setSelected] = useState3(null);
  const cats = ['Tous','Jambes','Poitrine','Dos','Épaules','Bras','Triceps','Abdominaux'];
  const filtered = FP_EXERCISES.filter(e =>
    (filterCat === 'Tous' || e.category === filterCat) &&
    e.name.toLowerCase().includes(search.toLowerCase())
  );
  if (selected) return <ExerciseDetail ex={selected} onBack={()=>setSelected(null)} />;
  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <div style={{ padding:'14px 16px 10px', flexShrink:0 }}>
        <div style={{ fontWeight:900, fontSize:20, marginBottom:12 }}>Bibliothèque</div>
        <input value={search} onChange={e=>setSearch(e.target.value)}
          placeholder="🔍  Rechercher un exercice..."
          style={{ width:'100%', background:C.surface2, border:`1px solid ${C.border}`, borderRadius:12, padding:'11px 14px', color:C.text, fontSize:14, fontFamily:"'Space Grotesk',sans-serif", boxSizing:'border-box', marginBottom:10 }} />
        <div style={{ display:'flex', gap:8, overflowX:'auto', paddingBottom:4 }}>
          {cats.map(c=>(
            <button key={c} onClick={()=>setFilterCat(c)} style={{
              whiteSpace:'nowrap', padding:'6px 14px', borderRadius:999, fontSize:12, fontWeight:700,
              cursor:'pointer', fontFamily:"'Space Grotesk',sans-serif",
              background: filterCat===c ? C.accent : C.surface2,
              color: filterCat===c ? '#0C0C14' : C.muted2,
              border: filterCat===c ? 'none' : `1px solid ${C.border}`,
            }}>{c}</button>
          ))}
        </div>
      </div>
      <div style={{ flex:1, overflowY:'auto', padding:'4px 16px 16px' }}>
        {filtered.length === 0 && <div style={{ textAlign:'center', color:C.muted2, marginTop:40 }}>Aucun exercice trouvé</div>}
        {filtered.map(ex=>(
          <div key={ex.id} onClick={()=>setSelected(ex)} style={{
            background:C.surface, borderRadius:14, padding:'14px', border:`1px solid ${C.border}`,
            marginBottom:10, cursor:'pointer', display:'flex', alignItems:'center', gap:14,
          }}>
            <div style={{ width:44, height:44, borderRadius:10, background:`${C.accent}18`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:22, flexShrink:0 }}>
              {ex.category==='Jambes'?'🦵':ex.category==='Poitrine'?'💪':ex.category==='Dos'?'🔙':ex.category==='Épaules'?'🙆':ex.category==='Bras'||ex.category==='Triceps'?'💪':'🎯'}
            </div>
            <div style={{ flex:1, minWidth:0 }}>
              <div style={{ fontWeight:700, fontSize:15, marginBottom:3 }}>{ex.name}</div>
              <div style={{ fontSize:12, color:C.muted2 }}>{ex.muscles.slice(0,2).join(' · ')}</div>
            </div>
            <div style={{ display:'flex', flexDirection:'column', alignItems:'flex-end', gap:4 }}>
              <DifficultyChip level={ex.difficulty} />
              <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke={C.muted} strokeWidth={2}><path d="M9 18l6-6-6-6"/></svg>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ExerciseDetail({ ex, onBack }) {
  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <BackHeader title={ex.name} onBack={onBack} />
      <div style={{ flex:1, overflowY:'auto' }}>
        {/* Video placeholder */}
        <div style={{ height:200, background:C.surface2, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:10, borderBottom:`1px solid ${C.border}` }}>
          <div style={{ width:60, height:60, borderRadius:'50%', background:`${C.accent}22`, border:`2px solid ${C.accent}44`, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <svg width={24} height={24} viewBox="0 0 24 24" fill={C.accent}><polygon points="5,3 19,12 5,21"/></svg>
          </div>
          <div style={{ fontSize:12, color:C.muted2 }}>Vidéo explicative</div>
          <div style={{ fontSize:11, color:C.muted, fontStyle:'italic' }}>// video demo placeholder</div>
        </div>
        <div style={{ padding:'20px 16px' }}>
          <div style={{ display:'flex', gap:8, marginBottom:16, flexWrap:'wrap' }}>
            <Chip label={ex.category} color={C.blue} />
            <DifficultyChip level={ex.difficulty} />
          </div>
          <div style={{ fontSize:14, color:C.muted2, lineHeight:1.7, marginBottom:20 }}>{ex.description}</div>
          <SectionTitle>Muscles travaillés</SectionTitle>
          <div style={{ display:'flex', flexWrap:'wrap', gap:8, marginBottom:20 }}>
            {ex.muscles.map(m=><Chip key={m} label={m} color={C.purple} />)}
          </div>
          <SectionTitle>Instructions</SectionTitle>
          {ex.instructions.map((inst,i)=>(
            <div key={i} style={{ display:'flex', gap:12, marginBottom:12, alignItems:'flex-start' }}>
              <div style={{ width:24, height:24, borderRadius:8, background:`${C.accent}22`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontWeight:800, fontSize:12, color:C.accent }}>{i+1}</div>
              <div style={{ fontSize:14, color:C.muted2, lineHeight:1.6, paddingTop:3 }}>{inst}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ─── WORKOUTS ─── */
function WorkoutsScreen({ planning, setPlanning }) {
  const [selected, setSelected] = useState3(null);
  const [filterDiff, setFilterDiff] = useState3('Tous');
  const [added, setAdded] = useState3(null);
  const diffs = ['Tous','Débutant','Intermédiaire','Avancé'];
  const filtered = FP_WORKOUTS.filter(w => filterDiff==='Tous' || w.difficulty===filterDiff);

  if (selected) return (
    <WorkoutDetail
      workout={selected}
      onBack={()=>setSelected(null)}
      onAdd={() => {
        const today = new Date();
        const nextDate = new Date(today);
        nextDate.setDate(today.getDate() + (planning.length * 2 + 1));
        const newEntry = {
          id: Date.now(), workoutId: selected.id,
          workoutName: selected.name,
          date: nextDate.toISOString().slice(0,10),
          time:'18:00', muscles: selected.muscles, duration: selected.duration,
        };
        setPlanning(p => [...p, newEntry].sort((a,b)=>a.date.localeCompare(b.date)));
        setAdded(selected.name);
        setTimeout(()=>setAdded(null), 2500);
        setSelected(null);
      }}
    />
  );

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <div style={{ padding:'14px 16px 10px', flexShrink:0 }}>
        <div style={{ fontWeight:900, fontSize:20, marginBottom:12 }}>Séances</div>
        <div style={{ display:'flex', gap:8, overflowX:'auto', paddingBottom:4 }}>
          {diffs.map(d=>(
            <button key={d} onClick={()=>setFilterDiff(d)} style={{
              whiteSpace:'nowrap', padding:'6px 14px', borderRadius:999, fontSize:12, fontWeight:700,
              cursor:'pointer', fontFamily:"'Space Grotesk',sans-serif",
              background: filterDiff===d ? C.accent : C.surface2,
              color: filterDiff===d ? '#0C0C14' : C.muted2,
              border: filterDiff===d ? 'none' : `1px solid ${C.border}`,
            }}>{d}</button>
          ))}
        </div>
      </div>
      <div style={{ flex:1, overflowY:'auto', padding:'4px 16px 16px' }}>
        {filtered.map(w=>(
          <div key={w.id} onClick={()=>setSelected(w)} style={{
            background:C.surface, borderRadius:16, border:`1px solid ${C.border}`,
            marginBottom:12, cursor:'pointer', overflow:'hidden',
          }}>
            <div style={{ padding:'16px', paddingBottom:12 }}>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', marginBottom:8 }}>
                <div>
                  <div style={{ fontWeight:800, fontSize:16, marginBottom:3 }}>{w.name}</div>
                  <div style={{ fontSize:13, color:C.muted2 }}>{w.muscles}</div>
                </div>
                <DifficultyChip level={w.difficulty} />
              </div>
              <div style={{ display:'flex', gap:12 }}>
                <span style={{ fontSize:13, color:C.muted2 }}>⏱ {w.duration} min</span>
                <span style={{ fontSize:13, color:C.muted2 }}>📋 {w.exercises.length} exercices</span>
              </div>
            </div>
            <div style={{ borderTop:`1px solid ${C.border}`, padding:'10px 16px', display:'flex', justifyContent:'space-between', alignItems:'center' }}>
              <div style={{ display:'flex', gap:6 }}>
                {w.exercises.slice(0,3).map((e,i)=>(
                  <span key={i} style={{ fontSize:11, color:C.muted2 }}>{e.name}{i<Math.min(2,w.exercises.length-1)?'·':''}</span>
                ))}
                {w.exercises.length > 3 && <span style={{ fontSize:11, color:C.muted }}>+{w.exercises.length-3}</span>}
              </div>
              <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke={C.muted} strokeWidth={2}><path d="M9 18l6-6-6-6"/></svg>
            </div>
          </div>
        ))}
      </div>
      {added && (
        <div style={{ position:'absolute', bottom:100, left:'50%', transform:'translateX(-50%)', background:`${C.green}22`, border:`1px solid ${C.green}44`, borderRadius:12, padding:'10px 20px', color:C.green, fontWeight:700, fontSize:14, whiteSpace:'nowrap', zIndex:50 }}>
          ✓ {added} ajouté au planning
        </div>
      )}
    </div>
  );
}

function WorkoutDetail({ workout, onBack, onAdd }) {
  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <BackHeader title={workout.name} onBack={onBack} />
      <div style={{ flex:1, overflowY:'auto', padding:'16px' }}>
        <div style={{ display:'flex', gap:8, marginBottom:16, flexWrap:'wrap' }}>
          <DifficultyChip level={workout.difficulty} />
          <Chip label={`${workout.duration} min`} color={C.blue} />
          <Chip label={workout.muscles} color={C.purple} />
        </div>
        <SectionTitle>Programme de la séance</SectionTitle>
        {workout.exercises.map((ex,i)=>(
          <div key={i} style={{ background:C.surface, borderRadius:14, padding:'14px', border:`1px solid ${C.border}`, marginBottom:10 }}>
            <div style={{ fontWeight:700, fontSize:15, marginBottom:10 }}>{ex.name}</div>
            <div style={{ display:'flex', gap:8, flexWrap:'wrap' }}>
              {ex.sets.map((s,j)=>(
                <div key={j} style={{ background:C.surface2, borderRadius:8, padding:'6px 12px', textAlign:'center', border:`1px solid ${C.border}` }}>
                  <div style={{ fontSize:10, color:C.muted2, marginBottom:2 }}>Série {j+1}</div>
                  <div style={{ fontWeight:800, fontSize:15, color:C.accent }}>{s.reps}</div>
                  <div style={{ fontSize:10, color:C.muted2 }}>{typeof s.reps==='number'?'reps':'sec'}</div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
      <div style={{ padding:'12px 16px 20px', flexShrink:0, borderTop:`1px solid ${C.border}` }}>
        <FPBtn onClick={onAdd}>📅 Ajouter à mon planning</FPBtn>
      </div>
    </div>
  );
}

/* ─── PLANNING ─── */
function PlanningScreen({ planning, setPlanning, onBack, onAddWorkout }) {
  const [showPicker, setShowPicker] = useState3(false);

  function remove(id) { setPlanning(p=>p.filter(x=>x.id!==id)); }

  function formatDate(dateStr) {
    const d = new Date(dateStr + 'T00:00:00');
    return d.toLocaleDateString('fr-FR', { weekday:'long', day:'numeric', month:'long' });
  }

  function daysUntil(dateStr) {
    const today = new Date(); today.setHours(0,0,0,0);
    const d = new Date(dateStr + 'T00:00:00');
    const diff = Math.round((d-today)/(1000*60*60*24));
    if (diff === 0) return 'Aujourd\'hui';
    if (diff === 1) return 'Demain';
    if (diff < 0) return 'Passé';
    return `Dans ${diff} jours`;
  }

  return (
    <div style={{ width:'100%', height:'100%', background:C.bg, display:'flex', flexDirection:'column', fontFamily:"'Space Grotesk',sans-serif" }}>
      <BackHeader title="Mon planning" onBack={onBack}
        rightEl={
          <button onClick={()=>setShowPicker(true)} style={{
            background:C.accent, border:'none', borderRadius:10, padding:'7px 14px',
            fontWeight:700, fontSize:13, cursor:'pointer', color:'#0C0C14', fontFamily:"'Space Grotesk',sans-serif",
          }}>+ Ajouter</button>
        }
      />
      <div style={{ flex:1, overflowY:'auto', padding:'16px' }}>
        {planning.length === 0 ? (
          <div style={{ textAlign:'center', marginTop:60 }}>
            <div style={{ fontSize:48, marginBottom:16 }}>📅</div>
            <div style={{ fontWeight:700, fontSize:18, marginBottom:8 }}>Aucune séance planifiée</div>
            <div style={{ color:C.muted2, fontSize:14, marginBottom:24 }}>Ajoute des séances depuis la bibliothèque</div>
            <FPBtn onClick={()=>setShowPicker(true)}>Parcourir les séances</FPBtn>
          </div>
        ) : (
          planning.map((p,i)=>(
            <div key={p.id} style={{ marginBottom:14 }}>
              {(i===0 || planning[i-1].date !== p.date) && (
                <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:10 }}>
                  <div style={{ fontSize:12, color:C.muted2, fontWeight:700, textTransform:'capitalize' }}>{formatDate(p.date)}</div>
                  <div style={{ flex:1, height:1, background:C.border }} />
                  <Chip label={daysUntil(p.date)} color={daysUntil(p.date)==='Aujourd\'hui'?C.accent:daysUntil(p.date)==='Passé'?C.muted:C.blue} />
                </div>
              )}
              <div style={{ background:C.surface, borderRadius:14, border:`1px solid ${C.border}`, overflow:'hidden' }}>
                <div style={{ padding:'14px', display:'flex', gap:12, alignItems:'center' }}>
                  <div style={{ width:44, height:44, borderRadius:12, background:`${C.accent}18`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, fontSize:22 }}>💪</div>
                  <div style={{ flex:1, minWidth:0 }}>
                    <div style={{ fontWeight:800, fontSize:15 }}>{p.workoutName}</div>
                    <div style={{ fontSize:12, color:C.muted2, marginTop:2 }}>{p.time} · {p.muscles}</div>
                    <div style={{ fontSize:12, color:C.muted2 }}>⏱ {p.duration} min</div>
                  </div>
                  <button onClick={()=>remove(p.id)} style={{ background:'#FF4F4F18', border:`1px solid #FF4F4F33`, borderRadius:10, padding:'7px 10px', cursor:'pointer', color:C.red }}>
                    <svg width={16} height={16} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.2}><polyline points="3,6 5,6 21,6"/><path d="M19,6l-1,14H6L5,6M10,11v6M14,11v6"/><path d="M9,6V4h6v2"/></svg>
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Workout picker modal */}
      {showPicker && (
        <div style={{ position:'absolute', inset:0, background:'rgba(0,0,0,0.75)', display:'flex', alignItems:'flex-end', zIndex:50 }} onClick={()=>setShowPicker(false)}>
          <div style={{ width:'100%', background:C.surface, borderRadius:'20px 20px 0 0', padding:'20px', maxHeight:'70%', overflowY:'auto', boxSizing:'border-box' }} onClick={e=>e.stopPropagation()}>
            <div style={{ fontWeight:800, fontSize:16, marginBottom:16 }}>Choisir une séance</div>
            {FP_WORKOUTS.map(w=>(
              <div key={w.id} onClick={()=>{
                const today = new Date();
                const nextDate = new Date(today);
                nextDate.setDate(today.getDate() + (planning.length * 2 + 1));
                setPlanning(p => [...p, {
                  id:Date.now(), workoutId:w.id, workoutName:w.name,
                  date: nextDate.toISOString().slice(0,10),
                  time:'18:00', muscles:w.muscles, duration:w.duration,
                }].sort((a,b)=>a.date.localeCompare(b.date)));
                setShowPicker(false);
              }} style={{
                display:'flex', alignItems:'center', gap:12, padding:'12px 14px',
                background:C.surface2, borderRadius:12, border:`1px solid ${C.border}`, marginBottom:8, cursor:'pointer',
              }}>
                <div style={{ flex:1 }}>
                  <div style={{ fontWeight:700, fontSize:14 }}>{w.name}</div>
                  <div style={{ fontSize:12, color:C.muted2, marginTop:2 }}>{w.muscles} · {w.duration} min</div>
                </div>
                <DifficultyChip level={w.difficulty} />
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { ExercisesScreen, WorkoutDetail, WorkoutsScreen, PlanningScreen });
