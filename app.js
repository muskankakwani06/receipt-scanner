/* ===================== STATE ===================== */
let state = {
  apiKey: localStorage.getItem('sb_apiKey') || '',
  budget: parseFloat(localStorage.getItem('sb_budget')) || 10000,
  currency: localStorage.getItem('sb_currency') || '₹',
  receipts: JSON.parse(localStorage.getItem('sb_receipts') || '[]'),
  currentScan: null,
  user: {
    name: localStorage.getItem('sb_userName') || 'Alex Johnson',
    email: localStorage.getItem('sb_userEmail') || 'alex.j@example.com'
  }
};

const CAT_COLORS = {
  'Food & Dining':   { bar: '#F97316', bg: 'rgba(249,115,22,0.15)',  text: '#FB923C', icon: '🍔' },
  'Transport':       { bar: '#3B7EF8', bg: 'rgba(59,126,248,0.15)',  text: '#60A5FA', icon: '🚗' },
  'Shopping':        { bar: '#A78BFA', bg: 'rgba(167,139,250,0.15)', text: '#C4B5FD', icon: '🛍️' },
  'Health':          { bar: '#22C55E', bg: 'rgba(34,197,94,0.15)',   text: '#4ADE80', icon: '💊' },
  'Entertainment':   { bar: '#FBBF24', bg: 'rgba(251,191,36,0.15)', text: '#FCD34D', icon: '🎬' },
  'Utilities':       { bar: '#38BDF8', bg: 'rgba(56,189,248,0.15)',  text: '#7DD3FC', icon: '💡' },
  'Other':           { bar: '#7A88A8', bg: 'rgba(122,136,168,0.12)', text: '#94A3B8', icon: '📦' },
};

/* ===================== INIT ===================== */
document.addEventListener('DOMContentLoaded', () => {
  updateClock();
  setInterval(updateClock, 1000);
  updateBudgetUI();
  renderRecentList();
  renderHistoryList();
  renderInsights();
  renderProfile();
  checkApiKey();

  // Set current month
  const now = new Date();
  document.getElementById('currentMonth').textContent =
    now.toLocaleString('default', { month: 'long', year: 'numeric' });

  // Register Service Worker
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('sw.js').catch(err => console.error('SW failed', err));
  }
});

function updateClock() {
  const now = new Date();
  let h = now.getHours(), m = now.getMinutes();
  document.getElementById('statusTime').textContent =
    `${h}:${m.toString().padStart(2,'0')}`;
}

/* ===================== TABS ===================== */
function switchTab(tab) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById(`screen-${tab}`).classList.add('active');
  document.getElementById(`tab-${tab}`).classList.add('active');

  if (tab === 'insights') renderInsights();
  if (tab === 'history') renderHistoryList();
  if (tab === 'profile') renderProfile();
}

/* ===================== API KEY ===================== */
function checkApiKey() {
  const hint = document.getElementById('apiHintCard');
  const analyzeSection = document.getElementById('analyzeSection');
  if (state.apiKey) {
    hint.style.display = 'none';
    analyzeSection.style.display = 'block';
  } else {
    hint.style.display = 'flex';
    analyzeSection.style.display = 'none';
  }
}

function openApiKeyModal() {
  document.getElementById('apiKeyInput').value = state.apiKey;
  document.getElementById('apiKeyModal').style.display = 'flex';
}
function closeApiKeyModal(e) {
  if (!e || e.target === document.getElementById('apiKeyModal'))
    document.getElementById('apiKeyModal').style.display = 'none';
}
function saveApiKey() {
  const key = document.getElementById('apiKeyInput').value.trim();
  if (!key) { showToast('⚠️ Please enter a valid API key'); return; }
  state.apiKey = key;
  localStorage.setItem('sb_apiKey', key);
  document.getElementById('apiKeyModal').style.display = 'none';
  checkApiKey();
  renderProfile();
  showToast('✅ API key saved!');
}

/* ===================== BUDGET ===================== */
function openBudgetEdit() {
  document.getElementById('budgetInput').value = state.budget;
  document.getElementById('modalCurrency').textContent = state.currency;
  document.getElementById('budgetModal').style.display = 'flex';
}
function closeBudgetModal(e) {
  if (!e || e.target === document.getElementById('budgetModal'))
    document.getElementById('budgetModal').style.display = 'none';
}
function saveBudget() {
  const val = parseFloat(document.getElementById('budgetInput').value);
  if (!val || val <= 0) { showToast('⚠️ Enter a valid budget'); return; }
  state.budget = val;
  localStorage.setItem('sb_budget', val);
  document.getElementById('budgetModal').style.display = 'none';
  updateBudgetUI();
  renderProfile();
  showToast('✅ Budget updated!');
}

function calcSpent() {
  const now = new Date();
  return state.receipts
    .filter(r => {
      const d = new Date(r.savedAt);
      return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
    })
    .reduce((sum, r) => sum + (r.total || 0), 0);
}

function updateBudgetUI() {
  const spent = calcSpent();
  const remaining = Math.max(0, state.budget - spent);
  const pct = Math.min(100, (spent / state.budget) * 100);
  const cur = state.currency;

  document.getElementById('totalSpent').textContent = cur + fmt(spent);
  document.getElementById('totalRemaining').textContent = cur + fmt(remaining);
  document.getElementById('budgetBarFill').style.width = pct + '%';
  document.getElementById('budgetPct').textContent = Math.round(pct) + '% used';

  // Update bar color based on pct
  const fill = document.getElementById('budgetBarFill');
  if (pct > 80) fill.style.background = 'linear-gradient(90deg,#EF4444,#F87171)';
  else if (pct > 60) fill.style.background = 'linear-gradient(90deg,#F97316,#FB923C)';
  else fill.style.background = 'linear-gradient(90deg,#3B7EF8,#5C9EFF)';

  // Category stats
  const cats = getCategoryTotals(state.receipts.filter(r => {
    const d = new Date(r.savedAt);
    const now = new Date();
    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  }));

  document.getElementById('statFood').textContent = cur + fmt(cats['Food & Dining'] || 0);
  document.getElementById('statTransport').textContent = cur + fmt(cats['Transport'] || 0);
  document.getElementById('statShopping').textContent = cur + fmt(cats['Shopping'] || 0);
  const otherTotal = Object.entries(cats)
    .filter(([k]) => !['Food & Dining','Transport','Shopping'].includes(k))
    .reduce((s, [,v]) => s+v, 0);
  document.getElementById('statOther').textContent = cur + fmt(otherTotal);
}

function getCategoryTotals(receipts) {
  const cats = {};
  receipts.forEach(r => {
    (r.items || []).forEach(item => {
      const cat = item.category || 'Other';
      cats[cat] = (cats[cat] || 0) + (item.price || 0);
    });
  });
  return cats;
}

function fmt(n) {
  return n >= 1000
    ? (n / 1000).toFixed(1).replace(/\.0$/, '') + 'k'
    : n.toFixed(2).replace(/\.00$/, '');
}

/* ===================== UPLOAD & SCAN ===================== */
function triggerUpload() {
  document.getElementById('fileInput').click();
}

function handleFileSelect(e) {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = ev => {
    document.getElementById('receiptPreview').src = ev.target.result;
    document.getElementById('uploadInner').style.display = 'none';
    document.getElementById('previewContainer').style.display = 'block';
    state.currentFile = { dataUrl: ev.target.result, file };
    document.getElementById('analyzeSection').style.display = state.apiKey ? 'block' : 'none';
  };
  reader.readAsDataURL(file);
}

async function analyzeReceipt() {
  if (!state.apiKey) { showToast('⚠️ Set your API key first'); openApiKeyModal(); return; }
  if (!state.currentFile) { showToast('⚠️ Please upload a receipt image'); return; }

  const currency = document.getElementById('currencySelect').value;
  state.currency = currency;
  localStorage.setItem('sb_currency', currency);

  // Show loading
  document.getElementById('analyzeSection').style.display = 'none';
  document.getElementById('loadingSection').style.display = 'block';
  document.getElementById('resultsSection').style.display = 'none';

  // Animate steps
  const steps = ['step1','step2','step3','step4'];
  let stepIdx = 0;
  const stepInterval = setInterval(() => {
    if (stepIdx > 0) {
      document.getElementById(steps[stepIdx-1]).classList.remove('active');
      document.getElementById(steps[stepIdx-1]).classList.add('done');
    }
    if (stepIdx < steps.length) {
      document.getElementById(steps[stepIdx]).classList.add('active');
      stepIdx++;
    } else {
      clearInterval(stepInterval);
    }
  }, 900);

  try {
    if (state.apiKey.trim().toLowerCase() === 'demo') {
      // Demo mode
      await new Promise(r => setTimeout(r, 2500));
      clearInterval(stepInterval);
      steps.forEach(s => { document.getElementById(s).classList.remove('active'); document.getElementById(s).classList.add('done'); });

      const parsed = {
        merchant: "Liquor Street",
        date: "20 May 2018",
        items: [
          { name: "Tandoori chicken", price: 309.75, category: "Food & Dining" },
          { name: "Lasooni Dal Tadka", price: 288.75, category: "Food & Dining" },
          { name: "Hyderabadi Murg Biryani", price: 393.75, category: "Food & Dining" },
          { name: "Tandoori Roti (all food less spicy)", price: 63.00, category: "Food & Dining" },
          { name: "Tandoori Roti", price: 31.50, category: "Food & Dining" }
        ],
        subtotal: 1035.00,
        tax: 103.53,
        total: 1139.00,
        currency: "₹"
      };
      
      state.currentScan = { ...parsed, currency: "₹" };
      setTimeout(() => {
        document.getElementById('loadingSection').style.display = 'none';
        showResults(parsed, "₹");
      }, 400);
      return;
    }

    // Convert to base64
    const base64 = state.currentFile.dataUrl.split(',')[1];
    const mediaType = state.currentFile.file.type || 'image/jpeg';

    const prompt = `You are the Receipt Scanner + AI. Analyze this receipt image and extract ALL items with prices.

Return ONLY valid JSON (no markdown, no explanation):
{
  "merchant": "Store/Restaurant name",
  "date": "DD MMM YYYY",
  "items": [
    {
      "name": "Item name",
      "price": 123.45,
      "category": "Food & Dining"
    }
  ],
  "subtotal": 0,
  "tax": 0,
  "total": 0,
  "currency": "${currency}"
}

Categories must be one of: Food & Dining, Transport, Shopping, Health, Entertainment, Utilities, Other.
If you cannot read the receipt clearly, make reasonable estimates based on what's visible.
All prices must be numbers (no currency symbols).`;

    // Call Google Gemini API
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${state.apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: prompt },
            { inlineData: { mimeType: mediaType, data: base64 } }
          ]
        }]
      })
    });

    clearInterval(stepInterval);
    steps.forEach(s => { document.getElementById(s).classList.remove('active'); document.getElementById(s).classList.add('done'); });

    const data = await response.json();
    if (!response.ok || data.error) {
      throw new Error(data.error?.message || 'API Error');
    }

    const raw = data.candidates[0].content.parts[0].text || '';
    const clean = raw.replace(/```json|```/g, '').trim();
    const parsed = JSON.parse(clean);

    state.currentScan = { ...parsed, currency };

    setTimeout(() => {
      document.getElementById('loadingSection').style.display = 'none';
      showResults(parsed, currency);
    }, 400);

  } catch (err) {
    clearInterval(stepInterval);
    document.getElementById('loadingSection').style.display = 'none';
    document.getElementById('analyzeSection').style.display = 'block';
    console.error(err);
    showToast('❌ ' + (err.message || 'Failed to analyze receipt'));
  }
}

function showResults(data, currency) {
  document.getElementById('resultsSection').style.display = 'block';
  document.getElementById('resultMerchant').textContent = data.merchant || 'Unknown Merchant';
  document.getElementById('resultDate').textContent = data.date || new Date().toLocaleDateString();
  document.getElementById('resultTotal').textContent = currency + (data.total || 0).toFixed(2);
  document.getElementById('itemsCount').textContent = `${(data.items||[]).length} items`;

  // Items
  const list = document.getElementById('itemsList');
  list.innerHTML = '';
  (data.items || []).forEach(item => {
    const catKey = item.category || 'Other';
    const catClass = 'cat-' + catKey.split(' ')[0].toLowerCase();
    const el = document.createElement('div');
    el.className = 'item-row';
    el.innerHTML = `
      <span class="item-cat-badge ${catClass}">${catKey}</span>
      <span class="item-name">${item.name}</span>
      <span class="item-price">${currency}${(item.price||0).toFixed(2)}</span>
    `;
    list.appendChild(el);
  });

  // Category breakdown
  const cats = {};
  (data.items || []).forEach(item => {
    const c = item.category || 'Other';
    cats[c] = (cats[c] || 0) + (item.price || 0);
  });
  const total = Object.values(cats).reduce((a,b) => a+b, 0) || 1;
  const bd = document.getElementById('categoryBreakdown');
  bd.innerHTML = '';
  Object.entries(cats).sort((a,b) => b[1]-a[1]).forEach(([cat, amount]) => {
    const pct = (amount / total) * 100;
    const info = CAT_COLORS[cat] || CAT_COLORS['Other'];
    const el = document.createElement('div');
    el.className = 'cat-row';
    el.innerHTML = `
      <div class="cat-row-top">
        <span class="cat-name">${info.icon} ${cat}</span>
        <span class="cat-total" style="color:${info.text}">${currency}${amount.toFixed(2)}</span>
      </div>
      <div class="cat-bar-bg">
        <div class="cat-bar-fill" style="width:${pct}%;background:${info.bar}"></div>
      </div>
    `;
    bd.appendChild(el);
  });
}

function saveTobudget() {
  if (!state.currentScan) return;
  const receipt = {
    ...state.currentScan,
    savedAt: new Date().toISOString(),
    id: Date.now(),
  };
  state.receipts.unshift(receipt);
  localStorage.setItem('sb_receipts', JSON.stringify(state.receipts));
  updateBudgetUI();
  renderRecentList();
  showToast('✅ Saved to budget!');
  setTimeout(() => { resetScan(); switchTab('home'); }, 800);
}

function resetScan() {
  state.currentScan = null;
  state.currentFile = null;
  document.getElementById('fileInput').value = '';
  document.getElementById('uploadInner').style.display = 'block';
  document.getElementById('previewContainer').style.display = 'none';
  document.getElementById('loadingSection').style.display = 'none';
  document.getElementById('resultsSection').style.display = 'none';
  document.getElementById('analyzeSection').style.display = state.apiKey ? 'block' : 'none';
  // reset steps
  ['step1','step2','step3','step4'].forEach(s => {
    const el = document.getElementById(s);
    el.classList.remove('active','done');
  });
  document.getElementById('step1').classList.add('active');
}

/* ===================== RENDER LISTS ===================== */
function getCatIcon(cat) {
  return (CAT_COLORS[cat] || CAT_COLORS['Other']).icon;
}
function getCatBg(cat) {
  return (CAT_COLORS[cat] || CAT_COLORS['Other']).bg;
}

function renderRecentList() {
  const container = document.getElementById('recentList');
  const recent = state.receipts.slice(0, 5);
  if (!recent.length) {
    container.innerHTML = `<div class="empty-state">
      <div class="empty-icon">🧾</div>
      <div class="empty-title">No receipts yet</div>
      <div class="empty-sub">Scan your first receipt to get started</div>
    </div>`;
    return;
  }
  container.innerHTML = recent.map(r => renderTxnItem(r)).join('');
}

function renderHistoryList() {
  const container = document.getElementById('historyList');
  if (!state.receipts.length) {
    container.innerHTML = `<div class="empty-state">
      <div class="empty-icon">📋</div>
      <div class="empty-title">No history yet</div>
      <div class="empty-sub">Scanned receipts will appear here</div>
    </div>`;
    return;
  }
  // Group by date
  const groups = {};
  state.receipts.forEach(r => {
    const d = new Date(r.savedAt);
    const key = d.toLocaleDateString('default', { day:'numeric', month:'long', year:'numeric' });
    if (!groups[key]) groups[key] = [];
    groups[key].push(r);
  });
  container.innerHTML = Object.entries(groups).map(([date, receipts]) => `
    <div style="margin-bottom:6px;padding:10px 4px 4px;font-size:12px;font-weight:700;color:var(--text2);text-transform:uppercase;letter-spacing:0.5px">${date}</div>
    ${receipts.map(r => renderTxnItem(r)).join('')}
  `).join('<div style="height:12px"></div>');
}

function renderTxnItem(r) {
  const topCat = getTopCat(r);
  const icon = getCatIcon(topCat);
  const bg = getCatBg(topCat);
  const cur = r.currency || state.currency;
  const d = new Date(r.savedAt);
  const timeStr = d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  return `<div class="transaction-item">
    <div class="txn-icon" style="background:${bg}">${icon}</div>
    <div class="txn-info">
      <div class="txn-merchant">${r.merchant || 'Unknown'}</div>
      <div class="txn-meta">${r.date || timeStr} · ${(r.items||[]).length} items · ${topCat}</div>
    </div>
    <div class="txn-amount">-${cur}${(r.total||0).toFixed(2)}</div>
  </div>`;
}

function getTopCat(r) {
  const cats = {};
  (r.items||[]).forEach(i => { const c = i.category||'Other'; cats[c]=(cats[c]||0)+(i.price||0); });
  return Object.entries(cats).sort((a,b)=>b[1]-a[1])[0]?.[0] || 'Other';
}

/* ===================== INSIGHTS ===================== */
function renderInsights() {
  const total = state.receipts.reduce((s,r) => s+(r.total||0), 0);
  const cur = state.currency;
  document.getElementById('insightTotal').textContent = cur + total.toFixed(2);
  document.getElementById('insightReceiptCount').textContent = `${state.receipts.length} receipt${state.receipts.length!==1?'s':''} scanned`;

  // Category totals
  const cats = getCategoryTotals(state.receipts);
  const catTotal = Object.values(cats).reduce((a,b)=>a+b,0) || 1;
  const sortedCats = Object.entries(cats).sort((a,b)=>b[1]-a[1]);

  const catsEl = document.getElementById('insightCats');
  if (!sortedCats.length) {
    catsEl.innerHTML = '<div class="empty-state" style="padding:24px"><div class="empty-icon">📊</div><div class="empty-title">No data yet</div></div>';
  } else {
    catsEl.innerHTML = sortedCats.map(([cat, amount]) => {
      const info = CAT_COLORS[cat] || CAT_COLORS['Other'];
      const pct = (amount / catTotal) * 100;
      return `<div class="insight-cat-row">
        <div class="insight-cat-icon" style="background:${info.bg}">${info.icon}</div>
        <div class="insight-cat-info">
          <div class="insight-cat-name">${cat}</div>
          <div class="insight-cat-bar-bg">
            <div class="insight-cat-bar-fill" style="width:${pct}%;background:${info.bar}"></div>
          </div>
        </div>
        <div class="insight-cat-amount" style="color:${info.text}">${cur}${amount.toFixed(2)}</div>
      </div>`;
    }).join('');
  }

  // Top merchants
  const merchants = {};
  state.receipts.forEach(r => {
    const m = r.merchant || 'Unknown';
    if (!merchants[m]) merchants[m] = { total: 0, count: 0 };
    merchants[m].total += r.total || 0;
    merchants[m].count++;
  });
  const sortedMerch = Object.entries(merchants).sort((a,b)=>b[1].total-a[1].total).slice(0,5);
  const merchEl = document.getElementById('insightMerchants');
  if (!sortedMerch.length) {
    merchEl.innerHTML = '<div class="empty-state" style="padding:24px"><div class="empty-icon">🏪</div><div class="empty-title">No merchants yet</div></div>';
  } else {
    merchEl.innerHTML = sortedMerch.map(([name, data]) => `
      <div class="merchant-row">
        <div class="merchant-left">
          <div class="merchant-icon">${name.charAt(0).toUpperCase()}</div>
          <div>
            <div class="merchant-name">${name}</div>
            <div class="merchant-count">${data.count} visit${data.count!==1?'s':''}</div>
          </div>
        </div>
        <div class="merchant-total">${cur}${data.total.toFixed(2)}</div>
      </div>
    `).join('');
  }
}

/* ===================== HISTORY ACTIONS ===================== */
function clearHistory() {
  if (!state.receipts.length) { showToast('Nothing to clear'); return; }
  if (!confirm(`Delete all ${state.receipts.length} receipts?`)) return;
  state.receipts = [];
  localStorage.setItem('sb_receipts', '[]');
  updateBudgetUI();
  renderRecentList();
  renderHistoryList();
  renderInsights();
  showToast('🗑️ History cleared');
}

function showNotifications() {
  showToast('🔔 No new notifications');
}

/* ===================== PROFILE ===================== */
function openProfileEdit() {
  document.getElementById('profileNameInput').value = state.user.name;
  document.getElementById('profileEmailInput').value = state.user.email;
  document.getElementById('profileModal').style.display = 'flex';
}
function closeProfileModal(e) {
  if (!e || e.target === document.getElementById('profileModal'))
    document.getElementById('profileModal').style.display = 'none';
}
function saveProfile() {
  const name = document.getElementById('profileNameInput').value.trim();
  const email = document.getElementById('profileEmailInput').value.trim();
  if (!name) { showToast('⚠️ Name cannot be empty'); return; }
  state.user.name = name;
  state.user.email = email;
  localStorage.setItem('sb_userName', name);
  localStorage.setItem('sb_userEmail', email);
  document.getElementById('profileModal').style.display = 'none';
  renderProfile();
  showToast('✅ Profile updated!');
}

function renderProfile() {
  const cur = state.currency;
  const budget = state.budget;
  const keySet = !!state.apiKey;

  const budgetEl = document.getElementById('profileBudgetVal');
  if (budgetEl) budgetEl.textContent = cur + fmt(budget);

  const keyEl = document.getElementById('profileApiKeyStatus');
  if (keyEl) {
    keyEl.textContent = keySet ? 'Set ✓' : 'Not Set';
    keyEl.style.color = keySet ? 'var(--green)' : 'var(--red)';
  }

  const nameDisplay = document.getElementById('displayUserName');
  if (nameDisplay) nameDisplay.textContent = state.user.name;

  const profileName = document.getElementById('profileName');
  if (profileName) profileName.textContent = state.user.name;

  const profileEmail = document.querySelector('.profile-email');
  if (profileEmail) profileEmail.textContent = state.user.email;

  const initials = state.user.name.split(' ').map(n => n[0]).join('').toUpperCase();
  const avatarInitials = document.getElementById('avatarInitials');
  if (avatarInitials) avatarInitials.textContent = initials;
  const profileAvatar = document.querySelector('.profile-avatar-large');
  if (profileAvatar) profileAvatar.textContent = initials;
}

/* ===================== TOAST ===================== */
let toastTimer;
function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.classList.remove('show'), 2800);
}

