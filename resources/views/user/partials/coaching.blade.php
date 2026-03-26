<div id="section-coaching" class="dashboard-section-content" style="display: none;">
    <h2 class="welcome-title" style="text-align: left; font-size: 2rem;">{{ __('Coaching AI') }}</h2>
    <div class="stat-card" style="margin-top: 20px; border-left: 5px solid var(--accent); padding: 40px;">
        <h3 class="welcome-title" style="margin-bottom: 15px;">{{ __('Votre programme AI personnalisé') }}</h3>
        <p style="margin-bottom: 25px; color: var(--muted);">{{ __('Basé sur vos dernières performances, voici vos recommandations pour demain.') }}</p>
        <div style="background: rgba(255,184,0,0.05); padding: 25px; border-radius: 20px; border: 1px solid rgba(255,184,0,0.1);">
            <p style="margin-bottom: 10px;"><strong>Focus :</strong> <span style="color: var(--accent);">{{ __('Haute Intensité (HIIT)') }}</span></p>
            <p style="margin: 0;"><strong>{{ __('Durée') }} :</strong> <span style="color: var(--accent);">45 {{ __('minutes') }}</span></p>
        </div>
    </div>

    <h3 class="welcome-title" style="margin-top: 40px; font-size: 1.5rem;">{{ __('Outils d\'Entraînement') }}</h3>
    <div class="modules-grid">
        <!-- Training Calculation -->
        <a href="{{ route('modules.show', 'training_calculation') }}" class="module-card">
            <div>
                <div class="module-icon-wrap" style="background: linear-gradient(135deg, rgba(14, 165, 233, 0.2) 0%, rgba(14, 165, 233, 0.05) 100%); color: #0EA5E9; border-color: rgba(14, 165, 233, 0.2);">
                    <svg class="icon-svg" viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6l-1.41-1.41-7.09 7.09-4-4L2 14.99l1.5 1.5z"/></svg>
                </div>
                <h2 class="module-title">Training Calculation</h2>
                <p class="module-desc">16 outils avancés : VMA, Cooper, Ruffier, YMCA, Charge d'entraînement (UA) et métabolisme.</p>
            </div>
            <i class="module-arrow">→</i>
        </a>

        <!-- General Calculator -->
        <a href="{{ route('modules.show', 'calculator') }}" class="module-card">
            <div>
                <div class="module-icon-wrap">
                    <svg class="icon-svg" viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/></svg>
                </div>
                <h2 class="module-title">Calculatrice</h2>
                <p class="module-desc">Outils mathématiques rapides pour évaluer l'IMC, le RM (Répétition Maximale) et autres indices corporels.</p>
            </div>
            <i class="module-arrow">→</i>
        </a>
    </div>
</div>
