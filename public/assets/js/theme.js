(() => {
  'use strict';
  const $ = (sel, root = document) => root.querySelector(sel);
  const THEME_KEY = 'smartcoachpro_theme';
  const docEl = document.documentElement;

  function applyTheme(mode) {
    if (mode !== 'light' && mode !== 'dark') mode = 'dark';
    docEl.setAttribute('data-theme', mode);
    docEl.setAttribute('data-theme-mode', mode);
    const targetLogo = mode === 'dark' ? 'assets/img/logo-dark.png' : 'assets/img/logo-light.png';
    document.querySelectorAll('.brand__logo, .splash__logo, .sidebar-logo').forEach(img => img.src = targetLogo);
    const favicon = document.getElementById('favicon');
    if (favicon) favicon.href = targetLogo;
    const backToTopImg = document.getElementById('backToTopImg');
    if (backToTopImg) backToTopImg.src = mode === 'dark' ? 'assets/img/dark.png' : 'assets/img/light.png';
    document.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: mode } }));
  }

  window.SmartCoachTheme = {
    load: () => applyTheme(localStorage.getItem(THEME_KEY) || 'dark'),
    cycle: () => {
      const current = docEl.getAttribute('data-theme-mode') || 'dark';
      const next = current === 'dark' ? 'light' : 'dark';
      localStorage.setItem(THEME_KEY, next);
      applyTheme(next);
    },
    bindButtons: () => {
      const btn1 = $('#themeBtn');
      const btn2 = $('#themeBtn2');
      const btn3 = $('#dashboardThemeToggle');
      const setLabel = () => {
        const mode = docEl.getAttribute('data-theme-mode') || 'dark';
        if (btn1) {
          btn1.querySelector('.iconBtn__icon').textContent = mode === 'dark' ? '☀' : '☾';
          btn1.querySelector('.iconBtn__text').textContent = mode === 'dark' ? 'Light' : 'Dark';
        }
      };
      [btn1, btn2, btn3].filter(Boolean).forEach(btn => btn.addEventListener('click', (e) => {
        if (btn === btn3) e.preventDefault();
        window.SmartCoachTheme.cycle();
        setLabel();
      }));
      setLabel();
    }
  };
})();