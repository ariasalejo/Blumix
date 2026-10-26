#!/usr/bin/env python3
"""Servidor local de BLUMIX: API de solo lectura, sin shell arbitraria ni red externa."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parent.parent
CLI = ROOT / "bin" / "blumix"

HTML = r"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="theme-color" content="#080b12"><link rel="manifest" href="/manifest.webmanifest">
<link rel="icon" href="/icon.svg" type="image/svg+xml">
<title>BLUMIX · Intelligence Center</title>
<style>
:root{color-scheme:dark;--bg:#080b12;--panel:#101722;--line:#263342;--text:#eef5fc;--muted:#8b9bb0;--cyan:#67f4e0;--lime:#c7ff72;--amber:#ffc66d;--red:#ff718b;--mono:ui-monospace,SFMono-Regular,Consolas,monospace;--sans:system-ui,-apple-system,"Segoe UI",sans-serif}
*{box-sizing:border-box}body{margin:0;background:radial-gradient(ellipse at 45% -15%,#172b3a,transparent 45%),var(--bg);color:var(--text);font:14px/1.5 var(--sans);min-height:100vh}button,select{font:inherit}button:focus-visible,a:focus-visible,select:focus-visible{outline:2px solid var(--cyan);outline-offset:3px}.shell{display:grid;grid-template-columns:220px 1fr;min-height:100vh}.rail{padding:25px 16px;border-right:1px solid var(--line);background:#090e16}.brand{font:700 17px var(--mono);letter-spacing:.12em;color:var(--cyan)}.sub{color:var(--muted);font-size:11px;margin:5px 0 30px}.nav{display:grid;gap:7px}.nav a{color:#a8b8ca;text-decoration:none;padding:10px 12px;border-radius:8px;border:1px solid transparent}.nav a:hover,.nav a:focus-visible{border-color:#35565e;background:#11252b;color:var(--cyan)}.rail-note{margin-top:36px;border:1px solid #5b482d;background:#211b14;padding:12px;border-radius:10px;color:var(--amber);font-size:11px}.main{min-width:0;padding:0 28px 36px}.top{height:66px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;gap:12px}.mono{font-family:var(--mono)}.muted{color:var(--muted)}.chip{font:10px var(--mono);border:1px solid var(--line);border-radius:6px;padding:6px 9px;color:var(--muted)}.hero{padding:28px 0 20px;display:flex;align-items:end;justify-content:space-between;gap:20px}.eyebrow{font:10px var(--mono);letter-spacing:.16em;color:var(--cyan);text-transform:uppercase}.hero h1{font-size:clamp(26px,3.4vw,42px);letter-spacing:-.04em;line-height:1.1;margin:8px 0}.hero p{color:var(--muted);max-width:620px;margin:0}.btn{border:1px solid #355c62;border-radius:8px;background:#10242a;color:var(--cyan);padding:10px 13px;cursor:pointer}.btn:hover{background:#16353b}.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px}.card,.panel{background:linear-gradient(145deg,#121c29,#0c121b);border:1px solid var(--line);border-radius:13px;min-width:0}.card{padding:15px}.label{font:10px var(--mono);color:var(--muted);text-transform:uppercase;letter-spacing:.09em}.value{font:27px var(--mono);margin:9px 0 4px}.detail{font-size:11px;color:var(--muted)}.cyan{color:var(--cyan)}.lime{color:var(--lime)}.amber{color:var(--amber)}.red{color:var(--red)}.section{margin:25px 0 11px;display:flex;justify-content:space-between;align-items:center;gap:12px}.section h2{font-size:14px;margin:0}.panel{overflow:hidden}.panel-head{display:flex;justify-content:space-between;align-items:center;gap:12px;padding:14px 16px;border-bottom:1px solid var(--line)}.panel-head h3{font-size:12px;margin:0}.table-wrap{overflow-x:auto}table{border-collapse:collapse;width:100%;min-width:480px}th,td{text-align:left;padding:12px 15px;border-bottom:1px solid #202b38;font-size:12px}th{font:10px var(--mono);color:var(--muted);text-transform:uppercase}td code{font:11px var(--mono);color:#b7c9da}.tag{display:inline-block;border:1px solid var(--line);padding:3px 7px;border-radius:5px;font:10px var(--mono)}.tag.good{color:var(--lime);border-color:#385b3c}.tag.warn{color:var(--amber);border-color:#5c482e}.tag.unknown{color:#b0bdcc;border-color:#3b4654}.cols{display:grid;grid-template-columns:1fr 1fr;gap:12px}.list{padding:15px;display:grid;gap:9px}.item{padding:11px;border:1px solid #263342;border-radius:9px;background:#0b121b}.item strong{font-size:12px}.item p{margin:5px 0 0;font-size:11px;color:var(--muted)}.notice{padding:12px 14px;border:1px solid #5b482d;background:#211b14;color:#e6c28e;border-radius:9px;font-size:11px;margin-top:15px}.footer{margin-top:26px;border-top:1px solid var(--line);padding-top:14px;color:#718197;font-size:10px;display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap}.status{font:11px var(--mono);color:var(--muted)}.error{color:var(--red)}.empty{padding:20px;color:var(--muted);font-size:12px}
@media(max-width:850px){.shell{grid-template-columns:1fr}.rail{position:static;padding:14px 18px;border-right:0;border-bottom:1px solid var(--line)}.sub{margin:2px 0 12px}.nav{display:flex;flex-wrap:wrap}.nav a{padding:7px 9px}.rail-note{margin-top:12px}.main{padding:0 16px 28px}.grid{grid-template-columns:repeat(2,minmax(0,1fr))}.cols{grid-template-columns:1fr}.hero{align-items:start;flex-direction:column}.top{height:auto;padding:14px 0;flex-wrap:wrap}}
@media(max-width:420px){.grid{grid-template-columns:1fr 1fr;gap:8px}.card{padding:11px}.value{font-size:22px}.chip{max-width:100%;overflow-wrap:anywhere}}
@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto!important;transition:none!important}}

/* BLUMIX COMMAND DECK — refinamiento visual ligero, sin dependencias externas */
:root{--bg:#070b12;--panel:#0e1622;--line:#26394b;--text:#f2f7ff;--muted:#8fa2b8;--cyan:#6af5e2;--lime:#c8ff7b;--amber:#ffd080;--red:#ff8198;--mono:ui-monospace,SFMono-Regular,Consolas,monospace;--sans:Inter,ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif}
html{scroll-behavior:smooth;scroll-padding-top:24px}
body{background:radial-gradient(ellipse at 74% 0%,rgba(19,91,105,.18),transparent 38%),radial-gradient(ellipse at 8% 75%,rgba(33,58,103,.13),transparent 34%),#070b12;letter-spacing:.005em}
body:before{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;opacity:.14;background-image:linear-gradient(rgba(110,154,180,.11) 1px,transparent 1px),linear-gradient(90deg,rgba(110,154,180,.11) 1px,transparent 1px);background-size:36px 36px;mask-image:linear-gradient(to bottom,black,transparent 88%)}
.shell{position:relative;z-index:1;grid-template-columns:244px minmax(0,1fr);max-width:1800px;margin:0 auto}
.rail{position:sticky;top:0;height:100vh;padding:28px 17px;background:linear-gradient(180deg,rgba(9,17,27,.97),rgba(7,12,20,.94));border-right:1px solid #223345;box-shadow:12px 0 45px rgba(0,0,0,.12)}
.brand{display:flex;align-items:center;gap:10px;font-size:18px;letter-spacing:.14em;color:#f4fbff}
.brand:before{content:"";display:inline-block;width:23px;height:23px;border:1.5px solid var(--cyan);transform:rotate(30deg);border-radius:6px;box-shadow:0 0 17px rgba(106,245,226,.16),inset 0 0 10px rgba(106,245,226,.09)}
.sub{font:9px var(--mono);letter-spacing:.12em;color:#72889f;margin:8px 0 35px}
.nav{gap:6px}.nav a{position:relative;display:flex;align-items:center;gap:10px;padding:11px 12px;border:1px solid transparent;border-radius:9px;color:#a5b6c9;font-size:12px;transition:background .18s,border-color .18s,color .18s}
.nav a:before{content:"";width:5px;height:5px;border:1px solid #668093;border-radius:2px;transform:rotate(45deg)}
.nav a:hover,.nav a:focus-visible{border-color:#28525a;background:linear-gradient(90deg,rgba(25,78,82,.36),rgba(17,37,43,.34));color:var(--cyan)}
.rail-note{position:relative;margin-top:42px;border:1px solid #29434b;background:linear-gradient(145deg,rgba(16,43,48,.72),rgba(11,23,32,.72));padding:14px;border-radius:11px;color:#b8d7d9;font-size:10px;line-height:1.65}
.rail-note:before{content:"POLÍTICA OPERATIVA";display:block;font:9px var(--mono);letter-spacing:.12em;color:var(--cyan);margin-bottom:9px}
.main{padding:0 clamp(18px,3vw,46px) 42px}
.top{height:70px;border-bottom:1px solid rgba(44,65,83,.72)}
.top .mono{font-size:10px;letter-spacing:.09em}
.chip{border-color:#2b4051;background:rgba(12,23,34,.78);letter-spacing:.04em}
.btn{font-size:11px;font-weight:650;letter-spacing:.02em;border-color:#32646a;background:linear-gradient(135deg,#12343a,#0e242d);box-shadow:0 4px 18px rgba(0,0,0,.16);transition:transform .18s,border-color .18s,background .18s}
.btn:hover{background:linear-gradient(135deg,#19464a,#12303a);border-color:#59cfc2;transform:translateY(-1px)}
.btn:disabled{opacity:.55;cursor:wait;transform:none}
.hero{position:relative;overflow:hidden;padding:38px 0 27px;align-items:center;min-height:215px}
.hero:after{content:"";position:absolute;right:17%;top:5px;width:270px;height:190px;pointer-events:none;background:radial-gradient(ellipse,rgba(41,178,177,.10),transparent 68%);filter:blur(5px)}
.eyebrow{font-size:9px;letter-spacing:.2em;color:#7af7e5}
.hero h1{font-size:clamp(30px,4vw,49px);letter-spacing:-.055em;margin:12px 0 12px;font-weight:690}
.hero p{font-size:12px;line-height:1.8;max-width:580px;color:#9aacc0}
.hero-side{position:relative;z-index:1;display:flex;align-items:center;gap:14px;min-width:190px;padding:12px 14px;border:1px solid #263e4c;border-radius:12px;background:linear-gradient(145deg,rgba(16,31,44,.86),rgba(9,17,27,.9));box-shadow:0 12px 35px rgba(0,0,0,.17)}
.hero-orbit{width:58px;height:58px;flex:0 0 58px;filter:drop-shadow(0 0 12px rgba(106,245,226,.12))}
.hero-side .label{font-size:9px;letter-spacing:.1em}.hero-side #updated{font-size:11px;margin-top:5px;color:#d9e7f3}
.grid{gap:13px}
.card{position:relative;overflow:hidden;padding:17px 17px 16px;border-color:#263748;background:linear-gradient(145deg,rgba(18,30,44,.97),rgba(10,17,27,.98));box-shadow:0 10px 30px rgba(0,0,0,.11);transition:transform .18s,border-color .18s,box-shadow .18s}
.card:before{content:"";position:absolute;left:0;right:0;top:0;height:2px;background:linear-gradient(90deg,rgba(106,245,226,.75),rgba(106,245,226,0))}
.card:hover{transform:translateY(-2px);border-color:#3d6871;box-shadow:0 15px 34px rgba(0,0,0,.19)}
.label{font-size:9px;letter-spacing:.13em}
.value{font-size:30px;letter-spacing:-.055em;font-weight:600;margin:12px 0 6px}
.detail{font-size:10px;line-height:1.6}
.section{margin:31px 0 13px}
.section h2{font-size:13px;font-weight:650;letter-spacing:.015em}
.status{font-size:10px}
select{color:var(--text);background:#0b1420;border:1px solid #2b4052;border-radius:7px;padding:6px 8px}
.panel{border-color:#27394b;background:linear-gradient(145deg,rgba(14,23,35,.97),rgba(9,15,24,.98));box-shadow:0 12px 32px rgba(0,0,0,.1)}
.panel-head{padding:15px 17px;background:rgba(18,31,45,.5);border-bottom-color:#253748}
.panel-head h3{font-size:10px;letter-spacing:.1em;text-transform:uppercase}
th{font-size:9px;letter-spacing:.12em}
th,td{padding:14px 16px;border-bottom-color:#1e2c3b}
tbody tr:hover{background:rgba(34,70,79,.12)}
td strong{font-size:12px;letter-spacing:.025em}
.tag{font-size:9px;letter-spacing:.025em;background:rgba(8,14,22,.45)}
.tag.good{color:#c8ff9c;border-color:#365c46;background:rgba(36,75,48,.15)}
.tag.warn{color:#ffd18a;border-color:#5c4a32;background:rgba(83,58,25,.15)}
.tag.unknown{color:#bdc9d7;border-color:#3a4b5c;background:rgba(47,63,79,.14)}
.cols{gap:13px}
.list{padding:13px;gap:8px}
.item{padding:13px 14px;border-color:#29394a;background:linear-gradient(135deg,rgba(15,27,40,.88),rgba(10,17,27,.9));border-radius:10px}
.item strong{font-size:11px;letter-spacing:.015em}
.item p{font-size:10px;line-height:1.7;color:#95a9bd}
.notice{border-color:#5c4a31;background:linear-gradient(100deg,rgba(53,39,22,.75),rgba(27,24,21,.8));color:#e8cc9c;border-radius:10px;line-height:1.7}
.footer{font-size:9px;letter-spacing:.025em;border-top-color:#263748}
.empty{font-size:11px;line-height:1.7}
#connection{display:inline-flex;align-items:center;gap:6px}
#connection:before{content:"";width:5px;height:5px;border-radius:50%;background:currentColor;box-shadow:0 0 9px currentColor}
#connection.lime{color:var(--lime)}
#connection.error{color:var(--red)}
#stale{scroll-margin-top:20px}
@media(max-width:850px){.shell{grid-template-columns:1fr}.rail{position:relative;height:auto;padding:18px 18px 14px}.sub{margin:7px 0 16px}.rail-note{margin-top:15px}.main{padding:0 18px 30px}.hero{min-height:0;padding:29px 0 22px}.hero:after{right:0}.hero-side{align-self:stretch;max-width:300px}.section{margin-top:25px}}
@media(max-width:520px){.main{padding:0 13px 25px}.top{align-items:flex-start;padding:12px 0}.top>div{display:flex;align-items:center;gap:7px;flex-wrap:wrap}.grid{gap:8px}.card{padding:13px 12px}.value{font-size:25px}.hero h1{font-size:31px}.hero p{font-size:11px}.hero-side{padding:10px 12px}.panel-head{padding:12px}.nav a{font-size:11px}.rail-note{font-size:10px}}
@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}*,*:before,*:after{transition:none!important;animation:none!important}}

.command-strip{display:flex;flex-wrap:wrap;gap:8px;margin-top:13px}
.command-strip span{display:inline-flex;align-items:center;gap:8px;border:1px solid #223646;background:rgba(10,18,28,.66);padding:8px 10px;border-radius:7px;color:#8198ad;font:9px var(--mono);letter-spacing:.06em}
.command-strip b{font-weight:500;color:var(--cyan)}

</style></head>
<body><div class="shell">
<aside class="rail"><div class="brand">⬡ BLUMIX</div><div class="sub">INTELLIGENCE CENTER · LOCAL</div>
<nav class="nav" aria-label="Navegación principal"><a href="#overview">Resumen ejecutivo</a><a href="#projects">Proyectos</a><a href="#services">Procesos y servicios</a><a href="#incidents">Hallazgos</a></nav>
<div class="rail-note">MODO SOLO LECTURA<br><br>El panel no instala, detiene, borra ni modifica servicios. La salud funcional solo se declara cuando existe una prueba específica.</div></aside>
<main class="main"><header class="top"><span class="mono muted">BLUMIX / LOCAL DIAGNOSTICS</span><div><span id="connection" class="chip">Conectando…</span> <button id="refresh" class="btn" type="button">Actualizar</button></div></header>
<section id="overview"><div class="hero"><div><div class="eyebrow">Control plane · evidencia, no suposiciones</div><h1>Centro de <span class="cyan">inteligencia</span></h1><p>Métricas locales y estados verificables del ecosistema. Los datos se consultan al equipo en el momento de la actualización; no se envían a servicios externos.</p></div><div class="hero-side"><svg class="hero-orbit" viewBox="0 0 64 64" role="img" aria-label="Emblema visual BLUMIX"><circle cx="32" cy="32" r="25" fill="none" stroke="#294a57" stroke-width="1"/><circle cx="32" cy="32" r="17" fill="none" stroke="#356b72" stroke-width="1" stroke-dasharray="3 4"/><ellipse cx="32" cy="32" rx="28" ry="10" fill="none" stroke="#6af5e2" stroke-width="1" opacity=".75" transform="rotate(-42 32 32)"/><path d="M32 20 42 26 42 38 32 44 22 38 22 26Z" fill="#102b34" stroke="#6af5e2" stroke-width="1.4"/><circle cx="32" cy="32" r="3" fill="#c8ff7b"/><circle cx="52" cy="15" r="2.5" fill="#c8ff7b"/></svg><div><div class="label">Última consulta local</div><div id="updated" class="mono muted">Sin datos todavía</div><div class="detail" style="margin-top:5px;color:#6af5e2">● SOLO LECTURA</div></div></div></div>
<div class="grid">
<div class="card"><div class="label">CPU</div><div id="cpu" class="value cyan">—</div><div class="detail">Muestra breve · no es tendencia</div></div>
<div class="card"><div class="label">Memoria usada</div><div id="memory" class="value">—</div><div class="detail">Calculada desde MemAvailable</div></div>
<div class="card"><div class="label">Disco raíz</div><div id="disk" class="value">—</div><div class="detail">Uso de la partición raíz</div></div>
<div class="card"><div class="label">Carga / núcleos</div><div id="load" class="value">—</div><div class="detail">Carga media a 1 minuto</div></div>
</div><div class="command-strip" aria-label="Política del centro de mando"><span><b>01</b> DIAGNÓSTICO LOCAL</span><span><b>02</b> SIN TELEMETRÍA EXTERNA</span><span><b>03</b> ACCIONES MANUALES</span></div></section>
<section id="projects"><div class="section"><h2>Inventario del ecosistema</h2><label class="status">Filtrar <select id="project-filter" aria-label="Filtrar proyectos"><option value="all">Todos los estados</option><option value="GIT_DETECTED">Git detectado</option><option value="DISCOVERED">Solo carpeta</option><option value="NOT_FOUND">No encontrado</option></select></label></div>
<div class="panel"><div class="panel-head"><h3>BLUMCL · BLUMSEC · BLUMELIX</h3><span id="project-count" class="status">Pendiente</span></div><div class="table-wrap"><table><thead><tr><th>Proyecto</th><th>Evidencia</th><th>Salud funcional</th></tr></thead><tbody id="projects-body"><tr><td colspan="3" class="empty">Esperando datos locales…</td></tr></tbody></table></div></div></section>
<section id="services"><div class="section"><h2>Procesos y unidades observables</h2><span class="status">Sin argumentos de procesos</span></div><div class="cols"><div class="panel"><div class="panel-head"><h3>Procesos relacionados por nombre</h3><span class="status">ps</span></div><div id="process-list" class="list"><div class="empty">Pendiente</div></div></div><div class="panel"><div class="panel-head"><h3>Unidades systemd relacionadas</h3><span class="status">systemctl</span></div><div id="service-list" class="list"><div class="empty">Pendiente</div></div></div></div></section>
<section id="incidents"><div class="section"><h2>Hallazgos y límites</h2><span class="status">Derivados de evidencia local</span></div><div id="findings" class="cols"><div class="item"><strong>Diagnóstico pendiente</strong><p>Actualiza para consultar los datos del equipo.</p></div></div></section>
<div class="notice" id="stale" role="status">La información no se considera actual hasta que la consulta termine correctamente. Si pierdes conexión, la interfaz estática puede seguir abriéndose, pero los diagnósticos no se actualizan offline.</div>
<footer class="footer"><span>BLUMIX · local-first · sin telemetría externa</span><span>Los procesos activos no prueban salud funcional.</span></footer>
</main></div>
<script>
"use strict";
const $ = id => document.getElementById(id);
let lastSuccess = null;
function tag(state){const c=state==="GIT_DETECTED"||state==="OBSERVED"?"good":state==="DISCOVERED"||state==="REVIEW"||state==="DEGRADED"?"warn":"unknown";return '<span class="tag '+c+'">'+escapeHtml(state)+'</span>'}
function escapeHtml(value){return String(value).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}
async function api(name){const response=await fetch("/api/"+name,{cache:"no-store",headers:{"Accept":"application/json"}});if(!response.ok)throw new Error(name+" HTTP "+response.status);return response.json()}
function renderProjects(data){const filter=$("project-filter").value;const items=data.projects.filter(x=>filter==="all"||x.state===filter);$("project-count").textContent=items.length+" / "+data.projects.length;$("projects-body").innerHTML=items.map(x=>'<tr><td><strong>'+escapeHtml(x.id)+'</strong></td><td>'+tag(x.state)+'<div class="detail">'+escapeHtml(x.evidence)+'</div></td><td>'+tag(x.functional_health)+'</td></tr>').join("")||'<tr><td colspan="3" class="empty">No hay proyectos en este filtro.</td></tr>'}
function renderServices(data){$("process-list").innerHTML=data.processes.length?data.processes.map(x=>'<div class="item"><strong>'+escapeHtml(x.name)+'</strong><p>PID '+escapeHtml(x.pid)+' · PROCESS_DETECTED</p></div>').join(""):'<div class="empty">No se observó un proceso con nombre explícito de proyecto. Esto no prueba que no exista una aplicación.</div>';$("service-list").innerHTML=data.services.length?data.services.map(x=>'<div class="item"><strong>'+escapeHtml(x.name)+'</strong><p>SERVICE_ACTIVE · '+escapeHtml(x.source)+'</p></div>').join(""):'<div class="empty">No se encontró una unidad systemd con nombre de proyecto. Otros gestores o procesos genéricos no se descartan.</div>'}
function renderFindings(intel,projects,services){const rows=[];if(intel.state==="DEGRADED")rows.push(["Atención prioritaria","Una o más métricas superan umbrales locales. Revisa la evidencia antes de intervenir."]);else if(intel.state==="REVIEW")rows.push(["Revisión recomendada","Una o más métricas están elevadas; una muestra aislada no determina la causa."]);else rows.push(["Sin alertas por umbral","Esto no demuestra ausencia de fallos funcionales."]);projects.projects.filter(p=>p.state==="NOT_FOUND").forEach(p=>rows.push(["Proyecto no encontrado",p.id+" no existe en la ubicación configurada para esta inspección."]));rows.push(["Salud funcional desconocida","No se han verificado endpoints, pruebas de aplicación ni contratos de servicio."]);$("findings").innerHTML=rows.map((x,i)=>'<div class="item"><strong>'+escapeHtml(String(i+1).padStart(2,"0")+" · "+x[0])+'</strong><p>'+escapeHtml(x[1])+'</p></div>').join("")}
async function refresh(){const button=$("refresh");button.disabled=true;$("connection").textContent="Consultando…";$("stale").textContent="Consultando diagnósticos locales…";try{const results=await Promise.all([api("intelligence"),api("projects"),api("services")]);const intel=results[0],projects=results[1],services=results[2];if(intel.schema!=="blumix.intelligence.v1"||projects.schema!=="blumix.projects.v1"||services.schema!=="blumix.services.v1")throw new Error("Esquema de respuesta no reconocido");const m=intel.metrics;$("cpu").textContent=m.cpu_percent===null?"N/D":m.cpu_percent+"%";$("memory").textContent=m.memory_used_percent===null?"N/D":m.memory_used_percent+"%";$("disk").textContent=m.root_disk_used_percent===null?"N/D":m.root_disk_used_percent+"%";$("load").textContent=(m.load_1m===null?"N/D":m.load_1m)+" / "+(m.logical_cores===null?"N/D":m.logical_cores);renderProjects(projects);renderServices(services);renderFindings(intel,projects,services);lastSuccess=new Date();$("updated").textContent=lastSuccess.toLocaleTimeString();$("connection").textContent="LOCAL · ACTUALIZADO";$("connection").className="chip lime";$("stale").textContent="Datos actualizados en "+lastSuccess.toLocaleString()+". La interfaz offline no refresca los diagnósticos."}catch(error){$("connection").textContent="SIN DATOS ACTUALES";$("connection").className="chip error";$("stale").textContent="No se pudo actualizar: "+error.message+". Los datos anteriores no deben interpretarse como actuales.";if(!lastSuccess)$("findings").innerHTML='<div class="item"><strong class="red">Diagnóstico no disponible</strong><p>'+escapeHtml(error.message)+'</p></div>'}finally{button.disabled=false}}
$("refresh").addEventListener("click",refresh);$("project-filter").addEventListener("change",()=>api("projects").then(renderProjects).catch(()=>{}));window.addEventListener("online",()=>{if(!lastSuccess||Date.now()-lastSuccess.getTime()>60000)refresh()});if("serviceWorker" in navigator)window.addEventListener("load",()=>navigator.serviceWorker.register("/sw.js").catch(()=>{}));refresh();
</script></body></html>"""

MANIFEST = {
    "name": "BLUMIX Intelligence Center",
    "short_name": "BLUMIX",
    "description": "Panel local de diagnóstico de solo lectura.",
    "lang": "es",
    "start_url": "/",
    "scope": "/",
    "display": "standalone",
    "background_color": "#080b12",
    "theme_color": "#080b12",
    "icons": [{"src": "/icon.svg", "sizes": "any", "type": "image/svg+xml", "purpose": "any maskable"}],
}
ICON = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128"><rect width="128" height="128" rx="24" fill="#080b12"/><path d="M36 15h56l28 49-28 49H36L8 64z" fill="#102a32" stroke="#67f4e0" stroke-width="4"/><path d="M39 82V46h8l17 22 17-22h8v36h-9V59L64 78 48 59v23z" fill="#67f4e0"/></svg>"""
SW = r"""'use strict';
const CACHE='blumix-intelligence-shell-v1';
const SHELL=['/','/manifest.webmanifest','/icon.svg','/sw.js'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(SHELL)));self.skipWaiting()});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('blumix-intelligence-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{const r=e.request;if(r.method!=='GET')return;const u=new URL(r.url);if(u.origin!==self.location.origin)return;if(u.pathname.startsWith('/api/')){e.respondWith(fetch(r,{cache:'no-store'}));return}if(r.mode==='navigate'){e.respondWith(fetch(r).catch(()=>caches.match('/')));return}e.respondWith(caches.match(r).then(c=>c||fetch(r)))});
"""

class Handler(BaseHTTPRequestHandler):
    server_version = "BLUMIXLocal/1.0"

    def _headers(self, status: int, content_type: str, length: int, cache: str = "no-store") -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(length))
        self.send_header("Cache-Control", cache)
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; connect-src 'self'; img-src 'self' data:; object-src 'none'; base-uri 'none'; frame-ancestors 'none'")
        self.end_headers()

    def _send(self, status: int, body: bytes, content_type: str) -> None:
        self._headers(status, content_type, len(body))
        self.wfile.write(body)

    def _json(self, status: int, value: object) -> None:
        body = json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self._send(status, body, "application/json; charset=utf-8")

    def do_GET(self) -> None:
        host = self.headers.get("Host", "")
        allowed = {"127.0.0.1", "localhost", "127.0.0.1:" + str(self.server.server_port), "localhost:" + str(self.server.server_port)}
        if host not in allowed:
            self._json(403, {"error": "Host no permitido; usa localhost o 127.0.0.1."})
            return
        path = urlsplit(self.path).path
        static = {
            "/": (HTML.encode("utf-8"), "text/html; charset=utf-8"),
            "/index.html": (HTML.encode("utf-8"), "text/html; charset=utf-8"),
            "/manifest.webmanifest": (json.dumps(MANIFEST, ensure_ascii=False).encode("utf-8"), "application/manifest+json; charset=utf-8"),
            "/icon.svg": (ICON.encode("utf-8"), "image/svg+xml; charset=utf-8"),
            "/sw.js": (SW.encode("utf-8"), "text/javascript; charset=utf-8"),
        }
        if path in static:
            body, content_type = static[path]
            cache = "no-cache" if path == "/sw.js" else "no-store"
            self._headers(200, content_type, len(body), cache)
            self.wfile.write(body)
            return
        commands = {
            "/api/intelligence": ["intelligence", "--json"],
            "/api/projects": ["projects", "--json"],
            "/api/services": ["services", "--json"],
        }
        if path in commands:
            try:
                result = subprocess.run(
                    [str(CLI), *commands[path]],
                    cwd=str(ROOT),
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    timeout=8,
                    check=False,
                    env={"PATH": "/usr/local/bin:/usr/bin:/bin", "HOME": str(Path.home()), "LC_ALL": "C.UTF-8", "BLUMIX_ANIM": "0"},
                )
                if result.returncode != 0:
                    self._json(503, {"error": "El diagnóstico local terminó con error.", "exit_code": result.returncode})
                    return
                data = json.loads(result.stdout)
                self._json(200, data)
            except subprocess.TimeoutExpired:
                self._json(504, {"error": "El diagnóstico superó el límite de 8 segundos."})
            except (OSError, json.JSONDecodeError):
                self._json(503, {"error": "No se pudo obtener una respuesta JSON válida del diagnóstico local."})
            return
        self._json(404, {"error": "Ruta no encontrada."})

    def do_POST(self) -> None:
        self._json(405, {"error": "Solo se permiten solicitudes GET de lectura."})

    def log_message(self, fmt: str, *args: object) -> None:
        # No registrar query strings ni datos potencialmente sensibles.
        sys.stderr.write("BLUMIX local: " + (fmt % args).split("?", 1)[0] + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Servidor web local de BLUMIX, solo lectura.")
    parser.add_argument("--port", type=int, default=8765, help="Puerto local entre 1024 y 65535 (por defecto 8765)")
    args = parser.parse_args()
    if not 1024 <= args.port <= 65535:
        parser.error("--port debe estar entre 1024 y 65535")
    if not CLI.is_file():
        print("BLUMIX: no se encuentra bin/blumix en la raíz del repositorio.", file=sys.stderr)
        return 1
    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    server.daemon_threads = True
    print("BLUMIX Intelligence Center disponible solo en este equipo: http://127.0.0.1:%d/" % args.port)
    print("Detener con Ctrl+C. La API es de solo lectura; no ejecuta comandos arbitrarios.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nCierre solicitado; no se modificó la configuración del sistema.")
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
