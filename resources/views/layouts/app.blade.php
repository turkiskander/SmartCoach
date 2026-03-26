<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" dir="{{ app()->getLocale() == 'ar' ? 'rtl' : 'ltr' }}" data-theme="auto">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="color-scheme" content="dark light" />
  <title>@yield('title', 'SmartCoach')</title>
  <meta name="description" content="SmartCoach : coaching IA premium — analyse intelligente en temps réel et planification." />
  
  <link rel="icon" type="image/png" href="{{ asset('assets/img/logo-dark.png') }}" id="favicon" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="{{ asset('assets/css/base.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/header_footer.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/questionnaire.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/dark.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/light.css') }}" />
  @yield('styles')
  <script>
    (function() {
        const theme = localStorage.getItem('smartcoachpro_theme') || 'dark';
        document.documentElement.setAttribute('data-theme', theme);
        document.documentElement.setAttribute('data-theme-mode', theme);
    })();
  </script>
</head>

<body>
  @yield('preloader')
  <!-- Animated Background Layers -->
  <canvas id="fx" class="fx" aria-hidden="true"></canvas>
  <div class="gridOverlay" aria-hidden="true"></div>

  @include('partials.header')

  <main id="top" class="page">
    @yield('content')
  </main>

  @include('partials.footer')

  <!-- Bouton Retour en haut -->
  <button id="backToTop" class="backToTop" aria-label="Retour en haut">
    <img src="{{ asset('assets/img/dark.png') }}" alt="Retour en haut" id="backToTopImg" />
  </button>

  <script src="{{ asset('assets/js/theme.js') }}"></script>
  <script src="{{ asset('assets/js/navigation.js') }}"></script>
  <script src="{{ asset('assets/js/questionnaire.js') }}"></script>
  <script src="{{ asset('assets/js/main.js') }}"></script>
  @yield('scripts')
</body>
</html>
