@extends('layouts.app')

@section('title', 'SmartCoach — Inscription')

@section('styles')
<style>
    .register-section {
        min-height: calc(100vh - 80px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 40px 20px;
        margin-top: 80px;
    }
    .register-card {
        width: 100%;
        max-width: 600px;
        background: rgba(15, 23, 42, 0.4);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: 32px;
        padding: 40px;
        text-align: center;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
        animation: fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        position: relative;
        overflow: hidden;
    }
    @keyframes fadeInScale {
        from { opacity: 0; transform: scale(0.95) translateY(10px); }
        to { opacity: 1; transform: scale(1) translateY(0); }
    }
    .step-indicator {
        display: flex;
        justify-content: center;
        gap: 12px;
        margin-bottom: 32px;
    }
    .step-dot {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.2);
        transition: all 0.3s ease;
    }
    .step-dot.active {
        background: #FFB800;
        box-shadow: 0 0 10px rgba(255, 184, 0, 0.5);
        width: 30px;
        border-radius: 5px;
    }
    .register-title {
        font-family: 'Orbitron', sans-serif;
        font-size: 1.8rem;
        font-weight: 700;
        margin-bottom: 8px;
        color: var(--text);
    }
    .register-subtitle {
        color: var(--text-muted);
        font-size: 0.9rem;
        margin-bottom: 32px;
        opacity: 0.8;
    }
    .form-step {
        display: none;
        animation: slideIn 0.5s ease;
    }
    .form-step.active {
        display: block;
    }
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(20px); }
        to { opacity: 1; transform: translateX(0); }
    }
    .form-group {
        margin-bottom: 20px;
        text-align: left;
    }
    .label-premium {
        display: block;
        margin-bottom: 8px;
        font-size: 0.85rem;
        font-weight: 600;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    .input-wrapper {
        position: relative;
    }
    .register-input {
        width: 100%;
        background: rgba(15, 23, 42, 0.6);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 14px 20px;
        color: var(--text);
        font-family: 'Inter', sans-serif;
        font-size: 0.95rem;
        transition: all 0.3s ease;
    }
    .register-input:focus {
        outline: none;
        border-color: #FFB800;
        background: rgba(255, 255, 255, 0.08);
        box-shadow: 0 0 15px rgba(255, 184, 0, 0.2);
    }
    .input-unit {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-muted);
        font-size: 0.85rem;
        font-weight: 600;
    }
    .gender-options {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
    }
    .gender-option {
        position: relative;
        cursor: pointer;
    }
    .gender-option input {
        display: none;
    }
    .gender-label {
        display: block;
        padding: 12px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        text-align: center;
        transition: all 0.3s ease;
        font-weight: 500;
    }
    .gender-option input:checked + .gender-label {
        background: rgba(255, 184, 0, 0.1);
        border-color: #FFB800;
        color: #FFB800;
    }
    .offers-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-top: 20px;
    }
    .offer-card {
        position: relative;
        cursor: pointer;
    }
    .offer-card input {
        display: none;
    }
    .offer-content {
        height: 100%;
        padding: 20px 10px;
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 16px;
        transition: all 0.3s ease;
    }
    .offer-card input:checked + .offer-content {
        background: linear-gradient(135deg, rgba(255, 184, 0, 0.2) 0%, rgba(212, 136, 0, 0.1) 100%);
        border-color: #FFB800;
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
    }
    .offer-title {
        font-weight: 700;
        font-size: 0.9rem;
        margin-bottom: 5px;
    }
    .offer-price {
        font-family: 'Orbitron', sans-serif;
        color: #FFB800;
        font-size: 1.2rem;
        font-weight: 700;
    }
    .btn-container {
        display: flex;
        gap: 15px;
        margin-top: 32px;
    }
    .nav-btn {
        flex: 1;
        padding: 16px;
        border-radius: 14px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.3s ease;
        border: none;
    }
    .btn-next {
        background: linear-gradient(135deg, #FFB800 0%, #D48800 100%);
        color: #000;
        box-shadow: 0 10px 20px -5px rgba(255, 184, 0, 0.4);
    }
    .btn-next:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px -5px rgba(255, 184, 0, 0.6);
    }
    .btn-prev {
        background: rgba(255, 255, 255, 0.05);
        color: var(--text);
        border: 1px solid rgba(255, 255, 255, 0.1);
    }
    .btn-prev:hover {
        background: rgba(255, 255, 255, 0.1);
    }
</style>
@endsection

@section('content')
<section class="register-section">
    <div class="register-card">
        <div class="step-indicator">
            <div class="step-dot active" data-step="1"></div>
            <div class="step-dot" data-step="2"></div>
            <div class="step-dot" data-step="3"></div>
            <div class="step-dot" data-step="4"></div>
        </div>

        <h1 class="register-title">Smart Coach</h1>
        <p class="register-subtitle" id="step-desc">Étape 1 : Créez votre compte</p>

        @if ($errors->any())
            <div style="background: rgba(255, 77, 77, 0.1); border: 1px solid #ff4d4d; border-radius: 12px; padding: 15px; margin-bottom: 20px; text-align: left;">
                <ul style="color: #ff4d4d; font-size: 0.85rem; margin: 0; padding-left: 20px;">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('register.post') }}" method="POST" id="register-form">
            @csrf
            
            <!-- Step 1: Basic Info -->
            <div class="form-step active" id="step-1">
                <div class="form-group">
                    <label class="label-premium">Nom Complet</label>
                    <input type="text" name="name" class="register-input" placeholder="Elon Musk" required>
                </div>
                <div class="form-group">
                    <label class="label-premium">Email</label>
                    <input type="email" name="email" class="register-input" placeholder="nom@smart.com" required>
                </div>
                <div class="form-group">
                    <label class="label-premium">Mot de passe</label>
                    <input type="password" name="password" id="password" class="register-input" placeholder="••••••••" required>
                </div>
                <div class="form-group">
                    <label class="label-premium">Confirmer le mot de passe</label>
                    <input type="password" name="password_confirmation" id="password_confirmation" class="register-input" placeholder="••••••••" required>
                    <p id="password-error" style="color: #ff4d4d; font-size: 0.75rem; margin-top: 5px; display: none;">Les mots de passe ne correspondent pas.</p>
                </div>
            </div>

            <!-- Step 2: Physical Data -->
            <div class="form-step" id="step-2">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div class="form-group">
                        <label class="label-premium">Taille</label>
                        <div class="input-wrapper">
                            <input type="number" name="height" class="register-input" placeholder="180" step="0.1" required>
                            <span class="input-unit">cm</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="label-premium">Poids</label>
                        <div class="input-wrapper">
                            <input type="number" name="weight" class="register-input" placeholder="75" step="0.1" required>
                            <span class="input-unit">kg</span>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <label class="label-premium">Date de naissance</label>
                    <input type="text" name="date_of_birth" id="date_of_birth_input" class="register-input" placeholder="JJ/MM/AAAA" maxlength="10" required>
                    <p id="date-error" style="color: #ff4d4d; font-size: 0.75rem; margin-top: 5px; display: none;">Format invalide (JJ/MM/AAAA).</p>
                </div>
                <div class="form-group">
                    <label class="label-premium">Genre</label>
                    <div class="gender-options">
                        <label class="gender-option">
                            <input type="radio" name="gender" value="homme" checked>
                            <span class="gender-label">Homme</span>
                        </label>
                        <label class="gender-option">
                            <input type="radio" name="gender" value="femme">
                            <span class="gender-label">Femme</span>
                        </label>
                    </div>
                </div>
                <div class="form-group">
                    <label class="label-premium">Poids Idéal (Objectif)</label>
                    <div class="input-wrapper">
                        <input type="number" name="ideal_weight" class="register-input" placeholder="70" step="0.1" required>
                        <span class="input-unit">kg</span>
                    </div>
                    <p style="font-size: 0.75rem; color: #FFB800; margin-top: 5px; opacity: 0.8;">"Visualisez votre succès !"</p>
                </div>
            </div>

            <!-- Step 3: Goals -->
            <div class="form-step" id="step-3">
                <div class="form-group">
                    <label class="label-premium">Objectif Principal</label>
                    <select name="goal" class="register-input" required>
                        <option value="perdre_poids">Perdre du poids</option>
                        <option value="prendre_muscle">Prendre du muscle</option>
                        <option value="endurance">Améliorer mon endurance</option>
                        <option value="bien_etre">Rester en forme / Bien-être</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="label-premium">Niveau d'activité</label>
                    <select name="activity_level" class="register-input" required>
                        <option value="sedentaire">Sédentaire (Peu ou pas d'exercice)</option>
                        <option value="leger">Légèrement actif (1-2 jours/semaine)</option>
                        <option value="modere">Modérément actif (3-4 jours/semaine)</option>
                        <option value="tres_actif">Très actif (5-7 jours/semaine)</option>
                    </select>
                </div>
            </div>

            <!-- Step 4: Offers -->
            <div class="form-step" id="step-4">
                <label class="label-premium">Choisissez votre offre</label>
                <div class="offers-grid">
                    <label class="offer-card">
                        <input type="radio" name="offer" value="basique" checked>
                        <div class="offer-content">
                            <div class="offer-title">Basique</div>
                            <div class="offer-price">29€</div>
                            <div style="font-size: 0.7rem; margin-top: 10px; opacity: 0.6;">/ mois</div>
                        </div>
                    </label>
                    <label class="offer-card">
                        <input type="radio" name="offer" value="premium">
                        <div class="offer-content">
                            <div class="offer-title">Premium</div>
                            <div class="offer-price">49€</div>
                            <div style="font-size: 0.7rem; margin-top: 10px; opacity: 0.6;">/ mois</div>
                        </div>
                    </label>
                    <label class="offer-card">
                        <input type="radio" name="offer" value="elite">
                        <div class="offer-content">
                            <div class="offer-title">Elite</div>
                            <div class="offer-price">89€</div>
                            <div style="font-size: 0.7rem; margin-top: 10px; opacity: 0.6;">/ mois</div>
                        </div>
                    </label>
                </div>
            </div>

            <div class="btn-container">
                <button type="button" class="nav-btn btn-prev" id="prev-btn" style="display: none;">Précédent</button>
                <button type="button" class="nav-btn btn-next" id="next-btn">Suivant</button>
            </div>
        </form>

        <p style="margin-top: 24px; font-size: 0.85rem; color: var(--text-muted);">
            Vous avez déjà un compte ? <a href="{{ route('login') }}" style="color: #FFB800; font-weight: 700; text-decoration: none;">Connectez-vous</a>
        </p>
    </div>
</section>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        let currentStep = 1;
        const totalSteps = 4;
        const form = document.getElementById('register-form');
        const nextBtn = document.getElementById('next-btn');
        const prevBtn = document.getElementById('prev-btn');
        const dots = document.querySelectorAll('.step-dot');
        const descriptions = [
            "Étape 1 : Créez votre compte",
            "Étape 2 : Vos données physiques",
            "Étape 3 : Vos objectifs",
            "Étape 4 : Choisissez votre offre"
        ];

        function updateStep() {
            document.querySelectorAll('.form-step').forEach(step => step.classList.remove('active'));
            document.getElementById(`step-${currentStep}`).classList.add('active');
            
            dots.forEach((dot, idx) => {
                if (idx + 1 === currentStep) dot.classList.add('active');
                else dot.classList.remove('active');
            });

            document.getElementById('step-desc').innerText = descriptions[currentStep - 1];

            if (currentStep === 1) {
                prevBtn.style.display = 'none';
            } else {
                prevBtn.style.display = 'block';
            }

            if (currentStep === totalSteps) {
                nextBtn.innerText = 'S\'inscrire';
            } else {
                nextBtn.innerText = 'Suivant';
            }
        }

        nextBtn.addEventListener('click', function() {
            if (currentStep < totalSteps) {
                // Basic validation for current step
                const inputs = document.querySelectorAll(`#step-${currentStep} input, #step-${currentStep} select`);
                let valid = true;
                
                inputs.forEach(input => {
                    if (!input.checkValidity()) {
                        input.reportValidity();
                        valid = false;
                    }
                });

                // Custom validation for Step 1: Passwords match
                if (currentStep === 1 && valid) {
                    const pass = document.getElementById('password').value;
                    const confirmPass = document.getElementById('password_confirmation').value;
                    const errorMsg = document.getElementById('password-error');
                    
                    if (pass !== confirmPass) {
                        errorMsg.style.display = 'block';
                        document.getElementById('password_confirmation').style.borderColor = '#ff4d4d';
                        valid = false;
                    } else {
                        errorMsg.style.display = 'none';
                        document.getElementById('password_confirmation').style.borderColor = '';
                    }
                }

                // Custom validation for Step 2: Date format
                if (currentStep === 2 && valid) {
                    const dateVal = document.getElementById('date_of_birth_input').value;
                    const dateRegex = /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d$/;
                    const dateError = document.getElementById('date-error');
                    
                    if (!dateRegex.test(dateVal)) {
                        dateError.style.display = 'block';
                        document.getElementById('date_of_birth_input').style.borderColor = '#ff4d4d';
                        valid = false;
                    } else {
                        dateError.style.display = 'none';
                        document.getElementById('date_of_birth_input').style.borderColor = '';
                    }
                }

                if (valid) {
                    currentStep++;
                    updateStep();
                }
            } else {
                form.submit();
            }
        });

        // Date input helper (auto-slash)
        const dateInput = document.getElementById('date_of_birth_input');
        dateInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length > 2) value = value.slice(0, 2) + '/' + value.slice(2);
            if (value.length > 5) value = value.slice(0, 5) + '/' + value.slice(5, 9);
            e.target.value = value;
        });

        prevBtn.addEventListener('click', function() {
            if (currentStep > 1) {
                currentStep--;
                updateStep();
            }
        });
    });
</script>
@endsection
