<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" dir="{{ app()->getLocale() == 'ar' ? 'rtl' : 'ltr' }}" data-theme="dark">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>@yield('title', 'SmartCoach Dashboard')</title>
  
  <link rel="icon" type="image/png" href="{{ asset('assets/img/logo-dark.png') }}" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="{{ asset('assets/css/base.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/header_footer.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/questionnaire.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/dark.css') }}" />
  <link rel="stylesheet" href="{{ asset('assets/css/light.css') }}" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  
  <script>
    (function() {
        const theme = localStorage.getItem('smartcoachpro_theme') || 'dark';
        document.documentElement.setAttribute('data-theme', theme);
        document.documentElement.setAttribute('data-theme-mode', theme);
    })();
  </script>

  <style>
    :root {
        --sidebar-width: 280px;
        --sidebar-border: rgba(255, 255, 255, 0.08);
        --nav-active-bg: rgba(255, 184, 0, 0.1);
        --nav-active-text: #FFB800;
        /* Inherit from style.css but allow overrides */
        --dashboard-bg: var(--bg);
        --font-display: 'Orbitron', sans-serif;
        --font-ui: 'Inter', sans-serif;
    }

    html[data-theme="light"] {
        --sidebar-bg: #000000;
        --sidebar-border: rgba(255, 184, 0, 0.2);
        --nav-active-bg: rgba(255, 184, 0, 0.15);
        --nav-active-text: #FFB800;
        --dashboard-bg: #FFCC00;
    }

    html[data-theme="dark"] {
        --sidebar-bg: rgba(13, 17, 23, 0.95);
        --sidebar-border: rgba(255, 255, 255, 0.08);
        --dashboard-bg: #000000;
    }

    body {
        margin: 0;
        padding: 0;
        background: var(--dashboard-bg);
        color: var(--text);
        font-family: var(--font-ui);
        overflow-x: hidden;
        min-height: 100vh;
    }

    /* Background Gradients matching Welcome Page */
    body::before {
        content: "";
        position: fixed;
        inset: 0;
        z-index: -1;
        background: radial-gradient(circle at 15% 25%, rgba(255, 184, 0, 0.12) 0%, transparent 45%),
                    radial-gradient(circle at 85% 75%, rgba(255, 138, 0, 0.08) 0%, transparent 55%),
                    linear-gradient(180deg, var(--bg) 0%, var(--bg2) 100%);
        filter: blur(60px);
        opacity: 1;
    }

    html[data-theme="light"] body::before {
        background: radial-gradient(circle at 10% 20%, #FFFFFF 0%, transparent 45%),
                    radial-gradient(circle at 85% 80%, rgba(255, 138, 0, 0.45) 0%, transparent 55%),
                    linear-gradient(135deg, #FFCC00 0%, #FFD700 100%);
        filter: blur(50px);
        opacity: 0.95;
    }

    .dashboard-layout {
        display: flex;
        min-height: 100vh;
        position: relative;
    }

    /* Sidebar Styles - Luxury Look */
    .dashboard-sidebar {
        width: var(--sidebar-width);
        background: var(--sidebar-bg);
        backdrop-filter: blur(30px);
        border-right: 1px solid var(--sidebar-border);
        display: flex;
        flex-direction: column;
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        z-index: 1000;
        overflow-y: auto;
        padding: 40px 24px;
        transition: all 0.3s ease;
    }

    html[data-theme="light"] .dashboard-sidebar {
        background: linear-gradient(135deg, #000000 0%, #151105 100%);
        box-shadow: 10px 0 30px rgba(0, 0, 0, 0.2);
    }

    .sidebar-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 40px;
        text-decoration: none;
    }

    .sidebar-logo {
        width: 45px;
        height: 45px;
        object-fit: contain;
    }

    .sidebar-brand {
        font-family: var(--font-display);
        font-size: 1.3rem;
        font-weight: 800;
        color: #FFFFFF; /* Always white for luxury black sidebar */
        letter-spacing: 1px;
    }

    html[data-theme="dark"] .sidebar-brand {
        color: var(--text);
    }

    .sidebar-profile {
        text-align: center;
        margin-bottom: 35px;
        padding-bottom: 25px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    .profile-avatar-wrap {
        position: relative;
        width: 85px;
        height: 85px;
        margin: 0 auto 15px;
        padding: 3px;
        background: linear-gradient(135deg, var(--accent) 0%, #D48800 100%);
        border-radius: 50%;
        box-shadow: 0 5px 15px rgba(255, 184, 0, 0.2);
    }

    .profile-avatar {
        width: 100%;
        height: 100%;
        border-radius: 50%;
        border: 2px solid #000;
        object-fit: cover;
    }

    .profile-name {
        font-family: var(--font-display);
        font-size: 1.1rem;
        color: #FFFFFF;
        margin: 0 0 4px;
        font-weight: 700;
    }

    .profile-status {
        font-size: 0.75rem;
        color: var(--accent);
        text-transform: uppercase;
        letter-spacing: 2px;
        font-weight: 800;
    }

    .nav-label {
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 2px;
        color: rgba(255, 255, 255, 0.4);
        margin: 25px 0 12px 10px;
        font-weight: 800;
    }

    .nav-item {
        display: flex;
        align-items: center;
        gap: 14px;
        padding: 12px 18px;
        border-radius: 14px;
        color: rgba(255, 255, 255, 0.7);
        font-weight: 600;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        text-decoration: none;
        margin-bottom: 2px;
    }

    .nav-item i {
        font-size: 1.2rem;
        color: var(--accent);
        opacity: 0.8;
    }

    .nav-item:hover {
        background: rgba(255, 184, 0, 0.08);
        color: #FFFFFF;
        transform: translateX(5px);
    }

    .nav-item.active {
        background: var(--nav-active-bg);
        color: var(--nav-active-text);
        box-shadow: inset 0 0 0 1px rgba(255, 184, 0, 0.2);
    }

    .nav-item.logout {
        margin-top: 30px;
        color: #ff6b6b;
    }

    .nav-item.logout:hover {
        background: rgba(255, 107, 107, 0.1);
        color: #ff4d4d;
    }

    .dashboard-content {
        flex-grow: 1;
        margin-left: var(--sidebar-width);
        padding: 60px;
        width: calc(100% - var(--sidebar-width));
        position: relative;
        z-index: 1;
    }

    /* RTL Support */
    [dir="rtl"] .dashboard-sidebar {
        left: auto;
        right: 0;
        border-right: none;
        border-left: 1px solid var(--sidebar-border);
    }

    [dir="rtl"] .dashboard-content {
        margin-left: 0;
        margin-right: var(--sidebar-width);
    }

    @keyframes contentFade {
        from { opacity: 0; transform: translateY(15px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .dashboard-fx {
        position: fixed;
        inset: 0;
        z-index: 0;
        pointer-events: none;
        background-image: linear-gradient(to right, rgba(255, 184, 0, 0.03) 1px, transparent 1px),
                          linear-gradient(to bottom, rgba(255, 184, 0, 0.03) 1px, transparent 1px);
        background-size: 50px 50px;
    }

    .lang-mini {
        width: 34px;
        height: 34px;
        border-radius: 10px;
        border: 2px solid rgba(255, 255, 255, 0.1);
        transition: all 0.3s ease;
        opacity: 0.6;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }

    .lang-mini img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .lang-mini.active {
        opacity: 1;
        border-color: var(--accent);
        box-shadow: 0 0 15px rgba(255, 184, 0, 0.3);
    }

    @media (max-width: 1024px) {
        :root { --sidebar-width: 85px; }
        .sidebar-brand, .profile-name, .profile-status, .nav-item span, .nav-label { display: none; }
        .dashboard-sidebar { padding: 35px 15px; align-items: center; }
        .profile-avatar-wrap { width: 50px; height: 50px; }
        .nav-item { justify-content: center; padding: 18px; margin-bottom: 10px; }
        .dashboard-content { 
            padding: 40px 20px; 
            margin-left: var(--sidebar-width); 
            width: calc(100% - var(--sidebar-width)); 
        }
        [dir="rtl"] .dashboard-content {
            margin-left: 0;
            margin-right: var(--sidebar-width);
        }
    }
  </style>
  @yield('dashboard-styles')
</head>
<body>
    <div class="dashboard-fx"></div>
    <canvas id="fx" class="fx" style="position: fixed; inset: 0; z-index: 0; pointer-events: none;"></canvas>

    <div class="dashboard-layout">
        <!-- Sidebar -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-header">
                <img src="{{ asset('assets/img/logo-dark.png') }}" alt="SC" class="sidebar-logo">
                <span class="sidebar-brand">SmartCoach</span>
            </div>

            <div class="sidebar-profile" style="cursor: pointer;" data-section="profil">
                <div class="profile-avatar-wrap">
                    <img src="{{ Auth::user()->avatar ? asset('storage/' . Auth::user()->avatar) : asset('assets/img/avatar_placeholder.png') }}" alt="Profile" class="profile-avatar">
                </div>
                <h3 class="profile-name">{{ Auth::user()->name }}</h3>
                <span class="profile-status">Premium SC</span>
            </div>

            <nav class="dashboard-nav">
                <div class="nav-label">{{ __('Préférences') }}</div>
                
                <!-- Language Switcher Inline -->
                <div class="nav-item" style="padding: 0; background: transparent; cursor: default; flex-direction: column; align-items: flex-start; gap: 10px; margin-bottom: 5px;">
                    <div style="display: flex; gap: 8px; width: 100%; padding: 0 15px;">
                        <a href="{{ route('set-locale', 'fr') }}" class="lang-mini {{ app()->getLocale() == 'fr' ? 'active' : '' }}" title="Français">
                            <img src="{{ asset('assets/img/FR.png') }}" alt="FR">
                        </a>
                        <a href="{{ route('set-locale', 'en') }}" class="lang-mini {{ app()->getLocale() == 'en' ? 'active' : '' }}" title="English">
                            <img src="{{ asset('assets/img/ENG.png') }}" alt="EN">
                        </a>
                        <a href="{{ route('set-locale', 'ar') }}" class="lang-mini {{ app()->getLocale() == 'ar' ? 'active' : '' }}" title="العربية">
                            <img src="{{ asset('assets/img/AR.jpg') }}" alt="AR">
                        </a>
                    </div>
                </div>

                <!-- Theme Toggle -->
                <a href="#" class="nav-item" id="dashboardThemeToggle">
                    <i data-lucide="sun-moon"></i> <span>{{ __('Changer de thème') }}</span>
                </a>

                <div class="nav-label">{{ __('Menu Principal') }}</div>
                <a href="{{ route('dashboard') }}?section=dashboard" class="nav-item {{ (!request()->has('section') || request()->query('section') == 'dashboard') && request()->routeIs('dashboard') ? 'active' : '' }}" data-section="dashboard">
                    <i data-lucide="layout-dashboard"></i> <span>{{ __('Tableau de bord') }}</span>
                </a>
                <a href="{{ route('dashboard') }}?section=sante" class="nav-item {{ request()->query('section') == 'sante' ? 'active' : '' }}" data-section="sante">
                    <i data-lucide="heart-pulse"></i> <span>{{ __('Santé') }}</span>
                </a>
                <a href="{{ route('dashboard') }}?section=activite" class="nav-item {{ request()->query('section') == 'activite' ? 'active' : '' }}" data-section="activite">
                    <i data-lucide="map-pin"></i> <span>{{ __('Activité & GPS') }}</span>
                </a>
                <a href="{{ route('dashboard') }}?section=coaching" class="nav-item {{ request()->query('section') == 'coaching' ? 'active' : '' }}" data-section="coaching">
                    <i data-lucide="bot"></i> <span>{{ __('Coaching AI') }}</span>
                </a>
                <a href="{{ route('dashboard') }}?section=nutrition" class="nav-item {{ request()->query('section') == 'nutrition' ? 'active' : '' }}" data-section="nutrition">
                    <i data-lucide="utensils"></i> <span>{{ __('Nutrition') }}</span>
                </a>
                <a href="{{ route('modules.show', 'beeper') }}" class="nav-item {{ request()->routeIs('modules.show') && request()->route('slug') == 'beeper' ? 'active' : '' }}" data-section="beeper">
                    <i data-lucide="timer"></i> <span>{{ __('Chronomètre') }}</span>
                </a>
                
                <div class="nav-label">{{ __('Données & Rapports') }}</div>
                <a href="{{ route('dashboard') }}?section=analyses" class="nav-item" data-section="analyses">
                    <i data-lucide="bar-chart-3"></i> <span>{{ __('Analyses') }}</span>
                </a>
                <a href="{{ route('dashboard') }}?section=rapport" class="nav-item" data-section="rapport">
                    <i data-lucide="file-text"></i> <span>{{ __('Rapport Médical') }}</span>
                </a>
                
                <div class="nav-label">{{ __('Support') }}</div>
                <a href="{{ route('dashboard') }}?section=reclamation" class="nav-item" data-section="reclamation">
                    <i data-lucide="help-circle"></i> <span>{{ __('Réclamation') }}</span>
                </a>

                <a href="{{ route('home') }}" class="nav-item">
                    <i data-lucide="home"></i> <span>{{ __('Accueil') }}</span>
                </a>

                <form action="{{ route('logout') }}" method="POST" id="logout-form" style="display: none;">
                    @csrf
                </form>
                <a href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();" class="nav-item logout">
                    <i data-lucide="log-out"></i> <span>{{ __('Déconnexion') }}</span>
                </a>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="dashboard-content">
            @yield('dashboard-content')
        </main>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="{{ asset('assets/js/theme.js') }}"></script>
    <script src="{{ asset('assets/js/navigation.js') }}"></script>
    <script src="{{ asset('assets/js/questionnaire.js') }}"></script>
    <script src="{{ asset('assets/js/dashboard.js') }}"></script>
    <script src="{{ asset('assets/js/main.js') }}"></script>
    @yield('dashboard-scripts')
</body>
</html>
