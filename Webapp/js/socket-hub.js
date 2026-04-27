/**
 * Socket.IO — même origine que l’API (mobile/lib/core/realtime/socket_hub.dart).
 * Nécessite la lib globale `io` (script CDN socket.io client).
 */
(function (global) {
  let socket = null;
  let boundUid = '';
  const joined = new Set();
  const msgHandlers = [];
  let inboxHandler = null;

  function origin() {
    return global.AlAselConfig.apiOrigin();
  }

  function connect(uid) {
    if (!uid || !global.io) return;
    if (global.AlAselConfig && global.AlAselConfig.isStaticApp && global.AlAselConfig.isStaticApp()) return;
    if (boundUid === uid && socket && socket.connected) return;
    disconnect();
    boundUid = uid;
    socket = global.io(origin(), {
      transports: ['websocket'],
      reconnectionAttempts: 10,
      reconnectionDelay: 1000,
    });
    socket.on('connect', function () {
      socket.emit('join_user', uid);
      joined.forEach(function (cid) {
        socket.emit('join_conversation', cid);
      });
    });
    socket.on('inbox_ping', function (raw) {
      if (typeof inboxHandler === 'function') inboxHandler(raw);
    });
    socket.on('new_message', function (data) {
      msgHandlers.slice().forEach(function (h) {
        try {
          h(data);
        } catch (_) {}
      });
    });
  }

  function disconnect() {
    try {
      if (socket) socket.disconnect();
    } catch (_) {}
    socket = null;
    boundUid = '';
    joined.clear();
  }

  function joinConversation(cid) {
    if (!cid) return;
    const wasNew = !joined.has(cid);
    joined.add(cid);
    if (wasNew && socket && socket.connected) socket.emit('join_conversation', cid);
  }

  function leaveConversation(cid) {
    if (!cid) return;
    joined.delete(cid);
    if (socket && socket.connected) socket.emit('leave_conversation', cid);
  }

  function onInboxPing(fn) {
    inboxHandler = fn;
  }

  function addNewMessageListener(fn) {
    msgHandlers.push(fn);
    return function () {
      const i = msgHandlers.indexOf(fn);
      if (i >= 0) msgHandlers.splice(i, 1);
    };
  }

  global.AlAselSocket = {
    connect,
    disconnect,
    joinConversation,
    leaveConversation,
    onInboxPing,
    addNewMessageListener,
  };
})(typeof window !== 'undefined' ? window : globalThis);
