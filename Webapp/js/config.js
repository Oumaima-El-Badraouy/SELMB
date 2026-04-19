/**
 * Configuration API — alignée sur mobile/lib/core/config/api_config.dart
 * Surcharge : localStorage.al_asel_api_base (URL complète se terminant par /api/v1)
 */
(function (global) {
  const JWT_KEY = 'al_asel_jwt';
  const API_BASE_KEY = 'al_asel_api_base';

  function defaultApiBase() {
    const { protocol, hostname, port } = global.location;
    // Pages ouvertes en file:// : hostname vide — sans ça l’URL devient file:///api/v1 et fetch échoue (« Failed to fetch »).
    if (protocol === 'file:' || !hostname) {
      return `http://127.0.0.1:4000/api/v1`;
    }
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return `http://127.0.0.1:4000/api/v1`;
    }
    if (port) {
      return `${protocol}//${hostname}:4000/api/v1`;
    }
    return `${protocol}//${hostname}/api/v1`;
  }

  function getApiBase() {
    try {
      const o = global.localStorage?.getItem(API_BASE_KEY);
      if (o && o.trim()) return normalizeApiBase(o.trim());
    } catch (_) {}
    return defaultApiBase();
  }

  function setApiBase(url) {
    const u = normalizeApiBase(String(url || '').trim());
    global.localStorage.setItem(API_BASE_KEY, u);
  }

  function normalizeApiBase(raw) {
    let u = raw.replace(/\/+$/, '');
    if (!u) return defaultApiBase();
    if (!u.includes('://')) u = 'http://' + u;
    if (!u.includes('/api/')) u = u + '/api/v1';
    return u;
  }

  function apiOrigin() {
    const u = getApiBase();
    const i = u.indexOf('/api/v1');
    if (i >= 0) return u.slice(0, i);
    const j = u.indexOf('/api/');
    if (j >= 0) return u.slice(0, j);
    return u.replace(/\/+$/, '');
  }

  function getToken() {
    try {
      return global.localStorage?.getItem(JWT_KEY) || null;
    } catch (_) {
      return null;
    }
  }

  function setToken(t) {
    if (t) global.localStorage.setItem(JWT_KEY, t);
    else global.localStorage.removeItem(JWT_KEY);
  }

  global.AlAselConfig = {
    JWT_KEY,
    API_BASE_KEY,
    getApiBase,
    setApiBase,
    apiOrigin,
    getToken,
    setToken,
  };
})(typeof window !== 'undefined' ? window : globalThis);
