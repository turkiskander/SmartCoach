@extends('layouts.app')

@section('title', 'SmartCoach — Coaching IA & Performance')

@section('preloader')
  <!-- Écran de chargement (Splash / Preloader) -->
  <div id="splash" class="splash" aria-hidden="true">
    <div class="splash__bg"></div>
    <div class="splash__content">
      <div class="splash__logoWrap">
        <img class="splash__logo" src="{{ asset('assets/img/logo-dark.png') }}" alt="SmartCoach logo" id="splashLogo" />
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
@endsection

@section('content')
  <!-- Section Héros Vidéo (100vh, affichage fluide au défilement) -->
  <section class="videoHero" id="videoHero">
    <div class="videoHero__sticky">
      <video class="videoHero__video" id="heroVideo" autoplay muted loop playsinline preload="metadata">
        <source src="{{ asset('assets/video/hero.mp4') }}" type="video/mp4" />
      </video>

      <div class="videoHero__overlay" aria-hidden="true"></div>
      <div class="videoHero__content">
        <div class="heroSlogan reveal is-in" id="heroSlogan">
          <div class="heroSlogan__kicker">{{ __('Smart digital coach') }}</div>
          <h1 class="heroSlogan__title">
            {{ __('SmartCoach,') }}<br />
            <span class="heroSlogan__accent">{{ __('Analyse intelligente en temps réel') }}</span>
          </h1>
          <p class="heroSlogan__sub">
            {{ __('Un coach IA premium qui interprète vos signaux, ajuste vos plans et vous guide vers une amélioration continue.') }}
          </p>

          <div class="heroSlogan__cta">
            <a class="btn btn--primary btn--lg btn--lux" href="#pricing" data-scroll>
              {{ __('Commencer') }}
              <span class="btn__spark" aria-hidden="true"></span>
            </a>
          </div>
        </div>

        <div class="scrollHint" aria-hidden="true">
          <div class="scrollHint__mouse"></div>
          <div class="scrollHint__text">{{ __('Scroll pour continuer') }}</div>
        </div>
      </div>

      <div class="scanLine" aria-hidden="true"></div>
    </div>
  </section>

  <!-- Remaining page content -->
  <section id="features" class="section section--afterHero">
    <div class="container">
      <div class="sectionHead">
        <div class="kicker">{{ __('Analyse • Coaching IA • Amélioration continue') }}</div>
        <h2 class="h2">{{ __('Votre progression, structurée par la donnée') }}</h2>
        <p class="muted">{{ __('SmartCoach analyse vos signaux et transforme vos objectifs en plans précis, ajustés au quotidien.') }}</p>
      </div>

      <div class="featureGrid">
        <article class="featureCard reveal" data-feature="0">
          <div class="featureCard__icon">❤️</div>
          <h3 class="h3">{{ __('feat_0_title') }}</h3>
          <p>{{ __('feat_0_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('HRV') }}</span><span class="tag">{{ __('Intensité') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="1">
          <div class="featureCard__icon">🩸</div>
          <h3 class="h3">{{ __('feat_1_title') }}</h3>
          <p>{{ __('feat_1_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('Oxygène') }}</span><span class="tag">{{ __('Sommeil') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="2">
          <div class="featureCard__icon">🏃</div>
          <h3 class="h3">{{ __('feat_2_title') }}</h3>
          <p>{{ __('feat_2_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('Fitness') }}</span><span class="tag">{{ __('Calories') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="3">
          <div class="featureCard__icon">📍</div>
          <h3 class="h3">{{ __('feat_3_title') }}</h3>
          <p>{{ __('feat_3_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('GPS') }}</span><span class="tag">{{ __('Routes') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="4">
          <div class="featureCard__icon">🧠</div>
          <h3 class="h3">{{ __('feat_4_title') }}</h3>
          <p>{{ __('feat_4_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('Focus') }}</span><span class="tag">{{ __('Stress') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="5">
          <div class="featureCard__icon">🏋️</div>
          <h3 class="h3">{{ __('feat_5_title') }}</h3>
          <p>{{ __('feat_5_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('Recovery') }}</span><span class="tag">{{ __('Power') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="6">
          <div class="featureCard__icon">🤖</div>
          <h3 class="h3">{{ __('feat_6_title') }}</h3>
          <p>{{ __('feat_6_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('IA') }}</span><span class="tag">{{ __('Adaptive') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="7">
          <div class="featureCard__icon">🥗</div>
          <h3 class="h3">{{ __('feat_7_title') }}</h3>
          <p>{{ __('feat_7_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('Food') }}</span><span class="tag">{{ __('Water') }}</span>
          </div>
        </article>

        <article class="featureCard reveal" data-feature="8">
          <div class="featureCard__icon">📋</div>
          <h3 class="h3">{{ __('feat_8_title') }}</h3>
          <p>{{ __('feat_8_desc') }}</p>
          <div class="featureCard__meta">
            <span class="tag">{{ __('Health') }}</span><span class="tag">{{ __('Reports') }}</span>
          </div>
        </article>
      </div>
    </div>
  </section>

  <section id="feedback-section" class="section">
    <div class="container">
      <!-- Tab Navigation -->
      <div class="tab-nav">
        <button class="tab-btn active" data-tab="contact">{{ __('Contact') }}</button>
        <button class="tab-btn" data-tab="feedback">{{ __('Votre avis') }}</button>
      </div>

      <div class="tab-content">
        <!-- Contact Zone -->
        <div id="contact-zone" class="tab-pane active">
          <div class="contact-wrapper">
            <div class="contact-grid">
              <div class="contact-card">
                <div class="contact-icon">📞</div>
                <div class="contact-val">
                  <a href="tel:+21625121210">(+216) 25.121.210</a><br>
                  <a href="tel:+21623337207">23.337.207</a>
                </div>
              </div>
              <div class="contact-card">
                <div class="contact-icon">🇸🇦</div>
                <div class="contact-val">
                  <a href="tel:+966556661636">(+966) 5566 61636</a>
                </div>
              </div>
              <div class="contact-card">
                <div class="contact-icon">🌐</div>
                <div class="contact-val">
                  <a href="https://www.elitesports-innovation-holding.com" target="_blank">www.elitesports-innovation-holding.com</a>
                </div>
              </div>
              <div class="contact-card">
                <div class="contact-icon">✉</div>
                <div class="contact-val">
                  <a href="mailto:b.mokhtari@elitesports-innovation-holding.com">b.mokhtari@elitesports-innovation-holding.com</a>
                </div>
              </div>
            </div>

            <!-- Modern Contact Form -->
            <div class="contact-form-container">
              <form id="contactForm" class="contact-form">
                <div class="form-row">
                  <div class="form-group">
                    <label for="firstName">{{ __('Prénom') }}</label>
                    <input type="text" id="firstName" name="firstName" placeholder="{{ __('Votre prénom') }}" required>
                  </div>
                  <div class="form-group">
                    <label for="lastName">{{ __('Nom') }}</label>
                    <input type="text" id="lastName" name="lastName" placeholder="{{ __('Votre nom') }}" required>
                  </div>
                </div>
                <div class="form-group">
                  <label for="email">{{ __('Email') }}</label>
                  <input type="email" id="email" name="email" placeholder="{{ __('votre@email.com') }}" required>
                </div>
                <div class="form-group">
                  <label for="message">{{ __('Message') }}</label>
                  <textarea id="message" name="message" rows="5" placeholder="{{ __('Comment pouvons-nous vous aider ?') }}" required></textarea>
                </div>
                <button type="submit" class="btn btn--primary btn--block btn--lux">
                  {{ __('Envoyer le message') }}
                  <span class="btn__spark" aria-hidden="true"></span>
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- Questionnaire Zone -->
        <div id="feedback-zone" class="tab-pane">
          <div class="sectionHead">
            <h2 class="h2">{{ __('Interagissez avec Smart Coach') }}</h2>
            <p class="muted">{{ __('Votre avis rend Smart Coach encore plus intelligent') }}</p>
          </div>
          <div class="text-center" style="text-align: center; padding: 30px;">
            <button id="open-feedback" class="btn btn--primary btn--lg btn--lux">
              {{ __('Donner votre avis') }}
              <span class="btn__spark" aria-hidden="true"></span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Feature Detail Modal -->
  <div id="feature-modal" class="modal-overlay">
    <div class="modal-container feature-modal-container">
      <button id="close-feature" class="modal-close" aria-label="Fermer">&times;</button>
      <div id="feature-detail-content" class="modal-content feature-modal-content">
        <!-- Content injected via JS -->
      </div>
    </div>
  </div>

  <!-- Feedback Modal -->
  <div id="feedback-modal" class="modal-overlay">
    <div class="modal-container">
      <button id="close-feedback" class="modal-close" aria-label="Fermer">&times;</button>
      
      <div class="modal-progress">
        <div id="feedback-progress-bar" class="progress-bar"></div>
      </div>

      <div id="feedback-content" class="modal-content">
        <!-- Dynamic content will be injected here -->
      </div>
    </div>
  </div>
@endsection

@section('scripts')
  <script>
    window.APP_TRANSLATIONS = {
        features: [
            { title: {!! json_encode(__('feat_0_title')) !!}, desc: {!! json_encode(__('feat_desc_0')) !!} },
            { title: {!! json_encode(__('feat_1_title')) !!}, desc: {!! json_encode(__('feat_desc_1')) !!} },
            { title: {!! json_encode(__('feat_2_title')) !!}, desc: {!! json_encode(__('feat_desc_2')) !!} },
            { title: {!! json_encode(__('feat_3_title')) !!}, desc: {!! json_encode(__('feat_desc_3')) !!} },
            { title: {!! json_encode(__('feat_4_title')) !!}, desc: {!! json_encode(__('feat_desc_4')) !!} },
            { title: {!! json_encode(__('feat_5_title')) !!}, desc: {!! json_encode(__('feat_desc_5')) !!} },
            { title: {!! json_encode(__('feat_6_title')) !!}, desc: {!! json_encode(__('feat_desc_6')) !!} },
            { title: {!! json_encode(__('feat_7_title')) !!}, desc: {!! json_encode(__('feat_desc_7')) !!} },
            { title: {!! json_encode(__('feat_8_title')) !!}, desc: {!! json_encode(__('feat_desc_8')) !!} }
        ],
        btnFermer: {!! json_encode(__('Fermer')) !!}
    };
  </script>
@endsection
