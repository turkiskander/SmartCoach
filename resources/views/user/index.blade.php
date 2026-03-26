@extends('layouts.dashboard')

@section('dashboard-styles')
<style>
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 25px;
        margin-top: 30px;
    }

    .stat-card {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 24px;
        padding: 25px;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
        backdrop-filter: blur(10px);
    }

    html[data-theme="light"] .stat-card {
        background: rgba(255, 255, 255, 0.85);
        border-color: rgba(0, 0, 0, 0.05);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
    }

    .dashboard-section-content {
        animation: contentFade 0.6s cubic-bezier(0.16, 1, 0.3, 1);
    }

    .stat-card::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 4px;
        height: 100%;
        background: var(--accent);
        opacity: 0.5;
    }

    .stat-card:hover {
        transform: translateY(-5px);
        background: rgba(255, 255, 255, 0.05);
        border-color: rgba(255, 184, 0, 0.3);
    }

    html[data-theme="light"] .stat-card:hover {
        background: #FFFFFF;
        border-color: var(--accent);
    }

    .stat-icon {
        width: 52px;
        height: 52px;
        border-radius: 14px;
        background: rgba(255, 184, 0, 0.1);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--accent);
        margin-bottom: 20px;
        font-size: 1.6rem;
        box-shadow: 0 5px 15px rgba(255, 184, 0, 0.1);
    }

    .stat-value {
        font-family: var(--font-display);
        font-size: 2.2rem;
        color: var(--text);
        margin-bottom: 5px;
        letter-spacing: -1px;
    }

    .stat-label {
        color: var(--muted);
        font-size: 0.85rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .stat-trend {
        margin-top: 15px;
        font-size: 0.85rem;
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: 600;
    }

    .trend-up { color: #10b981; }
    .trend-down { color: #ef4444; }

    .welcome-banner {
        background: linear-gradient(135deg, rgba(0, 0, 0, 0.8) 0%, rgba(13, 17, 23, 0.6) 100%);
        border: 1px solid rgba(255, 184, 0, 0.2);
        border-radius: 32px;
        padding: 45px;
        margin-bottom: 40px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 30px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 20px 40px rgba(0,0,0,0.3);
    }

    html[data-theme="light"] .welcome-banner {
        background: linear-gradient(135deg, #000000 0%, #151105 100%);
        border-color: rgba(255, 184, 0, 0.4);
    }

    .welcome-banner::after {
        content: "";
        position: absolute;
        right: -30px;
        top: -30px;
        width: 250px;
        height: 250px;
        background: radial-gradient(circle, rgba(255, 184, 0, 0.15) 0%, transparent 70%);
        pointer-events: none;
    }

    .banner-content h1 {
        font-family: var(--font-display);
        font-size: 2.5rem;
        margin-bottom: 15px;
        color: #FFFFFF;
        line-height: 1.1;
    }

    .banner-content p {
        color: rgba(255, 255, 255, 0.7);
        font-size: 1.15rem;
        max-width: 600px;
        line-height: 1.6;
    }

    .banner-badge {
        background: var(--accent);
        color: #000;
        padding: 8px 24px;
        border-radius: 99px;
        font-weight: 800;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 2px;
        margin-bottom: 20px;
        display: inline-block;
        box-shadow: 0 5px 15px rgba(255, 184, 0, 0.3);
    }

    /* Standardized Components */
    .welcome-title {
        font-family: var(--font-display);
        color: var(--text);
        font-weight: 800;
        letter-spacing: 1px;
        margin-bottom: 25px;
    }

    .btn-primary {
        background: var(--accent);
        color: #000 !important;
        padding: 12px 25px;
        border-radius: 14px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 1px;
        border: none;
        cursor: pointer;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 10px;
        box-shadow: 0 10px 20px rgba(255, 184, 0, 0.2);
    }

    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px rgba(255, 184, 0, 0.3);
        filter: brightness(1.1);
    }

    .btn-ghost {
        background: rgba(255, 255, 255, 0.05);
        color: var(--text);
        padding: 12px 25px;
        border-radius: 14px;
        font-weight: 700;
        border: 1px solid rgba(255, 255, 255, 0.1);
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .btn-ghost:hover {
        background: rgba(255, 255, 255, 0.1);
        border-color: var(--accent);
    }

    html[data-theme="light"] .btn-ghost {
        background: #FFFFFF;
        border-color: rgba(0, 0, 0, 0.1);
        color: #000;
    }

    /* Module Cards CSS */
    .modules-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 30px;
        margin-top: 30px;
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
        color: var(--text);
    }

    .module-title:hover {
        color: var(--text);
    }

    .module-desc {
        font-size: 1rem;
        color: var(--muted);
        line-height: 1.6;
        font-weight: 500;
        margin-bottom: 0px;
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
        font-style: normal;
    }

    .module-card:hover .module-arrow {
        opacity: 1;
        transform: translateX(0);
    }

    .icon-svg { width: 32px; height: 32px; fill: currentColor; }
</style>
@endsection

@section('dashboard-content')
    @include('user.partials.home')
    @include('user.partials.profile')
    @include('user.partials.health')
    @include('user.partials.activity')
    @include('user.partials.coaching')
    @include('user.partials.nutrition')
    @include('user.partials.analysis')
    @include('user.partials.report')
    @include('user.partials.support')
@endsection
