const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.send(`<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>GATE — Demo Facial</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Syne:wght@700;800&display=swap');
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0a0a0a;color:#f0f0f0;font-family:'JetBrains Mono',monospace;min-height:100vh;padding:2rem}
header{display:flex;align-items:baseline;gap:16px;margin-bottom:2rem;border-bottom:1px solid #222;padding-bottom:1.5rem}
header h1{font-family:'Syne',sans-serif;font-size:2rem;font-weight:800;background:linear-gradient(90deg,#00ff87,#00c4ff);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
header span{font-size:12px;color:#555;letter-spacing:.1em}
.card{background:#111;border:1px solid #222;border-radius:12px;padding:1.25rem;margin-bottom:1.5rem}
label{display:block;font-size:10px;color:#555;letter-spacing:.1em;margin-bottom:6px}
input[type=text],input[type=password],input[type=number]{width:100%;background:#1a1a1a;border:1px solid #2a2a2a;border-radius:8px;padding:9px 12px;color:#f0f0f0;font-family:'JetBrains Mono',monospace;font-size:12px;outline:none;margin-bottom:12px}
input:focus{border-color:#00ff87}
.row{display:flex;gap:10px;flex-wrap:wrap}
.row>*{flex:1;min-width:200px}
btn,.btn{padding:10px 20px;border-radius:8px;font-family:'JetBrains Mono',monospace;font-size:12px;font-weight:600;cursor:pointer;border:none;letter-spacing:.05em;transition:all .15s}
.btn-green{background:#00ff87;color:#000}.btn-green:hover{filter:brightness(1.1)}.btn-green:disabled{opacity:.3;cursor:not-allowed}
.btn-outline{background:transparent;border:1px solid #333;color:#f0f0f0}.btn-outline:hover{border-color:#00ff87;color:#00ff87}
.tabs{display:flex;gap:4px;margin-bottom:1.5rem}
.tab{padding:8px 20px;background:#111;border:1px solid #222;border-radius:8px;color:#555;font-family:'JetBrains Mono',monospace;font-size:12px;cursor:pointer;transition:all .2s}
.tab.active{background:#00ff87;color:#000;border-color:#00ff87;font-weight:600}
.panel{display:none}.panel.active{display:block}
.drop{border:2px dashed #2a2a2a;border-radius:12px;padding:2.5rem;text-align:center;cursor:pointer;transition:all .2s;position:relative;margin-bottom:12px}
.drop:hover,.drop.over{border-color:#00ff87;background:rgba(0,255,135,.03)}
.drop.has{border-style:solid;border-color:#00ff87;padding:1rem}
.drop input{position:absolute;inset:0;opacity:0;cursor:pointer}
.drop-preview{display:flex;align-items:center;gap:12px}
.drop-preview img{width:72px;height:72px;object-fit:cover;border-radius:8px;border:1px solid #2a2a2a}
#placeholder p{color:#555;font-size:13px;margin-top:8px}
.status{font-size:12px;color:#555;margin:10px 0;min-height:20px;display:flex;align-items:center;gap:8px}
.spin{width:12px;height:12px;border:2px solid #2a2a2a;border-top-color:#00ff87;border-radius:50%;animation:spin .7s linear infinite;flex-shrink:0}
@keyframes spin{to{transform:rotate(360deg)}}
.chip{display:inline-flex;align-items:center;gap:4px;padding:3px 10px;border-radius:99px;font-size:11px;font-weight:600}
.g{background:rgba(0,255,135,.12);color:#00ff87;border:1px solid rgba(0,255,135,.3)}
.r{background:rgba(255,71,87,.12);color:#ff4757;border:1px solid rgba(255,71,87,.3)}
.b{background:rgba(0,196,255,.12);color:#00c4ff;border:1px solid rgba(0,196,255,.3)}
.rcard{background:#111;border:1px solid #222;border-radius:12px;padding:1rem 1.25rem;margin-bottom:10px;display:flex;align-items:center;gap:14px;animation:fi .3s ease}
@keyframes fi{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}
.rcard img{width:64px;height:64px;object-fit:cover;border-radius:8px;border:1px solid #222;cursor:pointer;flex-shrink:0;transition:transform .15s}
.rcard img:hover{transform:scale(1.05)}
.ph{width:64px;height:64px;border-radius:8px;background:#1a1a1a;border:1px solid #222;display:flex;align-items:center;justify-content:center;flex-shrink:0;color:#333;font-size:22px}
.ri{flex:1}.ri h3{font-size:13px;font-weight:600;margin-bottom:4px;font-family:'Syne',sans-serif}
.ri p{font-size:12px;color:#555;margin-bottom:3px}
.bar-wrap{display:flex;align-items:center;gap:8px;margin-top:6px}
.bar-bg{flex:1;height:4px;background:#222;border-radius:99px;overflow:hidden}
.bar-fill{height:100%;border-radius:99px;background:#00ff87}
.dv{font-size:11px;color:#555;min-width:48px;text-align:right}
.empty{text-align:center;padding:3rem;color:#333;font-size:13px}
.lb{display:none;position:fixed;inset:0;background:rgba(0,0,0,.92);z-index:999;align-items:center;justify-content:center}
.lb.open{display:flex}.lb img{max-width:90vw;max-height:90vh;border-radius:12px}
.lb-x{position:fixed;top:20px;right:24px;background:none;border:none;color:#fff;font-size:28px;cursor:pointer}
</style>
</head>
<body>
<header><h1>GATE</h1><span>DEMO · RECONOCIMIENTO FACIAL</span></header>

<div class="card">
  <div class="row">
    <div><label>TOKEN JWT</label><input id="tok" type="password" placeholder="eyJhbGci..." /></div>
    <div style="display:flex;align-items:end;padding-bottom:12px;">
      <button class="btn btn-outline" onclick="autoLogin()">Auto login</button>
    </div>
  </div>
</div>

<div class="tabs">
  <button class="tab active" onclick="sw('buscar',this)">/ buscar por foto</button>
  <button class="tab" onclick="sw('sim',this)">/ ver similares</button>
</div>

<div id="p-buscar" class="panel active">
  <div class="drop" id="dz" ondragover="dov(event)" ondragleave="dlv()" ondrop="ddr(event)">
    <input type="file" accept="image/*" onchange="hf(this)" />
    <div id="placeholder"><svg width="36" height="36" fill="none" stroke="#333" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5"/></svg><p>Arrastra una foto o haz clic</p></div>
    <div id="prev" class="drop-preview" style="display:none"><img id="pimg" src="" alt=""/><span id="pname" style="font-size:12px;color:#888"></span></div>
  </div>
  <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
    <button class="btn btn-green" id="btnb" onclick="buscar()" disabled>Buscar coincidencias →</button>
    <span id="fchip"></span>
  </div>
  <div class="status" id="sb"></div>
  <div id="rb"></div>
</div>

<div id="p-sim" class="panel">
  <div class="card">
    <label>ID DEL REPORTE</label>
    <div style="display:flex;gap:10px">
      <input id="rid" type="number" placeholder="ej: 23" min="1" style="margin:0" onkeydown="if(event.key==='Enter')sim()" />
      <button class="btn btn-green" onclick="sim()" style="white-space:nowrap">Ver similares →</button>
    </div>
  </div>
  <div class="status" id="ss"></div>
  <div id="rs"></div>
</div>

<div class="lb" id="lb" onclick="clb()"><button class="lb-x" onclick="clb()">✕</button><img id="lbi" src="" alt=""/></div>

<script>
const API = '';  // mismo origen
let b64 = null;

function tok(){ return document.getElementById('tok').value.trim(); }
function hdr(){ return {'Content-Type':'application/json','Authorization':'Bearer '+tok()}; }

function sw(tab, btn){
  document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'));
  document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById('p-'+tab).classList.add('active');
}

async function autoLogin(){
  const email = prompt('Email:','admin@gate.com');
  const pass = prompt('Password:');
  if(!email||!pass) return;
  st('sb','load','Conectando...');
  try{
    const r = await fetch('/auth/login',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email,password:pass})});
    const d = await r.json();
    if(d.token){ document.getElementById('tok').value=d.token; st('sb','ok','Token listo ✓'); }
    else st('sb','err', d.error||'Error');
  }catch(e){ st('sb','err',e.message); }
}

function hf(inp){
  const file=inp.files[0]; if(!file) return;
  const fr=new FileReader();
  fr.onload=e=>{
    b64=e.target.result.split(',')[1];
    document.getElementById('pimg').src=e.target.result;
    document.getElementById('pname').textContent=file.name;
    document.getElementById('placeholder').style.display='none';
    document.getElementById('prev').style.display='flex';
    document.getElementById('dz').classList.add('has');
    document.getElementById('btnb').disabled=false;
    document.getElementById('fchip').innerHTML='';
  };
  fr.readAsDataURL(file);
}

function dov(e){e.preventDefault();document.getElementById('dz').classList.add('over');}
function dlv(){document.getElementById('dz').classList.remove('over');}
function ddr(e){
  e.preventDefault();dlv();
  const f=e.dataTransfer.files[0];if(!f||!f.type.startsWith('image/'))return;
  const dt=new DataTransfer();dt.items.add(f);
  const inp=document.querySelector('#dz input');inp.files=dt.files;hf(inp);
}

function st(id,type,msg){
  const el=document.getElementById(id);
  const icons={load:'<div class="spin"></div>',ok:'<span style="color:#00ff87">✓</span>',err:'<span style="color:#ff4757">✗</span>'};
  el.innerHTML=(icons[type]||'')+' '+msg;
}

async function buscar(){
  if(!b64)return;
  st('sb','load','Analizando rostro...');
  document.getElementById('rb').innerHTML='';
  document.getElementById('btnb').disabled=true;
  try{
    const r=await fetch('/reportes/buscar-cara',{method:'POST',headers:hdr(),body:JSON.stringify({image:b64})});
    const d=await r.json();
    document.getElementById('btnb').disabled=false;
    if(d.error){st('sb','err',d.error);document.getElementById('fchip').innerHTML='<span class="chip r">✗ Sin rostro</span>';return;}
    st('sb','ok',d.total+' coincidencia'+(d.total!==1?'s':'')+' encontrada'+(d.total!==1?'s':''));
    document.getElementById('fchip').innerHTML='<span class="chip g">✓ Rostro detectado</span>';
    render('rb',d.resultados||[]);
  }catch(e){document.getElementById('btnb').disabled=false;st('sb','err',e.message);}
}

async function sim(){
  const id=document.getElementById('rid').value;if(!id)return;
  st('ss','load','Buscando...');
  document.getElementById('rs').innerHTML='';
  try{
    const r=await fetch('/reportes/'+id+'/similares',{headers:hdr()});
    const d=await r.json();
    if(d.error){st('ss','err',d.error);return;}
    st('ss','ok','Reporte #'+id+' — '+d.total+' similar'+(d.total!==1?'es':''));
    render('rs',d.similares||[]);
  }catch(e){st('ss','err',e.message);}
}

async function render(container,items){
  const c=document.getElementById(container);
  if(!items.length){c.innerHTML='<div class="empty">Sin coincidencias en la base de datos</div>';return;}
  c.innerHTML='';
  for(const r of items){
    const pct=Math.max(0,Math.min(100,Math.round((1-r.distancia/0.6)*100)));
    const div=document.createElement('div');div.className='rcard';
    div.innerHTML=\`<div class="ph" id="i\${r.id}">👤</div>
    <div class="ri">
      <h3>Reporte #\${r.id}</h3>
      <p>\${r.description||'—'}</p>
      <p>📍 \${r.supermercado?.nombre||'—'} · \${r.date?new Date(r.date).toLocaleDateString('es-CL'):''}</p>
      <div class="bar-wrap">
        <span class="chip \${r.confianza==='alta'?'g':'b'}">\${r.confianza}</span>
        <div class="bar-bg"><div class="bar-fill" style="width:\${pct}%"></div></div>
        <span class="dv">d=\${r.distancia.toFixed(3)}</span>
      </div>
    </div>\`;
    c.appendChild(div);
    loadImg(r.id, document.getElementById('i'+r.id));
  }
}

async function loadImg(id, ph){
  try{
    const r=await fetch('/reportes/'+id+'/imagen',{headers:{'Authorization':'Bearer '+tok()}});
    if(!r.ok)return;
    const url=URL.createObjectURL(await r.blob());
    const img=document.createElement('img');img.src=url;img.alt='';
    img.onclick=()=>{document.getElementById('lbi').src=url;document.getElementById('lb').classList.add('open');};
    ph.replaceWith(img);
  }catch(e){}
}

function clb(){document.getElementById('lb').classList.remove('open');}
document.addEventListener('keydown',e=>{if(e.key==='Escape')clb();});
</script>
</body>
</html>`);
});

module.exports = router;
