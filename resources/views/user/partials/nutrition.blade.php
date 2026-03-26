<div id="section-nutrition" class="dashboard-section-content" style="display: none;">
    <h2 class="welcome-title" style="text-align: left; font-size: 2rem;">{{ __('Nutrition & Hydratation') }}</h2>
    <div class="stats-grid" style="margin-top: 20px;">
        <div class="stat-card">
            <h3>{{ __('Macros du jour') }}</h3>
            <p>{{ __('Protéines') }}: 120g / 180g</p>
            <div style="height: 10px; background: rgba(255,255,255,0.1); border-radius: 5px; margin: 10px 0;">
                <div style="width: 66%; height: 100%; background: var(--accent); border-radius: 5px;"></div>
            </div>
        </div>
    </div>

    <h3 class="welcome-title" style="margin-top: 40px; font-size: 1.5rem;">{{ __('Outils Nutritionnels') }}</h3>
    <div class="modules-grid">
        <!-- Protein Calculator -->
        <a href="{{ route('modules.show', 'protein') }}" class="module-card">
            <div>
                <div class="module-icon-wrap">
                    <svg class="icon-svg" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z"/></svg>
                </div>
                <h2 class="module-title">Protein Calculator</h2>
                <p class="module-desc">Calculez précisément vos besoins journaliers en protéines selon votre profil, votre activité et vos objectifs.</p>
            </div>
            <i class="module-arrow">→</i>
        </a>
    </div>
</div>
