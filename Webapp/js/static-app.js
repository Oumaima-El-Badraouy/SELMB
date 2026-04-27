/**
 * API factice — déploiement sans backend (activé par défaut dans config.js).
 * Désactiver l’API réelle : localStorage al_asel_static_app = "0", meta al-asel-static content="0", ou login.html?api=1
 * Connexion : tout email + mot de passe (≥1 car.) ; rôle artisan si l’email contient « artisan » / « حرفي » ou hassan@demo.ma
 */
(function (global) {
  function C() {
    return global.AlAselConfig;
  }

  function parseBody(opts) {
    var b = opts && opts.body;
    if (b == null || b === '') return null;
    if (typeof b === 'string') {
      try {
        return JSON.parse(b);
      } catch (_) {
        return null;
      }
    }
    return b;
  }

  function clone(o) {
    return o == null ? o : JSON.parse(JSON.stringify(o));
  }

  var state = {
    inited: false,
    posts: [],
    artisans: [],
    following: {},
    convMessages: {},
  };

  function nowIso() {
    return new Date().toISOString();
  }

  function initSeed() {
    if (state.inited) return;
    state.inited = true;
    var t = nowIso();
    state.artisans = [
      {
        id: 'static_demo_artisan',
        displayName: 'يوسف الزليج',
        name: 'يوسف الزليج',
        domain: 'zellige',
        category: 'zellige',
        city: 'مديونة',
        available: true,
      },
      {
        id: 'static_demo_artisan_2',
        displayName: 'فاطمة النسيج',
        name: 'فاطمة النسيج',
        domain: 'weaving',
        category: 'weaving',
        city: 'مديونة',
        available: true,
      },
    ];
    state.posts = [
      {
        id: 'seed_svc_zellige',
        userId: 'static_demo_artisan',
        authorId: 'static_demo_artisan',
        authorDisplayName: 'يوسف الزليج',
        authorRole: 'artisan',
        type: 'artisan_service',
        postType: 'service',
        content: 'تركيب وزليج تقليدي — عينات ألوان وضمان على التنفيذ في مديونة.',
        media: null,
        category: 'zellige',
        city: 'مديونة',
        createdAt: t,
        likesCount: 4,
        commentsCount: 1,
        likedByMe: false,
      },
      {
        id: 'seed_svc_plomb',
        userId: 'static_demo_artisan_2',
        authorId: 'static_demo_artisan_2',
        authorDisplayName: 'فاطمة النسيج',
        authorRole: 'artisan',
        type: 'artisan_service',
        postType: 'service',
        content: 'تصليحات منزلية وخدمات نسيج تقليدي — تواصل سريع.',
        media: null,
        category: 'weaving',
        city: 'مديونة',
        createdAt: t,
        likesCount: 2,
        commentsCount: 0,
        likedByMe: false,
      },
      {
        id: 'seed_demand_1',
        userId: 'static_client_demo',
        authorId: 'static_client_demo',
        authorDisplayName: 'علي بناني',
        authorRole: 'client',
        type: 'client_request',
        postType: 'demand',
        content: 'أبحث عن حرفي زليج لحمام صغير — الدار البيضاء قرب مديونة.',
        media: null,
        category: 'zellige',
        city: 'مديونة',
        createdAt: t,
        likesCount: 0,
        commentsCount: 0,
        likedByMe: false,
      },
    ];
  }

  function meUser() {
    var u = C().getStaticMe();
    if (!u) throw new Error('يجب تسجيل الدخول');
    return u;
  }

  function saveMe(partial) {
    var u = clone(meUser());
    Object.assign(u, partial);
    if (!Array.isArray(u.favoritePostIds)) u.favoritePostIds = [];
    C().setStaticMe(u);
    return clone(u);
  }

  function isArtisanEmail(email) {
    var e = String(email || '').toLowerCase();
    return e.indexOf('artisan') >= 0 || e.indexOf('حرفي') >= 0 || e === 'hassan@demo.ma';
  }

  function matchPosts(filters) {
    initSeed();
    var postType = filters.postType || 'all';
    var category = filters.category || '';
    var q = (filters.q || '').trim().toLowerCase();
    var sort = filters.sort || '';
    var list = state.posts.slice();
    if (postType && postType !== 'all') {
      list = list.filter(function (p) {
        if (postType === 'client_request') return p.postType === 'demand' || p.type === 'client_request';
        if (postType === 'artisan_service') return p.postType === 'service' || p.type === 'artisan_service';
        return true;
      });
    }
    if (category) {
      list = list.filter(function (p) {
        return (p.category || '') === category;
      });
    }
    if (q) {
      list = list.filter(function (p) {
        return String(p.content || '')
          .toLowerCase()
          .indexOf(q) >= 0;
      });
    }
    if (sort === 'popular') {
      list.sort(function (a, b) {
        return (b.likesCount || 0) - (a.likesCount || 0);
      });
    }
    return list.map(clone);
  }

  async function handle(path, opts) {
    initSeed();
    var method = String((opts && opts.method) || 'GET').toUpperCase();
    var qIdx = path.indexOf('?');
    var pathname = qIdx >= 0 ? path.slice(0, qIdx) : path;
    var qs = new URLSearchParams(qIdx >= 0 ? path.slice(qIdx + 1) : '');
    var body = parseBody(opts);

    if (pathname === '/auth/login' && method === 'POST') {
      var em = String(body && body.email ? body.email : '').trim().toLowerCase();
      var pw = String(body && body.password ? body.password : '');
      if (!em || !pw) throw new Error('البريد وكلمة المرور مطلوبان.');
      var role = isArtisanEmail(em) ? 'artisan' : 'client';
      var user;
      if (role === 'artisan') {
        user = {
          id: 'static_me_artisan',
          role: 'artisan',
          email: em,
          name: 'حرفي تجريبي',
          displayName: 'حرفي تجريبي',
          firstName: null,
          lastName: null,
          phone: '+212600000000',
          domain: 'plumbing,painting',
          description: 'وضع ثابت — عرض فقط.',
          city: 'مديونة',
          location: 'مديونة',
          favoritePostIds: [],
          photoUrl: null,
          createdAt: nowIso(),
        };
      } else {
        user = {
          id: 'static_me_client',
          role: 'client',
          email: em,
          name: 'زائر تجريبي',
          displayName: 'زائر تجريبي',
          firstName: 'زائر',
          lastName: 'تجريبي',
          phone: '+212610000000',
          city: 'مديونة',
          location: 'مديونة',
          favoritePostIds: [],
          photoUrl: null,
          createdAt: nowIso(),
        };
      }
      C().setToken(C().STATIC_TOKEN_VALUE);
      C().setStaticMe(user);
      return { token: C().STATIC_TOKEN_VALUE, user: clone(user) };
    }

    if (pathname === '/auth/register' && method === 'POST') {
      var roleR = body && body.role;
      if (roleR !== 'client' && roleR !== 'artisan') throw new Error('نوع الحساب غير صالح.');
      var id = 'static_reg_' + Date.now();
      var userR;
      if (roleR === 'client') {
        var fn = String(body.firstName || '').trim();
        var ln = String(body.lastName || '').trim();
        if (!fn || !ln) throw new Error('الاسم الأول والأخير مطلوبان.');
        userR = {
          id: id,
          role: 'client',
          email: String(body.email || '').trim().toLowerCase(),
          firstName: fn,
          lastName: ln,
          name: (fn + ' ' + ln).trim(),
          displayName: (fn + ' ' + ln).trim(),
          phone: String(body.phone || '').trim(),
          location: String(body.location || '').trim() || 'مديونة',
          city: 'مديونة',
          photoUrl: body.photoUrl || null,
          favoritePostIds: [],
          createdAt: nowIso(),
        };
      } else {
        userR = {
          id: id,
          role: 'artisan',
          email: String(body.email || '').trim().toLowerCase(),
          name: String(body.fullName || body.name || '').trim() || 'حرفي',
          displayName: String(body.fullName || body.name || '').trim() || 'حرفي',
          phone: String(body.phone || '').trim(),
          domain: String(body.domain || 'zellige').trim(),
          description: String(body.description || 'وصف تجريبي.').trim(),
          photoUrl: body.photoUrl || null,
          cinRectoUrl: body.cinRectoUrl || 'data:image/png;base64,',
          cinVersoUrl: body.cinVersoUrl || 'data:image/png;base64,',
          city: 'مديونة',
          location: String(body.location || '').trim() || 'مديونة',
          favoritePostIds: [],
          createdAt: nowIso(),
        };
      }
      C().setToken(C().STATIC_TOKEN_VALUE);
      C().setStaticMe(userR);
      return { token: C().STATIC_TOKEN_VALUE, user: clone(userR) };
    }

    if (pathname === '/contact' && method === 'POST') {
      return { ok: true, id: 'static_contact_' + Date.now() };
    }

    if (pathname === '/users/me' && method === 'GET') {
      return clone(meUser());
    }

    if (pathname === '/users/me' && method === 'PATCH') {
      return saveMe(body || {});
    }

    if (pathname === '/posts/feed' && method === 'GET') {
      var filters = {
        postType: qs.get('postType') || 'all',
        category: qs.get('category') || '',
        q: qs.get('q') || '',
        sort: qs.get('sort') || '',
      };
      var items = matchPosts(filters).map(clone);
      return { items: items };
    }

    if (pathname === '/posts/mine' && method === 'GET') {
      var uidM = meUser().id;
      var mine = state.posts
        .filter(function (p) {
          return p.authorId === uidM || p.userId === uidM;
        })
        .map(clone);
      return { items: mine };
    }

    if (pathname === '/users/me/favorite-posts' && method === 'GET') {
      var favIds = meUser().favoritePostIds || [];
      var favPosts = state.posts
        .filter(function (p) {
          return favIds.indexOf(p.id) >= 0;
        })
        .map(clone);
      return { items: favPosts };
    }

    if (pathname === '/posts' && method === 'POST') {
      var uP = meUser();
      var pid = 'p_' + Date.now();
      var typ = (body && body.type) || (body && body.postType) || 'artisan_service';
      var post = {
        id: pid,
        userId: uP.id,
        authorId: uP.id,
        authorDisplayName: uP.displayName || uP.name || '—',
        authorRole: uP.role,
        type: typ,
        postType: typ === 'client_request' || typ === 'demand' ? 'demand' : 'service',
        content: String((body && body.content) || '').trim() || '(منشور)',
        media: (body && body.media) || null,
        category: (body && body.category) || 'general',
        city: (body && body.city) || uP.city || 'مديونة',
        createdAt: nowIso(),
        likesCount: 0,
        commentsCount: 0,
        likedByMe: false,
      };
      state.posts.unshift(post);
      return clone(post);
    }

    var delM = pathname.match(/^\/posts\/([^/]+)$/);
    if (delM && method === 'DELETE') {
      var delId = decodeURIComponent(delM[1]);
      state.posts = state.posts.filter(function (p) {
        return p.id !== delId;
      });
      var uD = meUser();
      uD.favoritePostIds = (uD.favoritePostIds || []).filter(function (x) {
        return x !== delId;
      });
      C().setStaticMe(uD);
      return { ok: true };
    }

    var likeM = pathname.match(/^\/posts\/([^/]+)\/like$/);
    if (likeM && method === 'POST') {
      var lid = decodeURIComponent(likeM[1]);
      var postL = state.posts.find(function (p) {
        return p.id === lid;
      });
      if (!postL) throw new Error('NOT_FOUND');
      postL.likedByMe = !postL.likedByMe;
      postL.likesCount = Math.max(0, (postL.likesCount || 0) + (postL.likedByMe ? 1 : -1));
      return { liked: postL.likedByMe, likesCount: postL.likesCount };
    }

    var favM = pathname.match(/^\/posts\/([^/]+)\/favorite$/);
    if (favM && (method === 'POST' || method === 'DELETE')) {
      var fid = decodeURIComponent(favM[1]);
      var uF = meUser();
      var arr = uF.favoritePostIds || [];
      if (method === 'POST') {
        if (arr.indexOf(fid) < 0) arr.push(fid);
      } else {
        arr = arr.filter(function (x) {
          return x !== fid;
        });
      }
      uF.favoritePostIds = arr;
      C().setStaticMe(uF);
      return { ok: true };
    }

    var comM = pathname.match(/^\/posts\/([^/]+)\/comments$/);
    if (comM && method === 'GET') {
      return { items: [] };
    }
    if (comM && method === 'POST') {
      var cid = decodeURIComponent(comM[1]);
      var pc = state.posts.find(function (p) {
        return p.id === cid;
      });
      if (pc) pc.commentsCount = (pc.commentsCount || 0) + 1;
      return { id: 'c_' + Date.now(), ok: true };
    }

    var likM = pathname.match(/^\/posts\/([^/]+)\/likes$/);
    if (likM && method === 'GET') {
      return { items: [] };
    }

    var followM = pathname.match(/^\/follow\/([^/]+)$/);
    if (followM && method === 'POST') {
      state.following[followM[1]] = true;
      return { ok: true };
    }
    if (followM && method === 'DELETE') {
      delete state.following[followM[1]];
      return { ok: true };
    }

    var statM = pathname.match(/^\/follow\/([^/]+)\/status$/);
    if (statM && method === 'GET') {
      return { following: !!state.following[decodeURIComponent(statM[1])] };
    }

    if (pathname === '/users/me/following' && method === 'GET') {
      var keys = Object.keys(state.following).filter(function (k) {
        return state.following[k];
      });
      return { count: keys.length, items: keys.map(function (id) {
        return { id: id };
      }) };
    }

    var fcM = pathname.match(/^\/artisans\/([^/]+)\/followers-count$/);
    if (fcM && method === 'GET') {
      return { count: 12 };
    }

    if (pathname === '/artisans' && method === 'GET') {
      var cat = qs.get('category') || '';
      var city = qs.get('city') || '';
      var avail = qs.get('available');
      var arrA = state.artisans.filter(function (a) {
        if (cat && (a.domain || a.category) !== cat) return false;
        if (city && String(a.city || '').indexOf(city) < 0) return false;
        if (avail === 'true' && a.available === false) return false;
        return true;
      });
      return { items: arrA.map(clone) };
    }

    var oneArt = pathname.match(/^\/artisans\/([^/]+)$/);
    if (oneArt && method === 'GET' && pathname.indexOf('/full') < 0) {
      var aid = decodeURIComponent(oneArt[1]);
      var found = state.artisans.find(function (a) {
        return a.id === aid;
      });
      if (!found) throw new Error('NOT_FOUND');
      return clone(found);
    }

    var fullArt = pathname.match(/^\/artisans\/([^/]+)\/full$/);
    if (fullArt && method === 'GET') {
      var aidF = decodeURIComponent(fullArt[1]);
      var art = state.artisans.find(function (a) {
        return a.id === aidF;
      });
      if (!art) throw new Error('NOT_FOUND');
      var postsArt = state.posts.filter(function (p) {
        return p.authorId === aidF;
      });
      return {
        user: {
          id: art.id,
          name: art.displayName,
          phone: '+212600000000',
          location: 'مديونة',
          description: 'حرفي تجريبي — وضع ثابت.',
          photoUrl: null,
        },
        profile: {
          displayName: art.displayName,
          bio: 'خبرة في الحرف التقليدية (عرض ثابت).',
          categories: [art.domain || 'zellige'],
          location: 'مديونة',
          avgRating: 4.6,
          reviewCount: 14,
          trustScore: 72,
          portfolio: [],
        },
        posts: postsArt.map(clone),
        stats: {},
      };
    }

    if (pathname.indexOf('/estimate') === 0 && method === 'GET') {
      var catE = (qs.get('category') || 'general').toLowerCase();
      var sqm = parseFloat(qs.get('sqm') || '0') || 0;
      var urg = qs.get('urgency') || '';
      var bands = {
        plumbing: { min: 150, max: 1200 },
        painting: { min: 800, max: 8000, perMin: 25, perMax: 65 },
        zellige: { min: 1200, max: 15000, perMin: 80, perMax: 220 },
        tiling: { min: 1200, max: 15000, perMin: 80, perMax: 220 },
        general: { min: 200, max: 3000 },
      };
      var b = bands[catE] || bands.general;
      var mn = b.min;
      var mx = b.max;
      if (b.perMin && sqm > 0) {
        mn = Math.round(b.perMin * sqm);
        mx = Math.round(b.perMax * sqm);
      }
      if (urg === 'urgent') {
        mn = Math.round(mn * 1.15);
        mx = Math.round(mx * 1.25);
      }
      return {
        currency: 'د.م.',
        min: mn,
        max: mx,
        disclaimer: 'تقدير تقريبي للعرض الثابت — لا يغني عن زيارة الحرفي.',
      };
    }

    if (pathname === '/requests' && method === 'POST') {
      return { id: 'req_' + Date.now(), ok: true };
    }

    if (pathname === '/requests/mine' && method === 'GET') {
      return { items: [] };
    }

    if (pathname.indexOf('/artisans/match') === 0 && method === 'GET') {
      var catM = qs.get('category') || '';
      var sug = state.artisans
        .filter(function (a) {
          return !catM || (a.domain || a.category) === catM;
        })
        .map(function (a) {
          return { artisanId: a.id, id: a.id, displayName: a.displayName, name: a.name };
        });
      return { suggestions: sug.slice(0, 12) };
    }

    if (pathname === '/reports' && method === 'POST') {
      return { ok: true };
    }

    if (pathname === '/users/me/email/request-code' && method === 'POST') {
      return { ok: true, demoCode: '123456' };
    }

    if (pathname === '/users/me/email/verify' && method === 'POST') {
      return { ok: true };
    }

    var peerM = pathname.match(/^\/users\/peer\/([^/]+)\/contact$/);
    if (peerM && method === 'GET') {
      return { email: 'contact@demo.local', phone: '+212600000000' };
    }

    if (pathname === '/conversations' && method === 'GET') {
      return { items: [] };
    }
    if (pathname === '/conversations' && method === 'POST') {
      return { id: 'conv_static_' + Date.now(), peerId: (body && body.peerId) || '' };
    }

    var msgM = pathname.match(/^\/conversations\/([^/]+)\/messages$/);
    if (msgM && method === 'GET') {
      return { items: [] };
    }
    if (msgM && method === 'POST') {
      return { id: 'm_' + Date.now(), ok: true };
    }

    var readM = pathname.match(/^\/conversations\/([^/]+)\/read$/);
    if (readM && method === 'POST') {
      return { ok: true };
    }

    if (pathname === '/posts/media-video' && method === 'POST') {
      throw new Error('رفع الفيديو غير متاح في الوضع الثابت.');
    }

    throw new Error('وضع ثابت: المسار غير مدعوم — ' + pathname);
  }

  global.__staticAlAselFetch = function (path, opts) {
    return Promise.resolve().then(function () {
      return handle(path, opts);
    });
  };
})(typeof window !== 'undefined' ? window : globalThis);
