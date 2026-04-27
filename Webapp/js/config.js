/**
 * Configuration API — alignée sur mobile/lib/core/config/api_config.dart
 * Surcharge : localStorage.al_asel_api_base (URL complète se terminant par /api/v1)
 */
(function (global) {
  const JWT_KEY = 'al_asel_jwt';
  const API_BASE_KEY = 'al_asel_api_base';
  /** Mode démo sans backend : données locales + pas de fetch réseau */
  const STATIC_APP_KEY = 'al_asel_static_app';
  const STATIC_ME_KEY = 'al_asel_static_me';
  /** Jeton factice reconnu par js/static-app.js */
  const STATIC_TOKEN_VALUE = 'al-asel.static.v1';

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
    if (!t) {
      try {
        global.localStorage.removeItem(STATIC_ME_KEY);
      } catch (_) {}
    }
    if (t) global.localStorage.setItem(JWT_KEY, t);
    else global.localStorage.removeItem(JWT_KEY);
  }

  /**
   * Par défaut : mode sans serveur (استضافة ثابتة).
   * Désactiver : localStorage al_asel_static_app = "0", ou meta al-asel-static content="0", ou __AL_ASEL_STATIC__ = false.
   * Forcer sans serveur : "1" / meta "1" / ?static=1 sur login.
   * Forcer API réelle une fois : login.html?api=1 (enregistre "0").
   */
  function isStaticApp() {
    try {
      const v = global.localStorage?.getItem(STATIC_APP_KEY);
      if (v === '0') return false;
      if (v === '1') return true;
    } catch (_) {}
    try {
      const meta = global.document?.querySelector('meta[name="al-asel-static"]');
      const c = meta && String(meta.getAttribute('content') || '').trim();
      if (c === '0') return false;
      if (c === '1') return true;
    } catch (_) {}
    if (global.__AL_ASEL_STATIC__ === false) return false;
    if (global.__AL_ASEL_STATIC__ === true) return true;
    return true;
  }

  function setStaticApp(on) {
    try {
      if (on) {
        global.localStorage.setItem(STATIC_APP_KEY, '1');
        var tok = getToken();
        if (tok && tok !== STATIC_TOKEN_VALUE) {
          setToken(null);
        }
      } else {
        global.localStorage.setItem(STATIC_APP_KEY, '0');
        if (getToken() === STATIC_TOKEN_VALUE) {
          setToken(null);
        }
      }
    } catch (_) {}
  }

  function getStaticMe() {
    try {
      const raw = global.localStorage?.getItem(STATIC_ME_KEY);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch (_) {
      return null;
    }
  }

  function setStaticMe(user) {
    try {
      if (user) global.localStorage.setItem(STATIC_ME_KEY, JSON.stringify(user));
      else global.localStorage.removeItem(STATIC_ME_KEY);
    } catch (_) {}
  }

  function isStaticToken() {
    return getToken() === STATIC_TOKEN_VALUE;
  }

  global.AlAselConfig = {
    JWT_KEY,
    API_BASE_KEY,
    STATIC_APP_KEY,
    STATIC_ME_KEY,
    STATIC_TOKEN_VALUE,
    getApiBase,
    setApiBase,
    apiOrigin,
    getToken,
    setToken,
    isStaticApp,
    setStaticApp,
    getStaticMe,
    setStaticMe,
    isStaticToken,
  };
})(typeof window !== 'undefined' ? window : globalThis);
