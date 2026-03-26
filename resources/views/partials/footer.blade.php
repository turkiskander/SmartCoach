<footer id="footer" class="footer footer--pro">
  <div class="footer-top">
    <div class="container">
      <div class="footer-grid">
        <!-- Navigation -->
        <div class="footer-links">
          <h4 class="footer-title">{{ __('Navigation') }}</h4>
          <ul class="footer-list">
            <li><a href="{{ url('/') }}#top">{{ __('Accueil') }}</a></li>
            <li><a href="{{ url('/') }}#features">{{ __('Fonctionnalités') }}</a></li>
            <li><a href="{{ url('/') }}#showcase">{{ __('Interface') }}</a></li>
          </ul>
        </div>

        <!-- Solutions -->
        <div class="footer-links">
          <h4 class="footer-title">{{ __('Solutions') }}</h4>
          <ul class="footer-list">
            <li><a href="#">{{ __('Analyse & dashboards') }}</a></li>
            <li><a href="#">{{ __('Plans adaptatifs') }}</a></li>
            <li><a href="#">{{ __('Suivi santé') }}</a></li>
          </ul>
        </div>

        <!-- Newsletter -->
        <div class="footer-newsletter">
          <h4 class="footer-title">{{ __('Newsletter') }}</h4>
          <form class="footer-form" action="#" method="post">
            <label class="srOnly" for="footerEmail">{{ __('Email') }}</label>
            <input id="footerEmail" class="footer-input" type="email" name="email" placeholder="{{ __('Votre email') }}" required />
            <button class="footer-submit" type="submit">{{ __('S’abonner') }}</button>
          </form>

          <div class="footer-meta">
            <div class="footer-metaItem">
              <span class="metaDot" aria-hidden="true"></span>
              {{ __('Support 24/7') }}
            </div>
            <div class="footer-metaItem">
              <span class="metaDot metaDot--alt" aria-hidden="true"></span>
              {{ __('Données protégées') }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="footer-bottom">
    <div class="container footer-bottomInner">
      <div class="footer-copy">
        © <span id="year"></span> <strong>SmartCoach</strong>. {{ __('Tous droits réservés.') }}
      </div>
      <div class="footer-legal">
        <a href="#">{{ __('Confidentialité') }}</a>
        <span class="footer-sep">•</span>
        <a href="#">{{ __('Conditions') }}</a>
        <span class="footer-sep">•</span>
        <a href="{{ url('/') }}#top">{{ __('Haut de page') }}</a>
      </div>
    </div>
  </div>
</footer>
