@extends('layouts.dashboard')

@section('dashboard-styles')
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    .module-container {
        max-width: 900px;
        margin: 0 auto;
        animation: fadeIn 0.5s ease-out;
    }

    .glass-panel {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 24px;
        padding: 30px;
        backdrop-filter: blur(12px);
        margin-bottom: 25px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.2);
    }

    html[data-theme="light"] .glass-panel {
        background: rgba(255, 255, 255, 0.9);
        border-color: rgba(0, 0, 0, 0.08);
        box-shadow: 0 15px 35px rgba(0,0,0,0.05);
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-label {
        display: block;
        font-weight: 700;
        margin-bottom: 8px;
        color: var(--text);
        font-size: 0.95rem;
    }

    .form-control, .form-select {
        width: 100%;
        padding: 14px 20px;
        background: rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        color: var(--text);
        font-size: 1rem;
        transition: all 0.3s ease;
    }

    html[data-theme="light"] .form-control, 
    html[data-theme="light"] .form-select {
        background: rgba(0, 0, 0, 0.03);
        border-color: rgba(0, 0, 0, 0.1);
        color: #000;
    }

    .form-control:focus, .form-select:focus {
        outline: none;
        border-color: var(--accent, #FFB800);
        box-shadow: 0 0 0 3px rgba(255, 184, 0, 0.2);
    }

    .btn-calculate {
        background: var(--accent, #FFB800);
        color: #000;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 1px;
        padding: 16px 30px;
        border: none;
        border-radius: 14px;
        width: 100%;
        font-size: 1.1rem;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 10px 20px rgba(255, 184, 0, 0.2);
    }

    .btn-calculate:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 30px rgba(255, 184, 0, 0.3);
    }

    .result-box {
        text-align: center;
        padding: 20px;
        border-radius: 18px;
        background: linear-gradient(135deg, rgba(255,184,0,0.2) 0%, rgba(255,184,0,0.05) 100%);
        border: 1px solid rgba(255,184,0,0.3);
        display: none;
        margin-top: 20px;
        animation: slideUp 0.4s ease-out;
    }

    .result-value {
        font-family: var(--font-display);
        font-size: 3rem;
        font-weight: 900;
        color: var(--accent, #FFB800);
        margin: 10px 0;
    }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

    .chart-container {
        height: 250px;
        width: 100%;
        margin-top: 20px;
        display: none;
    }
</style>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
@endsection

@section('dashboard-content')
<div class="module-container">
    <div class="d-flex align-items-center mb-4" style="gap:15px;">
        <a href="{{ route('modules.index') }}" class="btn-ghost" style="padding: 10px 15px; color: white; text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <i data-lucide="arrow-left" style="width: 20px; height: 20px;"></i> {{ __('Retour') }}
        </a>
        <h1 class="welcome-title mb-0" style="font-size: 2.5rem; font-weight: 900; color: white;">Calculateur de Protéines</h1>
    </div>

    <!-- Main Dashboard Grid -->
    <div id="module-dashboard">
        <p class="text-muted mb-4" style="font-size: 1.1rem;">Calculez vos besoins nutritionnels quotidiens en protéines.</p>
        
        <div class="row g-3">
            <div class="col-12 col-md-4">
                <div class="glass-panel text-center p-4 tool-launcher" onclick="launchTool('protein-calc')" style="cursor:pointer; transition: 0.3s; height: 100%;">
                    <div style="font-size: 3rem; margin-bottom: 15px;">🍖</div>
                    <h4 style="font-weight: 800;">Calcul des Protéines</h4>
                    <p class="text-muted">Basé sur le poids, l'objectif et l'activité.</p>
                    <button class="btn btn-outline-warning mt-2">Démarrer</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Tool Detail View -->
    <div id="tool-detail-view" style="display: none;">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <button class="btn btn-outline-light btn-sm" onclick="backToDashboard()" style="display: flex; align-items: center; gap: 8px;">
                <i data-lucide="arrow-left" style="width: 16px; height: 16px;"></i> Retour au menu
            </button>
        </div>
        
        <div id="protein-calc" class="tab-pane fade show active">
            <div class="row">
                <div class="col-md-7">
                    <div class="glass-panel">
                        <h3 style="font-weight: 800; margin-bottom: 20px; color: var(--text);">Paramètres du profil</h3>
                        <div class="row">
                            <div class="col-6 form-group">
                                <label class="form-label">Âge</label>
                                <input type="number" id="age" class="form-control" placeholder="Ex: 25" min="1" max="100">
                            </div>
                            <div class="col-6 form-group">
                                <label class="form-label">Sexe</label>
                                <select id="sex" class="form-select">
                                    <option value="Male">Homme</option>
                                    <option value="Female">Femme</option>
                                </select>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6 form-group">
                                <label class="form-label">Poids</label>
                                <input type="number" id="weight" class="form-control" step="0.1" placeholder="Ex: 75">
                            </div>
                            <div class="col-6 form-group">
                                <label class="form-label">Système</label>
                                <select id="weightSystem" class="form-select">
                                    <option value="Kg">Kg</option>
                                    <option value="Lbs">Lbs</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Objectif</label>
                            <select id="goal" class="form-select">
                                <option value="Maintain">Maintien</option>
                                <option value="Fat Loss">Perte de graisse</option>
                                <option value="Muscle Gain">Prise de muscle</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Niveau d'activité</label>
                            <select id="activity" class="form-select">
                                <option value="Level 1">Sédentaire</option>
                                <option value="Level 2">Légèrement actif</option>
                                <option value="Level 3">Modérément actif</option>
                                <option value="Level 4">Très actif</option>
                                <option value="Level 5">Extrêmement actif</option>
                            </select>
                        </div>
                        <button class="btn-calculate" onclick="calculateProtein()">Calculer mes besoins</button>
                    </div>
                </div>
                <div class="col-md-5">
                    <div class="glass-panel" style="min-height: 100%; display: flex; flex-direction: column; justify-content: center;">
                        <div id="resultBox" class="result-box" style="background: transparent; border:none;">
                            <p style="margin:0; font-weight:700; text-align:center;">Cible journalière :</p>
                            <div id="proteinValue" class="result-value" style="text-align:center;">--</div>
                            <p style="margin:0; font-weight:700; text-align:center;">grammes / jour</p>
                        </div>
                        <div class="chart-container" id="chartContainer">
                            <canvas id="proteinChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('dashboard-scripts')
<script>
    function launchTool(toolId) {
        document.getElementById('module-dashboard').style.display = 'none';
        document.getElementById('tool-detail-view').style.display = 'block';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function backToDashboard() {
        document.getElementById('module-dashboard').style.display = 'block';
        document.getElementById('tool-detail-view').style.display = 'none';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    let proteinChartInstance = null;


    function calculateProtein() {
        const age = parseInt(document.getElementById('age').value);
        const sex = document.getElementById('sex').value;
        const weightSystem = document.getElementById('weightSystem').value;
        const weightVal = parseFloat(document.getElementById('weight').value);
        const goal = document.getElementById('goal').value;
        const activity = document.getElementById('activity').value;

        if (!age || age <= 0 || !sex || !weightVal || weightVal <= 0 || !goal || !activity) {
            alert("Veuillez remplir correctement tous les champs.");
            return;
        }

        // Logic equivalent to Dart
        const weightKg = (weightSystem === 'Lbs') ? weightVal * 0.453592 : weightVal;

        let activityIndex = 0;
        if (activity === 'Level 2') activityIndex = 1;
        else if (activity === 'Level 3') activityIndex = 2;
        else if (activity === 'Level 4') activityIndex = 3;
        else if (activity === 'Level 5') activityIndex = 4;

        let gPerKg = 1.2 + (activityIndex * 0.2);

        if (goal === 'Fat Loss') gPerKg += 0.2;
        else if (goal === 'Muscle Gain') gPerKg += 0.3;

        if (sex === 'Male') gPerKg += 0.1;

        if (gPerKg < 0.8) gPerKg = 0.8;
        if (gPerKg > 2.4) gPerKg = 2.4;

        const protein = Math.round(weightKg * gPerKg);

        // Display results
        document.getElementById('resultBox').style.display = 'block';
        document.getElementById('proteinValue').innerText = protein;
        document.getElementById('chartContainer').style.display = 'block';

        // Draw Chart
        drawChart(protein, weightKg);
    }

    function drawChart(protein, weightKg) {
        const ctx = document.getElementById('proteinChart').getContext('2d');
        
        // Estimer les autres macros juste pour le visuel (C'est un exemple de répartition classique)
        // Calories = weightKg * 24 * activityFactor (approximate)
        const totalCals = weightKg * 24 * 1.5; 
        const proteinCals = protein * 4;
        const fatCals = totalCals * 0.25; // 25% fats
        const carbCals = totalCals - proteinCals - fatCals;

        const fatGrams = Math.round(fatCals / 9);
        const carbGrams = Math.round(carbCals / 4);

        if (proteinChartInstance) {
            proteinChartInstance.destroy();
        }

        proteinChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Protéines', 'Glucides (Est.)', 'Lipides (Est.)'],
                datasets: [{
                    data: [protein, carbGrams, fatGrams],
                    backgroundColor: [
                        '#FFB800', 
                        'rgba(255, 255, 255, 0.4)', 
                        'rgba(255, 255, 255, 0.1)'
                    ],
                    borderColor: 'rgba(0,0,0,0.2)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: 'rgba(255,255,255,0.8)',
                            font: { size: 12 }
                        }
                    }
                }
            }
        });
    }
</script>
@endsection
