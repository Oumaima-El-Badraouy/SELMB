(function (global) {
  function escapeHtml(s) {
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function toast(msg, type) {
    let el = document.getElementById('asel-toast');
    if (!el) {
      el = document.createElement('div');
      el.id = 'asel-toast';
      el.className = 'asel-toast';
      document.body.appendChild(el);
    }
    el.textContent = msg;
    el.dataset.type = type || 'info';
    el.classList.add('asel-toast--show');
    clearTimeout(el._t);
    el._t = setTimeout(() => el.classList.remove('asel-toast--show'), 3200);
  }

  function requireAuth(role) {
    const t = global.AlAselConfig.getToken();
    if (!t) {
      global.location.href = 'login.html';
      return null;
    }
    return t;
  }

  global.AlAselUi = { escapeHtml, toast, requireAuth };
})(typeof window !== 'undefined' ? window : globalThis);
