<!DOCTYPE html>
<html lang="en" translate="no">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="google" content="notranslate">
  <title>TTC Command Center</title>
  <link rel="manifest" href="manifest.json?v=1">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    :root {
      --blue: #4361EE; --orange: #FF6B35; --lime: #C8FF00; --pink: #FF3D8A;
      --white: #FFFFFF; --off: #F8FAFC; --dark: #0F172A; --grey: #64748B;
      --light: #F1F5F9; --green: #10B981; --rust: #D94F2B; --border: #E2E8F0;
    }
    
    * { box-sizing: border-box; margin: 0; padding: 0; -webkit-tap-highlight-color: transparent; }
    body { 
      font-family: 'DM Sans', sans-serif; 
      background: var(--off);
      min-height: 100vh; padding-bottom: 120px; color: var(--dark); 
      overflow-x: hidden;
    }
    
    /* Header */
    .hdr { background: var(--white); padding: 16px 20px; border-bottom: 1px solid var(--border); position: sticky; top: 0; z-index: 100; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 10px rgba(0,0,0,0.02); }
    .hdr-logo { width: 40px; height: 40px; border-radius: 10px; object-fit: cover; border: 1px solid var(--border); }
    .hdr-title { font-size: 18px; font-weight: 800; color: var(--dark); line-height: 1.1; margin-bottom: 2px; }
    .hdr-badge { display: inline-block; font-size: 10px; font-weight: 800; background: var(--blue); color: var(--white); padding: 3px 8px; border-radius: 6px; text-transform: uppercase; letter-spacing: 0.5px; }

    .container { max-width: 600px; margin: 0 auto; padding: 20px 16px; }
    
    /* Smart Filter Engine */
    .filter-wrapper { position: relative; margin-bottom: 8px; }
    .filter-wrapper::after { content: ''; position: absolute; right: 0; top: 0; bottom: 12px; width: 40px; background: linear-gradient(to right, transparent, var(--off)); pointer-events: none; }
    .filter-scroll { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 12px; scrollbar-width: none; }
    .filter-scroll::-webkit-scrollbar { display: none; }
    .filter-chip { flex-shrink: 0; padding: 8px 16px; font-size: 13px; font-weight: 700; background: var(--white); border: 1px solid var(--border); border-radius: 50px; color: var(--grey); cursor: pointer; transition: 0.15s; }
    .filter-chip:active { transform: scale(0.96); }
    .filter-chip.active { background: var(--dark); color: var(--white); border-color: var(--dark); }
    .filter-chip.group-chip { display:flex; align-items:center; gap:6px; background: #FFF4E5; border-color: #FFD2B3; color: var(--rust); }
    .filter-chip.group-chip.active { background: var(--rust); color: var(--white); border-color: var(--rust); }
    .del-grp { background: rgba(0,0,0,0.06); border-radius: 50%; width: 18px; height: 18px; display:inline-flex; align-items:center; justify-content:center; font-size:10px; font-weight:bold; color:inherit; margin-right: -4px;}
    .filter-chip.active .del-grp { background: rgba(255,255,255,0.2); }

    /* Roster Pill Cards */
    .roster-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; padding: 0 4px; font-size: 13px; font-weight: 800; color: var(--grey); text-transform: uppercase; letter-spacing: 0.5px; }
    #selectAllBtn { font-size: 12px; font-weight: 700; background: var(--light); color: var(--dark); border: none; padding: 6px 12px; border-radius: 8px; cursor: pointer; transition: 0.1s; }
    #selectAllBtn:active { transform: scale(0.95); background: #E2E8F0; }
    
    .student-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-bottom: 16px; }
    .stu-check { background: var(--white); border: 1.5px solid var(--border); border-radius: 12px; padding: 12px 6px; text-align: center; cursor: pointer; transition: 0.15s; display: flex; flex-direction: column; align-items: center; justify-content: center; }
    .stu-check input { display: none; }
    .stu-check.selected { background: var(--rust); border-color: var(--rust); color: var(--white); box-shadow: 0 4px 10px rgba(217,79,43,0.2); }
    .stu-name { font-size: 14px; font-weight: 800; width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block; color: var(--dark); line-height: 1.2; }
    .stu-surname { font-size: 10px; font-weight: 500; color: var(--grey); display: block; margin-top: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .stu-check.selected .stu-name { color: var(--white); }
    .stu-check.selected .stu-surname { color: rgba(255,255,255,0.8); }
    .stu-cls { font-size: 9px; font-weight: 800; color: var(--blue); background: var(--off); padding: 2px 6px; border-radius: 4px; margin-top: 4px; }
    .stu-check.selected .stu-cls { color: var(--rust); background: rgba(255,255,255,0.9); }

    /* Casting Confirmation Strip */
    .casting-strip { margin-bottom: 24px; padding: 12px; background: var(--white); border-radius: 16px; border: 1px solid var(--border); box-shadow: 0 2px 8px rgba(0,0,0,0.02); display: none; animation: fadeUp 0.2s ease; }
    .cs-label { font-size: 11px; font-weight: 800; color: var(--grey); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
    .cs-pills { display: flex; gap: 8px; overflow-x: auto; scrollbar-width: none; }
    .cs-pills::-webkit-scrollbar { display: none; }
    .cs-pill { display: inline-flex; align-items: center; gap: 6px; background: var(--light); padding: 6px 12px; border-radius: 50px; font-size: 12px; font-weight: 700; color: var(--dark); white-space: nowrap; border: 1px solid var(--border); }
    .cs-pill .del { color: var(--grey); cursor: pointer; display: flex; align-items: center; justify-content: center; width: 16px; height: 16px; border-radius: 50%; background: #E2E8F0; font-size: 10px; }

    /* Tabs */
    .tabs { display: flex; gap: 8px; margin-bottom: 24px; background: var(--light); padding: 4px; border-radius: 12px; overflow-x: auto;}
    .tab-btn { flex: 1; min-width: 65px; padding: 10px 4px; font-size: 13px; font-weight: 700; color: var(--grey); background: transparent; border: none; border-radius: 8px; cursor: pointer; transition: 0.15s; }
    .tab-btn.active { background: var(--white); color: var(--blue); box-shadow: 0 2px 6px rgba(0,0,0,0.05); }
    .tab-content { display: none; animation: fadeUp 0.2s ease; }
    .tab-content.active { display: block; }

    /* Duolingo Style Data Cards */
    .dl-card { background: var(--white); border: 2.5px solid var(--border); border-radius: 20px; padding: 16px; position: relative; box-shadow: 0 6px 0 var(--border); transition: 0.1s; cursor: pointer; margin-bottom: 8px; }
    .dl-card:active { transform: translateY(6px); box-shadow: 0 0 0 var(--border); }
    .dl-hdr { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
    .dl-name { font-size: 18px; font-weight: 800; color: var(--dark); line-height: 1.1; }
    .dl-cls { font-size: 11px; font-weight: 800; color: var(--blue); background: var(--light); padding: 4px 8px; border-radius: 8px; }
    .dl-stats { display: flex; gap: 8px; margin-bottom: 12px; }
    .dl-stat { flex: 1; background: var(--off); border: 1.5px solid var(--border); border-radius: 12px; padding: 10px; text-align: center; }
    .dl-stat-val { font-size: 20px; font-weight: 900; color: var(--dark); }
    .dl-stat-lbl { font-size: 9px; font-weight: 800; color: var(--grey); text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px; }
    .dl-chart-wrap { height: 60px; width: 100%; position: relative; }

    @keyframes fadeUp { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes spin { 100% { transform: rotate(360deg); } }
    .spin-anim { animation: spin 1s linear infinite; }

    /* Inputs & Layout */
    .fld { margin-bottom: 16px; }
    label { display: block; font-size: 11px; font-weight: 800; letter-spacing: 0.5px; text-transform: uppercase; color: var(--grey); margin-bottom: 6px; }
    input[type="text"], input[type="number"], select, textarea { width: 100%; padding: 14px 16px; font-family: 'DM Sans', sans-serif; font-size: 15px; font-weight: 600; border: 1.5px solid var(--border); border-radius: 12px; background: var(--white); color: var(--dark); outline: none; transition: 0.15s; }
    input[type="text"]:focus, input[type="number"]:focus, select:focus, textarea:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(67,97,238,0.1); }
    textarea { height: 100px; resize: vertical; }

    .ttc-id-wrapper { display:flex; align-items:stretch; border:1.5px solid var(--border); border-radius:12px; overflow:hidden; background:var(--white); transition: 0.15s; }
    .ttc-id-wrapper:focus-within { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(67,97,238,0.1); }
    .ttc-id-prefix { background:var(--light); padding:14px 16px; font-weight:800; font-size:16px; color:var(--dark); border-right:1.5px solid var(--border); display:flex; align-items:center; }
    .ttc-id-wrapper input { border:none; border-radius:0; box-shadow:none; flex:1; font-size:18px; font-weight:800; color:var(--blue); padding:14px 16px; letter-spacing:1px; }
    .ttc-id-wrapper input:focus { border:none; box-shadow:none; }
    .id-status { font-size: 11px; font-weight: 700; margin-top: 6px; min-height: 14px; transition: 0.2s; }
    .id-status.avail { color: var(--green); }
    .id-status.taken { color: var(--rust); }

    .op-divider { text-align: center; margin: 28px 0 20px; position: relative; }
    .op-divider::before { content:''; position:absolute; left:0; top:50%; width:100%; height:1px; background:var(--border); z-index:1; }
    .op-divider span { background: var(--off); padding: 0 12px; font-size: 10px; font-weight: 800; color: var(--grey); position: relative; z-index: 2; letter-spacing: 1.5px; }

    .new-hw-row { display: flex; gap: 8px; align-items: flex-end; margin-bottom: 12px; }
    .new-hw-row .fld { margin-bottom: 0; }
    .remove-hw-btn { background: #FEE2E2; color: #EF4444; border: 1.5px solid #FCA5A5; border-radius: 12px; height: 51px; width: 51px; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 16px; font-weight: bold; flex-shrink: 0; transition: 0.15s; }
    .remove-hw-btn:active { transform: scale(0.95); }
    .add-more-btn { background: var(--off); color: var(--blue); border: 2px dashed rgba(67,97,238,0.4); border-radius: 12px; padding: 12px; font-size: 13px; font-weight: 800; cursor: pointer; width: 100%; transition: 0.15s; margin-bottom: 16px; }
    .add-more-btn:active { background: #E0E7FF; border-color: var(--blue); }

    /* Segmented Controls & List Items */
    .list-item { display: flex; flex-direction: column; gap: 8px; padding: 16px; background: var(--white); border: 1px solid var(--border); border-radius: 14px; margin-bottom: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
    .item-subj { font-size: 10px; font-weight: 800; color: var(--rust); text-transform: uppercase; letter-spacing: 0.5px; }
    .item-task { font-size: 14px; font-weight: 700; color: var(--dark); line-height: 1.3; word-break: break-word; white-space: normal; }
    
    .seg-ctrl { display: flex; background: var(--light); padding: 4px; border-radius: 10px; gap: 4px; width: 100%; }
    .seg-ctrl label { flex: 1; margin: 0; cursor: pointer; text-transform: none; font-weight: normal; letter-spacing: normal; }
    .seg-ctrl input[type="radio"] { display: none; }
    .seg-ctrl span { display: block; text-align: center; padding: 10px 0; border-radius: 8px; font-size: 13px; font-weight: 700; color: var(--grey); transition: all 0.2s; }
    .seg-ctrl.mini { padding: 2px; width: auto; flex: none; width: 140px; }
    .seg-ctrl.mini span { padding: 4px 0; font-size: 11px; }
    .seg-ctrl input[type="radio"]:checked + span { background: var(--white); color: var(--dark); box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    .seg-ctrl.syl input[value="Completed"]:checked + span { color: var(--green); }
    .seg-ctrl.syl input[value="Ongoing"]:checked + span { color: var(--orange); }
    .seg-ctrl.hw input[value="Done"]:checked + span { color: var(--green); }

    /* 🔥 THE SNIPER SWIPE ENGINE UI (Upgraded with Vector Icons) 🔥 */
    .swipe-wrapper { position: relative; overflow: hidden; border-radius: 14px; margin-bottom: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
    .swipe-actions { position: absolute; right: 0; top: 0; bottom: 0; width: 120px; display: flex; background: #F1F5F9; border: 1px solid var(--border); border-radius: 14px; }
    .swipe-actions button { flex: 1; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.1s; }
    
    .sa-edit { background: #EEF2FF; border-right: 1px solid var(--border); color: var(--blue); }
    .sa-edit:active { background: #C7D2FE; }
    .sa-del { background: #FEF2F2; border-radius: 0 14px 14px 0; color: #EF4444; }
    .sa-del:active { background: #FECACA; }
    
    /* The white box that slides */
    .swipe-content { position: relative; z-index: 2; transition: transform 0.25s cubic-bezier(0.34, 1.3, 0.64, 1); background: var(--white); border: 1px solid var(--border); border-radius: 14px; padding: 16px; width: 100%; display: flex; flex-direction: column; gap: 8px; }

    /* Action Bar */
    .action-bar { position: fixed; bottom: -100px; left: 0; right: 0; background: var(--white); border-top: 1px solid var(--border); padding: 12px 20px 24px; display: flex; justify-content: space-between; align-items: center; z-index: 200; box-shadow: 0 -4px 20px rgba(0,0,0,0.05); transition: bottom 0.3s cubic-bezier(.34,1.3,.64,1); }
    .action-bar.visible { bottom: 0; }
    .ab-left { display: flex; flex-direction: column; gap: 4px; max-width: 55%; }
    .selection-counter { font-size: 13px; font-weight: 800; color: var(--dark); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .save-grp-btn { background: var(--white); border: 1px solid var(--border); color: var(--grey); padding: 6px 12px; border-radius: 50px; font-size: 11px; font-weight: 700; display: inline-flex; align-items: center; gap: 4px; cursor: pointer; width: max-content; }
    .save-grp-btn:active { background: var(--light); }
    .submit-btn { padding: 14px 28px; background: var(--rust); color: var(--white); font-size: 15px; font-weight: 700; border: none; border-radius: 12px; cursor: pointer; transition: 0.15s; box-shadow: 0 4px 12px rgba(217,79,43,0.2); }
    .submit-btn:active { transform: scale(0.96); box-shadow: 0 2px 6px rgba(217,79,43,0.2); }

    /* Modals */
    .modal { display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.6); z-index: 999; align-items: center; justify-content: center; backdrop-filter: blur(2px); padding: 20px; }
    .modal-box { background: var(--white); padding: 24px; border-radius: 20px; border: 1px solid var(--border); width: 100%; max-width: 360px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); animation: fadeUp 0.2s ease; }
    .modal-title { font-size: 18px; font-weight: 800; color: var(--dark); margin-bottom: 16px; }
    .modal-btn { padding: 12px; border-radius: 12px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; flex: 1; }
    .modal-btn.secondary { background: var(--light); color: var(--dark); }
    .modal-btn.danger { background: #FEE2E2; color: #EF4444; }

    /* Overlays */
    .status-overlay { display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.6); z-index: 999; align-items: center; justify-content: center; backdrop-filter: blur(2px); padding: 20px; }
    .status-card { background: var(--white); padding: 24px; border-radius: 20px; border: 1px solid var(--border); text-align: center; width: 100%; max-width: 320px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); animation: fadeUp 0.2s ease; }
    .sc-icon { font-size: 40px; margin-bottom: 12px; }
    .sc-title { font-size: 18px; font-weight: 800; margin-bottom: 6px; color: var(--dark); }
    .sc-sub { font-size: 13px; color: var(--grey); font-weight: 500; }
  </style>
</head>
<body>

<header class="hdr" style="display:flex; justify-content:space-between; align-items:center;">
  <div style="display:flex; align-items:center; gap:12px;">
    <img class="hdr-logo" src="https://i.postimg.cc/x9mDND2Q/Ttc-logo.png" alt="TTC">
    <div>
      <div class="hdr-title">Command Center</div>
      <div class="hdr-badge">Master Portal</div>
    </div>
  </div>
  <button onclick="document.getElementById('settingsModal').style.display='flex'" style="background:var(--white); border:2px solid var(--dark); border-radius:12px; padding:6px 10px; cursor:pointer; box-shadow:2px 2px 0 var(--dark); font-size:18px; display:flex; align-items:center; justify-content:center; transition:transform 0.1s;">
    ⚙️
  </button>
</header>

<div class="container">
  
  <div id="db-loader" style="text-align:center; padding: 40px; font-size:15px; font-weight:700; color:var(--grey);">
    ⏳ Connecting to live roster...
  </div>

  <div id="main-ui" style="display:none;">
    <div class="filter-wrapper">
      <div class="filter-scroll" id="filterContainer"></div>
      <input type="text" id="rosterSearch" placeholder="🔍 Search student name..." oninput="renderRoster()" style="width:100%; padding:10px 14px; margin-top:8px; border:1px solid var(--border); border-radius:10px; font-size:13px; font-weight:600; outline:none; font-family:'DM Sans', sans-serif;">
    </div>

    <div class="roster-header">
      <span>Target Students</span>
      <button id="selectAllBtn" onclick="toggleAll()">Select All</button>
    </div>
    <div class="student-grid" id="studentGrid"></div>

    <div id="castingStrip" class="casting-strip">
      <div class="cs-label">Casting To:</div>
      <div class="cs-pills" id="csPills"></div>
    </div>

    <div class="tabs">
      <button class="tab-btn active" onclick="switchTab('hw')">📚 Homework</button>
      <button class="tab-btn" onclick="switchTab('syl')">✅ Syllabus</button>
      <button class="tab-btn" onclick="switchTab('admin')">🛡️ Admin</button>
      <button class="tab-btn" onclick="switchTab('json')">⚙️ JSON</button>
      <button class="tab-btn" onclick="switchTab('data')">📊 Data</button>
    </div>

    <div id="tab-data" class="tab-content">
      <div class="fld"><input type="text" id="dataSearch" placeholder="🔍 Search students..." oninput="renderDataTab()" style="width:100%; padding:14px; border:1.5px solid var(--border); border-radius:14px; font-weight:700;"></div>
      <div id="dataGrid" style="display:flex; flex-direction:column; gap:16px; padding-bottom:40px;"></div>
    </div>

    <div id="tab-hw" class="tab-content active">
      <div class="op-divider"><span>— ADD NEW —</span></div>
      <div id="newHwContainer">
        <div class="new-hw-row">
          <div class="fld" style="flex:1;"><label>Subject</label><input type="text" class="newHwSubj" placeholder="e.g. Maths"></div>
          <div class="fld" style="flex:2;"><label>Task Details</label><input type="text" class="newHwTask" placeholder="e.g. Ex 2.1 Q1-5"></div>
          <button class="remove-hw-btn" style="display:none;" onclick="this.parentElement.remove()">✕</button>
        </div>
      </div>
      <button class="add-more-btn" onclick="addHwRow()">+ Add Another Task</button>
      
      <div id="hw-history-container" style="display:none;">
        <div class="op-divider"><span>— UPDATE EXISTING —</span></div>
        <div style="font-size:10px; font-weight:800; color:var(--grey); text-align:center; margin-bottom:12px; text-transform:uppercase;">👈 Swipe tasks left to Edit / Delete</div>
        <div id="hwHistoryList"></div>
      </div>
    </div>

    <div id="tab-syl" class="tab-content">
      <div class="op-divider"><span>— ADD NEW —</span></div>
      <div style="display:flex; gap:12px;">
        <div class="fld" style="flex:1;"><label>Subject</label><input type="text" id="newSylSubj" placeholder="e.g. Science"></div>
        <div class="fld" style="flex:1;">
          <label>Status</label>
          <select id="newSylStatus">
            <option value="Completed">Completed</option>
            <option value="Ongoing">Ongoing</option>
            <option value="Pending">Upcoming</option>
          </select>
        </div>
      </div>
      <div class="fld"><label>Chapter Name</label><input type="text" id="newSylChap" placeholder="e.g. Current Electricity"></div>
      <div id="syl-history-container" style="display:none;">
         <div class="op-divider"><span>— UPDATE EXISTING —</span></div>
         <div class="fld"><input type="text" id="sylSearch" placeholder="🔍 Search syllabus..." onkeyup="filterSyllabus()" style="margin-bottom:12px;"></div>
         <div id="sylHistoryList"></div>
      </div>
    </div>

    <div id="tab-admin" class="tab-content">
      <div class="op-divider"><span>— 1-TAP ADMISSION —</span></div>
      <div class="section-box" style="background:var(--white); border: 1.5px solid var(--border); border-radius: 16px; padding: 16px; margin-bottom: 24px;">
        <div style="margin-bottom:12px;">
          <label>TTC ID NUMBER</label>
          <div class="ttc-id-wrapper">
            <div class="ttc-id-prefix">TTC</div>
            <input type="text" inputmode="numeric" id="newStuIdNum" placeholder="46" oninput="checkIdAvailability()" autocomplete="off">
          </div>
          <div id="idStatusText" class="id-status"></div>
        </div>
        <div style="margin-bottom:16px;">
          <label>Student Name</label>
          <input type="text" id="newStuName" placeholder="e.g. Aarav Sharma">
        </div>
        <div style="display:flex; gap:12px; margin-bottom:16px;">
          <div style="flex:1;"><label>Class</label><input type="text" id="newStuClass" placeholder="e.g. 10"></div>
          <div style="flex:1;"><label>Board</label><input type="text" id="newStuBoard" placeholder="e.g. CBSE"></div>
        </div>
        <div class="fld"><label>Parent Name</label><input type="text" id="newStuParent" placeholder="e.g. Mr. Sharma"></div>
        <button class="add-more-btn" style="border-color:var(--green); color:var(--green); background:#ECFDF5; margin-bottom:0;" onclick="adminAddStudent()">➕ Enroll Student</button>
      </div>

      <div class="op-divider"><span>— MANAGE ROSTER —</span></div>
      <div class="section-box" style="background:var(--white); border: 1.5px solid var(--border); border-radius: 16px; padding: 16px; margin-bottom: 24px;">
        <div class="fld">
          <label>Select Student to Delete</label>
          <select id="deleteStuSelect" style="width:100%; padding:14px; border:1.5px solid var(--border); border-radius:12px; background:var(--white); font-weight:600;">
            <option value="">-- Choose Student --</option>
          </select>
        </div>
        <button id="delStuBtn" class="add-more-btn" style="border-color:var(--rust); color:var(--rust); background:#FEF2F2; margin-bottom:0;" onclick="adminDeleteStudent()">🧨 Erase Student</button>
      </div>

      <div class="op-divider"><span>— DATABASE OPTIMIZER —</span></div>
      <div class="section-box" style="background:var(--white); border: 1.5px solid var(--border); border-radius: 16px; padding: 16px;">
        <div class="fld">
          <label>Prune Homework Older Than</label>
          <select id="pruneDaysSelect" style="width:100%; padding:14px; border:1.5px solid var(--border); border-radius:12px; background:var(--white); font-weight:600;">
            <option value="30">30 Days</option>
            <option value="60">60 Days</option>
            <option value="90">90 Days</option>
          </select>
        </div>
        <button class="add-more-btn" style="border-color:var(--blue); color:var(--blue); background:#EFF6FF; margin-bottom:0;" onclick="adminPruneDb()">⚡ Clean Old Data</button>
      </div>
    </div>

    <div id="tab-json" class="tab-content">
      <div class="op-divider"><span>— BULK OVERRIDE —</span></div>
      <div class="fld">
        <label>Raw JSON Data</label>
        <textarea id="jsonInput" placeholder='[{"studentName": "Aarav", "type": "Test"...}]'></textarea>
      </div>
    </div>

  </div>
</div>

<div class="action-bar" id="actionBar">
  <div class="ab-left">
    <div class="selection-counter" id="selCounterText">0 Selected</div>
    <div id="saveGroupBtn" class="save-grp-btn" onclick="openGroupModal()">🔖 Save as Group</div>
  </div>
  <button class="submit-btn" id="mainSubmitBtn" onclick="executeCast()">🚀 CAST</button>
</div>

<!-- Modals -->
<div class="modal" id="dataModal" style="align-items:flex-end; padding:0;">
  <div class="modal-box" style="max-width:100%; border-radius:24px 24px 0 0; padding:24px; height:85vh; overflow-y:auto; display:flex; flex-direction:column; animation:fadeUp 0.3s cubic-bezier(0.34, 1.3, 0.64, 1);">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
      <div class="modal-title" id="dmName" style="margin-bottom:0; font-size:24px; line-height:1.2;"></div>
      <button onclick="document.getElementById('dataModal').style.display='none'" style="background:var(--light); border:none; width:36px; height:36px; border-radius:50%; font-weight:bold; color:var(--dark); cursor:pointer; flex-shrink:0; display:flex; align-items:center; justify-content:center;">✕</button>
    </div>
    <div id="dmContent" style="flex:1;"></div>
  </div>
</div>

<div class="modal" id="sniperDeleteModal">
  <div class="modal-box">
    <div class="modal-title">🗑️ Delete Homework</div>
    <div style="font-size:13px; color:var(--grey); margin-bottom:16px;">Are you sure you want to remove this homework for the selected student(s)?</div>
    <div class="fld"><label>Subject</label><input type="text" id="sdSubj" disabled style="background:var(--off);"></div>
    <div class="fld"><label>Task</label><input type="text" id="sdOldTask" disabled style="background:var(--off);"></div>
    <div style="display:flex; gap:12px; margin-top:20px;">
      <button class="modal-btn secondary" onclick="document.getElementById('sniperDeleteModal').style.display='none'">Cancel</button>
      <button class="modal-btn danger" onclick="executeSniperDelete()">Delete</button>
    </div>
  </div>
</div>

<div class="modal" id="settingsModal">
  <div class="modal-box">
    <div class="modal-title">🛠️ Settings</div>
    <div class="op-divider" style="margin-top:16px; margin-bottom:12px;"><span>— AI ASSISTANT PROMPT —</span></div>
    <div style="font-size:13px; color:var(--grey); margin-bottom:16px; line-height:1.4;">Copy this prompt and send it to any AI along with your raw updates. It will give you the perfect JSON to paste in the JSON tab.</div>
    <button class="submit-btn" style="width:100%; display:flex; align-items:center; justify-content:center; gap:8px;" onclick="copyAiPrompt(this)">
      📋 Copy AI Prompt
    </button>
    <div style="display:flex; gap:12px; margin-top:20px;">
      <button class="modal-btn secondary" onclick="document.getElementById('settingsModal').style.display='none'">Close</button>
    </div>
  </div>
</div>

<div class="status-overlay" id="statusOverlay">
  <div class="status-card" id="statusCard">
    <div class="sc-icon" id="scIcon">⏳</div>
    <div class="sc-title" id="scTitle">Syncing...</div>
    <div class="sc-sub" id="scSub">Encrypting payload</div>
  </div>
</div>

<div class="status-overlay" id="groupModal" style="align-items:center;">
  <div class="status-card" style="text-align:left;">
    <div class="sc-title" style="font-size:18px;">Save Custom Cohort</div>
    <div style="font-size:13px; color:var(--grey); margin-bottom:16px;">Create quick-select groups like "St. Mary's Batch".</div>
    <input type="text" id="newGrpName" placeholder="e.g. Morning Batch" style="margin-bottom:20px; padding:12px; font-size:14px;">
    <div style="display:flex; gap:10px;">
      <button class="submit-btn" style="flex:1; background:var(--light); color:var(--dark); box-shadow:none; padding:12px; font-size:14px;" onclick="document.getElementById('groupModal').style.display='none'">Cancel</button>
      <button class="submit-btn" style="flex:1; padding:12px; font-size:14px; box-shadow:none;" onclick="saveCustomGroup()">Save</button>
    </div>
  </div>
</div>

<!-- 🎯 SNIPER MODE MODALS -->
<div class="status-overlay" id="sniperEditModal" style="align-items:center;">
  <div class="status-card" style="text-align:left;">
    <div class="sc-title" style="font-size:18px; color:var(--blue); display:flex; align-items:center; gap:8px;">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
      Edit Assignment
    </div>
    <div style="font-size:12px; font-weight:800; color:var(--grey); text-transform:uppercase; margin-bottom:4px; margin-top:8px;" id="seSubj">Maths</div>
    <input type="text" id="seNewTask" style="margin-bottom:20px; padding:14px; font-size:15px; width:100%;">
    <input type="hidden" id="seOldTask">
    <div style="display:flex; gap:10px;">
      <button class="submit-btn" style="flex:1; background:var(--light); color:var(--dark); box-shadow:none; padding:12px; font-size:14px;" onclick="document.getElementById('sniperEditModal').style.display='none'">Cancel</button>
      <button class="submit-btn" style="flex:1; padding:12px; font-size:14px; box-shadow:none; background:var(--blue);" onclick="executeSniperEdit()">Save Update</button>
    </div>
  </div>
</div>

<script>
  const WEB_APP_URL = 'https://script.google.com/macros/s/AKfycbxQiwdMGjaY2ZcGE0iaAbwC72CPjgRp2WhHKyj1mjF5vHd_2wzKjofdEMoeHisz2i-Xsg/exec';

  let ALL_STUDENTS = {};
  let selectedIds = new Set();
  let currentTab = 'hw';
  let customGroups = JSON.parse(localStorage.getItem('ttc_custom_groups')) || {};
  let currentFilterType = 'ALL'; 
  let currentFilterVal = 'ALL';
  let originalHWState = {}; 
  let originalSylState = {};

  async function init() {
    try {
      const res = await fetch(WEB_APP_URL);
      const json = await res.json();
      if (json.status !== 'ok') throw new Error(json.msg);
      ALL_STUDENTS = json.data;
      document.getElementById('db-loader').style.display = 'none';
      document.getElementById('main-ui').style.display = 'block';
      buildFilters(); renderRoster(); populateAdminDropdown();
    } catch (e) {
      document.getElementById('db-loader').innerHTML = "❌ Failed to connect to database.";
    }
  }

  function populateAdminDropdown() {
    const sel = document.getElementById('deleteStuSelect');
    let html = '<option value="">-- Choose Student --</option>';
    let ids = Object.keys(ALL_STUDENTS).sort((a,b) => ALL_STUDENTS[a].name.localeCompare(ALL_STUDENTS[b].name));
    ids.forEach(id => html += `<option value="${id}">${ALL_STUDENTS[id].name} (${id})</option>`);
    sel.innerHTML = html;
  }

  function buildFilters() {
    let classes = new Set();
    Object.values(ALL_STUDENTS).forEach(s => { if(s.class) classes.add(s.class); });
    let html = `<div class="filter-chip ${currentFilterType === 'ALL' ? 'active' : ''}" onclick="applyFilter('ALL', 'ALL', this)">All Students</div>`;
    Array.from(classes).sort().forEach(c => {
      let isAct = (currentFilterType === 'CLASS' && currentFilterVal === c) ? 'active' : '';
      html += `<div class="filter-chip ${isAct}" onclick="applyFilter('CLASS', '${c}', this)">${c}</div>`;
    });
    Object.keys(customGroups).sort().forEach(g => {
      let isAct = (currentFilterType === 'GROUP' && currentFilterVal === g) ? 'active' : '';
      html += `<div class="filter-chip group-chip ${isAct}" onclick="applyFilter('GROUP', '${g}', this)">🔖 ${g} <span class="del-grp" onclick="deleteGroup('${g}', event)">✕</span></div>`;
    });
    document.getElementById('filterContainer').innerHTML = html;
  }

  function applyFilter(type, val, btnElement) {
    currentFilterType = type; currentFilterVal = val;
    document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
    if(btnElement) btnElement.classList.add('active');
    renderRoster();
  }

  function renderRoster() {
    let html = '';
    let searchQuery = (document.getElementById('rosterSearch')?.value || '').toLowerCase();
    let filteredIds = Object.keys(ALL_STUDENTS).filter(id => {
      if (searchQuery && !ALL_STUDENTS[id].name.toLowerCase().includes(searchQuery)) return false;
      if (currentFilterType === 'ALL') return true;
      if (currentFilterType === 'CLASS') return ALL_STUDENTS[id].class === currentFilterVal;
      if (currentFilterType === 'GROUP') return customGroups[currentFilterVal] && customGroups[currentFilterVal].includes(id);
    });
    filteredIds.sort((a, b) => ALL_STUDENTS[a].name.localeCompare(ALL_STUDENTS[b].name));
    filteredIds.forEach(id => {
      let isSel = selectedIds.has(id); let s = ALL_STUDENTS[id];
      let nameParts = s.name.split(' '); let firstName = nameParts[0];
      let lastName = nameParts.slice(1).join(' ');
      let surnameHtml = lastName ? `<br><span class="stu-surname">${lastName}</span>` : '';
      html += `<label class="stu-check ${isSel ? 'selected' : ''}"><input type="checkbox" value="${id}" ${isSel ? 'checked' : ''} onchange="toggleStudent('${id}', this)"><span class="stu-name">${firstName}${surnameHtml}</span><span class="stu-cls">${s.class}</span></label>`;
    });
    document.getElementById('studentGrid').innerHTML = html;
    updateUIState();
  }

  function toggleStudent(id, checkbox) {
    if(checkbox.checked) selectedIds.add(id); else selectedIds.delete(id);
    checkbox.parentElement.classList.toggle('selected', checkbox.checked);
    updateUIState();
  }

  function removeStudent(id) {
    let cb = document.querySelector(`input[value="${id}"]`);
    if(cb) { cb.checked = false; toggleStudent(id, cb); } 
    else { selectedIds.delete(id); updateUIState(); }
  }

  let allSelected = false;
  function toggleAll() {
    let visibleCheckboxes = document.querySelectorAll('#studentGrid input[type="checkbox"]');
    allSelected = !allSelected;
    visibleCheckboxes.forEach(cb => {
      cb.checked = allSelected;
      if(allSelected) selectedIds.add(cb.value); else selectedIds.delete(cb.value);
      cb.parentElement.classList.toggle('selected', allSelected);
    });
    document.getElementById('selectAllBtn').innerText = allSelected ? "Deselect All" : "Select All";
    updateUIState();
  }

  function openGroupModal() {
    document.getElementById('newGrpName').value = ''; document.getElementById('groupModal').style.display = 'flex';
  }

  function saveCustomGroup() {
    let name = document.getElementById('newGrpName').value.trim(); if(!name) return;
    customGroups[name] = Array.from(selectedIds);
    localStorage.setItem('ttc_custom_groups', JSON.stringify(customGroups));
    document.getElementById('groupModal').style.display = 'none'; buildFilters(); 
    let chips = document.querySelectorAll('.filter-chip');
    applyFilter('GROUP', name, chips[chips.length - 1]);
  }

  function deleteGroup(name, event) {
    event.stopPropagation(); 
    if(confirm(`Delete custom cohort "${name}"?`)) {
      delete customGroups[name]; localStorage.setItem('ttc_custom_groups', JSON.stringify(customGroups));
      if(currentFilterType === 'GROUP' && currentFilterVal === name) { currentFilterType = 'ALL'; currentFilterVal = 'ALL'; }
      buildFilters(); renderRoster();
    }
  }

  function switchTab(tabId) {
    currentTab = tabId;
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    let btn = document.querySelector(`button[onclick="switchTab('${tabId}')"]`);
    if(btn) btn.classList.add('active');
    
    let content = document.getElementById('tab-' + tabId);
    if(content) content.classList.add('active');
    
    updateUIState();
    if (tabId === 'data') setTimeout(renderDataTab, 50);
  }

  function renderDataTab() {
    let query = document.getElementById('dataSearch').value.toLowerCase();
    let html = '';
    let ids = Object.keys(ALL_STUDENTS).filter(id => ALL_STUDENTS[id].name.toLowerCase().includes(query)).sort((a,b) => ALL_STUDENTS[a].name.localeCompare(ALL_STUDENTS[b].name));
    
    ids.forEach(id => {
      let s = ALL_STUDENTS[id];
      let avg = 0;
      
      let recentScores = (s.perfScores || []).slice(-6);
      let recentLabels = (s.perfLabels || []).slice(-6);

      if (recentScores.length > 0) {
         avg = Math.round(recentScores.reduce((a,b)=>a+b,0)/recentScores.length);
      }
      
      let pendingCount = 0;
      for (let hw of s.previousHomework || []) { if(!hw.done) pendingCount++; }
      for (let hw of s.todayHomework || []) { pendingCount++; }

      html += `
      <div class="dl-card" onclick="openDataModal('${id}')">
        <div class="dl-hdr">
          <div class="dl-name">${s.name}<div style="font-size:12px; color:var(--grey); font-weight:600; margin-top:4px;">${s.board || 'Unknown'} • ${s.parentName || 'Unknown'}</div></div>
          <div class="dl-cls">Class ${s.class || ''}</div>
        </div>
        <div class="dl-stats">
          <div class="dl-stat"><div class="dl-stat-val" style="color:var(--green);">${avg}%</div><div class="dl-stat-lbl">Avg Score</div></div>
          <div class="dl-stat"><div class="dl-stat-val" style="color:var(--rust);">${pendingCount}</div><div class="dl-stat-lbl">Pending HW</div></div>
        </div>
        <div class="dl-chart-wrap"><canvas id="chart-${id}"></canvas></div>
      </div>`;
    });
    document.getElementById('dataGrid').innerHTML = html;

    ids.forEach(id => {
      let s = ALL_STUDENTS[id];
      let recentScores = (s.perfScores || []).slice(-6);
      let recentLabels = (s.perfLabels || []).slice(-6);

      if (recentScores.length > 0) {
         let ctx = document.getElementById('chart-' + id).getContext('2d');
         
         // Create a sleek gradient for the area under the line
         let gradient = ctx.createLinearGradient(0, 0, 0, 60);
         gradient.addColorStop(0, 'rgba(67, 97, 238, 0.2)');
         gradient.addColorStop(1, 'rgba(67, 97, 238, 0)');

         new Chart(ctx, {
            type: 'line',
            data: { 
               labels: recentLabels, 
               datasets: [{ 
                  data: recentScores, 
                  borderColor: '#4361EE', 
                  backgroundColor: gradient,
                  borderWidth: 3, 
                  tension: 0.4, 
                  fill: true,
                  pointRadius: 5,
                  pointBackgroundColor: '#4361EE',
                  pointBorderColor: '#FFFFFF',
                  pointBorderWidth: 2,
                  pointHoverRadius: 7
               }] 
            },
            options: { 
               responsive: true, 
               maintainAspectRatio: false, 
               plugins: { legend: { display: false }, tooltip: { enabled: true, backgroundColor: '#0F172A', titleFont: {family: 'DM Sans'}, bodyFont: {family: 'DM Sans'}, padding: 8, cornerRadius: 8, displayColors: false } }, 
               scales: { x: { display: false }, y: { display: false, min: 0, max: 100 } }, 
               layout: { padding: { top: 10, bottom: 10, left: 10, right: 10 } } 
            }
         });
      }
    });
  }

  function openDataModal(id) {
    let s = ALL_STUDENTS[id];
    document.getElementById('dmName').innerText = s.name;
    let html = '';
    
    if (s.tests && s.tests.length) {
       html += `<div class="syl-accordion-header" onclick="toggleSylAccordion(this)" style="background:var(--white); padding:14px 16px; border-radius:12px; font-weight:800; color:var(--dark); display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; border:1px solid var(--border); box-shadow:0 2px 4px rgba(0,0,0,0.02); cursor:pointer;">
              <span style="font-size:15px;">Recent Tests</span>
              <span class="chevron" style="transition:0.2s; transform:rotate(180deg);">▼</span>
            </div>
            <div class="syl-accordion-content" style="display:block; padding-left:12px; border-left:2px solid var(--border); margin-bottom:16px;">`;
       s.tests.forEach(t => {
          html += `<div class="list-item" style="border:2px solid var(--border); box-shadow:none;">
             <div style="display:flex; justify-content:space-between;">
               <div><div class="item-subj">${t.subject} • ${t.date}</div><div class="item-task">${t.chapter}</div></div>
               <div style="text-align:right;"><div style="font-size:18px; font-weight:900; color:var(--blue);">${t.score}/${t.total}</div><div style="font-size:10px; font-weight:800; color:var(--grey);">${t.grade} Grade</div></div>
             </div>
          </div>`;
       });
       html += `</div>`;
    }

    let pending = (s.previousHomework || []).filter(h => !h.done);
    if (s.todayHomework) pending = [...s.todayHomework, ...pending];
    
    if (pending.length) {
       html += `<div class="op-divider" style="margin-top:8px;"><span>— PENDING HOMEWORK —</span></div>`;
       pending.forEach(h => {
          html += `<div class="list-item" style="border:2px solid #FFD2B3; background:#FFF4E5; box-shadow:none;">
             <div><div class="item-subj" style="color:var(--rust);">${h.subject}</div><div class="item-task">${h.task}</div></div>
          </div>`;
       });
    }

    if (s.tests && s.tests.length) {
       let subjTotals = {};
       s.tests.forEach(t => {
           let sc = parseFloat(t.score);
           let tot = parseFloat(t.total);
           if (!isNaN(sc) && !isNaN(tot) && tot > 0) {
               if (!subjTotals[t.subject]) subjTotals[t.subject] = { score: 0, total: 0 };
               subjTotals[t.subject].score += sc;
               subjTotals[t.subject].total += tot;
           }
       });

       if (Object.keys(subjTotals).length > 0) {
           html += `<div class="syl-accordion-header" onclick="toggleSylAccordion(this)" style="background:var(--white); padding:14px 16px; border-radius:12px; font-weight:800; color:var(--dark); display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; margin-top:20px; border:1px solid var(--border); box-shadow:0 2px 4px rgba(0,0,0,0.02); cursor:pointer;">
                  <span style="font-size:15px;">Subject Performance</span>
                  <span class="chevron" style="transition:0.2s; transform:rotate(180deg);">▼</span>
                </div>
                <div class="syl-accordion-content" style="display:block; padding-left:12px; border-left:2px solid var(--border); margin-bottom:16px;">`;
           
           for (let sub in subjTotals) {
               let pct = Math.round((subjTotals[sub].score / subjTotals[sub].total) * 100);
               let barColor = pct >= 80 ? 'var(--green)' : pct >= 40 ? 'var(--orange)' : 'var(--rust)';
               html += `
               <div style="margin-bottom:12px;">
                 <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:800; margin-bottom:6px;">
                   <span>${sub}</span> <span style="color:${barColor};">${pct}% Avg</span>
                 </div>
                 <div style="height:8px; background:var(--light); border-radius:4px; overflow:hidden;">
                   <div style="height:100%; background:${barColor}; width:${pct}%;"></div>
                 </div>
               </div>`;
           }
           html += `</div>`;
       }
    }

    document.getElementById('dmContent').innerHTML = html;
    document.getElementById('dataModal').style.display = 'flex';
  }

  function filterSyllabus() {
    let query = document.getElementById('sylSearch').value.toLowerCase();
    let items = document.querySelectorAll('#sylHistoryList .list-item, #sylHistoryList .swipe-wrapper');
    items.forEach(item => {
      let text = item.innerText.toLowerCase();
      item.style.display = text.includes(query) ? 'flex' : 'none';
    });
  }

  function toggleAccordion(el) {
    let acc = el.parentElement.querySelector('.indiv-accordion');
    if (acc) {
       acc.style.display = acc.style.display === 'none' ? 'block' : 'none';
    }
  }

  function toggleSylAccordion(el) {
    let content = el.nextElementSibling;
    let chevron = el.querySelector('.chevron');
    if (content.style.display === 'none' || !content.style.display) {
       content.style.display = 'block';
       if(chevron) chevron.style.transform = 'rotate(180deg)';
    } else {
       content.style.display = 'none';
       if(chevron) chevron.style.transform = 'rotate(0deg)';
    }
  }

  function copyAiPrompt(btn) {
    const promptText = `Act as a data structurer for my tuition class dashboard. I will give you natural language updates about my students. You must convert these updates into a strict JSON array.

Rules:
The "type" MUST be exactly one of: "Test", "HW_Assigned", "HW_Status", "Syllabus", or "Message".
Output ONLY the raw JSON array. Do not include markdown formatting (like \`\`\`json), and do not say anything else before or after the JSON.

Format for each object:
[{"studentName": "Full Name", "type": "Type", "subject": "Subject", "topic": "Chapter or Task", "score": "Number or blank", "total": "Number or blank", "status": "Done/Pending/blank", "text": "Remarks"}]

My Update:
`;
    navigator.clipboard.writeText(promptText).then(() => {
      const origText = btn.innerHTML;
      btn.innerHTML = '✅ Copied!';
      setTimeout(() => btn.innerHTML = origText, 2000);
    }).catch(err => alert("Failed to copy text."));
  }

  function addHwRow() {
    const container = document.getElementById('newHwContainer');
    const row = document.createElement('div'); row.className = 'new-hw-row';
    row.innerHTML = `<div class="fld" style="flex:1;"><label>Subject</label><input type="text" class="newHwSubj" placeholder="e.g. Maths"></div><div class="fld" style="flex:2;"><label>Task Details</label><input type="text" class="newHwTask" placeholder="e.g. Ex 2.1 Q1-5"></div><button class="remove-hw-btn" onclick="this.parentElement.remove()">✕</button>`;
    container.appendChild(row);
  }

  function updateUIState() {
    let count = selectedIds.size;
    let pillHtml = ''; let selNames = [];
    selectedIds.forEach(id => {
       let n = ALL_STUDENTS[id].name.split(' ')[0]; selNames.push(n);
       pillHtml += `<div class="cs-pill">${n} <span class="del" onclick="removeStudent('${id}')">✕</span></div>`;
    });
    document.getElementById('csPills').innerHTML = pillHtml;
    document.getElementById('castingStrip').style.display = count > 0 ? 'block' : 'none';

    if(count === 0) document.getElementById('selCounterText').innerText = "0 Selected";
    else if (count <= 2) document.getElementById('selCounterText').innerText = selNames.join(', ');
    else document.getElementById('selCounterText').innerText = `${selNames[0]}, ${selNames[1]} +${count - 2}`;
    
    const actionBar = document.getElementById('actionBar');
    if (count > 0 || currentTab === 'json') actionBar.classList.add('visible');
    else actionBar.classList.remove('visible');
    
    document.getElementById('saveGroupBtn').style.display = (count > 1) ? 'inline-flex' : 'none';

    if(count > 0) {
      document.getElementById('hw-history-container').style.display = 'block';
      document.getElementById('syl-history-container').style.display = 'block';
      buildSharedLists();
    } else {
      document.getElementById('hw-history-container').style.display = 'none';
      document.getElementById('syl-history-container').style.display = 'none';
    }

    if(currentTab === 'json') document.getElementById('mainSubmitBtn').innerText = "Execute JSON";
    else document.getElementById('mainSubmitBtn').innerText = "🚀 CAST";
  }

  // --- THE SNIPER SWIPE ENGINE ---
  let swipeStartX=0, swipeStartY=0, swipeCurrentX=0;
  let swipingElement=null, isHorizontalSwipe=null, activeSwipe=null;

  function initSwipeListeners() {
    const list = document.getElementById('hwHistoryList');
    list.addEventListener('touchstart', e => {
      const el = e.target.closest('.swipe-content'); if (!el) return;
      if (activeSwipe && activeSwipe !== el) { activeSwipe.style.transform = 'translateX(0)'; activeSwipe = null; }
      swipeStartX = e.touches[0].clientX; swipeStartY = e.touches[0].clientY;
      swipeCurrentX = swipeStartX; swipingElement = el; isHorizontalSwipe = null;
      el.style.transition = 'none';
    }, {passive: true});

    list.addEventListener('touchmove', e => {
      if (!swipingElement) return;
      swipeCurrentX = e.touches[0].clientX; let currentY = e.touches[0].clientY;
      let diffX = swipeStartX - swipeCurrentX; let diffY = swipeStartY - currentY;
      
      if (isHorizontalSwipe === null) {
          if (Math.abs(diffX) > Math.abs(diffY)) isHorizontalSwipe = true;
          else { isHorizontalSwipe = false; swipingElement = null; return; }
      }
      if (isHorizontalSwipe) {
          if(e.cancelable) e.preventDefault(); 
          if (diffX > 0 && diffX <= 140) swipingElement.style.transform = `translateX(-${diffX}px)`;
          else if (diffX <= 0) swipingElement.style.transform = `translateX(0px)`;
      }
    }, {passive: false});

    list.addEventListener('touchend', e => {
      if (!swipingElement) return;
      swipingElement.style.transition = 'transform 0.25s cubic-bezier(0.34, 1.3, 0.64, 1)';
      let diffX = swipeStartX - swipeCurrentX;
      if (diffX > 50) { swipingElement.style.transform = `translateX(-120px)`; activeSwipe = swipingElement; } 
      else { swipingElement.style.transform = `translateX(0)`; if (activeSwipe === swipingElement) activeSwipe = null; }
      swipingElement = null; isHorizontalSwipe = null;
    });
  }

  function openSniperEdit(subj, task) {
    document.getElementById('seSubj').innerText = subj;
    document.getElementById('seNewTask').value = task;
    document.getElementById('seOldTask').value = task;
    document.getElementById('sniperEditModal').style.display = 'flex';
  }
  function openSniperDelete(subj, task) {
    document.getElementById('sdSubj').value = subj;
    document.getElementById('sdOldTask').value = task;
    document.getElementById('sniperDeleteModal').style.display = 'flex';
  }
  
  function executeSniperEdit() {
    let sNames = Array.from(selectedIds).map(id => ALL_STUDENTS[id].name);
    let subj = document.getElementById('seSubj').innerText;
    let oldTopic = document.getElementById('seOldTask').value;
    let newTopic = document.getElementById('seNewTask').value.trim();
    if(!newTopic || newTopic === oldTopic) { document.getElementById('sniperEditModal').style.display='none'; return; }
    
    if (activeSwipe) {
        activeSwipe.querySelector('.item-task').innerText = newTopic;
        let hwSeg = activeSwipe.querySelector('.exc-hw-seg');
        if(hwSeg) {
           hwSeg.setAttribute('data-task', newTopic);
           let oldKey = hwSeg.getAttribute('data-key');
           let newKey = oldKey.replace(oldTopic, newTopic);
           hwSeg.setAttribute('data-key', newKey);
           originalHWState[newKey] = originalHWState[oldKey];
        }
        activeSwipe.style.transform = 'translateX(0)';
        activeSwipe = null;
    }
    
    let payload = sNames.map(name => ({ type: 'EDIT_HW', studentName: name, subject: subj, oldTopic: oldTopic, newTopic: newTopic }));
    document.getElementById('sniperEditModal').style.display='none';
    fireWebhook(payload);
  }
  
  function executeSniperDelete() {
    let sNames = Array.from(selectedIds).map(id => ALL_STUDENTS[id].name);
    let subj = document.getElementById('sdSubj').value;
    let oldTopic = document.getElementById('sdOldTask').value;
    
    if (activeSwipe) {
        let swipeWrapper = activeSwipe.closest('.swipe-wrapper');
        if (swipeWrapper) swipeWrapper.remove();
        activeSwipe = null;
    }

    let payload = sNames.map(name => ({ type: 'DELETE_HW', studentName: name, subject: subj, oldTopic: oldTopic }));
    document.getElementById('sniperDeleteModal').style.display='none';
    fireWebhook(payload);
  }


  function buildSharedLists() {
    let isSingle = selectedIds.size === 1;
    originalHWState = {}; originalSylState = {};
    let hwMap = new Map(); let sylMap = new Map();

    selectedIds.forEach(id => {
        let s = ALL_STUDENTS[id];
        (s.previousHomework || []).forEach(hw => {
            let task = hw.originalTopic || hw.task; let key = hw.subject + "|||" + task;
            if(!hwMap.has(key)) hwMap.set(key, {key: key, subj: hw.subject, task: task, states: [], date: hw.date});
            hwMap.get(key).states.push(hw.done);
        });
        for (let subj in (s.syllabus || {})) {
            let cleanSubj = subj.replace(/[^\x00-\x7F]/g, '').trim(); let data = s.syllabus[subj];
            ['completed', 'ongoing', 'pending'].forEach(stat => {
                (data[stat] || []).forEach(chap => {
                    let key = cleanSubj + '|||' + chap;
                    if(!sylMap.has(key)) sylMap.set(key, {subj: cleanSubj, chap: chap, states: []});
                    sylMap.get(key).states.push(stat === 'completed' ? 'Completed' : stat === 'ongoing' ? 'Ongoing' : 'Pending');
                });
            });
        }
    });

    let sylHtml = ''; let groupedSyl = {};
    sylMap.forEach((val, key) => { if(!groupedSyl[val.subj]) groupedSyl[val.subj] = []; groupedSyl[val.subj].push(val); });

    if (Object.keys(groupedSyl).length === 0) sylHtml = '<div style="color:var(--grey); font-size:13px; font-weight:600; text-align:center; padding:10px;">No history found.</div>';
    else {
        let segIdx = 0;
        for (let subj in groupedSyl) {
            sylHtml += `
            <div class="syl-accordion-header" onclick="toggleSylAccordion(this)" style="background:var(--white); padding:14px 16px; border-radius:12px; font-weight:800; color:var(--dark); display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; border:1px solid var(--border); box-shadow:0 2px 4px rgba(0,0,0,0.02); cursor:pointer;">
              <span style="font-size:15px;">${subj}</span>
              <span class="chevron" style="transition:0.2s;">▼</span>
            </div>
            <div class="syl-accordion-content" style="display:none; padding-left:12px; border-left:2px solid var(--border); margin-bottom:16px;">
            `;
            groupedSyl[subj].forEach(item => {
                let key = subj + '|||' + item.chap; let defaultStat = isSingle ? item.states[0] : 'MIXED';
                originalSylState[key] = defaultStat;
                
                let summaryHtml = '';
                if (!isSingle) {
                    let doneNames = []; let pendingNames = []; let ongoingNames = [];
                    let sIdArray = Array.from(selectedIds);
                    for(let i=0; i<sIdArray.length; i++) {
                       let name = ALL_STUDENTS[sIdArray[i]].name.split(' ')[0];
                       if (item.states[i] === 'Completed') doneNames.push(name); 
                       else if (item.states[i] === 'Ongoing') ongoingNames.push(name);
                       else pendingNames.push(name);
                    }
                    summaryHtml = `<div style="font-size:11px; margin-top:6px;">
                      ${doneNames.length ? `<span style="color:var(--green); font-weight:bold;">Done:</span> <span style="color:var(--grey);">${doneNames.join(', ')}</span> ` : ''}
                      ${ongoingNames.length ? `<span style="color:var(--blue); font-weight:bold;">Ongoing:</span> <span style="color:var(--grey);">${ongoingNames.join(', ')}</span> ` : ''}
                      ${pendingNames.length ? `<span style="color:var(--rust); font-weight:bold;">Pending:</span> <span style="color:var(--grey);">${pendingNames.join(', ')}</span>` : ''}
                    </div>`;
                }

                let options = isSingle ? `
                    <label><input type="radio" name="syl_${segIdx}" value="Completed" ${defaultStat==='Completed'?'checked':''}><span>Completed</span></label>
                    <label><input type="radio" name="syl_${segIdx}" value="Ongoing" ${defaultStat==='Ongoing'?'checked':''}><span>Ongoing</span></label>
                    <label><input type="radio" name="syl_${segIdx}" value="Pending" ${defaultStat==='Pending'?'checked':''}><span>Upcoming</span></label>
                ` : `
                    <label><input type="radio" name="syl_${segIdx}" value="MIXED" checked><span>Skip</span></label>
                    <label><input type="radio" name="syl_${segIdx}" value="Completed"><span>Completed</span></label>
                    <label><input type="radio" name="syl_${segIdx}" value="Ongoing"><span>Ongoing</span></label>
                    <label><input type="radio" name="syl_${segIdx}" value="Pending"><span>Upcoming</span></label>
                `;
                
                if (isSingle) {
                  sylHtml += `<div class="list-item"><div><div class="item-subj">${subj}</div><div class="item-task">${item.chap}</div></div><div class="seg-ctrl syl exc-syl-seg" data-key="${key}" data-subj="${subj}" data-chap="${item.chap}">${options}</div></div>`;
                } else {
                  let sIdArray = Array.from(selectedIds);
                  let indivHtml = `
                  <div class="indiv-accordion" style="display:none; margin-top:12px; padding-top:12px; border-top:1px dashed var(--border);">
                     <div style="font-size:11px; font-weight:800; letter-spacing:1px; color:var(--purple); margin-bottom:10px;">INDIVIDUAL STATUS OVERRIDE:</div>
                     ${sIdArray.map((id, i) => {
                        let cState = item.states[i] || 'Pending';
                        return `
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                           <span style="font-size:13px; font-weight:700; color:var(--dark);">${ALL_STUDENTS[id].name.split(' ')[0]}</span>
                           <div class="seg-ctrl mini indiv-syl-ctrl" data-sid="${id}" data-orig="${cState}">
                             <label><input type="radio" name="indiv_syl_${segIdx}_${id}" value="Pending" ${cState==='Pending'?'checked':''}><span>Upc</span></label>
                             <label><input type="radio" name="indiv_syl_${segIdx}_${id}" value="Ongoing" ${cState==='Ongoing'?'checked':''}><span>Ong</span></label>
                             <label><input type="radio" name="indiv_syl_${segIdx}_${id}" value="Completed" ${cState==='Completed'?'checked':''}><span>Done</span></label>
                           </div>
                        </div>
                        `
                     }).join('')}
                  </div>`;
                  sylHtml += `<div class="list-item">
                     <div onclick="toggleAccordion(this)" style="cursor:pointer; transition:opacity 0.2s;" onmouseover="this.style.opacity=0.7" onmouseout="this.style.opacity=1">
                        <div class="item-subj">${subj}</div>
                        <div class="item-task">${item.chap}</div>
                        ${summaryHtml}
                     </div>
                     <div class="seg-ctrl syl exc-syl-seg" data-key="${key}" data-subj="${subj}" data-chap="${item.chap}" style="margin-top:8px;">${options}</div>
                     ${indivHtml}
                  </div>`;
                }
                
                segIdx++;
            });
            sylHtml += `</div>`;
        }
    }
    document.getElementById('sylHistoryList').innerHTML = sylHtml;

    let hwHtml = '';
    if (hwMap.size === 0) hwHtml = '<div style="color:var(--grey); font-size:13px; font-weight:600; text-align:center; padding:10px;">No history found.</div>';
    else {
        let segIdx = 0;
        let sortedHw = Array.from(hwMap.values()).sort((a, b) => {
            let aPending = a.states.some(d => !d);
            let bPending = b.states.some(d => !d);
            if (aPending && !bPending) return -1;
            if (!aPending && bPending) return 1;
            return 0;
        });

        sortedHw.forEach(val => {
            let key = val.key;
            let defaultStat = isSingle ? (val.states[0] ? "Done" : "Pending") : 'MIXED'; originalHWState[key] = defaultStat;
            
            let isPending = defaultStat === 'Pending' || (defaultStat === 'MIXED' && val.states.some(d => !d));
            let dateBadge = isPending && val.date ? `<span style="font-size:9px; font-weight:800; background:#FFF4E5; color:var(--rust); padding:3px 6px; border-radius:6px; margin-left:8px; white-space:nowrap; border:1px solid #FFD2B3;">📅 ${val.date}</span>` : '';

            let summaryHtml = '';
            if (!isSingle) {
                let doneNames = [];
                let pendingNames = [];
                let sIdArray = Array.from(selectedIds);
                for(let i=0; i<sIdArray.length; i++) {
                   let name = ALL_STUDENTS[sIdArray[i]].name.split(' ')[0];
                   if (val.states[i]) doneNames.push(name); else pendingNames.push(name);
                }
                summaryHtml = `<div style="font-size:11px; margin-top:6px;"><span style="color:var(--green); font-weight:bold;">Done:</span> <span style="color:var(--grey);">${doneNames.length ? doneNames.join(', ') : 'None'}</span> | <span style="color:var(--rust); font-weight:bold;">Pending:</span> <span style="color:var(--grey);">${pendingNames.length ? pendingNames.join(', ') : 'None'}</span></div>`;
            }

            let options = isSingle ? `
                <label><input type="radio" name="hw_${segIdx}" value="Pending" ${defaultStat==='Pending'?'checked':''}><span>Pending</span></label>
                <label><input type="radio" name="hw_${segIdx}" value="Done" ${defaultStat==='Done'?'checked':''}><span>Done</span></label>
            ` : `
                <label><input type="radio" name="hw_${segIdx}" value="MIXED" checked><span>Skip</span></label>
                <label><input type="radio" name="hw_${segIdx}" value="Pending"><span>Pending</span></label>
                <label><input type="radio" name="hw_${segIdx}" value="Done"><span>Done</span></label>
            `;
            
            if (isSingle) {
              hwHtml += `
              <div class="swipe-wrapper">
                  <div class="swipe-actions">
                      <button class="sa-edit" onclick="openSniperEdit('${val.subj.replace(/'/g, "\\'")}', '${val.task.replace(/'/g, "\\'")}')">
                          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
                      </button>
                      <button class="sa-del" onclick="openSniperDelete('${val.subj.replace(/'/g, "\\'")}', '${val.task.replace(/'/g, "\\'")}')">
                          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                      </button>
                  </div>
                  <div class="swipe-content">
                      <div><div class="item-subj" style="display:flex; align-items:center;">${val.subj} ${dateBadge}</div><div class="item-task">${val.task}</div></div>
                      <div class="seg-ctrl hw exc-hw-seg" data-key="${key}" data-subj="${val.subj}" data-task="${val.task}">${options}</div>
                  </div>
              </div>`;
            } else {
              let sIdArray = Array.from(selectedIds);
              let indivHtml = `
              <div class="indiv-accordion" style="display:none; margin-top:12px; padding-top:12px; border-top:1px dashed var(--border);">
                 <div style="font-size:11px; font-weight:800; letter-spacing:1px; color:var(--purple); margin-bottom:10px;">INDIVIDUAL STATUS OVERRIDE:</div>
                 ${sIdArray.map((id, i) => `
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                       <span style="font-size:13px; font-weight:700; color:var(--dark);">${ALL_STUDENTS[id].name.split(' ')[0]}</span>
                       <div class="seg-ctrl mini indiv-hw-ctrl" data-sid="${id}" data-orig="${val.states[i]?'Done':'Pending'}">
                         <label><input type="radio" name="indiv_hw_${segIdx}_${id}" value="Pending" ${!val.states[i]?'checked':''}><span>Pending</span></label>
                         <label><input type="radio" name="indiv_hw_${segIdx}_${id}" value="Done" ${val.states[i]?'checked':''}><span>Done</span></label>
                       </div>
                    </div>
                 `).join('')}
              </div>`;

              hwHtml += `<div class="list-item">
                 <div onclick="toggleAccordion(this)" style="cursor:pointer; transition:opacity 0.2s;" onmouseover="this.style.opacity=0.7" onmouseout="this.style.opacity=1">
                    <div class="item-subj" style="display:flex; align-items:center;">${val.subj} ${dateBadge}</div>
                    <div class="item-task">${val.task}</div>
                    ${summaryHtml}
                 </div>
                 <div class="seg-ctrl hw exc-hw-seg" data-key="${key}" data-subj="${val.subj}" data-task="${val.task}" style="margin-top:8px;">${options}</div>
                 ${indivHtml}
              </div>`;
            }
            segIdx++;
        });
    }
    document.getElementById('hwHistoryList').innerHTML = hwHtml;
  }

  // Real-time ID Checker
  function checkIdAvailability() {
    const num = document.getElementById('newStuIdNum').value.trim(); const statusEl = document.getElementById('idStatusText');
    if (!num) { statusEl.innerHTML = ''; return; }
    const fullId = "TTC" + num;
    if (ALL_STUDENTS[fullId]) { statusEl.innerHTML = `⚠️ ID taken by <b>${ALL_STUDENTS[fullId].name}</b>`; statusEl.className = 'id-status taken'; } 
    else { statusEl.innerHTML = `✅ ID <b>${fullId}</b> is available`; statusEl.className = 'id-status avail'; }
  }

  function adminAddStudent() {
    const num = document.getElementById('newStuIdNum').value.trim(); const name = document.getElementById('newStuName').value.trim();
    const cls = document.getElementById('newStuClass').value.trim(); const board = document.getElementById('newStuBoard').value.trim();
    const parent = document.getElementById('newStuParent').value.trim();
    if (!num || !name || !cls || !board || !parent) { showStatus("error", "Missing Info", "Please fill all boxes."); setTimeout(closeStatus, 2000); return; }
    const ttcId = "TTC" + num;
    if (ALL_STUDENTS[ttcId]) { showStatus("error", "ID Taken", "That TTC ID is already in use."); setTimeout(closeStatus, 2000); return; }
    
    let payload = [{ type: 'ADD_STUDENT', ttcId: ttcId, studentName: name, className: cls, boardName: board, parentName: parent }];
    fireWebhook(payload);
    document.getElementById('newStuIdNum').value = ''; document.getElementById('newStuName').value = '';
    document.getElementById('newStuClass').value = ''; document.getElementById('newStuBoard').value = '';
    document.getElementById('newStuParent').value = ''; document.getElementById('idStatusText').innerHTML = ''; 
  }

  let delClickCount = 0; let delTimeout;
  function adminDeleteStudent() {
    const sel = document.getElementById('deleteStuSelect'); const stuId = sel.value;
    if (!stuId) { showStatus("error", "Select Student", "Choose someone to delete."); setTimeout(closeStatus, 2000); return; }
    const btn = document.getElementById('delStuBtn');
    
    if (delClickCount === 0) {
      delClickCount = 1; btn.style.background = 'var(--rust)'; btn.style.color = 'var(--white)'; btn.innerText = '⚠️ Tap Again to Permanently Erase';
      delTimeout = setTimeout(() => { delClickCount = 0; btn.style.background = '#FEF2F2'; btn.style.color = 'var(--rust)'; btn.innerText = '🧨 Erase Student'; }, 3000);
    } else {
      clearTimeout(delTimeout); delClickCount = 0; btn.style.background = '#FEF2F2'; btn.style.color = 'var(--rust)'; btn.innerText = '🧨 Erase Student';
      let payload = [{ type: 'DELETE_STUDENT', ttcId: stuId, studentName: ALL_STUDENTS[stuId].name }];
      fireWebhook(payload); sel.value = '';
    }
  }

  function adminPruneDb() {
    const days = document.getElementById('pruneDaysSelect').value;
    fireWebhook([{ type: 'PRUNE_DB', days: parseInt(days) }]);
  }

  function executeCast() {
    let payload = []; let sNames = Array.from(selectedIds).map(id => ALL_STUDENTS[id].name);

    if (currentTab === 'json') {
      try { let text = document.getElementById('jsonInput').value.trim().replace(/```json/g, '').replace(/```/g, '').trim(); payload = JSON.parse(text); if(!Array.isArray(payload)) payload = [payload]; } catch(e) { showStatus("error", "Invalid JSON", "Check formatting"); return; }
    } else {
      if (currentTab === 'hw') {
        document.querySelectorAll('.new-hw-row').forEach(row => {
          const newSubj = row.querySelector('.newHwSubj').value.trim(); const newTask = row.querySelector('.newHwTask').value.trim();
          if (newSubj && newTask) sNames.forEach(name => payload.push({ studentName: name, type: "HW_Assigned", subject: newSubj, topic: newTask }));
        });
        document.querySelectorAll('.exc-hw-seg').forEach(seg => {
          let val = seg.querySelector('input:checked').value;
          let key = seg.getAttribute('data-key');
          let subj = seg.getAttribute('data-subj');
          let task = seg.getAttribute('data-task');
          if (val !== 'MIXED') {
             if (val !== originalHWState[key]) {
                Array.from(selectedIds).forEach(id => {
                  payload.push({ type: 'HW_Status', studentName: ALL_STUDENTS[id].name, subject: subj, topic: task, status: val });
                });
             }
          } else {
             let acc = seg.parentElement.querySelector('.indiv-accordion');
             if (acc) {
                acc.querySelectorAll('.indiv-hw-ctrl').forEach(ctrl => {
                   let indivVal = ctrl.querySelector('input:checked').value;
                   let origVal = ctrl.getAttribute('data-orig');
                   if (indivVal !== origVal) {
                      let sId = ctrl.getAttribute('data-sid');
                      payload.push({ type: 'HW_Status', studentName: ALL_STUDENTS[sId].name, subject: subj, topic: task, status: indivVal });
                   }
                });
             }
          }
        });
      }
      else if (currentTab === 'syl') {
        const newSubj = document.getElementById('newSylSubj').value.trim(); const newChap = document.getElementById('newSylChap').value.trim(); const newStat = document.getElementById('newSylStatus').value;
        if (newSubj && newChap) sNames.forEach(name => payload.push({ studentName: name, type: "Syllabus", subject: newSubj, topic: newChap, status: newStat }));
        
        document.querySelectorAll('.exc-syl-seg').forEach(seg => {
            let val = seg.querySelector('input:checked').value;
            let key = seg.getAttribute('data-key');
            let subj = seg.getAttribute('data-subj');
            let chap = seg.getAttribute('data-chap');
            if (val !== 'MIXED') {
               if (val !== originalSylState[key]) {
                  Array.from(selectedIds).forEach(id => {
                    payload.push({ type: 'Syllabus', studentName: ALL_STUDENTS[id].name, subject: subj, topic: chap, status: val });
                  });
               }
            } else {
               let acc = seg.parentElement.querySelector('.indiv-accordion');
               if (acc) {
                  acc.querySelectorAll('.indiv-syl-ctrl').forEach(ctrl => {
                     let indivVal = ctrl.querySelector('input:checked').value;
                     let origVal = ctrl.getAttribute('data-orig');
                     if (indivVal !== origVal) {
                        let sId = ctrl.getAttribute('data-sid');
                        payload.push({ type: 'Syllabus', studentName: ALL_STUDENTS[sId].name, subject: subj, topic: chap, status: indivVal });
                     }
                  });
               }
            }
        });
      }
    }

    if(payload.length === 0) { showStatus("error", "Empty Data", "Add or update a task to sync."); return; }
    fireWebhook(payload);
  }

  async function fireWebhook(payload) {
    showStatus("load", "Executing...", `Processing command...`);
    try {
      const res = await fetch(WEB_APP_URL, { method: 'POST', body: JSON.stringify(payload), headers: { 'Content-Type': 'text/plain;charset=utf-8' }});
      const result = await res.json();
      if (result.status === 'success' || result.status === 'ok') {
        showStatus("success", "Success!", "Database live updated.");
        setTimeout(() => { closeStatus(); clearInputs(); }, 1500);
        setTimeout(() => { init(); }, 3500); // Delayed refresh so UI remains optimistic
      } else throw new Error("Server rejected.");
    } catch (e) { showStatus("error", "Cast Failed", "Connection error."); setTimeout(closeStatus, 2000); }
  }

  function clearInputs() {
    document.getElementById('newHwContainer').innerHTML = `<div class="new-hw-row"><div class="fld" style="flex:1;"><label>Subject</label><input type="text" class="newHwSubj" placeholder="e.g. Maths"></div><div class="fld" style="flex:2;"><label>Task Details</label><input type="text" class="newHwTask" placeholder="e.g. Ex 2.1 Q1-5"></div><button class="remove-hw-btn" style="display:none;" onclick="this.parentElement.remove()">✕</button></div>`;
    document.getElementById('newSylChap').value = ''; document.getElementById('jsonInput').value = '';
  }

  const overlay = document.getElementById('statusOverlay');
  function showStatus(type, title, sub) {
    overlay.style.display = 'flex'; document.getElementById('scTitle').innerText = title; document.getElementById('scSub').innerText = sub;
    let icon = document.getElementById('scIcon');
    if(type === 'load') icon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--blue)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="spin-anim"><circle cx="12" cy="12" r="10"></circle><path d="M12 2a10 10 0 0 1 10 10"></path></svg>';
    if(type === 'success') icon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--green)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>';
    if(type === 'error') icon.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--rust)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>';
  }
  function closeStatus() { overlay.style.display = 'none'; }

  window.onload = () => { init(); initSwipeListeners(); };
</script>
</body>
</html>
