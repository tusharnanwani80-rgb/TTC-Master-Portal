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


/* ═══════════════════════════════════════════════════════════
   📚 Syllabus (added with the "students can edit syllabus" update)
   1) "✍️ by parent" tag on chapters a parent / student changed
   2) one short update notice for you & the teachers — at most 5 times per device, and never again once used
   ═══════════════════════════════════════════════════════════ */
(function () {
  'use strict';
  var NOTE_KEY = 'ttc_cc_syl_notice_n', NOTE_MAX = 5;

  function lsGet(k) { try { return localStorage.getItem(k); } catch (e) { return null; } }
  function lsSet(k, v) { try { localStorage.setItem(k, v); } catch (e) { } }
  function plain(k) { return String(k).replace(/[^\x00-\x7F]/g, '').trim(); }   // same clean-up the syllabus list uses for subject names

  // ── 1) tags ──
  function tagParentEdits() {
    var box = document.getElementById('sylHistoryList');
    if (!box || typeof ALL_STUDENTS === 'undefined' || typeof selectedIds === 'undefined') return;
    var ids = Array.from(selectedIds);
    Array.prototype.forEach.call(box.querySelectorAll('.list-item'), function (it) {
      if (it.querySelector('.sx-by')) return;
      var sEl = it.querySelector('.item-subj'), cEl = it.querySelector('.item-task');
      if (!sEl || !cEl) return;
      var subj = sEl.textContent.trim(), chap = cEl.textContent.trim();
      var names = [];
      ids.forEach(function (id) {
        var s = ALL_STUDENTS[id]; if (!s || !s.sylMeta) return;
        for (var k in s.sylMeta) {
          if (plain(k) !== subj) continue;
          var m = s.sylMeta[k][chap];
          if (m && m.p) { names.push(String(s.name).split(' ')[0]); break; }
        }
      });
      if (!names.length) return;
      var tag = document.createElement('span');
      tag.className = 'sx-by';
      tag.style.cssText = 'display:inline-block;margin-left:8px;font-size:10px;font-weight:800;text-transform:none;letter-spacing:0;color:#4361EE;background:#EEF2FF;border:1px solid #C7D2FE;border-radius:50px;padding:2px 8px;vertical-align:middle';
      tag.textContent = ids.length > 1 ? '✍️ by parent: ' + names.join(', ') : '✍️ by parent';
      sEl.appendChild(tag);
    });
  }

  // ── 2) notice ──
  function noteCount() { return parseInt(lsGet(NOTE_KEY) || '0', 10) || 0; }
  var shown = false;
  function showNotice() {
    var m = document.createElement('div');
    m.className = 'modal'; m.id = 'sylNotice'; m.style.display = 'flex';
    m.innerHTML =
      '<div class="modal-box" style="text-align:center">' +
        '<div style="width:56px;height:56px;border-radius:18px;background:#EEF2FF;display:flex;align-items:center;justify-content:center;font-size:28px;margin:0 auto 12px">📚</div>' +
        '<div class="modal-title" style="margin-bottom:8px">TTC PD update</div>' +
        '<p style="font-size:14px;font-weight:600;color:var(--grey);line-height:1.5;margin-bottom:18px">Students and parents can now add subjects &amp; chapters and mark their own syllabus progress. Their changes show a “✍️ by parent” tag, and chapters you mark Completed stay locked for them.</p>' +
        '<div style="display:flex;gap:10px"><button type="button" class="modal-btn secondary" data-n="ok">Got it</button>' +
        '<button type="button" class="modal-btn" data-n="go" style="background:var(--rust);color:#fff">Open Syllabus</button></div>' +
      '</div>';
    document.body.appendChild(m);
    m.addEventListener('click', function (e) {
      var b = e.target.closest ? e.target.closest('[data-n]') : null;
      if (b && b.getAttribute('data-n') === 'go') { lsSet(NOTE_KEY, String(NOTE_MAX)); m.parentNode.removeChild(m); if (typeof switchTab === 'function') switchTab('syl'); }
      else if ((b && b.getAttribute('data-n') === 'ok') || e.target === m) m.parentNode.removeChild(m);
    });
  }
  function maybeNotice() {
    if (shown || noteCount() >= NOTE_MAX) return;
    shown = true;                                            // once per app opening…
    lsSet(NOTE_KEY, String(noteCount() + 1));                // …and 5 openings in total
    showNotice();
  }
  function waitForLogin() {
    var tries = 0;
    var iv = setInterval(function () {
      var ui = document.getElementById('main-ui');
      if (ui && ui.style.display !== 'none' && ui.style.display !== '') { clearInterval(iv); setTimeout(maybeNotice, 1500); }
      else if (++tries > 240) clearInterval(iv);             // give up after ~3 minutes
    }, 750);
  }

  function start() {
    var box = document.getElementById('sylHistoryList');
    if (box) new MutationObserver(tagParentEdits).observe(box, { childList: true });
    if (noteCount() < NOTE_MAX) waitForLogin();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
