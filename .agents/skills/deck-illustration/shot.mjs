// usage: node shot.mjs <deck> <outDir> <n1,n2,...>
import { spawn } from 'node:child_process';
import { writeFileSync, mkdirSync } from 'node:fs';
const [deck, outDir, list] = process.argv.slice(2);
mkdirSync(outDir, { recursive: true });
const port = 9333;
const edge = spawn('C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe', [
  '--headless=new', `--remote-debugging-port=${port}`, '--window-size=1280,720',
  '--hide-scrollbars', '--user-data-dir=' + (await import('node:path')).resolve(outDir, '_profile'), 'about:blank'], { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let tgt;
for (let i = 0; i < 40; i++) { try { tgt = await (await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, { method: 'PUT' })).json(); break; } catch { await sleep(250); } }
const ws = new WebSocket(tgt.webSocketDebuggerUrl);
await new Promise(r => ws.onopen = r);
let id = 0; const pend = {};
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pend[m.id]) { pend[m.id](m.result); delete pend[m.id]; } };
const send = (method, params = {}) => new Promise(r => { const i = ++id; pend[i] = r; ws.send(JSON.stringify({ id: i, method, params })); });
await send('Emulation.setDeviceMetricsOverride', { width: 1280, height: 720, deviceScaleFactor: 1, mobile: false });
await send('Page.enable');
// serve 가 IPv4/IPv6 중 한쪽에만 붙는 경우가 있어 열리는 주소를 고릅니다
let base = 'http://127.0.0.1:5599';
for (const b of ['http://127.0.0.1:5599', 'http://[::1]:5599']) { try { await fetch(b + '/'); base = b; break; } catch {} }
await send('Page.navigate', { url: `${base}/?deck=${encodeURIComponent(deck)}` });
await sleep(3500);
await send('Runtime.evaluate', { expression: `document.querySelector('.nav-controls, .controls, nav')?.style.setProperty('display','none')` });
for (const n of list.split(',')) {
  await send('Runtime.evaluate', { expression: `currentSlide=${n - 1}; updateSlideUI();` });
  await sleep(1500);
  const r = await send('Page.captureScreenshot', { format: 'jpeg', quality: 80 });
  writeFileSync(`${outDir}/${String(n).padStart(2, '0')}.jpg`, Buffer.from(r.data, 'base64'));
}
ws.close(); edge.kill();
console.log('done');
