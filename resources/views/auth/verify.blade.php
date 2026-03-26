@extends('layouts.app')

@section('title', 'SmartCoach — Vérification')

@section('styles')
<style>
    .verify-section {
        min-height: calc(100vh - 80px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        margin-top: 80px;
    }

    .verify-card {
        width: 100%;
        max-width: 480px;
        background: rgba(15, 23, 42, 0.4);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: 32px;
        padding: 48px;
        text-align: center;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
        animation: fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1);
    }

    @keyframes fadeInScale {
        from { opacity: 0; transform: scale(0.95) translateY(10px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }

    .verify-icon {
        font-size: 3rem;
        margin-bottom: 24px;
        display: block;
    }

    .verify-title {
        font-family: 'Orbitron', sans-serif;
        font-size: 1.8rem;
        font-weight: 700;
        margin-bottom: 12px;
        color: var(--text);
    }
    .verify-subtitle {
        color: var(--text-muted);
        font-size: 0.95rem;
        margin-bottom: 32px;
        line-height: 1.6;
    }
    .code-input-container {
        display: flex;
        justify-content: center;
        gap: 12px;
        margin-bottom: 32px;
    }
    .code-input {
        width: 100%;
        background: rgba(15, 23, 42, 0.6);
        border: 2px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 20px;
        color: #FFB800;
        font-family: 'Orbitron', sans-serif;
        font-size: 2rem;
        font-weight: 700;
        text-align: center;
        letter-spacing: 12px;
        transition: all 0.3s ease;
    }
    .code-input:focus {
        outline: none;
        border-color: #FFB800;
        background: rgba(255, 255, 255, 0.08);
        box-shadow: 0 0 15px rgba(255, 184, 0, 0.2);
    }
    .verify-btn {
        width: 100%;
        background: linear-gradient(135deg, #FFB800 0%, #D48800 100%);
        color: #000;
        border: none;
        border-radius: 14px;
        padding: 18px;
        font-weight: 700;
        font-size: 1.1rem;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 10px 20px -5px rgba(255, 184, 0, 0.4);
    }
    .verify-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(255, 184, 0, 0.6);
    }
    .resend-link {
        margin-top: 24px;
        display: block;
        color: var(--text-muted);
        text-decoration: none;
        font-size: 0.9rem;
        transition: color 0.3s ease;
    }
    .resend-link:hover {
        color: #FFB800;
    }
</style>
@endsection

@section('content')
<section class="verify-section">
    <div class="verify-card">
        <span class="verify-icon">✉️</span>
        <h1 class="verify-title">Vérification</h1>
        <p class="verify-subtitle">Nous avons envoyé un code à 6 chiffres à votre adresse e-mail. Veuillez le saisir ci-dessous pour continuer.</p>

        <form action="{{ route('verify.post') }}" method="POST">
            @csrf
            <div class="form-group">
                <input type="text" name="code" class="code-input" maxlength="6" pattern="\d{6}" placeholder="000000" required autofocus autocomplete="off">
            </div>
            
            @error('code')
                <p style="color: #ff4d4d; font-size: 0.85rem; margin-bottom: 20px;">{{ $message }}</p>
            @enderror

            <button type="submit" class="verify-btn">Vérifier le code</button>
        </form>

        <a href="#" class="resend-link">Je n'ai pas reçu le code. Renvoyer.</a>
    </div>
</section>
@endsection
