@extends('layouts.app')

@section('title', 'SmartCoach — En attente d\'approbation')

@section('styles')
<style>
    .approval-section {
        min-height: calc(100vh - 80px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        margin-top: 80px;
    }
    .approval-card {
        width: 100%;
        max-width: 520px;
        background: rgba(15, 23, 42, 0.4);
        backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: 32px;
        padding: 48px;
        text-align: center;
        box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
        animation: fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1);
    }
    .approval-icon {
        font-size: 4rem;
        margin-bottom: 24px;
        display: block;
        animation: pulse 2s infinite;
    }
    @keyframes pulse {
        0% { transform: scale(1); opacity: 1; }
        50% { transform: scale(1.1); opacity: 0.8; }
        100% { transform: scale(1); opacity: 1; }
    }
    .approval-title {
        font-family: 'Orbitron', sans-serif;
        font-size: 1.8rem;
        font-weight: 700;
        margin-bottom: 16px;
        color: var(--text);
    }
    .approval-message {
        color: var(--text-muted);
        font-size: 1.05rem;
        line-height: 1.6;
        margin-bottom: 32px;
    }
    .status-badge {
        display: inline-block;
        padding: 8px 20px;
        background: rgba(255, 184, 0, 0.1);
        border: 1px solid #FFB800;
        border-radius: 30px;
        color: #FFB800;
        font-weight: 700;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 32px;
    }
    .back-btn {
        display: inline-block;
        background: rgba(255, 255, 255, 0.05);
        color: var(--text);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        padding: 16px 32px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
    }
    .back-btn:hover {
        background: rgba(255, 255, 255, 0.1);
        transform: translateY(-2px);
    }
</style>
@endsection

@section('content')
<section class="approval-section">
    <div class="approval-card" id="approval-card">
        <!-- Pending UI -->
        <div id="pending-ui">
            <span class="approval-icon">⏳</span>
            <h1 class="approval-title">Merci pour votre inscription !</h1>
            
            <div class="status-badge">Compte en attente d'approbation</div>

            <p class="approval-message">
                Bienvenue dans la communauté SmartCoach. Votre profil est actuellement en cours d'examen par notre équipe administrative. 
                <br><br>
                Vous recevrez un e-mail dès que votre accès sera validé. En attendant, préparez-vous à transformer votre vie !
            </p>

            <a href="{{ route('login') }}" class="back-btn">Retour à la connexion</a>
        </div>

        <!-- Success UI (Hidden) -->
        <div id="success-ui" style="display: none;">
            <span class="approval-icon" style="animation: none;">✨</span>
            <h1 class="approval-title" id="welcome-title">Bienvenue !</h1>
            
            <div class="status-badge" style="background: rgba(0, 96, 57, 0.1); border-color: #006039; color: #006039;">Compte Validé</div>

            <p class="approval-message" id="welcome-message">
                Votre compte a été validé. Préparez-vous à commencer votre voyage avec SmartCoach. 
                Cette page sera bientôt enrichie de vos analyses et de votre programme personnalisé.
            </p>

            <p style="margin-bottom: 32px; font-weight: 600; color: var(--text);">
                Profil : <span id="user-profile" style="color: #FFB800;"></span>
            </p>

            <a href="{{ route('login') }}" class="back-btn" style="background: #FFB800; color: #000; border: none; font-weight: 800;">Se connecter</a>
        </div>
    </div>
</section>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const checkStatus = () => {
            fetch("{{ route('check-approval-status') }}")
                .then(response => response.json())
                .then(data => {
                    if (data.is_approved) {
                        const user = data.user;
                        
                        // Update UI
                        document.getElementById('welcome-title').innerText = `Bienvenue, ${user.name} !`;
                        document.getElementById('user-profile').innerText = `${user.gender.charAt(0).toUpperCase() + user.gender.slice(1)} | Objectif : ${user.goal}`;
                        
                        // Transition
                        document.getElementById('pending-ui').style.display = 'none';
                        document.getElementById('success-ui').style.display = 'block';
                        
                        // Stop polling
                        clearInterval(pollInterval);
                    }
                })
                .catch(err => console.error('Erreur de vérification:', err));
        };

        // Poll every 3 seconds
        const pollInterval = setInterval(checkStatus, 3000);
    });
</script>
@endsection
