(function (global) {
  const U = global.AlAselUi;
  const A = global.AlAselApi;
  const Cat = global.AlAselCategories;
  const Mod = global.AlAselModals;
  const Session = global.AlAselSession;

  function postIsService(p) {
    const t = p.type || p.postType;
    return t === 'artisan_service' || t === 'service';
  }

  function postIsDemand(p) {
    const t = p.type || p.postType;
    return t === 'client_request' || t === 'demand';
  }

  function authorId(p) {
    return p.userId || p.authorId || '';
  }

  function likeSvg(liked) {
    if (liked) {
      return '<svg class="post-action-svg" width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>';
    }
    return '<svg class="post-action-svg" width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="1.75" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>';
  }

  function commentSvg() {
    return '<svg class="post-action-svg" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>';
  }

  function starSvg(filled) {
    if (filled) {
      return '<svg class="post-action-svg" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l8.91-1.01L12 2z"/></svg>';
    }
    return '<svg class="post-action-svg" width="18" height="18" viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';
  }

  function mediaHtml(p) {
    const m = p.media;
    if (!m) return '';
    const url = A.resolveMedia(m);
    if (!url) return '';
    if (url.startsWith('data:image') || /\.(jpe?g|png|gif|webp)(\?|$)/i.test(url)) {
      return `<img class="media-preview" src="${U.escapeHtml(url)}" alt="" loading="lazy" />`;
    }
    return `<video class="media-preview" src="${U.escapeHtml(url)}" controls playsinline></video>`;
  }

  function avatarHtml(p, profileHref) {
    const ph = p.authorPhotoUrl;
    const inner =
      ph ?
        `<img class="avatar" src="${U.escapeHtml(A.resolveMedia(ph))}" alt="" />`
      : (() => {
          const name = (p.authorDisplayName || '?').trim();
          const ch = name.charAt(0) || '?';
          return `<div class="avatar" style="display:flex;align-items:center;justify-content:center;font-weight:800;color:var(--deep-blue)">${U.escapeHtml(ch)}</div>`;
        })();
    if (profileHref) {
      return `<a href="${profileHref}" class="post-avatar-link">${inner}</a>`;
    }
    return inner;
  }

  async function batchFollowStatus(ids) {
    const map = {};
    const uniq = [...new Set(ids.filter(Boolean))];
    await Promise.all(
      uniq.map(async (id) => {
        try {
          const st = await A.followStatus(id);
          map[id] = !!(st && st.following);
        } catch (_) {
          map[id] = false;
        }
      })
    );
    return map;
  }

  /**
   * @param {HTMLElement} el
   * @param {object[]} posts
   * @param {{
   *   role: string,
   *   meId?: string,
   *   onRefresh?: () => void,
   *   user?: object
   * }} ctx
   */
  async function renderPosts(el, posts, ctx) {
    if (!posts.length) {
      el.innerHTML = '<p class="empty-hint">لا توجد منشورات حالياً.</p>';
      return;
    }

    const u = ctx.user || (Session && typeof Session.getUser === 'function' && Session.getUser()) || {};
    const favSet = new Set(u.favoritePostIds || []);

    const followIds = [];
    if (ctx.role === 'client' && ctx.meId) {
      for (const p of posts) {
        const aid = authorId(p);
        if (postIsService(p) && aid && aid !== ctx.meId) followIds.push(aid);
      }
    }
    const followMap = ctx.role === 'client' && followIds.length ? await batchFollowStatus(followIds) : {};

    const canEngage = u.id && (ctx.role === 'client' || ctx.role === 'artisan');

    el.innerHTML = posts
      .map((p) => {
        const demand = postIsDemand(p);
        const aid = authorId(p);
        const isMine = ctx.meId && aid === ctx.meId;
        const profileHref = aid ? `artisan-profile.html?id=${encodeURIComponent(aid)}` : '';
        const canMsg = ctx.role === 'client' && aid && postIsService(p);
        const chatUrl =
          canMsg && aid ?
            `chat.html?peer=${encodeURIComponent(aid)}&name=${encodeURIComponent(p.authorDisplayName || '')}`
          : '';

        let followBtn = '';
        if (ctx.role === 'client' && !isMine && postIsService(p) && aid) {
          const fwing = followMap[aid];
          followBtn =
            '<button type="button" class="btn-follow ' +
            (fwing ? 'is-following' : '') +
            '" data-follow="' +
            U.escapeHtml(aid) +
            '">' +
            (fwing ? 'متابَع' : 'متابعة') +
            '</button>';
        }

        const isFav = favSet.has(p.id);
        const favHtml =
          '<span class="post-tool-inner">' + starSvg(isFav) + '<span class="post-tool-text">' + (isFav ? 'في المفضلة' : 'مفضلة') + '</span></span>';

        const cityLine =
          p.city ?
            '<div class="post-city">' + U.escapeHtml(p.city) + '</div>'
          : '';

        const catHash =
          p.category ?
            '<div class="post-cathash">#' + U.escapeHtml(Cat.categoryLabel(p.category)) + '</div>'
          : '';

        return `
        <article class="card post-card post-card--rich" data-post-id="${U.escapeHtml(p.id)}">
          <div class="post-head">
            ${avatarHtml(p, profileHref)}
            <div class="post-head-main">
              <div class="post-author-line">
                ${
                  profileHref ?
                    `<a class="post-author-name" href="${profileHref}">${U.escapeHtml(p.authorDisplayName || '—')}</a>`
                  : `<span class="post-author-name">${U.escapeHtml(p.authorDisplayName || '—')}</span>`
                }
                <div class="post-head-actions">${followBtn}${cityLine}</div>
              </div>
              ${catHash}
            </div>
          </div>
          <div class="post-content">${U.escapeHtml(p.content || '')}</div>
          ${mediaHtml(p)}
          <div class="post-toolbar">
            ${
              canEngage ?
                `<span class="post-like-wrap">
              <button type="button" class="icon-like post-icon-btn as-like ${p.likedByMe ? 'is-liked' : ''}" data-id="${U.escapeHtml(p.id)}" aria-label="إعجاب">${likeSvg(!!p.likedByMe)}</button>
              <button type="button" class="as-likers linkish" data-id="${U.escapeHtml(p.id)}">${p.likesCount ?? 0}</button>
            </span>`
              : ''
            }
            ${
              canEngage ?
                `<button type="button" class="post-tool as-comments" data-id="${U.escapeHtml(p.id)}">
              ${commentSvg()}<span class="post-tool-text">${p.commentsCount ?? 0}</span>
            </button>`
              : ''
            }
            ${
              canEngage ?
                `<button type="button" class="post-tool as-fav ${isFav ? 'is-fav' : ''}" data-id="${U.escapeHtml(p.id)}">${favHtml}</button>`
              : ''
            }
            ${chatUrl ? `<a class="post-tool" href="${chatUrl}">رسالة</a>` : ''}
            ${ctx.meId && isMine ? `<button type="button" class="post-tool as-del" data-id="${U.escapeHtml(p.id)}">حذف</button>` : ''}
          </div>
        </article>`;
      })
      .join('');

    el.querySelectorAll('.as-like').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const id = btn.getAttribute('data-id');
        try {
          const r = await A.toggleLike(id);
          btn.innerHTML = likeSvg(!!r.liked);
          btn.classList.toggle('is-liked', !!r.liked);
          const n = btn.parentElement && btn.parentElement.querySelector('.as-likers');
          if (n) n.textContent = String(r.likesCount ?? 0);
          ctx.onRefresh && ctx.onRefresh();
        } catch (e) {
          U.toast(String(e.message || e), 'error');
        }
      });
    });

    el.querySelectorAll('.as-likers').forEach((btn) => {
      btn.addEventListener('click', () => {
        Mod.openLikers(btn.getAttribute('data-id'));
      });
    });

    el.querySelectorAll('.as-fav').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const id = btn.getAttribute('data-id');
        try {
          const cur = Session.getUser();
          const set = new Set((cur && cur.favoritePostIds) || []);
          if (set.has(id)) {
            await A.removeFavorite(id);
            U.toast('أزيل من المفضلة');
          } else {
            await A.addFavorite(id);
            U.toast('أضيف للمفضلة');
          }
          await Session.refresh();
          ctx.onRefresh && ctx.onRefresh();
        } catch (e) {
          U.toast(String(e.message || e), 'error');
        }
      });
    });

    el.querySelectorAll('.as-del').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const id = btn.getAttribute('data-id');
        if (!confirm('حذف المنشور؟')) return;
        try {
          await A.deletePost(id);
          U.toast('تم الحذف');
          ctx.onRefresh && ctx.onRefresh();
        } catch (e) {
          U.toast(String(e.message || e), 'error');
        }
      });
    });

    el.querySelectorAll('.as-comments').forEach((btn) => {
      btn.addEventListener('click', () => {
        const id = btn.getAttribute('data-id');
        Mod.openComments(id, {
          user: Session.getUser(),
          onCommentAdded: function () {
            ctx.onRefresh && ctx.onRefresh();
          },
          onFollowToggled: function () {
            ctx.onRefresh && ctx.onRefresh();
          },
        });
      });
    });

    el.querySelectorAll('[data-follow]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const id = btn.getAttribute('data-follow');
        try {
          const st = await A.followStatus(id);
          if (st.following) {
            await A.unfollow(id);
            U.toast('تم إلغاء المتابعة');
            btn.textContent = 'متابعة';
            btn.classList.remove('is-following');
          } else {
            await A.follow(id);
            U.toast('أنت تتابع هذا الحرفي');
            btn.textContent = 'متابَع';
            btn.classList.add('is-following');
          }
          ctx.onRefresh && ctx.onRefresh();
        } catch (e) {
          U.toast(String(e.message || e), 'error');
        }
      });
    });
  }

  global.AlAselFeed = { renderPosts, postIsDemand, postIsService, authorId };
})(typeof window !== 'undefined' ? window : globalThis);
