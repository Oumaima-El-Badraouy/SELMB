/**
 * Client HTTP — mêmes routes que mobile/lib/data/repositories/marketplace_repository.dart
 */
(function (global) {
  function C() {
    const x = global.AlAselConfig;
    if (!x) throw new Error('Charger config.js avant api.js');
    return x;
  }

  function resolveMedia(media) {
    const m = String(media || '').trim();
    if (!m) return m;
    const origin = C().apiOrigin();
    let ou;
    try {
      ou = new URL(origin);
    } catch {
      return m;
    }
    if (m.startsWith('/')) {
      return origin + m;
    }
    let u;
    try {
      u = new URL(m);
    } catch {
      return m;
    }
    if (u.protocol === 'http:' || u.protocol === 'https:') {
      if (u.pathname.startsWith('/uploads/')) {
        return `${ou.protocol}//${ou.host}${ou.port ? ':' + ou.port : ''}${u.pathname}${u.search || ''}`;
      }
    }
    return m;
  }

  async function apiFetch(path, opts) {
    opts = opts || {};
    if (C().isStaticApp && C().isStaticApp() && typeof global.__staticAlAselFetch === 'function') {
      return global.__staticAlAselFetch(path, opts);
    }
    const base = C().getApiBase().replace(/\/+$/, '');
    const url = path.startsWith('http') ? path : base + (path.startsWith('/') ? path : '/' + path);
    const headers = Object.assign({}, opts.headers || {});
    const token = opts.skipAuth ? null : C().getToken();
    if (token) headers['Authorization'] = 'Bearer ' + token;
    if (opts.json !== false && opts.body && typeof opts.body === 'object' && !(opts.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json';
      opts.body = JSON.stringify(opts.body);
    }
    if (opts.body instanceof FormData) {
      delete headers['Content-Type'];
    }

    let res;
    try {
      res = await fetch(url, Object.assign({}, opts, { headers }));
    } catch (e) {
      const m = (e && e.message) || String(e);
      if (/failed to fetch|networkerror|load failed|fetch/i.test(m) || (e && e.name === 'TypeError')) {
        throw new Error(
          'تعذر الاتصال بالخادم. تأكد أن واجهة API تعمل (مثلاً: npm run dev في مجلد backend، المنفذ 4000). العنوان الحالي: ' +
            base +
            '. يمكنك تعديله أسفل صفحة تسجيل الدخول.'
        );
      }
      throw e;
    }
    const text = await res.text();
    let data = null;
    if (text) {
      try {
        data = JSON.parse(text);
      } catch {
        data = text;
      }
    }
    if (!res.ok) {
      const msg =
        (data && data.message) ||
        (data && data.error) ||
        (typeof data === 'string' ? data : '') ||
        res.statusText;
      throw new Error(msg || 'HTTP ' + res.status);
    }
    return data;
  }

  async function login(email, password) {
    const data = await apiFetch('/auth/login', {
      method: 'POST',
      body: { email, password },
      json: true,
    });
    C().setToken(data.token);
    return data;
  }

  async function registerClient(body) {
    const data = await apiFetch('/auth/register', { method: 'POST', body: Object.assign({ role: 'client' }, body) });
    C().setToken(data.token);
    return data;
  }

  async function registerArtisan(body) {
    const data = await apiFetch('/auth/register', { method: 'POST', body: Object.assign({ role: 'artisan' }, body) });
    C().setToken(data.token);
    return data;
  }

  /** Formulaire « اتصل بنا » — sans en-tête JWT (évite 401 si token expiré ou intermédiaire strict). */
  async function submitContact(body) {
    return apiFetch('/contact', { method: 'POST', body, json: true, skipAuth: true });
  }

  async function me() {
    return apiFetch('/users/me');
  }

  async function patchMe(data) {
    return apiFetch('/users/me', { method: 'PATCH', body: data });
  }

  async function postsFeed(q) {
    const qs = new URLSearchParams();
    if (q.category) qs.set('category', q.category);
    qs.set('postType', q.postType || 'all');
    if (q.sort) qs.set('sort', q.sort);
    if (q.q) qs.set('q', q.q);
    return apiFetch('/posts/feed?' + qs.toString());
  }

  async function myPosts() {
    return apiFetch('/posts/mine');
  }

  async function favoritePosts() {
    return apiFetch('/users/me/favorite-posts');
  }

  async function createPost(body) {
    return apiFetch('/posts', { method: 'POST', body });
  }

  async function deletePost(id) {
    return apiFetch('/posts/' + encodeURIComponent(id), { method: 'DELETE' });
  }

  async function toggleLike(postId) {
    return apiFetch('/posts/' + encodeURIComponent(postId) + '/like', { method: 'POST' });
  }

  async function addFavorite(postId) {
    return apiFetch('/posts/' + encodeURIComponent(postId) + '/favorite', { method: 'POST' });
  }

  async function removeFavorite(postId) {
    return apiFetch('/posts/' + encodeURIComponent(postId) + '/favorite', { method: 'DELETE' });
  }

  async function postComments(postId) {
    return apiFetch('/posts/' + encodeURIComponent(postId) + '/comments');
  }

  async function addComment(postId, text) {
    return apiFetch('/posts/' + encodeURIComponent(postId) + '/comments', {
      method: 'POST',
      body: { text },
    });
  }

  async function postLikers(postId) {
    return apiFetch('/posts/' + encodeURIComponent(postId) + '/likes');
  }

  async function follow(id) {
    return apiFetch('/follow/' + encodeURIComponent(id), { method: 'POST' });
  }

  async function unfollow(id) {
    return apiFetch('/follow/' + encodeURIComponent(id), { method: 'DELETE' });
  }

  async function followStatus(id) {
    return apiFetch('/follow/' + encodeURIComponent(id) + '/status');
  }

  async function myFollowing() {
    return apiFetch('/users/me/following');
  }

  async function followersCount(artisanId) {
    return apiFetch('/artisans/' + encodeURIComponent(artisanId) + '/followers-count');
  }

  async function listArtisans(params) {
    const qs = new URLSearchParams();
    if (params.category) qs.set('category', params.category);
    if (params.city) qs.set('city', params.city);
    if (params.available) qs.set('available', 'true');
    return apiFetch('/artisans?' + qs.toString());
  }

  async function getArtisan(id) {
    return apiFetch('/artisans/' + encodeURIComponent(id));
  }

  async function getArtisanFull(id) {
    return apiFetch('/artisans/' + encodeURIComponent(id) + '/full');
  }

  async function estimate(params) {
    const qs = new URLSearchParams({ category: params.category });
    if (params.sqm != null) qs.set('sqm', String(params.sqm));
    if (params.urgency) qs.set('urgency', params.urgency);
    return apiFetch('/estimate?' + qs.toString());
  }

  async function createRequest(body) {
    return apiFetch('/requests', { method: 'POST', body });
  }

  async function myRequests() {
    return apiFetch('/requests/mine');
  }

  async function matchSuggestions(category, city) {
    const qs = new URLSearchParams({ category });
    if (city) qs.set('city', city);
    return apiFetch('/artisans/match?' + qs.toString());
  }

  async function submitReport(text, category) {
    return apiFetch('/reports', {
      method: 'POST',
      body: { text, category: category || undefined },
    });
  }

  async function requestEmailCode() {
    return apiFetch('/users/me/email/request-code', { method: 'POST' });
  }

  async function verifyEmailCode(code) {
    return apiFetch('/users/me/email/verify', { method: 'POST', body: { code } });
  }

  async function peerContact(peerId) {
    return apiFetch('/users/peer/' + encodeURIComponent(peerId) + '/contact');
  }

  async function openConversation(peerId) {
    return apiFetch('/conversations', { method: 'POST', body: { peerId } });
  }

  async function listConversations() {
    return apiFetch('/conversations');
  }

  async function listMessages(conversationId) {
    return apiFetch('/conversations/' + encodeURIComponent(conversationId) + '/messages');
  }

  async function sendMessage(conversationId, text, audioUrl) {
    const body = {};
    if (text != null && String(text).trim()) body.text = String(text).trim();
    if (audioUrl != null && String(audioUrl).trim()) body.audioUrl = String(audioUrl).trim();
    return apiFetch('/conversations/' + encodeURIComponent(conversationId) + '/messages', {
      method: 'POST',
      body,
    });
  }

  async function markRead(conversationId) {
    return apiFetch('/conversations/' + encodeURIComponent(conversationId) + '/read', { method: 'POST' });
  }

  async function uploadPostVideo(file) {
    const fd = new FormData();
    fd.append('video', file, file.name || 'video.mp4');
    return apiFetch('/posts/media-video', { method: 'POST', body: fd });
  }

  global.AlAselApi = {
    apiFetch,
    resolveMedia,
    login,
    registerClient,
    registerArtisan,
    submitContact,
    me,
    patchMe,
    postsFeed,
    myPosts,
    favoritePosts,
    createPost,
    deletePost,
    toggleLike,
    addFavorite,
    removeFavorite,
    postComments,
    addComment,
    postLikers,
    follow,
    unfollow,
    followStatus,
    myFollowing,
    followersCount,
    listArtisans,
    getArtisan,
    getArtisanFull,
    estimate,
    createRequest,
    myRequests,
    submitReport,
    requestEmailCode,
    verifyEmailCode,
    peerContact,
    openConversation,
    listConversations,
    listMessages,
    sendMessage,
    markRead,
    uploadPostVideo,
    matchSuggestions,
  };
})(typeof window !== 'undefined' ? window : globalThis);
