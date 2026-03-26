<div id="section-dashboard" class="dashboard-section-content">
    <div class="welcome-banner">
        <div class="banner-content">
            <span class="banner-badge">{{ __('Profil Activé') }}</span>
            <h1>{{ __('Prêt pour votre séance') }}, {{ Auth::user()->name }} ?</h1>
            <p>
                {{ __('Bienvenue dans votre espace SmartCoach. Vos analyses personnalisées sont en cours de génération basées sur votre objectif :') }} <strong>{{ __(str_replace('_', ' ', Auth::user()->goal)) }}</strong>.
            </p>
        </div>
        <div class="banner-icon">
            <i data-lucide="sparkles" style="width: 64px; height: 64px; color: var(--accent); opacity: 0.3;"></i>
        </div>
    </div>

    <div class="stats-grid">
        <!-- Health Cardio -->
        <div class="stat-card">
            <div class="stat-icon"><i data-lucide="activity"></i></div>
            <div class="stat-value">72 <span style="font-size: 0.8rem; opacity: 0.6;">BPM</span></div>
            <div class="stat-label">{{ __('Rythme Cardiaque') }}</div>
            <div class="stat-trend trend-up">
                <i class="lucide-trending-up"></i> {{ __('Stable') }}
            </div>
        </div>

        <!-- Daily Steps -->
        <div class="stat-card">
            <div class="stat-icon"><i data-lucide="footprints"></i></div>
            <div class="stat-value">8,432</div>
            <div class="stat-label">{{ __('Pas Quotidiens') }}</div>
            <div class="stat-trend trend-up">
                <i class="lucide-trending-up"></i> +12% {{ __('vs hier') }}
            </div>
        </div>

        <!-- Calories Burned -->
        <div class="stat-card">
            <div class="stat-icon"><i data-lucide="flame"></i></div>
            <div class="stat-value">450 <span style="font-size: 0.8rem; opacity: 0.6;">KCAL</span></div>
            <div class="stat-label">{{ __('Calories Brûlées') }}</div>
            <div class="stat-trend trend-down">
                <i class="lucide-trending-down"></i> -5% {{ __('vs hier') }}
            </div>
        </div>

        <!-- Hydration -->
        <div class="stat-card">
            <div class="stat-icon"><i data-lucide="droplets"></i></div>
            <div class="stat-value">1.2 <span style="font-size: 0.8rem; opacity: 0.6;">L</span></div>
            <div class="stat-label">{{ __('Hydratation') }}</div>
            <div class="stat-trend trend-up">
                <i class="lucide-trending-up"></i> {{ __('Objectif') }}: 2.5L
            </div>
        </div>
    </div>
</div>
