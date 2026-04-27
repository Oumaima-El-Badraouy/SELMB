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
  var tab = 'feed';
  var feedDebounce = null;

  function hashTab() {
    var h = (location.hash || '#feed').replace('#', '') || 'feed';
    if (['feed', 'explore', 'favorites', 'profile'].indexOf(h) < 0) h = 'feed';
    return h;
  }

  function setTab(t) {
    tab = t;
    location.hash = t;
    document.querySelectorAll('.client-web-nav__btn[data-tab]').forEach(function (b) {
      b.classList.toggle('active', b.dataset.tab === t);
    });
    document.querySelectorAll('.panel').forEach(function (p) {
      p.classList.toggle('active', p.id === 'panel-' + t);
    });
    var titles = { feed: 'الرئيسية', explore: 'الحرفيون', favorites: 'المفضلة', profile: 'الملف' };
    document.getElementById('topTitle').textContent = titles[t] || '';
    var br = document.getElementById('btnRefresh');
    if (br) br.style.display = t === 'feed' ? '' : 'none';
    if (t === 'feed') loadFeed();
    if (t === 'explore') loadExplore();
    if (t === 'favorites') loadFavorites();
    if (t === 'profile') loadProfile();
  }

  window.addEventListener('hashchange', function () {
    setTab(hashTab());
  });

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

  async function init() {
    try {
      user = await Session.refresh();
      if (!user || user.role !== 'client') {
        location.href = 'artisan.html';
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
        if (hashTab() === 'feed') loadFeed();
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
    document.getElementById('btnMenu').onclick = openMenu;
    var sr = document.getElementById('shellReportBtn');
    if (sr) sr.onclick = function () {
      location.href = 'report.html';
    };

    var fq = document.getElementById('feedQ');
    if (fq) {
      fq.addEventListener('input', function () {
        clearTimeout(feedDebounce);
        feedDebounce = setTimeout(function () {
          if (hashTab() === 'feed') loadFeed();
        }, 450);
      });
    }

    setTab(hashTab());
  }

  function openMenu() {
    var actions = [
      { t: 'الموقع العام', h: 'index.html' },
      { t: 'طلب خدمة (نموذج)', h: 'request.html' },
      { t: 'إبلاغ عن مشكلة', h: 'report.html' },
      { t: 'تأكيد البريد', h: 'verify-email.html' },
      { t: 'استكشف (صفحة كاملة)', h: 'explore.html' },
    ];
    var d = document.createElement('div');
    d.className = 'modal-backdrop';
    d.innerHTML =
      '<div class="modal-sheet"><h3 style="margin-top:0">قائمة</h3>' +
      actions
        .map(function (x) {
          return '<p><a href="' + x.h + '">' + U.escapeHtml(x.t) + '</a></p>';
        })
        .join('') +
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

  function getFeedCategory() {
    var h = document.getElementById('feedCatKey');
    return h ? h.value : '';
  }

  async function loadFeed() {
    var el = document.getElementById('feedList');
    el.innerHTML = '<p class="empty-hint">…</p>';
    try {
      user = await Session.refresh();
      var q = document.getElementById('feedQ').value.trim();
      var sort = document.getElementById('feedSort').value;
      var cat = getFeedCategory();
      var data = await A.postsFeed({
        postType: 'artisan_service',
        sort: sort === 'popular' ? 'popular' : undefined,
        q: q || undefined,
        category: cat || undefined,
      });
      var posts = data.items || [];
      await F.renderPosts(el, posts, {
        role: 'client',
        meId: user.id,
        user: Session.getUser(),
        onRefresh: loadFeed,
      });
    } catch (e) {
      el.innerHTML = '<p class="empty-hint">' + U.escapeHtml(e.message || String(e)) + '</p>';
    }
  }

  async function loadExplore() {
    var el = document.getElementById('exploreList');
    el.innerHTML = '<p class="empty-hint">…</p>';
    try {
      var data = await A.listArtisans({
        category: document.getElementById('exCat').value || undefined,
        city: document.getElementById('exCity').value.trim() || undefined,
        available: document.getElementById('exAvail').checked || undefined,
      });
      var items = data.items || [];
      if (!items.length) {
        el.innerHTML = '<p class="empty-hint">لا حرفيين.</p>';
        return;
      }
      el.innerHTML = items
        .map(function (a) {
          return (
            '<a class="card client-artisan-tile" href="artisan-profile.html?id=' +
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

  async function loadFavorites() {
    var el = document.getElementById('favList');
    el.innerHTML = '<p class="empty-hint">…</p>';
    try {
      var data = await A.favoritePosts();
      var posts = data.items || [];
      if (!posts.length) {
        el.innerHTML = '<p class="empty-hint">لا مفضلات بعد.</p>';
        return;
      }
      await F.renderPosts(el, posts, {
        role: 'client',
        meId: user.id,
        user: Session.getUser(),
        onRefresh: loadFavorites,
      });
    } catch (e) {
      el.innerHTML = '<p class="empty-hint">' + U.escapeHtml(e.message || String(e)) + '</p>';
    }
  }

  function handleForUser(u) {
    var f = (u.firstName || '').trim().toLowerCase().replace(/\s+/g, '');
    var l = (u.lastName || '').trim().toLowerCase().replace(/\s+/g, '');
    if (f && l) return f + '_' + l;
    if (f) return f;
    var em = u.email || '';
    var at = em.indexOf('@');
    return at > 0 ? em.slice(0, at) : 'profil';
  }

  async function loadProfile() {
    try {
      user = await Session.refresh();
    } catch (_) {}
    var u = user;
    document.getElementById('profHandle').textContent = handleForUser(u);
    document.getElementById('profName').textContent =
      [u.firstName, u.lastName].filter(Boolean).join(' ').trim() || u.displayName || u.name || '—';
    document.getElementById('profEmail').textContent = u.email || '';
    document.getElementById('profLoc').textContent = u.location || '—';
    var av = document.getElementById('profAvatar');
    if (u.photoUrl) {
      av.src = A.resolveMedia(u.photoUrl);
      av.style.display = '';
    } else {
      av.removeAttribute('src');
      av.style.display = 'none';
    }
    try {
      var fol = await A.myFollowing();
      document.getElementById('statFol').textContent = (fol.count != null ? fol.count : (fol.items || []).length) || 0;
    } catch (_) {
      document.getElementById('statFol').textContent = '—';
    }
    var mine = await A.myPosts();
    var demands = (mine.items || []).filter(function (p) {
      return F.postIsDemand(p);
    });
    document.getElementById('statDem').textContent = demands.length;
    var list = document.getElementById('demandList');
    if (!demands.length) {
      list.innerHTML = '<p class="empty-hint">لا طلبات. اضغط + لنشر طلب.</p>';
    } else {
      list.innerHTML = demands
        .map(function (p) {
          return (
            '<div class="card" style="padding:12px;margin-bottom:10px"><div style="font-weight:700">' +
            U.escapeHtml((p.content || '').slice(0, 120)) +
            '</div><button type="button" class="btn btn-outline" style="margin-top:8px" data-del="' +
            U.escapeHtml(p.id) +
            '">حذف</button></div>'
          );
        })
        .join('');
      list.querySelectorAll('[data-del]').forEach(function (btn) {
        btn.onclick = async function () {
          if (!confirm('حذف الطلب؟')) return;
          try {
            await A.deletePost(btn.getAttribute('data-del'));
            U.toast('تم الحذف');
            loadProfile();
          } catch (e) {
            U.toast(e.message || String(e), 'error');
          }
        };
      });
    }
    document.getElementById('btnNewPost').onclick = function () {
      location.href = 'create-post.html?type=client_request';
    };
    document.getElementById('btnEditNames').onclick = async function () {
      var fn = prompt('الاسم الأول', u.firstName || '');
      if (fn == null) return;
      var ln = prompt('الاسم', u.lastName || '');
      if (ln == null) return;
      try {
        await A.patchMe({ firstName: fn.trim(), lastName: ln.trim() });
        await Session.refresh();
        U.toast('تم الحفظ');
        loadProfile();
      } catch (e) {
        U.toast(e.message || String(e), 'error');
      }
    };
    document.getElementById('btnEditLoc').onclick = async function () {
      var v = prompt('الموقع / الحي', u.location || '');
      if (v == null) return;
      v = v.trim();
      if (v.length < 2) {
        U.toast('موقع غير صالح', 'error');
        return;
      }
      try {
        await A.patchMe({ location: v });
        await Session.refresh();
        U.toast('تم الحفظ');
        loadProfile();
      } catch (e) {
        U.toast(e.message || String(e), 'error');
      }
    };
  }

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

  async function uploadCin(ev, recto) {
    readFile(ev, async function (dataUrl) {
      try {
        await A.patchMe(recto ? { cinRectoUrl: dataUrl } : { cinVersoUrl: dataUrl });
        U.toast('تم حفظ صور البطاقة.');
        loadProfile();
      } catch (e) {
        U.toast(e.message || String(e), 'error');
      }
    });
  }

  document.getElementById('feedSearchBtn').onclick = loadFeed;
  document.getElementById('feedSort').addEventListener('change', loadFeed);
  var br = document.getElementById('btnRefresh');
  if (br) br.onclick = loadFeed;
  document.getElementById('exSearch').onclick = loadExplore;
  document.getElementById('cinR').addEventListener('change', function (ev) {
    uploadCin(ev, true);
  });
  document.getElementById('cinV').addEventListener('change', function (ev) {
    uploadCin(ev, false);
  });

  (function buildFeedChips() {
    var wrap = document.getElementById('feedChips');
    var hidden = document.getElementById('feedCatKey');
    if (!wrap || !hidden) return;
    var cats = [{ id: '', label: 'الكل' }].concat(
      window.MOROCCAN_TRADES.map(function (t) {
        return { id: t.id, label: t.labelAr };
      })
    );
    wrap.innerHTML = cats
      .map(function (c, i) {
        return (
          '<button type="button" class="feed-chip' +
          (i === 0 ? ' is-on' : '') +
          '" data-cat="' +
          U.escapeHtml(c.id) +
          '">' +
          U.escapeHtml(c.label) +
          '</button>'
        );
      })
      .join('');
    wrap.querySelectorAll('.feed-chip').forEach(function (btn) {
      btn.addEventListener('click', function () {
        wrap.querySelectorAll('.feed-chip').forEach(function (b) {
          b.classList.remove('is-on');
        });
        btn.classList.add('is-on');
        hidden.value = btn.getAttribute('data-cat') || '';
        loadFeed();
      });
    });
  })();
  var ex = document.getElementById('exCat');
  var ox = document.createElement('option');
  ox.value = '';
  ox.textContent = 'الكل';
  ex.appendChild(ox);
  window.MOROCCAN_TRADES.forEach(function (t) {
    var o = document.createElement('option');
    o.value = t.id;
    o.textContent = t.labelAr;
    ex.appendChild(o);
  });

  document.querySelectorAll('.client-web-nav__btn[data-tab]').forEach(function (b) {
    b.addEventListener('click', function () {
      setTab(b.dataset.tab);
    });
  });

  window._aselLoadFeed = loadFeed;

  init();
})();
