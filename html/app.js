const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'rsg-wardrobe';
const $ = (id) => document.getElementById(id);
let T = {}, LABELS = {}, STATE = { slots: [] }, modalAction = null;

const post = (name, data = {}) =>
    fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) })
        .then((r) => r.json()).catch(() => null);

const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

function applyText() {
    document.querySelectorAll('[data-t]').forEach((el) => { el.textContent = T[el.dataset.t] || el.dataset.t; });
}

function renderSlots() {
    const box = $('slots');
    const slots = [...STATE.slots].sort((a, b) => (LABELS[a.name] || a.name).localeCompare(LABELS[b.name] || b.name));
    box.innerHTML = slots.map((s) => {
        const cls = s.removed ? 'off' : s.worn ? 'on' : '';
        const txt = s.removed ? T.ui_off : s.worn ? T.ui_worn : T.ui_none;
        return `<div class="slot ${s.available ? '' : 'disabled'}" data-slot="${esc(s.name)}">
            <span class="slot-name">${esc(LABELS[s.name] || s.name)}</span><span class="pill ${cls}">${esc(txt)}</span></div>`;
    }).join('');
}

function renderDirt() {
    const v = Math.max(0, Math.min(100, STATE.dirt || 0));
    const f = $('dirt-fill');
    f.style.width = v + '%';
    f.className = 'fill ' + (v < 35 ? 'stat-good' : v < 70 ? 'stat-warn' : 'stat-bad');
    $('dirt-val').textContent = v + '%';
}

async function loadOutfits() {
    const list = (await post('getOutfits')) || [];
    const box = $('outfits');
    if (!list.length) { box.innerHTML = `<div class="empty">${esc(T.ui_no_outfits)}</div>`; return; }
    box.innerHTML = list.map((o) => `
        <div class="row" style="cursor:default">
            <div class="badge"><i class="fa-solid ${o.is_default ? 'fa-star' : 'fa-shirt'}"></i></div>
            <div class="row-text"><div class="row-title">${esc(o.name)}</div>${o.is_default ? `<div class="row-desc">${esc(T.ui_default)}</div>` : ''}</div>
            <div class="row-btns">
                <button class="wood-btn small" data-wear="${o.id}">${esc(T.ui_wear)}</button>
                ${o.is_default ? '' : `<button class="wood-btn small muted" data-del="${o.id}" data-name="${esc(o.name)}">${esc(T.ui_delete)}</button>`}
            </div>
        </div>`).join('');
}

function showTab(tab) {
    document.querySelectorAll('.tab').forEach((t) => t.classList.toggle('active', t.dataset.tab === tab));
    document.querySelectorAll('.view').forEach((v) => v.classList.toggle('hidden', v.id !== 'view-' + tab));
    if (tab === 'outfits') loadOutfits();
}

function openModal(title, okText, withInput, action) {
    $('modal-title').textContent = title;
    $('modal-ok').textContent = okText;
    $('modal-input').classList.toggle('hidden', !withInput);
    $('modal-input').value = '';
    $('modal-input').placeholder = T.ui_outfit_name || '';
    modalAction = action;
    $('modal').classList.remove('hidden');
    if (withInput) $('modal-input').focus();
}
const closeModal = () => { $('modal').classList.add('hidden'); modalAction = null; };

function close() { closeModal(); $('app').classList.add('hidden'); post('close'); }

window.addEventListener('message', (e) => {
    const d = e.data;
    if (d.action === 'open') {
        T = d.text || {}; LABELS = d.labels || {}; STATE = d.state || STATE;
        applyText();
        $('tab-outfits').classList.toggle('hidden', !STATE.outfits);
        $('tab-care').classList.toggle('hidden', !STATE.care);
        renderSlots(); renderDirt(); showTab('clothing');
        $('app').classList.remove('hidden');
    } else if (d.action === 'state') {
        STATE = d.state || STATE; renderSlots(); renderDirt();
    } else if (d.action === 'close') {
        closeModal(); $('app').classList.add('hidden');
    }
});

document.addEventListener('click', async (e) => {
    const t = e.target.closest('[data-slot],[data-tab],[data-care],[data-wear],[data-del],button');
    if (!t) return;
    if (t.dataset.tab) return showTab(t.dataset.tab);
    if (t.dataset.slot) { if (!t.classList.contains('disabled')) post('toggle', { name: t.dataset.slot }); return; }
    if (t.dataset.care) { $('app').classList.add('hidden'); return post('care', { action: t.dataset.care }); }
    if (t.dataset.wear) { await post('wearOutfit', { id: Number(t.dataset.wear) }); return; }
    if (t.dataset.del) {
        const id = Number(t.dataset.del);
        return openModal(`${T.ui_delete_confirm} "${t.dataset.name}"?`, T.ui_delete, false, async () => { await post('deleteOutfit', { id }); loadOutfits(); });
    }
    switch (t.id) {
        case 'close': return close();
        case 'undress': return post('undress');
        case 'dress': return post('dress');
        case 'save-open': return openModal(T.ui_save_outfit, T.ui_save, true, async (name) => { await post('saveOutfit', { name }); loadOutfits(); });
        case 'modal-cancel': return closeModal();
        case 'modal-ok': { const a = modalAction, v = $('modal-input').value.trim(); closeModal(); if (a) a(v); return; }
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') { if (!$('modal').classList.contains('hidden')) closeModal(); else if (!$('app').classList.contains('hidden')) close(); }
    if (e.key === 'Enter' && !$('modal').classList.contains('hidden')) $('modal-ok').click();
});
