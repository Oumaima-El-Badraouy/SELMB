/**
 * Cache utilisateur /me — aligné sur refreshMe (mobile).
 */
(function (global) {
  const S = { user: null };

  async function refresh() {
    const A = global.AlAselApi;
    const cfg = global.AlAselConfig;
    if (!A || !cfg || !cfg.getToken()) {
      S.user = null;
      return null;
    }
    if (cfg.isStaticApp && cfg.isStaticApp() && cfg.isStaticToken && cfg.isStaticToken()) {
      const sm = cfg.getStaticMe && cfg.getStaticMe();
      if (!sm) {
        cfg.setToken(null);
        S.user = null;
        return null;
      }
    }
    S.user = await A.me();
    return S.user;
  }

  async function ensure() {
    if (!S.user) await refresh();
    return S.user;
  }

  function clear() {
    S.user = null;
  }

  function getUser() {
    return S.user;
  }

  global.AlAselSession = { refresh, ensure, clear, getUser };
})(typeof window !== 'undefined' ? window : globalThis);
