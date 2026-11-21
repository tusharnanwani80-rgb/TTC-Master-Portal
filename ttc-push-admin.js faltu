/* ═══════════════════════════════════════════════════════════
   TTC Command Center — Push coverage + health add-on
   Loaded with ONE line in the Command Center index.html.
   ═══════════════════════════════════════════════════════════ */
(function () {
  'use strict';
  var coverage = null, health = null;

  function norm(x) { return String(x || '').trim().toUpperCase(); }
  function esc(x) { return String(x).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }

  function buildPanel() {
    if (document.getElementById('ttcPushPanel')) return;
    var anchor = document.querySelector('#main-ui .roster-header');
    if (!anchor) return;
    var p = document.createElement('div');
    p.id = 'ttcPushPanel';
    p.style.cssText = 'margin:0 0 10px';
    p.innerHTML =
      '<div id="ttcPushWarn" style="display:none;background:#FEE2E2;border:1px solid #FCA5A5;color:#991B1B;border-radius:12px;padding:10px 12px;font-size:12px;font-weight:700;line-height:1.4;margin-bottom:8px"></div>' +
      '<div style="display:flex;justify-content:space-between;align-items:center;gap:8px;background:var(--white);border:1px solid var(--border);border-radius:12px;padding:8px 12px">' +
        '<span id="ttcPushCount" style="font-size:12px;font-weight:700;color:var(--dark)">🔔 Checking alerts…</span>' +
        '<button id="ttcPushCopy" type="button" style="border:1px solid var(--border);background:var(--light);border-radius:50px;padding:5px 11px;font-size:11px;font-weight:800;color:var(--dark);cursor:pointer;white-space:nowrap;display:none">📋 Copy missing</button>' +
      '</div>';
    anchor.parentNode.insertBefore(p, anchor);
    document.getElementById('ttcPushCopy').onclick = copyMissing;
  }

  function visibleRows() {
    var out = [];
    document.querySelectorAll('#studentGrid .stu-check input').forEach(function (inp) {
      var id = inp.value;
      out.push({ id: id, on: (coverage && coverage[norm(id)]) > 0 });
    });
    return out;
  }

  function decorate() {
    if (!coverage) return;
    document.querySelectorAll('#studentGrid .stu-check').forEach(function (l) {
      var inp = l.querySelector('input'); if (!inp) return;
      var n = coverage[norm(inp.value)] || 0;
      var b = l.querySelector('.ttc-bell');
      if (!b) {
        b = document.createElement('span'); b.className = 'ttc-bell';
        b.style.cssText = 'position:absolute;top:3px;right:5px;font-size:10px;line-height:1';
        l.style.position = 'relative'; l.appendChild(b);
      }
      b.textContent = n ? '🔔' : '🔕';
      b.style.opacity = n ? '1' : '0.35';
      b.title = n ? (n + ' device(s) with alerts ON') : 'Alerts not enabled yet';
    });
    summary();
  }

  function summary() {
    buildPanel();
    var el = document.getElementById('ttcPushCount'), btn = document.getElementById('ttcPushCopy');
    if (!el || !coverage) return;
    var rows = visibleRows();
    if (!rows.length) { el.textContent = '🔔 Alerts: —'; if (btn) btn.style.display = 'none'; return; }
    var on = rows.filter(function (r) { return r.on; }).length;
    el.textContent = '🔔 Alerts ON: ' + on + ' of ' + rows.length + ' in view';
    if (btn) btn.style.display = (rows.length - on) > 0 ? 'inline-block' : 'none';
  }

  function banner() {
    buildPanel();
    var w = document.getElementById('ttcPushWarn'); if (!w) return;
    if (health && health.failed > 0) {
      w.style.display = 'block';
      w.innerHTML = '⚠️ Push alerts had a problem (' + esc(health.ts || '') + '). Parents may NOT be getting notifications.<br><span style="font-weight:600">' +
        esc(health.err || 'Unknown error') + '</span><br><span style="font-weight:600">Check the Firebase key (FCM_SA) or GAS → Executions → doPost log.</span>';
    } else { w.style.display = 'none'; }
  }

  function copyMissing() {
    var missing = visibleRows().filter(function (r) { return !r.on; }).map(function (r) {
      var s = (typeof ALL_STUDENTS !== 'undefined' && ALL_STUDENTS[r.id]) || {};
      return (s.name || r.id) + ' (' + r.id + ')' + (s.class ? ' – ' + s.class : '');
    });
    var text = 'Alerts not enabled yet:\n' + missing.join('\n');
    var btn = document.getElementById('ttcPushCopy'), old = btn.textContent;
    function done() { btn.textContent = '✅ Copied'; setTimeout(function () { btn.textContent = old; }, 1500); }
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, fallback); else fallback();
    function fallback() {
      var ta = document.createElement('textarea'); ta.value = text; document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy'); done(); } catch (e) {} document.body.removeChild(ta);
    }
  }

  async function load() {
    try {
      var r = await fetch(WEB_APP_URL + '?push=status');
      var j = await r.json();
      if (j.status === 'ok') { coverage = j.coverage || {}; health = j.health || null; decorate(); banner(); }
    } catch (e) { /* silent: the Command Center must never break because of this add-on */ }
  }

  function start() {
    buildPanel();
    var grid = document.getElementById('studentGrid');
    if (grid) new MutationObserver(decorate).observe(grid, { childList: true });   // re-badge after filters/search/refresh
    load();
    setInterval(load, 60000);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
