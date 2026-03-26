(() => {
  'use strict';
  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  function runSplash() {
    const splash = $('#splash'); if (!splash) return;
    const bar = splash.querySelector('.splash__meterBar');
    let p = 0;
    const tick = () => {
      p = Math.min(92, p + Math.random() * 10);
      if (bar) bar.style.width = p + '%';
      if (p >= 92) {
        setTimeout(() => {
          if (bar) bar.style.width = '100%';
          setTimeout(() => { splash.classList.add('is-hidden'); setTimeout(() => splash.remove(), 650); }, 350);
        }, 180);
        return;
      }
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  function initCanvasFx() {
    const canvas = $('#fx'); if (!canvas) return;
    const ctx = canvas.getContext('2d');
    let w, h, dpr, particles = [];
    const resize = () => {
      dpr = Math.min(2, window.devicePixelRatio || 1);
      w = canvas.width = window.innerWidth * dpr;
      h = canvas.height = window.innerHeight * dpr;
      canvas.style.width = window.innerWidth + 'px'; canvas.style.height = window.innerHeight + 'px';
    };
    const seed = () => {
      const isLight = document.documentElement.getAttribute('data-theme') === 'light';
      particles = Array.from({ length: 70 }, () => ({
        x: Math.random() * w, y: Math.random() * h, vx: (Math.random() - 0.5) * dpr, vy: (Math.random() - 0.5) * dpr, r: (1 + Math.random() * 2) * dpr, a: 0.1 + Math.random() * 0.2,
        hue: isLight ? (Math.random() > 0.5 ? 45 : 0) : 45, sat: isLight ? 95 : 95, lum: isLight ? 55 : 55
      }));
    };
    const step = () => {
      ctx.clearRect(0, 0, w, h);
      const isLight = document.documentElement.getAttribute('data-theme') === 'light';
      particles.forEach((p, i) => {
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0) p.x = w; if (p.x > w) p.x = 0; if (p.y < 0) p.y = h; if (p.y > h) p.y = 0;
        ctx.fillStyle = `hsla(${p.hue}, ${p.sat}%, ${p.lum}%, ${p.a})`;
        ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2); ctx.fill();
        for (let j = i + 1; j < particles.length; j++) {
          const q = particles[j], dist = Math.hypot(p.x - q.x, p.y - q.y);
          if (dist < 150 * dpr) {
            ctx.strokeStyle = `rgba(255,184,0,${(1 - dist / (150 * dpr)) * 0.15})`;
            ctx.beginPath(); ctx.moveTo(p.x, p.y); ctx.lineTo(q.x, q.y); ctx.stroke();
          }
        }
      });
      requestAnimationFrame(step);
    };
    window.addEventListener('resize', () => { resize(); seed(); });
    document.addEventListener('themeChanged', seed);
    resize(); seed(); step();
  }

  function bindReveal() {
    const io = new IntersectionObserver(entries => {
      entries.forEach(ent => { if (ent.isIntersecting) { ent.target.classList.add('is-in'); io.unobserve(ent.target); } });
    }, { threshold: 0.14 });
    $$('.reveal').forEach(el => io.observe(el));
  }

  function bindCounters() {
    const io = new IntersectionObserver(entries => {
      entries.forEach(ent => {
        if (ent.isIntersecting) {
          const el = ent.target, to = Number(el.dataset.count), dur = 1000, start = performance.now();
          const step = (now) => {
            const t = Math.min(1, (now - start) / dur);
            el.textContent = Math.floor(to * t);
            if (t < 1) requestAnimationFrame(step);
          };
          requestAnimationFrame(step);
          io.unobserve(el);
        }
      });
    }, { threshold: 0.4 });
    $$('[data-count]').forEach(el => io.observe(el));
  }

  function bindParallax() {
    const slogan = $('#heroSlogan'), overlay = $('.videoHero__overlay');
    window.addEventListener('scroll', () => {
      const y = window.scrollY, prog = Math.min(1, y / 800);
      if (slogan) slogan.style.transform = `translate3d(0, ${y * 0.2}px,0)`;
      if (overlay) overlay.style.opacity = 0.55 + prog * 0.3;
    }, { passive: true });
  }

  class FeatureManager {
    constructor() {
      this.modal = $('#feature-modal'); this.content = $('#feature-detail-content');
      $$('.featureCard').forEach((card, i) => card.addEventListener('click', () => this.open(i)));
      $('#close-feature')?.addEventListener('click', () => this.close());
    }
    open(i) {
      this.content.innerHTML = '<h2>Feature ' + i + '</h2><p>Dtails...</p>'; // Generic for now, but I will keep the actual data in final.
      this.modal.classList.add('is-visible');
    }
    close() { this.modal.classList.remove('is-visible'); }
  }

  // --- Boot ---
  const boot = () => {
    window.SmartCoachTheme?.load();
    window.SmartCoachTheme?.bindButtons();
    runSplash();
    window.SmartCoachNav?.init();
    initCanvasFx();
    bindReveal();
    bindCounters();
    bindParallax();
    window.SmartCoachQuiz?.init();
    new FeatureManager();
    if ($('#year')) $('#year').textContent = new Date().getFullYear();
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
})();