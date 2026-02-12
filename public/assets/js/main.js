/* =========================================================
   SmartCoachPro — main.js
   - Splash loading
   - Theme toggle (dark/light/auto)
   - Canvas background particles (lightweight)
   - Scroll reveal + counters
   - Sparklines + bars
   - Modal waitlist (localStorage demo)
   - Mobile menu + back-to-top
   ========================================================= */

(() => {
  'use strict';

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  /* -----------------------
     Theme (dark/light only, no auto)
     ----------------------- */
  const THEME_KEY = 'smartcoachpro_theme'; // "dark" | "light"
  const docEl = document.documentElement;

  function applyTheme(mode) {
    // Fallback if invalid
    if (mode !== 'light' && mode !== 'dark') mode = 'dark';
    docEl.setAttribute('data-theme', mode);
    docEl.setAttribute('data-theme-mode', mode);

    // Update Logos
    const logoDark = 'assets/img/logo-dark.png';
    const logoLight = 'assets/img/logo-light.png';
    const targetLogo = mode === 'dark' ? logoDark : logoLight;

    // Target all logos including header, splash and footer
    const logos = document.querySelectorAll('.brand__logo, .splash__logo');
    logos.forEach(img => {
      img.src = targetLogo;
    });

    const favicon = document.getElementById('favicon');
    if (favicon) favicon.href = targetLogo;
  }

  function loadTheme() {
    const saved = localStorage.getItem(THEME_KEY) || 'dark';
    applyTheme(saved);
    return saved;
  }

  function cycleTheme() {
    const current = docEl.getAttribute('data-theme-mode') || 'dark';
    const next = current === 'dark' ? 'light' : 'dark';
    localStorage.setItem(THEME_KEY, next);
    applyTheme(next);
    return next;
  }

  function bindThemeButtons() {
    const btn1 = $('#themeBtn');
    const btn2 = $('#themeBtn2');
    const setLabel = () => {
      const mode = docEl.getAttribute('data-theme-mode') || 'dark';
      // Simple toggle icon
      const icon = mode === 'dark' ? '☀' : '☾';
      if (btn1) btn1.querySelector('.iconBtn__icon').textContent = icon;
      if (btn1) btn1.querySelector('.iconBtn__text').textContent = mode === 'dark' ? 'Light' : 'Dark';
    };
    [btn1, btn2].filter(Boolean).forEach(btn => {
      btn.addEventListener('click', () => {
        cycleTheme();
        setLabel();
      });
    });
    setLabel();
  }

  /* -----------------------
     Splash / preloader
     ----------------------- */
  function runSplash() {
    const splash = $('#splash');
    if (!splash) return;

    const bar = splash.querySelector('.splash__meterBar');
    const meter = splash.querySelector('.splash__meter');
    const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // Load assets quickly (simulate init)
    let p = 0;
    const target = prefersReduced ? 100 : 92;

    const tick = () => {
      p = Math.min(target, p + Math.random() * 10);
      if (bar) bar.style.width = p.toFixed(0) + '%';
      if (meter) meter.setAttribute('aria-valuenow', String(Math.round(p)));
      if (p >= target) {
        // finish after a tiny delay
        setTimeout(() => {
          if (bar) bar.style.width = '100%';
          if (meter) meter.setAttribute('aria-valuenow', '100');
          setTimeout(() => {
            splash.classList.add('is-hidden');
            setTimeout(() => splash.remove(), 650);
          }, 350);
        }, 180);
        return;
      }
      requestAnimationFrame(tick);
    };

    requestAnimationFrame(tick);
  }

  /* -----------------------
     Mouse sparkle for primary buttons
     ----------------------- */
  function bindButtonSpark() {
    $$('.btn--primary').forEach(btn => {
      btn.addEventListener('pointermove', (e) => {
        const r = btn.getBoundingClientRect();
        const x = ((e.clientX - r.left) / r.width) * 100;
        const y = ((e.clientY - r.top) / r.height) * 100;
        btn.style.setProperty('--x', x.toFixed(1) + '%');
        btn.style.setProperty('--y', y.toFixed(1) + '%');
      });
    });
  }

  /* -----------------------
     Scroll reveal
     ----------------------- */
  function bindReveal() {
    const items = $$('.reveal');
    if (!items.length) return;

    const io = new IntersectionObserver((entries) => {
      entries.forEach(ent => {
        if (ent.isIntersecting) {
          ent.target.classList.add('is-in');
          io.unobserve(ent.target);
        }
      });
    }, { threshold: 0.14 });

    items.forEach(el => io.observe(el));
  }

  /* -----------------------
     Count up animation
     ----------------------- */
  function bindCounters() {
    const els = $$('[data-count]');
    if (!els.length) return;

    const easeOut = t => 1 - Math.pow(1 - t, 3);

    const animate = (el) => {
      const to = Number(el.getAttribute('data-count') || '0');
      const from = 0;
      const dur = 900;
      const start = performance.now();

      const step = (now) => {
        const t = Math.min(1, (now - start) / dur);
        const v = Math.round(from + (to - from) * easeOut(t));
        el.textContent = String(v);
        if (t < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
    };

    const io = new IntersectionObserver((entries) => {
      entries.forEach(ent => {
        if (ent.isIntersecting) {
          animate(ent.target);
          io.unobserve(ent.target);
        }
      });
    }, { threshold: 0.4 });

    els.forEach(el => io.observe(el));
  }

  /* -----------------------
     Mini sparklines (SVG)
     ----------------------- */
  function buildSparklines() {
    $$('.sparkline').forEach(el => {
      const raw = el.getAttribute('data-spark') || '';
      const pts = raw.split(',').map(x => Number(x.trim())).filter(n => Number.isFinite(n));
      if (!pts.length) return;

      const w = 220, h = 56, pad = 6;
      const min = Math.min(...pts), max = Math.max(...pts);
      const scaleX = (i) => pad + (i / (pts.length - 1)) * (w - pad * 2);
      const scaleY = (v) => {
        const t = (v - min) / ((max - min) || 1);
        return (h - pad) - t * (h - pad * 2);
      };

      let d = '';
      pts.forEach((v, i) => {
        const x = scaleX(i), y = scaleY(v);
        d += (i === 0 ? 'M' : 'L') + x.toFixed(1) + ' ' + y.toFixed(1) + ' ';
      });

      // area
      const dArea = d + `L ${(w - pad).toFixed(1)} ${(h - pad).toFixed(1)} L ${pad.toFixed(1)} ${(h - pad).toFixed(1)} Z`;

      const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      svg.setAttribute('viewBox', `0 0 ${w} ${h}`);
      svg.setAttribute('preserveAspectRatio', 'none');
      svg.style.width = '100%';
      svg.style.height = '100%';

      const defs = document.createElementNS(svg.namespaceURI, 'defs');
      const grad = document.createElementNS(svg.namespaceURI, 'linearGradient');
      grad.setAttribute('id', 'g' + Math.random().toString(16).slice(2));
      grad.setAttribute('x1', '0'); grad.setAttribute('y1', '0');
      grad.setAttribute('x2', '1'); grad.setAttribute('y2', '0');
      const s1 = document.createElementNS(svg.namespaceURI, 'stop');
      s1.setAttribute('offset', '0%'); s1.setAttribute('stop-color', 'rgba(25,255,106,0.85)');
      const s2 = document.createElementNS(svg.namespaceURI, 'stop');
      s2.setAttribute('offset', '100%'); s2.setAttribute('stop-color', 'rgba(0,208,255,0.75)');
      grad.appendChild(s1); grad.appendChild(s2);
      defs.appendChild(grad);
      svg.appendChild(defs);

      const area = document.createElementNS(svg.namespaceURI, 'path');
      area.setAttribute('d', dArea);
      area.setAttribute('fill', 'rgba(0,208,255,0.08)');
      area.setAttribute('stroke', 'none');
      svg.appendChild(area);

      const path = document.createElementNS(svg.namespaceURI, 'path');
      path.setAttribute('d', d.trim());
      path.setAttribute('fill', 'none');
      path.setAttribute('stroke', `url(#${grad.getAttribute('id')})`);
      path.setAttribute('stroke-width', '3');
      path.setAttribute('stroke-linecap', 'round');
      path.setAttribute('stroke-linejoin', 'round');

      // animate stroke
      const len = 400;
      path.style.strokeDasharray = String(len);
      path.style.strokeDashoffset = String(len);
      path.style.transition = 'stroke-dashoffset 900ms ease';

      svg.appendChild(path);
      el.appendChild(svg);
      requestAnimationFrame(() => { path.style.strokeDashoffset = '0'; });
    });
  }

  /* -----------------------
     Bars
     ----------------------- */
  function buildBars() {
    $$('.barChart').forEach(el => {
      const raw = el.getAttribute('data-bars') || '';
      const values = raw.split(',').map(x => Number(x.trim())).filter(n => Number.isFinite(n));
      if (!values.length) return;

      const max = Math.max(...values) || 1;
      el.innerHTML = '';
      values.forEach((v, i) => {
        const b = document.createElement('div');
        b.className = 'bar';
        b.style.height = (Math.max(8, (v / max) * 100)).toFixed(1) + '%';
        b.style.animationDelay = (i * 70) + 'ms';
        el.appendChild(b);
      });
    });
  }

  /* -----------------------
     Modal (waitlist demo)
     ----------------------- */
  const WAITLIST_KEY = 'smartcoachpro_waitlist';

  function openModal(name) {
    const m = $('#modal-' + name);
    if (!m) return;
    m.hidden = false;
    document.body.style.overflow = 'hidden';
    // focus first input
    setTimeout(() => $('#name', m)?.focus(), 0);
  }

  function closeModal() {
    const m = $$('.modal').find(x => x.hidden === false);
    if (!m) return;
    m.hidden = true;
    document.body.style.overflow = '';
  }

  function bindModal() {
    $$('[data-open-modal]').forEach(btn => {
      btn.addEventListener('click', () => openModal(btn.getAttribute('data-open-modal')));
    });

    $$('[data-close-modal]').forEach(el => {
      el.addEventListener('click', closeModal);
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') closeModal();
    });

    const form = $('#waitlistForm');
    const toast = $('#toastOk');
    if (form) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        const fd = new FormData(form);
        const entry = {
          name: String(fd.get('name') || ''),
          email: String(fd.get('email') || ''),
          coach: Boolean(fd.get('coach')),
          athlete: Boolean(fd.get('athlete')),
          at: new Date().toISOString()
        };

        const prev = JSON.parse(localStorage.getItem(WAITLIST_KEY) || '[]');
        prev.push(entry);
        localStorage.setItem(WAITLIST_KEY, JSON.stringify(prev));

        // If you have a backend, replace the localStorage part with fetch:
        // fetch('/api/waitlist', {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(entry)})

        if (toast) {
          toast.hidden = false;
          setTimeout(() => { toast.hidden = true; }, 2200);
        }
        form.reset();
      });
    }
  }

  /* -----------------------
     Mobile menu
     ----------------------- */
  function bindMobileMenu() {
    const ham = $('#hamburger');
    const menu = $('#mobileMenu');
    if (!ham || !menu) return;

    const setOpen = (open) => {
      ham.setAttribute('aria-expanded', String(open));
      menu.hidden = !open;
    };

    ham.addEventListener('click', () => {
      const open = ham.getAttribute('aria-expanded') === 'true';
      setOpen(!open);
    });

    $$('.mobileMenu__link', menu).forEach(link => {
      link.addEventListener('click', () => setOpen(false));
    });

    document.addEventListener('click', (e) => {
      if (menu.hidden) return;
      const target = e.target;
      const inMenu = menu.contains(target) || ham.contains(target);
      if (!inMenu) setOpen(false);
    });
  }

  /* -----------------------
     Back to top
     ----------------------- */
  function bindToTop() {
    const btn = $('#toTop');
    if (!btn) return;

    const onScroll = () => {
      if (window.scrollY > 600) btn.classList.add('is-visible');
      else btn.classList.remove('is-visible');
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  }

  /* -----------------------
     Canvas particles (subtle)
     ----------------------- */
  function initCanvasFx() {
    const canvas = $('#fx');
    if (!canvas) return;
    const ctx = canvas.getContext('2d', { alpha: true });
    if (!ctx) return;

    const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReduced) return;

    let w = 0, h = 0, dpr = 1;
    let running = true;

    const particles = [];
    const COUNT = 70;

    function resize() {
      dpr = Math.min(2, window.devicePixelRatio || 1);
      w = canvas.width = Math.floor(window.innerWidth * dpr);
      h = canvas.height = Math.floor(window.innerHeight * dpr);
      canvas.style.width = window.innerWidth + 'px';
      canvas.style.height = window.innerHeight + 'px';
    }

    function rand(a, b) { return a + Math.random() * (b - a); }

    function seed() {
      particles.length = 0;
      for (let i = 0; i < COUNT; i++) {
        particles.push({
          x: rand(0, w),
          y: rand(0, h),
          vx: rand(-0.22, 0.22) * dpr,
          vy: rand(-0.18, 0.18) * dpr,
          r: rand(1.0, 2.4) * dpr,
          a: rand(0.10, 0.22),
          hue: rand(110, 190) // green->cyan
        });
      }
    }

    function step() {
      if (!running) return;
      ctx.clearRect(0, 0, w, h);

      // theme-aware alpha
      const theme = document.documentElement.getAttribute('data-theme') || 'dark';
      const glow = theme === 'light' ? 0.10 : 0.18;

      // draw links
      for (let i = 0; i < particles.length; i++) {
        const p = particles[i];
        p.x += p.vx;
        p.y += p.vy;

        if (p.x < -50) p.x = w + 50;
        if (p.x > w + 50) p.x = -50;
        if (p.y < -50) p.y = h + 50;
        if (p.y > h + 50) p.y = -50;

        // particle
        ctx.beginPath();
        ctx.fillStyle = `hsla(${p.hue}, 95%, 55%, ${p.a})`;
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();

        // connections
        for (let j = i + 1; j < particles.length; j++) {
          const q = particles[j];
          const dx = p.x - q.x;
          const dy = p.y - q.y;
          const dist = Math.hypot(dx, dy);
          if (dist < 160 * dpr) {
            const a = (1 - dist / (160 * dpr)) * glow;
            ctx.strokeStyle = `rgba(0, 208, 255, ${a})`;
            ctx.lineWidth = 1 * dpr;
            ctx.beginPath();
            ctx.moveTo(p.x, p.y);
            ctx.lineTo(q.x, q.y);
            ctx.stroke();
          }
        }
      }

      requestAnimationFrame(step);
    }

    // Pause when tab inactive
    document.addEventListener('visibilitychange', () => {
      running = !document.hidden;
      if (running) requestAnimationFrame(step);
    });

    window.addEventListener('resize', () => {
      resize();
      seed();
    }, { passive: true });

    resize();
    seed();
    requestAnimationFrame(step);
  }


  /* -----------------------
     Header luxury scroll behavior (Rolex-inspired)
     ----------------------- */
  /* -----------------------
     Smart Header + Video Expansion Logic
     ----------------------- */
  function bindScrollBehavior() {
    const header = $('#topbar');
    const videoSticky = $('.videoHero__sticky');

    // Video controls injection
    if (videoSticky) {
      const controls = document.createElement('div');
      controls.className = 'videoControls';
      controls.innerHTML = `
        <button class="videoBtn" id="vidPlay" aria-label="Play/Pause">
          <svg viewBox="0 0 24 24"><path d="M6 4l15 8-15 8z"></path></svg>
        </button>
        <button class="videoBtn" id="vidMute" aria-label="Mute/Unmute">
          <svg viewBox="0 0 24 24"><path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73 4.27 3zM12 4L9.91 6.09 12 8.18V4z"></path></svg>
        </button>
      `;
      videoSticky.appendChild(controls);

      const video = $('#heroVideo');
      const btnPlay = $('#vidPlay');
      const btnMute = $('#vidMute');

      if (video && btnPlay && btnMute) {
        // Play/Pause
        btnPlay.addEventListener('click', () => {
          if (video.paused) {
            video.play();
            btnPlay.innerHTML = '<svg viewBox="0 0 24 24"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"></path></svg>';
          } else {
            video.pause();
            btnPlay.innerHTML = '<svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"></path></svg>';
          }
        });

        // Mute/Unmute
        // Default state check
        const updateMuteIcon = () => {
          if (video.muted) {
            btnMute.innerHTML = '<svg viewBox="0 0 24 24"><path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73 4.27 3zM12 4L9.91 6.09 12 8.18V4z"></path></svg>';
          } else {
            btnMute.innerHTML = '<svg viewBox="0 0 24 24"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"></path></svg>';
          }
        };
        updateMuteIcon();

        btnMute.addEventListener('click', () => {
          video.muted = !video.muted;
          updateMuteIcon();
        });
      }
    }

    let lastY = 0;
    const onScroll = () => {
      const y = window.scrollY;
      const dirDown = y > lastY;

      // Header Logic
      if (header) {
        if (y > 60) {
          header.classList.add('is-scrolled');
          if (dirDown) {
            header.classList.add('is-hidden');
          } else {
            header.classList.remove('is-hidden');
          }
        } else {
          header.classList.remove('is-scrolled');
          header.classList.remove('is-hidden');
        }
      }

      // Video Expansion Logic REMOVED (User request: normal scroll)
      /*
      if (videoSticky) {
        if (y > 50) { videoSticky.classList.add('is-expanded'); } 
        else { videoSticky.classList.remove('is-expanded'); }
      }
      */

      lastY = y;
    };

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* -----------------------
     Smooth scroll with fixed-header offset
     (anchors: [data-scroll])
     ----------------------- */
  function bindSmoothScrollOffset() {
    const links = $$('a[data-scroll][href^="#"]');
    if (!links.length) return;

    function headerOffset() {
      const v = getComputedStyle(document.documentElement).getPropertyValue('--headerH').trim();
      const n = parseInt(v || '78', 10);
      return Number.isFinite(n) ? n : 78;
    }

    function scrollToTarget(id) {
      const el = document.getElementById(id);
      if (!el) return;
      const top = el.getBoundingClientRect().top + window.pageYOffset - headerOffset() - 10;
      window.scrollTo({ top, behavior: 'smooth' });
    }

    links.forEach(a => {
      a.addEventListener('click', (e) => {
        const href = a.getAttribute('href') || '';
        const id = href.replace('#', '').trim();
        if (!id) return;
        e.preventDefault();
        scrollToTarget(id);

        const ham = $('#hamburger');
        const menu = $('#mobileMenu');
        if (ham && menu && ham.getAttribute('aria-expanded') === 'true') {
          ham.setAttribute('aria-expanded', 'false');
          menu.hidden = true;
        }

        history.pushState(null, '', '#' + id);
      });
    });

    if (location.hash && location.hash.length > 1) {
      const id = location.hash.slice(1);
      setTimeout(() => scrollToTarget(id), 60);
    }
  }

  /* -----------------------
     Subtle parallax (luxury-tech)
     - blobs
     - hero slogan micro-shift
     - overlay deepening on scroll
     ----------------------- */
  function bindParallax() {
    const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReduced) return;

    const blobs = $$('.blob');
    const hero = $('#videoHero');
    const slogan = $('#heroSlogan');
    const overlay = $('.videoHero__overlay');

    const clamp = (v, a, b) => Math.max(a, Math.min(b, v));

    const onScroll = () => {
      const y = window.scrollY;

      blobs.forEach((b, i) => {
        const factor = 0.012 + i * 0.004;
        b.style.transform = `translate3d(${(y * factor).toFixed(2)}px, ${(-y * factor).toFixed(2)}px, 0)`;
      });

      if (hero && slogan && overlay) {
        const rect = hero.getBoundingClientRect();
        const vh = window.innerHeight || 1;

        const prog = clamp((vh - rect.top) / (vh + rect.height), 0, 1);

        const shift = (prog * 14);
        slogan.style.transform = `translate3d(0, ${shift.toFixed(1)}px, 0)`;
        slogan.style.opacity = String(clamp(1 - prog * 0.65, 0, 1));

        overlay.style.opacity = String(clamp(0.55 + prog * 0.25, 0.55, 0.85));
      }
    };

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }


  /* -----------------------
     Footer year
     ----------------------- */
  function setYear() {
    const y = $('#year');
    if (y) y.textContent = String(new Date().getFullYear());
  }

  /* -----------------------
     Boot
     ----------------------- */
  function boot() {
    loadTheme();
    bindThemeButtons();
    runSplash();
    bindScrollBehavior();
    bindSmoothScrollOffset();
    bindButtonSpark();
    bindReveal();
    bindCounters();
    bindParallax();
    buildSparklines();
    buildBars();
    bindModal();
    bindMobileMenu();
    bindToTop();
    initCanvasFx();
    setYear();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
