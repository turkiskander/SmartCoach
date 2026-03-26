@extends('layouts.app')

@section('title', 'SmartCoach Admin — Connexion')

@section('styles')
<style>
    .login-section {
        min-height: calc(100vh - 80px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        margin-top: 80px;
    }
    .login-card {
        width: 100%;
        max-width: 520px;
        background: rgba(20, 10, 20, 0.6); 
        backdrop-filter: blur(20px); 
        border: 1px solid rgba(255, 100, 100, 0.2);
        border-radius: 32px; 
        padding: 40px 48px;
        text-align: center;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.8), 0 0 40px rgba(255, 50, 50, 0.1);
        animation: fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        position: relative;
        overflow: hidden;
    }
    .login-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0; right: 0; height: 4px;
        background: linear-gradient(90deg, #ff4b4b, #ff0000);
    }
    @keyframes fadeInScale {
        from { opacity: 0; transform: scale(0.95) translateY(10px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .admin-badge {
        display: inline-block;
        background: rgba(255, 75, 75, 0.15);
        color: #ff4b4b;
        padding: 6px 16px;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: 800;
        letter-spacing: 2px;
        text-transform: uppercase;
        margin-bottom: 20px;
        border: 1px solid rgba(255, 75, 75, 0.3);
    }
    .login-logo {
        width: 72px;
        margin: 0 auto 16px;
        filter: drop-shadow(0 0 10px rgba(255, 0, 0, 0.3));
    }
    .login-title {
        font-family: 'Orbitron', sans-serif;
        font-size: 1.8rem;
        font-weight: 700;
        margin-bottom: 8px;
        letter-spacing: 1px;
        color: #ffffff;
    }
    .login-subtitle {
        color: rgba(255, 255, 255, 0.6);
        font-size: 0.95rem;
        margin-bottom: 30px;
        line-height: 1.5;
    }
    .form-group {
        margin-bottom: 16px;
        text-align: left;
    }
    .input-wrapper {
        position: relative;
    }
    .input-icon {
        position: absolute;
        left: 20px;
        top: 50%;
        transform: translateY(-50%);
        color: rgba(255, 255, 255, 0.4);
        font-size: 1.2rem;
        transition: all 0.3s ease;
    }
    .login-input {
        width: 100%;
        background: rgba(0, 0, 0, 0.4);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 16px 20px 16px 52px;
        color: #ffffff;
        font-family: 'Inter', sans-serif;
        font-size: 0.95rem;
        transition: all 0.3s ease;
    }
    .login-input:focus {
        outline: none;
        border-color: #ff4b4b;
        background: rgba(255, 75, 75, 0.05);
        box-shadow: 0 0 15px rgba(255, 75, 75, 0.15);
    }
    .login-input:focus + .input-icon {
        color: #ff4b4b;
    }
    .login-btn {
        width: 100%;
        background: linear-gradient(135deg, #e63946 0%, #aa0000 100%);
        color: #ffffff;
        border: none;
        border-radius: 14px;
        padding: 18px;
        font-family: 'Inter', sans-serif;
        font-weight: 700;
        font-size: 1.1rem;
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        margin-top: 10px;
        box-shadow: 0 10px 20px -5px rgba(230, 57, 70, 0.5);
    }
    .login-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(230, 57, 70, 0.7);
        filter: brightness(1.1);
    }
    .error-msg {
        color: #ff4d4d; 
        font-size: 0.85rem; 
        margin-top: 6px; 
        display: block;
        font-weight: 500;
    }
    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin-top: 30px;
        color: rgba(255, 255, 255, 0.5);
        text-decoration: none;
        font-size: 0.9rem;
        font-weight: 500;
        transition: color 0.3s ease;
    }
    .back-link:hover {
        color: #ffffff;
    }
    
    [dir="rtl"] .input-icon {
        left: auto;
        right: 20px;
    }
    [dir="rtl"] .login-input {
        padding: 16px 52px 16px 20px;
    }
</style>
@endsection

@section('content')
<section class="login-section">
    <div class="login-card">
        <div class="admin-badge">Portail Administrateur</div>
        
        <img src="{{ asset('assets/img/logo-dark.png') }}" alt="SmartCoach Admin" class="login-logo">
        <h1 class="login-title">SmartCoach Pro</h1>
        <p class="login-subtitle">{{ __('Veuillez vous identifier pour accéder au panneau de configuration.') }}</p>

        <form action="{{ route('admin.login.post') }}" method="POST">
            @csrf
            
            <div class="form-group">
                <div class="input-wrapper">
                    <span class="input-icon">✉</span>
                    <input type="email" name="email" class="login-input" placeholder="admin@smartcoach.tn" required value="{{ old('email') }}">
                </div>
                @error('email')
                    <span class="error-msg">{{ $message }}</span>
                @enderror
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <span class="input-icon">🔒</span>
                    <input type="password" name="password" class="login-input" placeholder="{{ __('Mot de passe') }}" required>
                </div>
            </div>

            <button type="submit" class="login-btn">{{ __('Connexion Sécurisée') }}</button>
        </form>

        <a href="{{ route('home') }}" class="back-link">
            <span>←</span> {{ __('Retour au site public') }}
        </a>
    </div>
</section>
@endsection
