(() => {
  'use strict';
  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  function bindMobileMenu() {
    const ham = $('#hamburger'), menu = $('#mobileMenu');
    if (!ham || !menu) return;
    const setOpen = (open) => { ham.setAttribute('aria-expanded', String(open)); menu.hidden = !open; };
    ham.addEventListener('click', () => setOpen(ham.getAttribute('aria-expanded') !== 'true'));
    $$('.mobileMenu__link', menu).forEach(link => link.addEventListener('click', () => setOpen(false)));
    document.addEventListener('click', (e) => { if (!menu.hidden && !menu.contains(e.target) && !ham.contains(e.target)) setOpen(false); });
  }

  function bindScrollBehavior() {
    const header = $('#topbar'), videoSticky = $('.videoHero__sticky');
    let lastY = 0;
    window.addEventListener('scroll', () => {
      const y = window.scrollY, dirDown = y > lastY;
      if (header) {
        if (y > 10) {
          header.classList.add('is-scrolled');
          header.classList.toggle('is-hidden', dirDown && y > 100);
        } else {
          header.classList.remove('is-scrolled', 'is-hidden');
        }
      }
      lastY = y;
    }, { passive: true });
  }

  function bindSmoothScroll() {
    const headerOffset = () => parseInt(getComputedStyle(document.documentElement).getPropertyValue('--headerH') || '78', 10);
    const scrollTo = (id) => {
      const el = document.getElementById(id);
      if (!el) return;
      window.scrollTo({ top: el.getBoundingClientRect().top + window.pageYOffset - headerOffset() - 10, behavior: 'smooth' });
    };
    $$('a[data-scroll][href^="#"]').forEach(a => a.addEventListener('click', (e) => {
      const id = a.getAttribute('href').slice(1);
      if (!id) return;
      e.preventDefault(); scrollTo(id);
      const ham = $('#hamburger'); if (ham && ham.getAttribute('aria-expanded') === 'true') ham.click();
      history.pushState(null, '', '#' + id);
    }));
    if (location.hash.length > 1) setTimeout(() => scrollTo(location.hash.slice(1)), 60);
  }

  function bindBackToTop() {
    const btn = $('#backToTop'); if (!btn) return;
    window.addEventListener('scroll', () => btn.classList.toggle('is-visible', window.scrollY > 400), { passive: true });
    btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  }

  window.SmartCoachNav = { init: () => { bindMobileMenu(); bindScrollBehavior(); bindSmoothScroll(); bindBackToTop(); } };
})();