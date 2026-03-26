@extends('layouts.dashboard')

@section('dashboard-styles')
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    .module-container {
        max-width: 1000px;
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

    .nav-pills-custom .nav-link {
        color: var(--text);
        border-radius: 12px;
        padding: 12px 25px;
        font-weight: 700;
        margin-right: 10px;
        margin-bottom: 10px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        transition: all 0.3s;
    }

    .nav-pills-custom .nav-link.active {
        background: var(--accent, #FFB800);
        color: #000;
        border-color: var(--accent, #FFB800);
        box-shadow: 0 5px 15px rgba(255, 184, 0, 0.3);
    }

    .form-group { margin-bottom: 20px; }
    .form-label { display: block; font-weight: 700; margin-bottom: 8px; color: var(--text); font-size: 0.95rem; }
    
    .form-control, .form-select {
        width: 100%;
        padding: 14px 20px;
        background: rgba(0, 0, 0, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 14px;
        color: var(--text);
        font-size: 1rem;
        transition: all 0.3s;
    }

    html[data-theme="light"] .form-control, html[data-theme="light"] .form-select {
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

    .result-value-big {
        font-family: var(--font-display);
        font-size: 3.5rem;
        font-weight: 900;
        color: var(--accent, #FFB800);
        text-align: center;
        margin: 10px 0;
        animation: slideUp 0.4s ease-out;
        display: none;
    }

    .result-status {
        text-align: center;
        font-weight: 800;
        font-size: 1.2rem;
        padding: 10px;
        border-radius: 10px;
        display: none;
        margin-top: 15px;
        background: rgba(255,255,255,0.1);
    }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
</style>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
@endsection

@section('dashboard-content')
<div class="module-container">
    <div class="d-flex align-items-center mb-4" style="gap:15px;">
        <a href="{{ route('modules.index') }}" class="btn-ghost" style="padding: 10px 15px; color: white; text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <i data-lucide="arrow-left" style="width: 20px; height: 20px;"></i> {{ __('Retour') }}
        </a>
        <h1 class="welcome-title mb-0" style="font-size: 2.5rem; font-weight: 900; color: white;">Calculatrice Sportive</h1>
    </div>

    <!-- Main Dashboard Grid -->
    <div id="module-dashboard">
        <p class="text-muted mb-4" style="font-size: 1.1rem;">Sélectionnez un outil de calcul pour vos mesures physiques et performances.</p>
        
        <div class="row g-3">
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('imc-calc')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⚖️</div>
                    <h5 style="font-weight: 800;">IMC</h5>
                    <small class="text-muted">Indice de Masse Corporelle</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('bmr-calc')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🔥</div>
                    <h5 style="font-weight: 800;">BMR</h5>
                    <small class="text-muted">Métabolisme de Base</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('rm-calc')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🏋️</div>
                    <h5 style="font-weight: 800;">1RM</h5>
                    <small class="text-muted">Force Maximale</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('img-calc')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">👤</div>
                    <h5 style="font-weight: 800;">IMG</h5>
                    <small class="text-muted">Indice de Masse Grasse</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('ideal-weight')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">📏</div>
                    <h5 style="font-weight: 800;">Poids Idéal</h5>
                    <small class="text-muted">Formules de Lorentz/Creff</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('bio-age')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⏳</div>
                    <h5 style="font-weight: 800;">Âge Bio</h5>
                    <small class="text-muted">Âge biologique estimé</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Tool Detail View -->
    <div id="tool-detail-view" style="display: none;">
        <div class="row">
            <!-- Mini Sidebar -->
            <div class="col-md-3 d-none d-md-block">
                <button class="btn btn-outline-light w-100 mb-3" onclick="backToDashboard()" style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                    <i data-lucide="layout-grid" style="width: 18px; height: 18px;"></i> Menu
                </button>
                <div class="nav flex-column nav-pills nav-pills-custom" id="calcTabs" role="tablist">
                    <button class="nav-link active" id="imc-tab" data-bs-toggle="pill" data-bs-target="#imc-calc">IMC</button>
                    <button class="nav-link" id="bmr-tab" data-bs-toggle="pill" data-bs-target="#bmr-calc">BMR</button>
                    <button class="nav-link" id="rm-tab" data-bs-toggle="pill" data-bs-target="#rm-calc">1RM</button>
                    <button class="nav-link" id="img-tab" data-bs-toggle="pill" data-bs-target="#img-calc">IMG</button>
                    <button class="nav-link" id="weight-tab" data-bs-toggle="pill" data-bs-target="#ideal-weight">Poids Idéal</button>
                </div>
            </div>
            <div class="col-md-9">
                <div class="d-md-none mb-3">
                   <button class="btn btn-outline-light btn-sm" onclick="backToDashboard()"><i class="fas fa-arrow-left"></i> Liste des outils</button>
                </div>
                <div class="tab-content">
        
        <!-- IMC (BMI) -->
        <div class="tab-pane fade show active" id="imc-calc" role="tabpanel">
            <div class="row">
                <div class="col-md-5">
                    <div class="glass-panel">
                        <h3 style="font-weight: 800; margin-bottom: 20px;">Paramètres</h3>
                        <div class="form-group">
                            <label class="form-label">Taille (cm)</label>
                            <input type="number" id="imc_height" class="form-control" placeholder="Ex: 175" min="50" max="250">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Poids (kg)</label>
                            <input type="number" id="imc_weight" class="form-control" placeholder="Ex: 70" min="20" max="300" step="0.1">
                        </div>
                        <button class="btn-calculate" onclick="calculateIMC()">Calculer l'IMC</button>
                    </div>
                </div>
                <div class="col-md-7">
                    <div class="glass-panel" style="min-height:100%; display:flex; flex-direction:column; justify-content:center;">
                        <h3 style="font-weight: 800; margin-bottom: 10px; text-align:center;">Votre IMC</h3>
                        <p style="color: var(--muted); font-size: 0.9rem; text-align:center;">L'IMC permet d'estimer la corpulence d'une personne.</p>
                        
                        <div id="imcResult" class="result-value-big">--</div>
                        <div id="imcStatus" class="result-status">En attente de calcul...</div>
                        
                        <div style="margin-top:30px; display:flex; gap:2px; height:10px; border-radius:5px; overflow:hidden;">
                            <div style="background:#3b82f6; flex: 18.5;" title="Maigreur"></div>
                            <div style="background:#10b981; flex: 6.5;" title="Normal"></div>
                            <div style="background:#f59e0b; flex: 5;" title="Surpoids"></div>
                            <div style="background:#ef4444; flex: 5;" title="Obésité modérée"></div>
                            <div style="background:#991b1b; flex: 10;" title="Obésité sévère"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- BMR -->
        <div class="tab-pane fade" id="bmr-calc" role="tabpanel">
            <div class="row">
                <div class="col-md-6">
                    <div class="glass-panel">
                        <h3 style="font-weight: 800; margin-bottom: 20px;">Vos données</h3>
                        
                        <div class="row">
                            <div class="col-6 form-group">
                                <label class="form-label">Sexe</label>
                                <select id="bmr_sex" class="form-select">
                                    <option value="male">Homme</option>
                                    <option value="female">Femme</option>
                                </select>
                            </div>
                            <div class="col-6 form-group">
                                <label class="form-label">Âge</label>
                                <input type="number" id="bmr_age" class="form-control" placeholder="Ex: 28">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-6 form-group">
                                <label class="form-label">Taille (cm)</label>
                                <input type="number" id="bmr_height" class="form-control" placeholder="Ex: 175">
                            </div>
                            <div class="col-6 form-group">
                                <label class="form-label">Poids (kg)</label>
                                <input type="number" id="bmr_weight" class="form-control" placeholder="Ex: 70">
                            </div>
                        </div>
                        
                        <button class="btn-calculate" onclick="calculateBMR()">Calculer le BMR</button>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="glass-panel" style="min-height:100%; display:flex; flex-direction:column; justify-content:center;">
                        <h3 style="font-weight: 800; margin-bottom: 10px; text-align:center;">Métabolisme de Base</h3>
                        <p style="text-align:center; color:var(--muted); font-size: 0.9rem;">(Mifflin-St Jeor) Calories brûlées au repos.</p>
                        
                        <div id="bmrResult" class="result-value-big" style="font-size: 3rem;">--</div>
                        <p id="bmrLabel" style="text-align:center; color:var(--muted); font-weight:700; display:none;">kcal / jour</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 1RM -->
        <div class="tab-pane fade" id="rm-calc" role="tabpanel">
            <div class="row">
                <div class="col-md-5">
                    <div class="glass-panel">
                        <h3 style="font-weight: 800; margin-bottom: 20px;">Performance</h3>
                        <div class="form-group">
                            <label class="form-label">Poids soulevé (kg)</label>
                            <input type="number" id="rm_weight" class="form-control" placeholder="Ex: 80">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Nombre de Répétitions</label>
                            <input type="number" id="rm_reps" class="form-control" placeholder="Ex: 5" max="20">
                        </div>
                        <button class="btn-calculate" onclick="calculate1RM()">Estimer le 1RM</button>
                    </div>
                </div>
                <div class="col-md-7">
                    <div class="glass-panel" style="min-height:100%; display:flex; flex-direction:column; justify-content:center;">
                        <h3 style="font-weight: 800; margin-bottom: 10px; text-align:center;">1RM Estimé</h3>
                        <div id="rmResult" class="result-value-big">--</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- IMG (Body Fat Index) -->
        <div class="tab-pane fade" id="img-calc" role="tabpanel">
            <div class="glass-panel">
                <h3 style="font-weight: 800; margin-bottom: 20px;">Indice de Masse Grasse (IMG)</h3>
                <div class="row">
                    <div class="col-md-6 form-group">
                        <label class="form-label">IMC (déjà calculé ou estimé)</label>
                        <input type="number" id="img_imc" class="form-control" placeholder="Ex: 22.5">
                    </div>
                    <div class="col-md-3 form-group">
                        <label class="form-label">Âge</label>
                        <input type="number" id="img_age" class="form-control" placeholder="30">
                    </div>
                    <div class="col-md-3 form-group">
                        <label class="form-label">Sexe</label>
                        <select id="img_sex" class="form-select">
                            <option value="1">Homme</option>
                            <option value="0">Femme</option>
                        </select>
                    </div>
                </div>
                <button class="btn-calculate" onclick="calculateIMG()">Calculer l'IMG</button>
                <div id="imgResult" class="result-value-big mt-4">--</div>
            </div>
        </div>

        <!-- Ideal Weight -->
        <div class="tab-pane fade" id="ideal-weight" role="tabpanel">
            <div class="glass-panel">
                <h3 style="font-weight: 800; margin-bottom: 20px;">Poids Idéal (Lorentz)</h3>
                <div class="row">
                    <div class="col-md-6 form-group">
                        <label class="form-label">Taille (cm)</label>
                        <input type="number" id="iw_height" class="form-control" placeholder="175">
                    </div>
                    <div class="col-md-6 form-group">
                        <label class="form-label">Sexe</label>
                        <select id="iw_sex" class="form-select">
                            <option value="male">Homme</option>
                            <option value="female">Femme</option>
                        </select>
                    </div>
                </div>
                <button class="btn-calculate" onclick="calculateIdealWeight()">Calculer</button>
                <div id="iwResult" class="result-value-big mt-4">--</div>
            </div>
        </div>

        <!-- Bio Age -->
        <div class="tab-pane fade" id="bio-age" role="tabpanel">
            <div class="glass-panel text-center">
                <h3 style="font-weight: 800; margin-bottom: 20px;">Âge Biologique</h3>
                <p class="text-muted">Estimation basée sur vos habitudes de vie et marqueurs physiques.</p>
                <div class="row text-start">
                    <div class="col-md-6 form-group">
                        <label class="form-label">Âge Réel</label>
                        <input type="number" id="ba_age" class="form-control">
                    </div>
                    <div class="col-md-6 form-group">
                        <label class="form-label">Tabac ?</label>
                        <select id="ba_smoke" class="form-select">
                            <option value="0">Non</option>
                            <option value="2">Oui</option>
                        </select>
                    </div>
                </div>
                <button class="btn-calculate" onclick="calculateBioAge()">Estimer</button>
                <div id="baResult" class="result-value-big mt-4">--</div>
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
        const triggerEl = document.querySelector(`button[data-bs-target="#${toolId}"]`);
        if (triggerEl && typeof bootstrap !== 'undefined') {
            const tab = bootstrap.Tab.getOrCreateInstance(triggerEl);
            tab.show();
        }
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function backToDashboard() {
        document.getElementById('module-dashboard').style.display = 'block';
        document.getElementById('tool-detail-view').style.display = 'none';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // --- IMC (BMI) ---
    function calculateIMC() {
        const heightCm = parseFloat(document.getElementById('imc_height').value);
        const weight = parseFloat(document.getElementById('imc_weight').value);
        if (!heightCm || !weight) return;
        const heightM = heightCm / 100;
        const imc = weight / (heightM * heightM);
        document.getElementById('imcResult').style.display = 'block';
        document.getElementById('imcResult').innerText = imc.toFixed(1);
        const statusLabel = document.getElementById('imcStatus');
        statusLabel.style.display = 'block';
        document.getElementById('img_imc').value = imc.toFixed(1); // Auto-fill IMG field
        if (imc < 18.5) { statusLabel.innerText = "Maigreur"; statusLabel.style.color = "#3b82f6"; }
        else if (imc < 25) { statusLabel.innerText = "Normal"; statusLabel.style.color = "#10b981"; }
        else if (imc < 30) { statusLabel.innerText = "Surpoids"; statusLabel.style.color = "#f59e0b"; }
        else { statusLabel.innerText = "Obésité"; statusLabel.style.color = "#ef4444"; }
    }

    // --- BMR ---
    function calculateBMR() {
        const sex = document.getElementById('bmr_sex').value;
        const weight = parseFloat(document.getElementById('bmr_weight').value);
        const height = parseFloat(document.getElementById('bmr_height').value);
        const age = parseInt(document.getElementById('bmr_age').value);
        if (!weight || !height || !age) return;
        let bmr = (10 * weight) + (6.25 * height) - (5 * age);
        bmr += (sex === 'male' ? 5 : -161);
        document.getElementById('bmrResult').style.display = 'block';
        document.getElementById('bmrResult').innerText = Math.round(bmr) + " kcal";
    }

    // --- 1RM ---
    function calculate1RM() {
        const weight = parseFloat(document.getElementById('rm_weight').value);
        const reps = parseInt(document.getElementById('rm_reps').value);
        if (!weight || !reps) return;
        const brzycki = weight * (36 / (37 - reps));
        document.getElementById('rmResult').style.display = 'block';
        document.getElementById('rmResult').innerText = brzycki.toFixed(1) + " kg";
    }

    // --- IMG ---
    function calculateIMG() {
        const imc = parseFloat(document.getElementById('img_imc').value);
        const age = parseInt(document.getElementById('img_age').value);
        const sex = parseInt(document.getElementById('img_sex').value);
        if(!imc || !age) return;
        const img = (1.20 * imc) + (0.23 * age) - (10.8 * sex) - 5.4;
        document.getElementById('imgResult').style.display = 'block';
        document.getElementById('imgResult').innerText = img.toFixed(1) + "%";
    }

    // --- Ideal Weight ---
    function calculateIdealWeight() {
        const h = parseFloat(document.getElementById('iw_height').value);
        const sex = document.getElementById('iw_sex').value;
        if(!h) return;
        let target = (sex === 'male') ? (h - 100 - (h - 150) / 4) : (h - 100 - (h - 150) / 2.5);
        document.getElementById('iwResult').style.display = 'block';
        document.getElementById('iwResult').innerText = target.toFixed(1) + " kg";
    }

    // --- Bio Age ---
    function calculateBioAge() {
        const age = parseInt(document.getElementById('ba_age').value);
        const smoke = parseInt(document.getElementById('ba_smoke').value);
        if(!age) return;
        document.getElementById('baResult').style.display = 'block';
        document.getElementById('baResult').innerText = (age + smoke) + " ans";
    }
</script>
@endsection
