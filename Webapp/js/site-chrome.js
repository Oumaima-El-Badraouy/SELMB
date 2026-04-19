/**
 * شريط تنقل + تذييل موحّد (عربي، شعار الأصل، نفس الألوان).
 * body[data-nav-active="home|about|contact|auth|app"]
 */
(function (global) {
  function navHtml(active) {
    function cls(key) {
      return key === active ? ' is-active' : '';
    }
    return (
      '<nav class="site-nav-wrap" aria-label="التنقل الرئيسي">' +
      '<div class="site-nav-inner">' +
      '<a class="site-brand site-brand--mark-only" href="index.html" aria-label="الأصل">' +
      '<img src="assets/branding/logo_al_asel.png" width="64" height="64" alt="" />' +
      '</a>' +
      '<div class="site-links">' +
      '<a href="index.html#hero" class="' +
      cls('home') +
      '">الرئيسية</a>' +
      '<a href="about.html" class="' +
      cls('about') +
      '">من نحن</a>' +
      '<a href="contact.html" class="' +
      cls('contact') +
      '">اتصل بنا</a>'  +
      '</div>' +
      '<div class="site-actions">' +
      '<a href="login.html" class="site-btn site-btn--outline">تسجيل الدخول</a>' +
      '<a href="index.html#register" class="site-btn site-btn--primary">إنشاء حساب</a>' +
      '<a href="mobile-app.html" class="site-btn site-btn--gold" title="للمستخدمين المسجّلين">دخول التطبيق</a>' +
      '</div></div></nav>'
    );
  }

  function footerHtml() {
    return (
      '<footer class="site-footer">' +
      '<div class="site-footer-inner">' +
      '<div><h3>الأصل</h3><p>منصة تربط سكّان مديونة بالحرفيين والخدمات التقليدية، بثقة وبألوان الزليج والزربية.</p></div>' +
      '<div><h3>روابط</h3><p><a href="index.html#about">من نحن</a><br /><a href="contact.html">اتصل بنا</a><br /><a href="mobile-app.html">تطبيق الجوال</a><br /><a href="login.html">تسجيل الدخول</a></p></div>' +
      '<div><h3>تسجيل</h3><p><a href="register-client.html">حساب زبون</a><br /><a href="register-artisan.html">حساب حرفي</a><br /><a href="app.html">فتح التطبيق</a></p></div>' +
      '</div>' +
      '<div class="site-footer-copy">© الأصل — مديونة. جميع الحقوق محفوظة.</div></footer>'
    );
  }

  function mount() {
    var active = (document.body && document.body.getAttribute('data-nav-active')) || 'home';
    var navRoot = document.getElementById('site-nav-root');
    var footRoot = document.getElementById('site-footer-root');
    if (navRoot) navRoot.innerHTML = navHtml(active);
    if (footRoot) footRoot.innerHTML = footerHtml();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }

  global.AlAselSiteChrome = { mount };
})(typeof window !== 'undefined' ? window : globalThis);
