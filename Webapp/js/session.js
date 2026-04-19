/**
 * Cache utilisateur /me — aligné sur refreshMe (mobile).
 */
(function (global) {
  const S = { user: null };

  async function refresh() {
    const A = global.AlAselApi;
    if (!A || !global.AlAselConfig.getToken()) {
      S.user = null;
      return null;
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
