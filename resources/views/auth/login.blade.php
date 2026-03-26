@extends('layouts.app')

@section('title', 'SmartCoach — Se connecter')

@section('styles')
<style>
    .login-section {
        min-height: calc(100vh - 80px); /* Adjust based on header height */
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        margin-top: 80px; /* Header space */
    }
    .login-card {
        width: 100%;
        max-width: 520px; /* Increased horizontal from 480px */
        background: rgba(15, 23, 42, 0.4); 
        backdrop-filter: blur(20px); 
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: 32px; 
        padding: 32px 48px; /* Decreased vertical from 48px */
        text-align: center;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
        animation: fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1);
    }
    @keyframes fadeInScale {
        from { opacity: 0; transform: scale(0.95) translateY(10px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .login-logo {
        width: 64px; /* Slightly smaller logo */
        margin: 0 auto 16px;
    }
    .login-title {
        font-family: 'Orbitron', sans-serif;
        font-size: 1.8rem;
        font-weight: 700;
        margin-bottom: 4px; /* Reduced from 8px */
        letter-spacing: 1px;
        color: var(--text);
    }
    .login-subtitle {
        color: var(--text-muted);
        font-size: 0.9rem;
        margin-bottom: 24px; /* Reduced from 32px */
        line-height: 1.5;
        opacity: 0.8;
    }
    .form-group {
        margin-bottom: 12px; /* Reduced from 16px */
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
        color: var(--text-muted);
        font-size: 1.1rem;
        font-size: 1.2rem;
        opacity: 0.5;
        transition: all 0.3s ease;
    }
    .login-input {
        width: 100%;
        background: rgba(15, 23, 42, 0.6);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 16px 20px 16px 52px;
        color: var(--text);
        font-family: 'Inter', sans-serif;
        font-size: 0.95rem;
        transition: all 0.3s ease;
    }
    .login-input:focus {
        outline: none;
        border-color: #FFB800; /* Gold focus */
        background: rgba(255, 255, 255, 0.08);
        box-shadow: 0 0 15px rgba(255, 184, 0, 0.2);
    }
    .login-input:focus + .input-icon {
        opacity: 1;
        color: #FFB800; /* Gold icon on focus */
    }
    .login-btn {
        width: 100%;
        background: linear-gradient(135deg, #FFB800 0%, #D48800 100%); /* Gold Gradient */
        color: #000;
        border: none;
        border-radius: 14px;
        padding: 20px; /* Increased from 16px */
        font-family: 'Inter', sans-serif;
        font-weight: 700;
        font-size: 1.1rem; /* Increased from 1rem */
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        margin-top: 12px; /* Reduced from 20px */
        box-shadow: 0 10px 20px -5px rgba(255, 184, 0, 0.4);
    }
    .login-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(255, 184, 0, 0.6);
        filter: brightness(1.1);
    }
    .forgot-pass {
        display: block;
        margin: 16px 0; /* Reduced from 24px */
        color: var(--text-muted);
        text-decoration: none;
        font-size: 0.85rem;
        transition: color 0.3s ease;
        font-weight: 500;
    }
    .forgot-pass:hover {
        color: #FFB800;
    }
    .divider {
        display: flex;
        align-items: center;
        margin: 16px 0; /* Reduced from 24px */
        color: var(--text-muted);
        font-size: 0.75rem;
        opacity: 0.5;
    }
    .divider::before, .divider::after {
        content: "";
        flex: 1;
        height: 1px;
        background: rgba(255, 255, 255, 0.1);
    }
    .divider span {
        padding: 0 16px;
        text-transform: uppercase;
        letter-spacing: 2px;
    }
    .google-btn {
        width: 100%;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 14px; /* Reduced from 16px */
        color: var(--text);
        font-family: 'Inter', sans-serif;
        font-weight: 600;
        font-size: 0.9rem;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    .google-btn:hover {
        background: rgba(255, 255, 255, 0.08);
        border-color: rgba(255, 255, 255, 0.2);
    }
    .google-icon {
        width: 18px; /* Slightly smaller */
        height: 18px;
    }
    .signup-link {
        margin-top: 40px;
        font-size: 0.9rem;
        color: var(--text-muted);
    }
    .signup-link span:hover {
        color: #FFB800;
        text-decoration: underline;
    }
    .signup-link a {
        color: #FFB800;
        text-decoration: none;
        font-weight: 700;
        transition: all 0.3s ease;
    }
    .signup-link a:hover {
        text-decoration: underline;
        filter: brightness(1.2);
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
        <img src="{{ asset('assets/img/logo-dark.png') }}" alt="SmartCoach" class="login-logo">
        <h1 class="login-title">Smart Coach</h1>
        <p class="login-subtitle">{{ __('Saisissez votre adresse e-mail et mot de passe ci-dessous pour vous connecter à votre compte.') }}</p>

        <form action="{{ route('login.post') }}" method="POST">
            @csrf
            <div class="form-group">
                <div class="input-wrapper">
                    <span class="input-icon">✉</span>
                    <input type="email" name="email" class="login-input" placeholder="nom@smart.com" required value="{{ old('email') }}">
                </div>
                @error('email')
                    <span style="color: #ff4d4d; font-size: 0.8rem; margin-top: 4px; display: block;">{{ $message }}</span>
                @enderror
            </div>

            <div class="form-group">
                <div class="input-wrapper">
                    <span class="input-icon">🔒</span>
                    <input type="password" name="password" class="login-input" placeholder="{{ __('Mot de passe') }}" required>
                </div>
            </div>

            <button type="submit" class="login-btn">{{ __('Se connecter') }}</button>
        </form>

        <a href="#" class="forgot-pass">{{ __('Mot de passe oublié ?') }}</a>

        <div class="divider">
            <span>{{ __('ou') }}</span>
        </div>

        <button class="google-btn">
            <svg class="google-icon" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            {{ __('Connecter avec un compte Google') }}
        </button>

        <p class="signup-link">
            {{ __('Vous n\'avez pas de compte ?') }} <a href="{{ route('register') }}">{{ __('Inscrivez-vous') }}</a>
        </p>
    </div>
</section>
@endsection
