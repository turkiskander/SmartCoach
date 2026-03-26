<header class="topbar topbar--fixed" id="topbar">
    <div class="container topbar__inner">
      <a class="brand" href="{{ url('/') }}#top" data-scroll>
        <img src="{{ asset('assets/img/logo-dark.png') }}" alt="SmartCoach" class="brand__logo" id="brandLogo" />
        <span class="brand__name">SmartCoach</span>
      </a>

      <nav class="nav" aria-label="Primary">
        <a href="{{ url('/') }}" class="nav__link" data-scroll>{{ __('Accueil') }}</a>
        <a href="{{ url('/') }}#features" class="nav__link" data-scroll>{{ __('Fonctionnalités') }}</a>
        <a href="{{ url('/') }}#feedback-section" class="nav__link" data-scroll>{{ __('Contact / Avis clients') }}</a>
      </nav>

      <div class="topbar__actions">
        @include('langue')
        
        <button class="iconBtn iconBtn--lux" id="themeBtn" type="button" aria-label="Toggle theme">
          <span class="iconBtn__icon" aria-hidden="true">◐</span>
          <span class="iconBtn__text">{{ __('Thème') }}</span>
        </button>

        @auth
          <a href="{{ route('dashboard') }}" class="btn btn--ghost btn--sm">{{ __('Tableau de bord') }}</a>
          <form action="{{ route('logout') }}" method="POST" style="display: inline;">
            @csrf
            <button type="submit" class="btn btn--ghost btn--sm">{{ __('Logout') }}</button>
          </form>
        @else
          <a href="{{ route('login') }}" class="btn btn--primary btn--lux">
            {{ __('Login') }}
            <span class="btn__spark" aria-hidden="true"></span>
          </a>
        @endauth

        <button class="hamburger" id="hamburger" type="button" aria-label="Open menu" aria-controls="mobileMenu" aria-expanded="false">
          <span></span><span></span><span></span>
        </button>
      </div>
    </div>

    <div class="mobileMenu" id="mobileMenu" hidden>
      <div class="mobileMenu__panel">
        <a href="{{ url('/') }}" class="mobileMenu__link" data-scroll>{{ __('Accueil') }}</a>
        <a href="{{ url('/') }}#features" class="mobileMenu__link" data-scroll>{{ __('Fonctionnalités') }}</a>
        <a href="{{ url('/') }}#feedback-section" class="mobileMenu__link" data-scroll>{{ __('Contact / Avis clients') }}</a>
        
        <div class="mobileMenu__cta">
          @auth
            <a href="{{ route('dashboard') }}" class="btn btn--ghost btn--block">{{ __('Tableau de bord') }}</a>
            <form action="{{ route('logout') }}" method="POST">
              @csrf
              <button type="submit" class="btn btn--ghost btn--block">{{ __('Logout') }}</button>
            </form>
          @else
            <a href="{{ route('login') }}" class="btn btn--primary btn--block">{{ __('Login') }}</a>
          @endauth
          <button class="btn btn--ghost btn--block" type="button" id="themeBtn2">{{ __('Toggle Theme') }}</button>
        </div>
      </div>
    </div>
</header>
