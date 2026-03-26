@extends('layouts.dashboard')

@section('dashboard-styles')
<style>
    .modules-banner {
        background: linear-gradient(135deg, rgba(8, 14, 23, 0.9) 0%, rgba(15, 23, 42, 0.8) 100%);
        border: 1px solid rgba(255, 184, 0, 0.3);
        border-radius: 32px;
        padding: 50px;
        margin-bottom: 40px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 20px 40px rgba(0,0,0,0.4);
    }
    
    html[data-theme="light"] .modules-banner {
        background: linear-gradient(135deg, #111 0%, #222 100%);
        color: white;
    }

    .modules-banner::before {
        content: "";
        position: absolute;
        top: -100px;
        right: -100px;
        width: 300px;
        height: 300px;
        background: radial-gradient(circle, rgba(255,184,0,0.2) 0%, transparent 60%);
        filter: blur(40px);
    }

    .banner-badge {
        background: var(--accent, #FFB800);
        color: #000;
        padding: 8px 24px;
        border-radius: 99px;
        font-weight: 800;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 2px;
        margin-bottom: 25px;
        display: inline-block;
        box-shadow: 0 5px 15px rgba(255, 184, 0, 0.3);
    }

    .modules-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 30px;
        margin-top: 10px;
    }

    .module-card {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 28px;
        padding: 35px;
        text-decoration: none;
        color: var(--text);
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        position: relative;
        overflow: hidden;
        backdrop-filter: blur(12px);
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        min-height: 250px;
    }

    html[data-theme="light"] .module-card {
        background: rgba(255, 255, 255, 0.9);
        border-color: rgba(0, 0, 0, 0.08);
        box-shadow: 0 15px 35px rgba(0,0,0,0.05);
    }

    .module-card:hover {
        transform: translateY(-10px) scale(1.02);
        background: rgba(255, 255, 255, 0.08);
        border-color: rgba(255, 184, 0, 0.5);
        box-shadow: 0 25px 50px rgba(0,0,0,0.3);
    }

    html[data-theme="light"] .module-card:hover {
        background: #FFFFFF;
        box-shadow: 0 25px 50px rgba(0,0,0,0.1);
    }

    .module-icon-wrap {
        width: 70px;
        height: 70px;
        border-radius: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2rem;
        margin-bottom: 25px;
        background: linear-gradient(135deg, rgba(255,184,0,0.2) 0%, rgba(255,184,0,0.05) 100%);
        color: var(--accent, #FFB800);
        border: 1px solid rgba(255,184,0,0.2);
        box-shadow: 0 10px 20px rgba(255, 184, 0, 0.15);
        transition: all 0.4s ease;
    }

    .module-card:hover .module-icon-wrap {
        transform: scale(1.1) rotate(5deg);
        background: var(--accent, #FFB800);
        color: #000;
        box-shadow: 0 15px 30px rgba(255, 184, 0, 0.4);
    }

    .module-title {
        font-family: var(--font-display);
        font-size: 1.8rem;
        font-weight: 800;
        margin-bottom: 15px;
        letter-spacing: -0.5px;
    }

    .module-desc {
        font-size: 1rem;
        color: var(--muted);
        line-height: 1.6;
        font-weight: 500;
    }

    .module-arrow {
        position: absolute;
        bottom: 35px;
        right: 35px;
        opacity: 0;
        transform: translateX(-20px);
        color: var(--accent, #FFB800);
        transition: all 0.4s ease;
        font-size: 1.5rem;
    }

    .module-card:hover .module-arrow {
        opacity: 1;
        transform: translateX(0);
    }

    /* Icons via Boxicons or FontAwesome (assuming they are included in dashboard layout, will use SVG fallback if not) */
    .icon-svg { width: 32px; height: 32px; fill: currentColor; }
</style>
@endsection

@section('dashboard-content')
<div class="dashboard-section-content active">
    
    <div class="modules-banner">
        <div class="banner-badge">SMART TOOLS</div>
        <h1 style="font-family: var(--font-display); font-size: 3rem; margin-bottom: 15px; font-weight: 900; letter-spacing: -1px;">
            Outils & Calculateurs
        </h1>
        <p style="font-size: 1.2rem; color: rgba(255,255,255,0.7); max-width: 650px; line-height: 1.6;">
            Accédez à vos modules avancés pour calculer vos besoins nutritionnels, gérer vos chronomètres d'entraînement et analyser vos paramètres de santé.
        </p>
    </div>

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

        <!-- Beeper -->
        <a href="{{ route('modules.show', 'beeper') }}" class="module-card">
            <div>
                <div class="module-icon-wrap">
                    <svg class="icon-svg" viewBox="0 0 24 24"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
                </div>
                <h2 class="module-title">Beeper & Timer</h2>
                <p class="module-desc">Chronomètres avancés pour vos entraînements intermittents et vos protocoles de test (Beep Test).</p>
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
    </div>

</div>
@endsection
