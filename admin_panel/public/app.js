// Enterprise Admin Portal Client JavaScript
const API_BASE = '';

let allFaqs = [];
let allNotifications = [];

// DOM Elements
const systemStatusDot = document.getElementById('system-status-dot');
const systemStatusText = document.getElementById('system-status-text');
const navButtons = document.querySelectorAll('.nav-btn');
const tabContents = document.querySelectorAll('.tab-content');
const pageHeading = document.getElementById('page-heading');
const pageSubheading = document.getElementById('page-subheading');

// FAQs DOM
const faqsTbody = document.getElementById('faqs-tbody');
const faqSearchInput = document.getElementById('faq-search');
const faqCategorySelect = document.getElementById('faq-filter-category');
const btnRefreshFaqs = document.getElementById('btn-refresh-faqs');
const btnRefreshNotifs = document.getElementById('btn-refresh-notifs');
const btnSeedFaqs = document.getElementById('btn-seed-faqs');
const btnCreateFaq = document.getElementById('btn-create-faq');
const faqModal = document.getElementById('faq-modal');
const faqModalForm = document.getElementById('faq-modal-form');
const modalTitle = document.getElementById('modal-title');
const modalClose = document.getElementById('modal-close');
const modalCancel = document.getElementById('modal-cancel');

// Notifications DOM
const notifForm = document.getElementById('notification-form');
const notifTitle = document.getElementById('notif-title');
const notifBody = document.getElementById('notif-body');
const notifBadge = document.getElementById('notif-badge');
const notifBadgeColor = document.getElementById('notif-badge-color');
const previewTitle = document.getElementById('preview-title');
const previewBody = document.getElementById('preview-body');
const previewBadge = document.getElementById('preview-badge');
const notificationsTbody = document.getElementById('notifications-tbody');
const toastContainer = document.getElementById('toast-container');

// --- Initialization ---
document.addEventListener('DOMContentLoaded', () => {
  initTabs();
  checkSystemHealth();
  loadUserStats();
  loadFaqs();
  loadNotifications();
  loadPromo();
  setupLivePreview();
  setupPromoLivePreview();
  setupEventHandlers();
  setInterval(loadUserStats, 15000); // Live poll device stats
});

async function loadUserStats() {
  try {
    const res = await fetch(`${API_BASE}/api/user-stats`);
    const data = await res.json();
    if (data.success) {
      const totalEl = document.getElementById('stats-total');
      const enEl = document.getElementById('stats-en');
      const haEl = document.getElementById('stats-ha');
      if (totalEl) totalEl.textContent = data.totalDevices || 0;
      if (enEl) enEl.textContent = data.englishCount || 0;
      if (haEl) haEl.textContent = data.hausaCount || 0;
    }
  } catch (err) {
    console.warn('Could not load user stats:', err);
  }
}

// Tab Navigation
function initTabs() {
  navButtons.forEach((btn) => {
    btn.addEventListener('click', () => {
      navButtons.forEach((b) => b.classList.remove('active'));
      tabContents.forEach((t) => t.classList.remove('active'));

      btn.classList.add('active');
      const targetId = btn.getAttribute('data-tab');
      document.getElementById(targetId).classList.add('active');

      if (targetId === 'faqs-tab') {
        pageHeading.textContent = 'FAQ Knowledge Base';
        pageSubheading.textContent = 'Manage verified statutory student loan policies & guidance in real time';
      } else if (targetId === 'promo-tab') {
        pageHeading.textContent = 'Sauki Go Promo';
        pageSubheading.textContent = 'Configure companion data & airtime plans, store links, and modal cadence';
      } else {
        pageHeading.textContent = 'Push Notifications';
        pageSubheading.textContent = 'Dispatch high-priority bulletins to Android and iOS student devices';
      }
    });
  });
}

// System Health Check
async function checkSystemHealth() {
  try {
    const res = await fetch(`${API_BASE}/api/health`);
    const data = await res.json();
    if (data.firebaseReady) {
      systemStatusDot.classList.add('online');
      systemStatusText.textContent = 'Firestore & FCM Connected';
    } else {
      systemStatusText.textContent = 'Firebase Offline';
    }
  } catch (err) {
    systemStatusText.textContent = 'Server Offline';
  }
}

// Toast Feedback
function showToast(message, isError = false) {
  const toast = document.createElement('div');
  toast.className = `toast ${isError ? 'error' : ''}`;
  toast.textContent = message;
  toastContainer.appendChild(toast);
  setTimeout(() => {
    toast.remove();
  }, 4000);
}

// --- FAQs Manager ---
async function loadFaqs() {
  try {
    const res = await fetch(`${API_BASE}/api/faqs`);
    const data = await res.json();
    if (data.success) {
      allFaqs = data.data || [];
      renderFaqs();
    } else {
      faqsTbody.innerHTML = `<tr><td colspan="6" class="text-center" style="color: #DC2626;">Error: ${data.error}</td></tr>`;
    }
  } catch (err) {
    faqsTbody.innerHTML = `<tr><td colspan="6" class="text-center" style="color: #DC2626;">Failed to load FAQs: ${err.message}</td></tr>`;
  }
}

function renderFaqs() {
  const query = (faqSearchInput.value || '').trim().toLowerCase();
  const cat = faqCategorySelect.value;

  const filtered = allFaqs.filter((item) => {
    if (cat !== 'all' && item.category !== cat) return false;
    if (query) {
      const matchQ = (item.question || '').toLowerCase().includes(query);
      const matchA = (item.answer || '').toLowerCase().includes(query);
      const matchR = (item.statutoryReference || '').toLowerCase().includes(query);
      return matchQ || matchA || matchR;
    }
    return true;
  });

  if (filtered.length === 0) {
    faqsTbody.innerHTML = `<tr><td colspan="6" class="text-center" style="padding: 32px; color: #64748B;">No matching FAQs found. Click "Seed Statutory 15 FAQs" or "New FAQ Entry" to add one.</td></tr>`;
    return;
  }

  faqsTbody.innerHTML = filtered
    .map((item) => {
      const catClass = `pill-${item.category || 'applying'}`;
      return `
        <tr>
          <td><code style="font-size: 11px; background: #F1F5F9; padding: 2px 6px; border-radius: 4px;">${item.id || ''}</code></td>
          <td><span class="pill-category ${catClass}">${item.category || 'applying'}</span></td>
          <td style="font-weight: 600;">${escapeHtml(item.question || '')}</td>
          <td style="color: #334155;">${escapeHtml(item.answer || '')}</td>
          <td style="font-size: 11.5px; color: #64748B;">${escapeHtml(item.statutoryReference || 'Statutory Act')}</td>
          <td>
            <div class="table-actions">
              <button class="btn-icon" title="Edit" onclick="openEditModal('${item.id}')">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
              </button>
              <button class="btn-icon delete" title="Delete" onclick="deleteFaq('${item.id}')">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
              </button>
            </div>
          </td>
        </tr>
      `;
    })
    .join('');
}

function openCreateModal() {
  modalTitle.textContent = 'Create New FAQ Entry';
  document.getElementById('faq-id').value = '';
  document.getElementById('form-category').value = 'applying';
  document.getElementById('form-question').value = '';
  document.getElementById('form-question-ha').value = '';
  document.getElementById('form-answer').value = '';
  document.getElementById('form-answer-ha').value = '';
  document.getElementById('form-ref').value = 'Students Loans Act 2024';
  document.getElementById('form-ref-ha').value = '';
  faqModal.classList.add('show');
}

window.openEditModal = function(id) {
  const item = allFaqs.find((f) => f.id === id);
  if (!item) return;

  modalTitle.textContent = `Edit FAQ [${id}]`;
  document.getElementById('faq-id').value = item.id;
  document.getElementById('form-category').value = item.category || 'applying';
  document.getElementById('form-question').value = item.question || '';
  document.getElementById('form-question-ha').value = item.questionHa || '';
  document.getElementById('form-answer').value = item.answer || '';
  document.getElementById('form-answer-ha').value = item.answerHa || '';
  document.getElementById('form-ref').value = item.statutoryReference || '';
  document.getElementById('form-ref-ha').value = item.statutoryReferenceHa || '';
  faqModal.classList.add('show');
};

function closeModal() {
  faqModal.classList.remove('show');
}

window.deleteFaq = async function(id) {
  if (!confirm(`Are you sure you want to delete FAQ "${id}" from Cloud Firestore?`)) return;

  try {
    const res = await fetch(`${API_BASE}/api/faqs/${encodeURIComponent(id)}`, {
      method: 'DELETE',
    });
    const data = await res.json();
    if (data.success) {
      showToast(`FAQ ${id} deleted successfully.`);
      allFaqs = allFaqs.filter((f) => f.id !== id);
      renderFaqs();
    } else {
      showToast(data.error || 'Failed to delete FAQ', true);
    }
  } catch (err) {
    showToast(err.message, true);
  }
};

// --- Push Notification Dispatcher ---
function setupLivePreview() {
  const updatePreview = () => {
    previewTitle.textContent = notifTitle.value.trim() || '2024/2025 Application Window Open';
    previewBody.textContent = notifBody.value.trim() || 'Full-time students in tertiary institutions can now submit loan requests.';
    previewBadge.textContent = notifBadge.value;
    previewBadge.style.backgroundColor = notifBadgeColor.value;
  };

  notifTitle.addEventListener('input', updatePreview);
  notifBody.addEventListener('input', updatePreview);
  notifBadge.addEventListener('change', updatePreview);
  notifBadgeColor.addEventListener('change', updatePreview);
}

// --- Sauki Go Promo Manager ---
function updatePromoPreview() {
  const appNameEl = document.getElementById('promo-app-name');
  const cycleEnEl = document.getElementById('promo-cycle-en');
  const headlineEnEl = document.getElementById('promo-headline-en');
  const p1dEl = document.getElementById('promo-plan1-data');
  const p1pEl = document.getElementById('promo-plan1-price');
  const p2dEl = document.getElementById('promo-plan2-data');
  const p2pEl = document.getElementById('promo-plan2-price');

  const prevName = document.getElementById('promo-preview-name');
  const prevCycle = document.getElementById('promo-preview-cycle');
  const prevHeadline = document.getElementById('promo-preview-headline');
  const prevP1d = document.getElementById('promo-preview-p1d');
  const prevP1p = document.getElementById('promo-preview-p1p');
  const prevP2d = document.getElementById('promo-preview-p2d');
  const prevP2p = document.getElementById('promo-preview-p2p');

  if (prevName && appNameEl) prevName.textContent = `⚡ ${appNameEl.value.trim() || 'Sauki Go'}`;
  if (prevCycle && cycleEnEl) prevCycle.textContent = cycleEnEl.value.trim() || 'All Monthly';
  if (prevHeadline && headlineEnEl) {
    prevHeadline.textContent = headlineEnEl.value.trim() || 'Get affordable data and airtime from our trusted app';
  }
  if (prevP1d && p1dEl) prevP1d.textContent = p1dEl.value.trim() || '1GB';
  if (prevP1p && p1pEl) prevP1p.textContent = p1pEl.value.trim() || '₦400';
  if (prevP2d && p2dEl) prevP2d.textContent = p2dEl.value.trim() || '5GB';
  if (prevP2p && p2pEl) prevP2p.textContent = p2pEl.value.trim() || '₦1,500';
}

function setupPromoLivePreview() {
  const ids = [
    'promo-app-name',
    'promo-cycle-en',
    'promo-headline-en',
    'promo-plan1-data',
    'promo-plan1-price',
    'promo-plan2-data',
    'promo-plan2-price',
  ];
  ids.forEach((id) => {
    const el = document.getElementById(id);
    if (el) el.addEventListener('input', updatePromoPreview);
  });
}

async function loadPromo() {
  try {
    const res = await fetch(`${API_BASE}/api/promo`);
    const result = await res.json();
    if (!result.success || !result.data) return;
    const d = result.data;
    const setVal = (id, val) => {
      const el = document.getElementById(id);
      if (el && val !== undefined && val !== null) el.value = String(val);
    };
    setVal('promo-enabled', d.enabled !== false);
    setVal('promo-modal-enabled', d.modalEnabled !== false);
    setVal('promo-app-name', d.appName || 'Sauki Go');
    setVal('promo-cooldown-days', d.cooldownDays ?? 7);
    setVal('promo-plan1-data', d.plan1Data || '1GB');
    setVal('promo-plan1-price', d.plan1Price || '₦400');
    setVal('promo-plan2-data', d.plan2Data || '5GB');
    setVal('promo-plan2-price', d.plan2Price || '₦1,500');
    setVal('promo-cycle-en', d.cycleEn || 'All Monthly');
    setVal('promo-cycle-ha', d.cycleHa || 'Duka na Wata-Wata');
    setVal('promo-headline-en', d.headlineEn || '');
    setVal('promo-headline-ha', d.headlineHa || '');
    setVal('promo-subtitle-en', d.subtitleEn || '');
    setVal('promo-subtitle-ha', d.subtitleHa || '');
    setVal('promo-appstore-url', d.appStoreUrl || 'https://apps.apple.com/app/id6815456102');
    setVal('promo-playstore-url', d.playStoreUrl || 'https://play.google.com/store/apps/details?id=com.saukimart.go');
    updatePromoPreview();
  } catch (err) {
    console.warn('Could not load Sauki Go promo config:', err);
  }
}

async function loadNotifications() {
  try {
    const res = await fetch(`${API_BASE}/api/notifications`);
    const data = await res.json();
    if (data.success) {
      allNotifications = data.data || [];
      renderNotifications();
    }
  } catch (err) {
    notificationsTbody.innerHTML = `<tr><td colspan="5" class="text-center" style="color: #DC2626;">Error: ${err.message}</td></tr>`;
  }
}

function renderNotifications() {
  if (allNotifications.length === 0) {
    notificationsTbody.innerHTML = `<tr><td colspan="5" class="text-center" style="padding: 32px; color: #64748B;">No notifications published yet. Use the composer above to dispatch one.</td></tr>`;
    return;
  }

  notificationsTbody.innerHTML = allNotifications
    .map((item) => {
      const badgeCol = item.badgeColorHex || '#0D5C3A';
      return `
        <tr>
          <td style="font-size: 11.5px; color: #64748B;">${item.timestamp || ''}</td>
          <td>
            <span style="display: inline-block; padding: 2px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; color: #FFF; background-color: ${badgeCol};">
              ${escapeHtml(item.badge || 'Advisory')}
            </span>
          </td>
          <td style="font-weight: 600;">${escapeHtml(item.title || '')}</td>
          <td style="color: #334155;">${escapeHtml(item.body || '')}</td>
          <td style="text-align: right;">
            <button class="btn-icon delete" title="Delete Notification" onclick="deleteNotification('${item.id}')">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
            </button>
          </td>
        </tr>
      `;
    })
    .join('');
}

window.deleteNotification = async function(id) {
  if (!confirm(`Delete bulletin "${id}" from Cloud Firestore?`)) return;

  try {
    const res = await fetch(`${API_BASE}/api/notifications/${encodeURIComponent(id)}`, {
      method: 'DELETE',
    });
    const data = await res.json();
    if (data.success) {
      showToast('Notification deleted from Firestore.');
      allNotifications = allNotifications.filter((n) => n.id !== id);
      renderNotifications();
    } else {
      showToast(data.error || 'Failed to delete notification', true);
    }
  } catch (err) {
    showToast(err.message, true);
  }
};

// Event Handlers Setup
function setupEventHandlers() {
  faqSearchInput.addEventListener('input', renderFaqs);
  faqCategorySelect.addEventListener('change', renderFaqs);

  btnCreateFaq.addEventListener('click', openCreateModal);
  modalClose.addEventListener('click', closeModal);
  modalCancel.addEventListener('click', closeModal);

  // Refresh FAQs Live DB
  if (btnRefreshFaqs) {
    btnRefreshFaqs.addEventListener('click', async () => {
      btnRefreshFaqs.disabled = true;
      btnRefreshFaqs.textContent = 'Refreshing...';
      await loadFaqs();
      showToast(`Synchronized ${allFaqs.length} FAQs from Cloud Firestore`);
      btnRefreshFaqs.disabled = false;
      btnRefreshFaqs.innerHTML = `<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 4v6h-6"/><path d="M1 20v-6h6"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg> Refresh Live DB`;
    });
  }

  // Refresh Notifications Live DB
  if (btnRefreshNotifs) {
    btnRefreshNotifs.addEventListener('click', async () => {
      btnRefreshNotifs.disabled = true;
      btnRefreshNotifs.textContent = 'Refreshing...';
      await loadNotifications();
      showToast(`Synchronized ${allNotifications.length} bulletins from Cloud Firestore`);
      btnRefreshNotifs.disabled = false;
      btnRefreshNotifs.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 4v6h-6"/><path d="M1 20v-6h6"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg> Refresh`;
    });
  }

  // Seed Statutory 19 In-App FAQs
  btnSeedFaqs.addEventListener('click', async () => {
    if (!confirm('Sync all 19 official in-app statutory policies into Cloud Firestore? This will populate the full dataset and purge any legacy entries.')) return;

    btnSeedFaqs.disabled = true;
    btnSeedFaqs.textContent = 'Syncing...';
    try {
      const res = await fetch(`${API_BASE}/api/faqs/seed`, { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        showToast(data.message);
        await loadFaqs();
      } else {
        showToast(data.error || 'Failed to seed FAQs', true);
      }
    } catch (err) {
      showToast(err.message, true);
    } finally {
      btnSeedFaqs.disabled = false;
      btnSeedFaqs.innerHTML = `<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg> Sync All 19 In-App FAQs`;
    }
  });

  // Save / Update FAQ Modal
  faqModalForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('faq-id').value;
    const isEdit = Boolean(id);

    const payload = {
      id: id || undefined,
      category: document.getElementById('form-category').value,
      question: document.getElementById('form-question').value,
      questionHa: document.getElementById('form-question-ha').value,
      answer: document.getElementById('form-answer').value,
      answerHa: document.getElementById('form-answer-ha').value,
      statutoryReference: document.getElementById('form-ref').value,
      statutoryReferenceHa: document.getElementById('form-ref-ha').value,
    };

    const url = isEdit ? `${API_BASE}/api/faqs/${encodeURIComponent(id)}` : `${API_BASE}/api/faqs`;
    const method = isEdit ? 'PUT' : 'POST';

    try {
      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (data.success) {
        showToast(isEdit ? 'FAQ updated in Firestore' : 'FAQ created in Firestore');
        closeModal();
        await loadFaqs();
      } else {
        showToast(data.error || 'Failed to save FAQ', true);
      }
    } catch (err) {
      showToast(err.message, true);
    }
  });

  // Refresh Sauki Go Promo
  const btnRefreshPromo = document.getElementById('btn-refresh-promo');
  if (btnRefreshPromo) {
    btnRefreshPromo.addEventListener('click', async () => {
      btnRefreshPromo.disabled = true;
      btnRefreshPromo.textContent = 'Refreshing...';
      await loadPromo();
      showToast('Synchronized Sauki Go promo config from Firestore');
      btnRefreshPromo.disabled = false;
      btnRefreshPromo.textContent = 'Refresh';
    });
  }

  // Save Sauki Go Promo Form
  const promoForm = document.getElementById('promo-form');
  if (promoForm) {
    promoForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const saveBtn = document.getElementById('btn-save-promo');
      if (saveBtn) {
        saveBtn.disabled = true;
        saveBtn.textContent = 'Saving to Firestore...';
      }

      const payload = {
        enabled: document.getElementById('promo-enabled').value === 'true',
        modalEnabled: document.getElementById('promo-modal-enabled').value === 'true',
        appName: document.getElementById('promo-app-name').value.trim(),
        cooldownDays: parseInt(document.getElementById('promo-cooldown-days').value, 10) || 7,
        plan1Data: document.getElementById('promo-plan1-data').value.trim(),
        plan1Price: document.getElementById('promo-plan1-price').value.trim(),
        plan2Data: document.getElementById('promo-plan2-data').value.trim(),
        plan2Price: document.getElementById('promo-plan2-price').value.trim(),
        cycleEn: document.getElementById('promo-cycle-en').value.trim(),
        cycleHa: document.getElementById('promo-cycle-ha').value.trim(),
        headlineEn: document.getElementById('promo-headline-en').value.trim(),
        headlineHa: document.getElementById('promo-headline-ha').value.trim(),
        subtitleEn: document.getElementById('promo-subtitle-en').value.trim(),
        subtitleHa: document.getElementById('promo-subtitle-ha').value.trim(),
        appStoreUrl: document.getElementById('promo-appstore-url').value.trim(),
        playStoreUrl: document.getElementById('promo-playstore-url').value.trim(),
      };

      try {
        const res = await fetch(`${API_BASE}/api/promo`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });
        const data = await res.json();
        if (data.success) {
          showToast('Sauki Go promo configuration saved to Firestore!');
          updatePromoPreview();
        } else {
          showToast(data.error || 'Failed to save promo config', true);
        }
      } catch (err) {
        showToast(err.message, true);
      } finally {
        if (saveBtn) {
          saveBtn.disabled = false;
          saveBtn.textContent = 'Save Sauki Go Promo to Cloud Firestore';
        }
      }
    });
  }

  // Dispatch Push Notification Form
  notifForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = document.getElementById('btn-send-push');
    const topicSelect = document.getElementById('notif-topic');
    const notifTitleHa = document.getElementById('notif-title-ha');
    const notifBodyHa = document.getElementById('notif-body-ha');

    submitBtn.disabled = true;
    submitBtn.textContent = 'Dispatching to FCM Topic...';

    const payload = {
      title: notifTitle.value.trim(),
      titleHa: notifTitleHa ? notifTitleHa.value.trim() : '',
      body: notifBody.value.trim(),
      bodyHa: notifBodyHa ? notifBodyHa.value.trim() : '',
      badge: notifBadge.value,
      badgeColorHex: notifBadgeColor.value,
      topic: topicSelect ? topicSelect.value : 'all',
    };

    try {
      const res = await fetch(`${API_BASE}/api/notifications/send`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (data.success) {
        showToast('Push notification dispatched & saved to Firestore!');
        notifTitle.value = '';
        notifBody.value = '';
        if (notifTitleHa) notifTitleHa.value = '';
        if (notifBodyHa) notifBodyHa.value = '';
        await loadNotifications();
      } else {
        showToast(data.error || 'Failed to dispatch push notification', true);
      }
    } catch (err) {
      showToast(err.message, true);
    } finally {
      submitBtn.disabled = false;
      submitBtn.innerHTML = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg> Dispatch High-Priority Push Notification`;
    }
  });
}

function escapeHtml(str) {
  return str.replace(/[&<>'"]/g, 
    tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
  );
}
