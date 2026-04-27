(function () {
  var U = window.AlAselUi;
  var A = window.AlAselApi;
  var F = window.AlAselFeed;
  var Cat = window.AlAselCategories;
  var Session = window.AlAselSession;
  var Socket = window.AlAselSocket;

  if (!window.AlAselConfig.getToken()) {
    location.href = 'login.html';
    return;
  }

  var user = null;
  var tab = 'demands';

  async function updateUnread() {
    var badge = document.getElementById('shellUnread');
    if (!badge) return;
    try {
      var items = await A.listConversations();
      var n = 0;
      (items.items || []).forEach(function (c) {
        n += (c.unreadCount && +c.unreadCount) || 0;
      });
      badge.textContent = n > 99 ? '99+' : String(n);
      badge.style.display = n > 0 ? 'inline-flex' : 'none';
    } catch (_) {
      badge.style.display = 'none';
    }
  }

  function hashTab() {
    var h = (location.hash || '#demands').replace('#', '') || 'demands';
    if (['demands', 'discover', 'posts', 'profile'].indexOf(h) < 0) h = 'demands';
    return h;
  }

  function setTab(t) {
    tab = t;
    location.hash = t;
    document.querySelectorAll('.bottom-nav button').forEach(function (b) {
      b.classList.toggle('active', b.dataset.tab === t);
    });
    document.querySelectorAll('.panel').forEach(function (p) {
      p.classList.toggle('active', p.id === 'panel-' + t);
    });
    var titles = { demands: 'الطلبات', discover: 'استكشاف', posts: 'منشوراتي', profile: 'الملف' };
    document.getElementById('topTitle').textContent = titles[t] || '';
    if (t === 'demands') loadDemands();
    if (t === 'discover') loadDiscover();
    if (t === 'posts') loadMyPosts();
    if (t === 'profile') loadProfile();
  }

  window.addEventListener('hashchange', function () {
    setTab(hashTab());
  });

  async function init() {
    try {
      user = await Session.refresh();
      if (!user || user.role !== 'artisan') {
        location.href = 'client.html';
        return;
      }
    } catch (e) {
      U.toast(e.message || String(e), 'error');
      window.AlAselConfig.setToken(null);
      location.href = 'login.html';
      return;
    }
    if (Socket && Socket.connect) {
      Socket.connect(user.id);
      Socket.onInboxPing(function () {
        updateUnread();
        if (hashTab() === 'demands') loadDemands();
      });
    }
    updateUnread();
    setInterval(updateUnread, 18000);

    var goInbox = function () {
      location.href = 'inbox.html';
    };
    document.getElementById('btnInbox').onclick = goInbox;
    var si = document.getElementById('shellInboxBtn');
    if (si) si.onclick = goInbox;
    var sr = document.getElementById('shellReportBtn');
    if (sr) sr.onclick = function () {
      location.href = 'report.html';
    };
    document.getElementById('btnNew').onclick = function () {
      location.href = 'create-post.html?type=artisan_service';
    };
    document.getElementById('btnMenu').onclick = openMenu;
    setTab(hashTab());
  }

  function openMenu() {
    var d = document.createElement('div');
    d.className = 'modal-backdrop';
    d.innerHTML =
      '<div class="modal-sheet"><h3 style="margin-top:0">قائمة</h3>' +
      '<p><a href="index.html">الموقع العام</a></p>' +
      '<p><a href="report.html">إبلاغ عن مشكلة</a></p>' +
      '<p><a href="verify-email.html">تأكيد البريد</a></p>' +
      '<button type="button" class="btn btn-outline btn-block" id="lo">تسجيل الخروج</button>' +
      '<button type="button" class="btn btn-primary btn-block" style="margin-top:8px" id="cl">إغلاق</button></div>';
    document.body.appendChild(d);
    d.querySelector('#cl').onclick = function () {
      d.remove();
    };
    d.querySelector('#lo').onclick = function () {
      window.AlAselConfig.setToken(null);
      location.href = 'login.html';
    };
    d.onclick = function (ev) {
      if (ev.target === d) d.remove();
    };
  }

  async function loadDemands() {
    var el = document.getElementById('demList');
    el.innerHTML = '<p class="empty-hint">…</p>';
    try {
      user = await Session.refresh();
      var data = await A.postsFeed({ postType: 'client_request' });
      var posts = data.items || [];
      await F.renderPosts(el, posts, {
        role: 'artisan',
        meId: user.id,
        user: Session.getUser(),
        onRefresh: loadDemands,
      });
    } catch (e) {
      el.innerHTML = '<p class="empty-hint">' + U.escapeHtml(e.message || String(e)) + '</p>';
    }
  }

  async function loadDiscover() {
    var el = document.getElementById('discList');
    el.innerHTML = '<p class="empty-hint">…</p>';
    try {
      var data = await A.listArtisans({
        category: document.getElementById('adCat').value || undefined,
        city: document.getElementById('adCity').value.trim() || undefined,
        available: document.getElementById('adAvail').checked || undefined,
      });
      var items = data.items || [];
      if (!items.length) {
        el.innerHTML = '<p class="empty-hint">لا حرفيين.</p>';
        return;
      }
      el.innerHTML = items
        .map(function (a) {
          return (
            '<a class="card" style="display:block;padding:14px;margin-bottom:10px;text-decoration:none;color:inherit" href="artisan-profile.html?id=' +
            encodeURIComponent(a.id) +
            '"><div style="font-weight:800">' +
            U.escapeHtml(a.displayName || a.name || '—') +
            '</div><div style="font-size:0.85rem;color:var(--muted)">' +
            U.escapeHtml(Cat.categoryLabel(a.domain || a.category || '')) +
            '</div></a>'
          );
        })
        .join('');
    } catch (e) {
      el.innerHTML = '<p class="empty-hint">' + U.escapeHtml(e.message || String(e)) + '</p>';
    }
  }

  async function loadMyPosts() {
    var el = document.getElementById('myPostsList');
    el.innerHTML = '<p class="empty-hint">…</p>';
    try {
      user = await Session.refresh();
      var data = await A.myPosts();
      var posts = data.items || [];
      await F.renderPosts(el, posts, {
        role: 'artisan',
        meId: user.id,
        user: Session.getUser(),
        onRefresh: loadMyPosts,
      });
    } catch (e) {
      el.innerHTML = '<p class="empty-hint">' + U.escapeHtml(e.message || String(e)) + '</p>';
    }
  }

  async function loadProfile() {
    try {
      user = await Session.refresh();
    } catch (_) {}
    var u = user;
    document.getElementById('ap_fn').value = u.firstName || '';
    document.getElementById('ap_ln').value = u.lastName || '';
    if (!document.getElementById('ap_fn').value && !document.getElementById('ap_ln').value && u.name) {
      var parts = u.name.trim().split(/\s+/);
      if (parts.length >= 2) {
        document.getElementById('ap_fn').value = parts[0];
        document.getElementById('ap_ln').value = parts.slice(1).join(' ');
      } else {
        document.getElementById('ap_fn').value = u.name;
      }
    }
    document.getElementById('ap_phone').value = u.phone || '';
    document.getElementById('ap_domain').value = u.domain || '';
    document.getElementById('ap_desc').value = u.description || u.bio || '';
    document.getElementById('ap_loc').value = u.location || '';
    document.getElementById('ap_email').textContent = u.email || '—';
    var av = document.getElementById('ap_avatar');
    if (u.photoUrl) {
      av.src = A.resolveMedia(u.photoUrl);
      av.style.display = '';
    } else {
      av.removeAttribute('src');
      av.style.display = 'none';
    }
    try {
      var fc = await A.followersCount(u.id);
      document.getElementById('ap_followers').textContent = fc.count != null ? fc.count : fc;
    } catch (_) {
      document.getElementById('ap_followers').textContent = '—';
    }
    try {
      var fd = await A.postsFeed({ postType: 'client_request' });
      document.getElementById('ap_demands').textContent = (fd.items || []).length;
    } catch (_) {
      document.getElementById('ap_demands').textContent = '—';
    }
  }

  document.getElementById('adSearch').onclick = loadDiscover;

  document.getElementById('ap_save').onclick = async function () {
    var btn = document.getElementById('ap_save');
    btn.disabled = true;
    try {
      await A.patchMe({
        firstName: document.getElementById('ap_fn').value.trim(),
        lastName: document.getElementById('ap_ln').value.trim(),
        phone: document.getElementById('ap_phone').value.trim(),
        location: document.getElementById('ap_loc').value.trim(),
        domain: document.getElementById('ap_domain').value.trim(),
        description: document.getElementById('ap_desc').value.trim(),
      });
      await Session.refresh();
      U.toast('تم تحديث الملف');
      loadProfile();
    } catch (e) {
      U.toast(e.message || String(e), 'error');
    }
    btn.disabled = false;
  };

  document.getElementById('ap_pick').onclick = function () {
    document.getElementById('ap_photo').click();
  };
  document.getElementById('ap_photo').addEventListener('change', function (ev) {
    var f = ev.target.files[0];
    if (!f) return;
    var r = new FileReader();
    r.onload = async function () {
      try {
        await A.patchMe({ photoUrl: r.result });
        await Session.refresh();
        U.toast('تم تحديث صورة الملف');
        loadProfile();
      } catch (e) {
        U.toast(e.message || String(e), 'error');
      }
    };
    r.readAsDataURL(f);
  });

  document.getElementById('cinRa').addEventListener('change', function (ev) {
    cinUp(ev, true);
  });
  document.getElementById('cinVa').addEventListener('change', function (ev) {
    cinUp(ev, false);
  });
  document.getElementById('btnCRa').onclick = function () {
    document.getElementById('cinRa').click();
  };
  document.getElementById('btnCVa').onclick = function () {
    document.getElementById('cinVa').click();
  };

  function readFile(ev, cb) {
    var f = ev.target.files[0];
    if (!f) return;
    if (f.size > 4 * 1024 * 1024) {
      U.toast('الصورة كبيرة جداً', 'error');
      return;
    }
    var r = new FileReader();
    r.onload = function () {
      cb(r.result);
    };
    r.readAsDataURL(f);
  }

  async function cinUp(ev, recto) {
    readFile(ev, async function (d) {
      try {
        await A.patchMe(recto ? { cinRectoUrl: d } : { cinVersoUrl: d });
        U.toast('تم حفظ صور البطاقة.');
      } catch (e) {
        U.toast(e.message || String(e), 'error');
      }
    });
  }

  var ad = document.getElementById('adCat');
  var ox = document.createElement('option');
  ox.value = '';
  ox.textContent = 'الكل';
  ad.appendChild(ox);
  window.MOROCCAN_TRADES.forEach(function (t) {
    var o = document.createElement('option');
    o.value = t.id;
    o.textContent = t.labelAr;
    ad.appendChild(o);
  });

  document.querySelectorAll('.bottom-nav button').forEach(function (b) {
    b.addEventListener('click', function () {
      setTab(b.dataset.tab);
    });
  });

  init();
})();
