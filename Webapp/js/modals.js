/**
 * Modales type bottom-sheet — commentaires, j’aime (mobile: PostCommentsSheet, PostLikersSheet).
 */
(function (global) {
  const U = global.AlAselUi;
  const A = global.AlAselApi;

  function closeOnBackdrop(root, inner) {
    root.addEventListener('click', function (ev) {
      if (ev.target === root) root.remove();
    });
    inner.querySelector('.asel-sheet-close')?.addEventListener('click', function () {
      root.remove();
    });
  }

  function openLikers(postId) {
    const root = document.createElement('div');
    root.className = 'modal-backdrop';
    root.innerHTML =
      '<div class="modal-sheet modal-sheet--tall asel-sheet-inner">' +
      '<div class="asel-sheet-head"><strong>إعجابات</strong><button type="button" class="icon-btn asel-sheet-close">×</button></div>' +
      '<div class="asel-sheet-body" id="likersBody">…</div></div>';
    document.body.appendChild(root);
    const inner = root.querySelector('.asel-sheet-inner');
    closeOnBackdrop(root, inner);
    A.postLikers(postId)
      .then(function (data) {
        const items = data.items || [];
        const body = root.querySelector('#likersBody');
        if (!items.length) {
          body.innerHTML = '<p class="empty-hint">لا أحد بعد.</p>';
          return;
        }
        body.innerHTML = items
          .map(function (x) {
            const name =
              [x.firstName, x.lastName].filter(Boolean).join(' ').trim() ||
              x.displayName ||
              x.name ||
              'مستخدم';
            const role = x.role === 'artisan' ? 'حرفي' : x.role === 'client' ? 'زبون' : '';
            return (
              '<div class="comment-line"><strong>' +
              U.escapeHtml(name) +
              '</strong>' +
              (role ? ' <span style="color:var(--muted);font-size:0.8rem">' + U.escapeHtml(role) + '</span>' : '') +
              '</div>'
            );
          })
          .join('');
      })
      .catch(function (e) {
        root.querySelector('#likersBody').textContent = e.message || String(e);
      });
  }

  function displayNameLine(c) {
    const fn = (c.authorFirstName || '').trim();
    const ln = (c.authorLastName || '').trim();
    if (fn || ln) return (fn + ' ' + ln).trim();
    return c.authorDisplayName || 'مستخدم';
  }

  function openComments(postId, ctx) {
    ctx = ctx || {};
    const me =
      ctx.user ||
      (global.AlAselSession && typeof global.AlAselSession.getUser === 'function' && global.AlAselSession.getUser());
    const meId = me && me.id;
    const meRole = me && me.role;

    const root = document.createElement('div');
    root.className = 'modal-backdrop';
    root.innerHTML =
      '<div class="modal-sheet modal-sheet--tall asel-sheet-inner">' +
      '<div class="asel-sheet-head"><strong>التعليقات</strong><button type="button" class="icon-btn asel-sheet-close">×</button></div>' +
      '<div class="asel-sheet-body" id="comBody">…</div>' +
      '<div class="asel-sheet-footer" id="comFoot"></div></div>';
    document.body.appendChild(root);
    const inner = root.querySelector('.asel-sheet-inner');
    closeOnBackdrop(root, inner);

    const canWrite = me && (me.role === 'client' || me.role === 'artisan');
    const foot = root.querySelector('#comFoot');
    if (canWrite) {
      foot.innerHTML =
        '<p style="font-size:0.82rem;color:var(--muted);margin:0 0 6px">تعليقات عامة على هذا المنشور</p>' +
        '<div style="display:flex;gap:8px"><input type="text" id="comInp" class="com-inp" placeholder="أضف تعليقاً…" style="flex:1" />' +
        '<button type="button" class="btn btn-primary" id="comSend">إرسال</button></div>';
    } else {
      foot.innerHTML = '<p class="empty-hint" style="padding:8px">سجّل دخولك كزبون أو حرفي للتعليق.</p>';
    }

    function canChat(c) {
      if (!meId || c.userId === meId) return false;
      const ar = c.authorRole;
      if (meRole === 'client' && ar === 'artisan') return true;
      if (meRole === 'artisan' && ar === 'client') return true;
      return false;
    }

    function canFollow(c) {
      return meRole === 'client' && c.authorRole === 'artisan' && c.userId !== meId;
    }

    async function load() {
      const body = root.querySelector('#comBody');
      try {
        const data = await A.postComments(postId);
        const items = data.items || [];
        if (!items.length) {
          body.innerHTML = '<p class="empty-hint">لا تعليقات. كن أول من يعلق.</p>';
          return;
        }
        body.innerHTML = items
          .map(function (c) {
            const name = U.escapeHtml(displayNameLine(c));
            const roleLabel =
              c.authorRole === 'artisan' ? 'حرفي' : c.authorRole === 'client' ? 'زبون' : '';
            const chat =
              canChat(c) ?
                '<a class="btn btn-outline" style="padding:4px 10px;font-size:0.78rem" href="chat.html?peer=' +
                encodeURIComponent(c.userId) +
                '&name=' +
                encodeURIComponent(displayNameLine(c)) +
                '">رسالة</a>'
              : '';
            const fol =
              canFollow(c) ?
                '<button type="button" class="btn btn-outline as-fl" data-uid="' +
                U.escapeHtml(c.userId) +
                '" style="padding:4px 10px;font-size:0.78rem">متابعة</button>'
              : '';
            return (
              '<div class="comment-line" style="padding:10px 0;border-bottom:1px solid rgba(0,0,0,0.06)">' +
              '<div style="display:flex;justify-content:space-between;gap:8px;align-items:flex-start">' +
              '<div><strong>' +
              name +
              '</strong>' +
              (roleLabel ?
                ' <span style="color:var(--muted);font-size:0.75rem">' +
                U.escapeHtml(roleLabel) +
                '</span>'
              : '') +
              '<div style="margin-top:6px;white-space:pre-wrap">' +
              U.escapeHtml(c.text || '') +
              '</div></div>' +
              '<div style="display:flex;flex-direction:column;gap:4px;flex-shrink:0">' +
              chat +
              fol +
              '</div></div>'
            );
          })
          .join('');
        body.querySelectorAll('.as-fl').forEach(function (btn) {
          btn.addEventListener('click', async function () {
            const uid = btn.getAttribute('data-uid');
            try {
              const st = await A.followStatus(uid);
              if (st.following) {
                await A.unfollow(uid);
                U.toast('تم إلغاء المتابعة');
              } else {
                await A.follow(uid);
                U.toast('أنت تتابع هذا الحرفي');
              }
              if (ctx.onFollowToggled) ctx.onFollowToggled(uid);
              load();
            } catch (e) {
              U.toast(e.message || String(e), 'error');
            }
          });
        });
      } catch (e) {
        body.textContent = e.message || String(e);
      }
    }

    root.querySelector('#comSend')?.addEventListener('click', async function () {
      const inp = root.querySelector('#comInp');
      const t = (inp && inp.value.trim()) || '';
      if (!t) return;
      try {
        await A.addComment(postId, t);
        inp.value = '';
        if (ctx.onCommentAdded) ctx.onCommentAdded();
        load();
      } catch (e) {
        U.toast(e.message || String(e), 'error');
      }
    });

    load();
  }

  global.AlAselModals = { openLikers, openComments };
})(typeof window !== 'undefined' ? window : globalThis);
