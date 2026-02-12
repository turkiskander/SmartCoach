<!doctype html>
<html lang="fr" data-theme="auto">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="color-scheme" content="dark light" />
  <title>SmartCoach</title>
  <meta name="description" content="SmartCoach : coaching IA premium — analyse intelligente en temps réel et planification." />

  <meta property="og:title" content="SmartCoach — Coaching IA & Performance" />
  <meta property="og:description" content="Coaching IA premium : analyse intelligente, planification et amélioration continue." />
  <meta property="og:type" content="website" />

  <link rel="icon" type="image/png" href="assets/img/logo-dark.png" id="favicon" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <link rel="stylesheet" href="assets/css/style.css" />
</head>

<body>
  <!-- Splash / Preloader -->
  <div id="splash" class="splash" aria-hidden="true">
    <div class="splash__bg"></div>
    <div class="splash__content">
      <div class="splash__logoWrap">
        <img class="splash__logo" src="assets/img/logo-dark.png" alt="SmartCoach logo" id="splashLogo" />
        <div class="splash__ring" aria-hidden="true"></div>
        <div class="splash__ring splash__ring--2" aria-hidden="true"></div>
      </div>
      <div class="splash__title">SmartCoach</div>
      <div class="splash__sub">Initialisation du coach intelligent…</div>

      <div class="splash__meter" role="progressbar" aria-label="Loading" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
        <div class="splash__meterBar"></div>
      </div>
      <div class="splash__hint">Astuce : basculez Dark/Light à tout moment</div>
    </div>
  </div>

  <!-- Animated Background Layers -->
  <canvas id="fx" class="fx" aria-hidden="true"></canvas>
  <div class="blobs" aria-hidden="true">
    <div class="blob blob--1"></div>
    <div class="blob blob--2"></div>
    <div class="blob blob--3"></div>
  </div>
  <div class="gridOverlay" aria-hidden="true"></div>

  <!-- Fixed Header (Rolex-inspired green) -->
  <header class="topbar topbar--fixed" id="topbar">
    <div class="container topbar__inner">
      <a class="brand" href="#top" data-scroll>
        <img src="assets/img/logo-dark.png" alt="SmartCoach" class="brand__logo" id="brandLogo" />
        <span class="brand__name">SmartCoach</span>
      </a>

      <nav class="nav" aria-label="Primary">
        <a href="#features" class="nav__link" data-scroll>Fonctionnalités</a>
        <a href="#showcase" class="nav__link" data-scroll>Interface</a>
        <a href="#pricing" class="nav__link" data-scroll>Offres</a>
        <a href="#faq" class="nav__link" data-scroll>FAQ</a>
      </nav>

      <div class="topbar__actions">
        <button class="iconBtn iconBtn--lux" id="themeBtn" type="button" aria-label="Toggle theme">
          <span class="iconBtn__icon" aria-hidden="true">◐</span>
          <span class="iconBtn__text">Thème</span>
        </button>

        <button class="hamburger" id="hamburger" type="button" aria-label="Open menu" aria-controls="mobileMenu" aria-expanded="false">
          <span></span><span></span><span></span>
        </button>
      </div>
    </div>

    <div class="mobileMenu" id="mobileMenu" hidden>
      <div class="mobileMenu__panel">
        <a href="#features" class="mobileMenu__link" data-scroll>Fonctionnalités</a>
        <a href="#showcase" class="mobileMenu__link" data-scroll>Interface</a>
        <a href="#pricing" class="mobileMenu__link" data-scroll>Offres</a>
        <a href="#faq" class="mobileMenu__link" data-scroll>FAQ</a>
        <div class="mobileMenu__cta">
          <button class="btn btn--ghost btn--block" type="button" id="themeBtn2">Toggle Theme</button>
        </div>
      </div>
    </div>
  </header>

  <main id="top" class="page">
    <!-- VIDEO HERO (100vh, sticky reveal on scroll) -->
    <section class="videoHero" id="videoHero">
      <div class="videoHero__sticky">
        <video class="videoHero__video" id="heroVideo" autoplay muted loop playsinline preload="metadata">
          <source src="assets/video/hero.mp4" type="video/mp4" />
        </video>

        <div class="videoHero__overlay" aria-hidden="true"></div>

        <div class="videoHero__content">
          <div class="heroSlogan reveal is-in" id="heroSlogan">
            <div class="heroSlogan__kicker">Smart digital coach</div>
            <h1 class="heroSlogan__title">
              SmartCoach,<br />
              <span class="heroSlogan__accent">Analyse intelligente en temps réel</span>
            </h1>
            <p class="heroSlogan__sub">
              Un coach IA premium qui interprète vos signaux, ajuste vos plans et vous guide vers une amélioration continue.
            </p>

            <div class="heroSlogan__cta">
              <a class="btn btn--primary btn--lg btn--lux" href="#pricing" data-scroll>
                Commencer
                <span class="btn__spark" aria-hidden="true"></span>
              </a>
            </div>



          </div>

          <div class="scrollHint" aria-hidden="true">
            <div class="scrollHint__mouse"></div>
            <div class="scrollHint__text">Scroll pour continuer</div>
          </div>
        </div>

        <div class="scanLine" aria-hidden="true"></div>
      </div>
    </section>

    <!-- Remaining page content (kept UI, refined copy within the SmartCoachPro theme) -->
    <section id="features" class="section section--afterHero">
      <div class="container">
        <div class="sectionHead">
          <div class="kicker">Analyse • Coaching IA • Amélioration continue</div>
          <h2 class="h2">Votre progression, structurée par la donnée</h2>
          <p class="muted">SmartCoach analyse vos signaux et transforme vos objectifs en plans précis, ajustés au quotidien.</p>
        </div>

        <div class="featureGrid">
          <article class="featureCard reveal">
            <div class="featureCard__icon">🧠</div>
            <h3 class="h3">Coaching IA</h3>
            <p>Recommandations contextualisées : charge, récupération, intensité et micro-ajustements après chaque session.</p>
            <div class="featureCard__meta">
              <span class="tag">Insights</span><span class="tag">Guidance</span>
            </div>
          </article>

          <article class="featureCard reveal">
            <div class="featureCard__icon">❤</div>
            <h3 class="h3">Surveillance santé</h3>
            <p>Suivi des signaux clés (rythme, variabilité, sommeil) et alertes discrètes pour rester dans la zone optimale.</p>
            <div class="featureCard__meta">
              <span class="tag">Zones</span><span class="tag">ECG</span>
            </div>
          </article>

          <article class="featureCard reveal">
            <div class="featureCard__icon">📈</div>
            <h3 class="h3">Analyse en temps réel</h3>
            <p>Lecture instantanée de tendances : fatigue, progression, risques — et décisions guidées par vos données.</p>
            <div class="featureCard__meta">
              <span class="tag">KPIs</span><span class="tag">Trends</span>
            </div>
          </article>

          <article class="featureCard reveal">
            <div class="featureCard__icon">🗓</div>
            <h3 class="h3">Planification premium</h3>
            <p>Plans structurés (train/rehab/peak) avec une logique d’amélioration continue et une périodisation adaptative.</p>
            <div class="featureCard__meta">
              <span class="tag">Periodization</span><span class="tag">Adaptive</span>
            </div>
          </article>

          <article class="featureCard reveal">
            <div class="featureCard__icon">👥</div>
            <h3 class="h3">Mode coach & équipes</h3>
            <p>Tableaux d’équipe, rôle-based access, communication et suivi collectif — sans perdre la précision individuelle.</p>
            <div class="featureCard__meta">
              <span class="tag">Teams</span><span class="tag">Roles</span>
            </div>
          </article>

          <article class="featureCard reveal">
            <div class="featureCard__icon">🔒</div>
            <h3 class="h3">Contrôle & confidentialité</h3>
            <p>Architecture orientée sécurité : règles claires, paramètres transparents et protection des données personnelles.</p>
            <div class="featureCard__meta">
              <span class="tag">Secure</span><span class="tag">Controls</span>
            </div>
          </article>
        </div>

        <div class="callout reveal">
          <div class="callout__left">
            <div class="callout__kicker">Intégrations</div>
            <div class="callout__title">Connectez vos appareils & sessions</div>
            <div class="callout__text">Synchronisez vos mesures et obtenez une analyse cohérente : santé, charge, récupération et performance.</div>
          </div>
          <div class="callout__right">
            <div class="pillList">
              <div class="pillList__item"><span class="pillDot"></span>Wear OS</div>
              <div class="pillList__item"><span class="pillDot"></span>Apple Watch</div>
              <div class="pillList__item"><span class="pillDot"></span>Garmin</div>
              <div class="pillList__item"><span class="pillDot"></span>Polar</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="showcase" class="section section--alt">
      <div class="container">
        <div class="sectionHead">
          <div class="kicker">Interface premium</div>
          <h2 class="h2">Une expérience luxueuse, rapide et lisible</h2>
          <p class="muted">Micro-interactions, néons subtils, et dashboards conçus pour analyser et décider.</p>
        </div>

        <div class="showcaseGrid">
          <div class="shot reveal">
            <div class="shot__top">
              <div class="shot__title">Timeline de plan</div>
              <div class="shot__chip">Structuré</div>
            </div>
            <div class="shot__body">
              <div class="lane">
                <div class="lane__label">Lun</div>
                <div class="lane__blocks">
                  <div class="block block--a">Force</div>
                  <div class="block block--b">Mobilité</div>
                </div>
              </div>
              <div class="lane">
                <div class="lane__label">Mer</div>
                <div class="lane__blocks">
                  <div class="block block--c">Intervalles</div>
                  <div class="block block--b">Respiration</div>
                </div>
              </div>
              <div class="lane">
                <div class="lane__label">Ven</div>
                <div class="lane__blocks">
                  <div class="block block--d">Endurance</div>
                  <div class="block block--b">Stretch</div>
                </div>
              </div>
              <div class="shot__note">Prototype UI (landing uniquement)</div>
            </div>
          </div>

          <div class="shot reveal">
            <div class="shot__top">
              <div class="shot__title">Santé & zones</div>
              <div class="shot__chip shot__chip--alt">Monitoring</div>
            </div>
            <div class="shot__body">
              <div class="healthRow">
                <div class="healthCard">
                  <div class="healthCard__label">Zone cardiaque</div>
                  <div class="healthCard__value">Z3</div>
                  <div class="healthCard__bar"><span style="--w: 63%"></span></div>
                </div>
                <div class="healthCard">
                  <div class="healthCard__label">Sommeil</div>
                  <div class="healthCard__value">7h 42m</div>
                  <div class="healthCard__bar"><span style="--w: 78%"></span></div>
                </div>
              </div>
              <div class="ecg">
                <div class="ecg__label">ECG</div>
                <div class="ecg__line" aria-hidden="true"></div>
                <div class="ecg__caption">Waveform discret (animation)</div>
              </div>
            </div>
          </div>

          <div class="shot reveal">
            <div class="shot__top">
              <div class="shot__title">Notes IA</div>
              <div class="shot__chip">Coach</div>
            </div>
            <div class="shot__body">
              <div class="chat">
                <div class="bubble bubble--ai">
                  Charge maîtrisée. Baissez légèrement l’intensité demain pour optimiser la récupération.
                </div>
                <div class="bubble bubble--me">
                  Je peux ajouter du gainage ?
                </div>
                <div class="bubble bubble--ai">
                  Oui — 10 minutes. Surveillez l’HRV au réveil.
                </div>
              </div>
              <a class="btn btn--ghost btn--block btn--lux" href="#pricing" data-scroll>Voir les offres</a>
            </div>
          </div>

          <div class="shot reveal">
            <div class="shot__top">
              <div class="shot__title">Tendances</div>
              <div class="shot__chip shot__chip--alt">Analyse</div>
            </div>
            <div class="shot__body">
              <div class="barChart" data-bars="22,38,55,44,62,71,68"></div>
              <div class="shot__note">Charge hebdomadaire & progression</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="pricing" class="section">
      <div class="container">
        <div class="sectionHead">
          <div class="kicker">Offres</div>
          <h2 class="h2">Commencez, puis montez en puissance</h2>
          <p class="muted">Des plans clairs pour l’individuel et les équipes.</p>
        </div>

        <div class="pricingGrid">
          <div class="priceCard reveal">
            <div class="priceCard__head">
              <div class="priceCard__name">Starter</div>
              <div class="priceCard__price"><span class="currency">$</span>0<span class="per">/mo</span></div>
              <div class="priceCard__desc">Suivi personnel + bases de planification.</div>
            </div>
            <ul class="list">
              <li>Templates hebdomadaires</li>
              <li>Signaux santé essentiels</li>
              <li>Snapshots de progression</li>
            </ul>
            <a class="btn btn--ghost btn--block btn--lux" href="#faq" data-scroll>Questions</a>
          </div>

          <div class="priceCard priceCard--featured reveal">
            <div class="priceCard__badge">Best choice</div>
            <div class="priceCard__head">
              <div class="priceCard__name">Pro</div>
              <div class="priceCard__price"><span class="currency">$</span>12<span class="per">/mo</span></div>
              <div class="priceCard__desc">Analyse plus profonde + coaching IA.</div>
            </div>
            <ul class="list">
              <li>Périodisation adaptative</li>
              <li>Résumé IA des sessions</li>
              <li>Readiness & recovery avancés</li>
              <li>Dashboards personnalisés</li>
            </ul>
            <a class="btn btn--primary btn--block btn--lux" href="#top" data-scroll>
              Choisir Pro
              <span class="btn__spark" aria-hidden="true"></span>
            </a>
          </div>

          <div class="priceCard reveal">
            <div class="priceCard__head">
              <div class="priceCard__name">Team</div>
              <div class="priceCard__price"><span class="currency">$</span>39<span class="per">/mo</span></div>
              <div class="priceCard__desc">Pour clubs, coachs et groupes.</div>
            </div>
            <ul class="list">
              <li>Tableaux d’équipe</li>
              <li>Accès par rôles</li>
              <li>Messagerie coach</li>
              <li>Exports & rapports</li>
            </ul>
            <a class="btn btn--ghost btn--block btn--lux" href="#top" data-scroll>Nous contacter</a>
          </div>
        </div>

        <div class="ribbon reveal">
          <div class="ribbon__left">
            <div class="ribbon__title">Approche “amélioration continue”</div>
            <div class="ribbon__text">Chaque semaine : mesure → analyse → ajustement → progression.</div>
          </div>
          <div class="ribbon__right">
            <a class="btn btn--primary btn--lux" href="#features" data-scroll>
              Voir les piliers
              <span class="btn__spark" aria-hidden="true"></span>
            </a>
          </div>
        </div>
      </div>
    </section>

    <section id="faq" class="section section--alt">
      <div class="container">
        <div class="sectionHead">
          <div class="kicker">FAQ</div>
          <h2 class="h2">Questions</h2>
          <p class="muted">Des réponses courtes, orientées usage.</p>
        </div>

        <div class="faqGrid">
          <details class="faq reveal">
            <summary>Le site supporte Dark et Light mode ?</summary>
            <div class="faq__body">Oui. Le toggle est disponible et le site respecte aussi le thème système.</div>
          </details>
          <details class="faq reveal">
            <summary>Comment SmartCoachPro “analyse en temps réel” ?</summary>
            <div class="faq__body">Le concept : vos signaux (santé + charge) alimentent des indicateurs et un coach IA propose des ajustements.</div>
          </details>
          <details class="faq reveal">
            <summary>Je peux remplacer la vidéo d’accueil ?</summary>
            <div class="faq__body">Oui. Remplacez <code>assets/video/hero.mp4</code> par votre vidéo (même nom).</div>
          </details>
          <details class="faq reveal">
            <summary>Est-ce responsive (mobile/tablet/desktop) ?</summary>
            <div class="faq__body">Oui. Le header fixe, la vidéo 100vh et les grilles s’adaptent à toutes tailles d’écran.</div>
          </details>
        </div>

        <div class="finalCta reveal">
          <div class="finalCta__left">
            <h3 class="h3">Prêt à passer au niveau supérieur ?</h3>
            <p class="muted">Analyse intelligente, planification premium et amélioration continue.</p>
          </div>
          <div class="finalCta__right">
            <a class="btn btn--primary btn--lg btn--lux" href="#pricing" data-scroll>
              Voir les offres
              <span class="btn__spark" aria-hidden="true"></span>
            </a>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer class="footer">
    <div class="container footer__inner">
      <div class="footer__left">
        <div class="brand brand--footer">
          <img src="assets/img/logo-dark.png" alt="SmartCoach" class="brand__logo" />
          <div>
            <div class="brand__name">SmartCoach</div>
            <div class="brand__tag">Smart training • Health monitoring • AI coaching</div>
          </div>
        </div>
        <div class="footer__small">© <span id="year"></span> SmartCoach. All rights reserved.</div>
      </div>

      <div class="footer__right">
        <a class="footer__link" href="#features" data-scroll>Fonctionnalités</a>
        <a class="footer__link" href="#pricing" data-scroll>Offres</a>
        <a class="footer__link" href="#faq" data-scroll>FAQ</a>
        <a class="footer__link" href="#top" data-scroll>Top</a>
      </div>
    </div>
  </footer>

  <button class="toTop" id="toTop" type="button" aria-label="Back to top">↑</button>

  <script src="assets/js/main.js"></script>
</body>
</html>
