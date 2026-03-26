<div id="section-sante" class="dashboard-section-content" style="display: none;">
    <h2 class="welcome-title" style="text-align: left; font-size: 2rem;">{{ __('Suivi de Santé') }}</h2>
    <div class="stat-card" style="margin-top: 20px; text-align: center; padding: 100px 40px; border-style: dashed;">
        <i data-lucide="heart-pulse" style="width: 56px; height: 56px; color: var(--accent); margin-bottom: 25px; opacity: 0.5;"></i>
        <h3 class="welcome-title" style="margin-bottom: 10px;">{{ __('Analyse Cardiaque Avancée') }}</h3>
        <p style="color: var(--muted); font-size: 1.1rem;">{{ __('Connectez vos appareils pour visualiser vos données de santé en temps réel.') }}</p>
    </div>

    <h3 class="welcome-title" style="margin-top: 40px; font-size: 1.5rem;">{{ __('Outils de Santé') }}</h3>
    <div class="modules-grid">
        <!-- PP Calculator -->
        <a href="{{ route('modules.show', 'pp_calculator') }}" class="module-card">
            <div>
                <div class="module-icon-wrap">
                    <svg class="icon-svg" viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zm4.24 16L12 15.45 7.77 18l1.12-4.81-3.73-3.23 4.92-.42L12 5l1.92 4.53 4.92.42-3.73 3.23L16.23 18z"/></svg>
                </div>
                <h2 class="module-title">Health (PP)</h2>
                <p class="module-desc">Analyse complète : métabolisme de base, VO2Max, zones de fréquence cardiaque et pressions physiologiques.</p>
            </div>
            <i class="module-arrow">→</i>
        </a>
    </div>
</div>
