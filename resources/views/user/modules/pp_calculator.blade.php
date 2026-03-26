@extends('layouts.dashboard')

@section('dashboard-styles')
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    .module-container {
        max-width: 1400px;
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

    /* Vertical Pills style */
    .nav-pills-custom {
        display: flex;
        flex-direction: column;
        gap: 8px;
        padding-right: 15px;
        border-right: 1px solid rgba(255,255,255,0.1);
    }
    html[data-theme="light"] .nav-pills-custom {
        border-right: 1px solid rgba(0,0,0,0.1);
    }

    .nav-pills-custom .nav-link {
        color: var(--text);
        border-radius: 12px;
        padding: 12px 20px;
        font-weight: 600;
        font-size: 0.95rem;
        background: transparent;
        border: 1px solid transparent;
        transition: all 0.3s;
        text-align: left;
    }

    .nav-pills-custom .nav-link:hover {
        background: rgba(255, 255, 255, 0.05);
    }

    .nav-pills-custom .nav-link.active {
        background: var(--accent, #FFB800);
        color: #000;
        font-weight: 800;
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
        font-size: 3rem;
        font-weight: 900;
        color: var(--accent, #FFB800);
        text-align: center;
        margin: 10px 0;
        animation: slideUp 0.4s ease-out;
        display: none;
    }

    .chart-container {
        position: relative;
        height: 300px;
        width: 100%;
        margin-top: 30px;
        display: none;
    }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
</style>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
@endsection

@section('dashboard-content')
<div class="module-container">
    <div class="d-flex align-items-center mb-4" style="gap:15px;">
        <a href="{{ route('modules.index') }}" class="btn-ghost" style="padding: 10px 15px; color: white; text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <i data-lucide="arrow-left" style="width: 20px; height: 20px;"></i> {{ __('Retour') }}
        </a>
        <h1 class="welcome-title mb-0" style="font-size: 2.5rem; font-weight: 900; color: white;">Santé & Performance (PP)</h1>
    </div>

    <!-- Main Dashboard Grid -->
    <div id="module-dashboard">
        <p class="text-muted mb-4" style="font-size: 1.1rem;">Explorez les 13 tests de santé et de performance physique.</p>
        
        <div class="row g-3">
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-target-hr')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">❤️</div>
                    <h5 style="font-weight: 800;">Target HR</h5>
                    <small class="text-muted">Zones d'entraînement</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-vo2max')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🌬️</div>
                    <h5 style="font-weight: 800;">VO₂max</h5>
                    <small class="text-muted">Capacité aérobie</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-vma')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🏃</div>
                    <h5 style="font-weight: 800;">VMA</h5>
                    <small class="text-muted">Vitesse Max Aérobie</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-vvo2max')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⚡</div>
                    <h5 style="font-weight: 800;">vVO₂max</h5>
                    <small class="text-muted">Vitesse à VO2max</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-resting-hr')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🛌</div>
                    <h5 style="font-weight: 800;">Resting HR</h5>
                    <small class="text-muted">FC au repos</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-blood-pressure')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🩺</div>
                    <h5 style="font-weight: 800;">Blood Pressure</h5>
                    <small class="text-muted">Tension artérielle</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-water-req')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">💧</div>
                    <h5 style="font-weight: 800;">Water Req</h5>
                    <small class="text-muted">Hydratation journalière</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-water-loss')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🚿</div>
                    <h5 style="font-weight: 800;">Water Loss</h5>
                    <small class="text-muted">Pertes à l'effort</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-full-body')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">👤</div>
                    <h5 style="font-weight: 800;">Body Analysis</h5>
                    <small class="text-muted">% Masse grasse</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <a href="{{ route('modules.show', 'training_calculation') }}" style="text-decoration: none; color: inherit;">
                <div class="glass-panel text-center p-4 h-100" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">📊</div>
                    <h5 style="font-weight: 800;">Training Calc</h5>
                    <small class="text-muted">Ouvrir module complet</small>
                </div>
                </a>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-yoyo1')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🔄</div>
                    <h5 style="font-weight: 800;">Yo-Yo Test 1</h5>
                    <small class="text-muted">Intermittent IR1</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-yoyo2')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🔃</div>
                    <h5 style="font-weight: 800;">Yo-Yo Test 2</h5>
                    <small class="text-muted">Intermittent IR2</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('tab-yoyo-end')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">♾️</div>
                    <h5 style="font-weight: 800;">Yo-Yo Endur.</h5>
                    <small class="text-muted">Endurance 1/2</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Tool Detail View -->
    <div id="tool-detail-view" style="display: none;">
        <div class="row">
            <!-- Sidebar Navigation (mini) -->
            <div class="col-md-3 d-none d-md-block">
                <button class="btn btn-outline-light w-100 mb-3" onclick="backToDashboard()" style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                    <i data-lucide="layout-grid" style="width: 18px; height: 18px;"></i> Menu des tests
                </button>
                <div class="nav flex-column nav-pills nav-pills-custom" id="v-pills-tab" role="tablist">
                    <button class="nav-link active" data-bs-toggle="pill" data-bs-target="#tab-target-hr">1. Target HR</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-vo2max">2. VO₂max</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-vma">3. VMA</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-vvo2max">4. vVO₂max</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-resting-hr">5. Resting HR</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-blood-pressure">6. Blood Pressure</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-water-req">7. Water Req</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-water-loss">8. Water Loss</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-full-body">9. Body Analysis</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-yoyo1">10. Yo-Yo Test 1</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-yoyo2">11. Yo-Yo Test 2</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#tab-yoyo-end">12. Yo-Yo Endur.</button>
                </div>
            </div>
            <div class="col-md-9">
                <div class="d-md-none mb-3">
                   <button class="btn btn-outline-light btn-sm" onclick="backToDashboard()"><i class="fas fa-arrow-left"></i> Liste des tests</button>
                </div>
                <div class="tab-content">
                
                <!-- 1. Target HR -->
                <div class="tab-pane fade show active" id="tab-target-hr" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Target Heart Rate (Karvonen)</h3>
                        <div class="row mt-4">
                            <div class="col-md-6 form-group">
                                <label class="form-label">Âge</label>
                                <input type="number" id="t_hr_age" class="form-control" placeholder="Ex: 30">
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="form-label">FC Repos (BPM)</label>
                                <input type="number" id="t_hr_rest" class="form-control" placeholder="Ex: 60">
                            </div>
                        </div>
                        <button class="btn-calculate" onclick="calcTargetHR()">Calculer les Zones</button>
                        <div class="chart-container" id="hrChartContainer"><canvas id="hrChart"></canvas></div>
                    </div>
                </div>

                <!-- 2. VO2 MAX -->
                <div class="tab-pane fade" id="tab-vo2max" role="tabpanel">
                    <div class="glass-panel">
                        <h3>VO₂max (Test de Cooper)</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Distance parcourue en 12 minutes (mètres)</label>
                            <input type="number" id="vo2_dist" class="form-control" placeholder="Ex: 2400">
                        </div>
                        <button class="btn-calculate" onclick="calcVO2()">Estimer VO₂max</button>
                        <div id="vo2Result" class="result-value-big mt-4">--</div>
                    </div>
                </div>

                <!-- 3. VMA -->
                <div class="tab-pane fade" id="tab-vma" role="tabpanel">
                    <div class="glass-panel">
                        <h3>VMA (Vitesse Maximale Aérobie)</h3>
                        <p class="text-muted">Test demi-Cooper (6 minutes) : courez le plus loin possible en 6 minutes.</p>
                        <div class="form-group mt-4">
                            <label class="form-label">Distance (mètres)</label>
                            <input type="number" id="vma_dist" class="form-control" placeholder="Ex: 1500">
                        </div>
                        <button class="btn-calculate" onclick="calcVMA()">Calculer VMA</button>
                        <div id="vmaResult" class="result-value-big mt-4">--</div>
                        <p id="vmaLabel" class="text-center text-muted" style="display:none;">km/h</p>
                    </div>
                </div>

                <!-- 4. vVO2max -->
                <div class="tab-pane fade" id="tab-vvo2max" role="tabpanel">
                    <div class="glass-panel">
                        <h3>vVO₂max (Velocity at VO₂max)</h3>
                        <p class="text-muted">La vitesse associée à votre consommation maximale d'oxygène.</p>
                        <div class="form-group mt-4">
                            <label class="form-label">VO₂max calculé (ml/kg/min)</label>
                            <input type="number" id="vvo2_val" class="form-control" placeholder="Ex: 50">
                        </div>
                        <button class="btn-calculate" onclick="calcVVO2()">Calculer vVO₂max</button>
                        <div id="vvo2Result" class="result-value-big mt-4">--</div>
                        <p id="vvo2Label" class="text-center text-muted" style="display:none;">km/h</p>
                    </div>
                </div>

                <!-- 5. Average Resting HR -->
                <div class="tab-pane fade" id="tab-resting-hr" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Average Resting Heart Rate</h3>
                        <p class="text-muted">Saisissez votre FC au repos sur 3 à 5 jours pour obtenir une moyenne fiable.</p>
                        <div class="row mt-3">
                            <div class="col form-group"><label class="form-label">Jour 1</label><input type="number" id="rhr1" class="form-control" placeholder="60"></div>
                            <div class="col form-group"><label class="form-label">Jour 2</label><input type="number" id="rhr2" class="form-control" placeholder="62"></div>
                            <div class="col form-group"><label class="form-label">Jour 3</label><input type="number" id="rhr3" class="form-control" placeholder="59"></div>
                        </div>
                        <button class="btn-calculate" onclick="calcRestingHR()">Calculer la Moyenne</button>
                        <div id="rhrResult" class="result-value-big mt-4">--</div>
                        <p id="rhrLabel" class="text-center text-muted" style="display:none;">BPM</p>
                    </div>
                </div>

                <!-- 6. Blood Pressure -->
                <div class="tab-pane fade" id="tab-blood-pressure" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Blood Pressure (Classification)</h3>
                        <div class="row mt-4">
                            <div class="col-md-6 form-group">
                                <label class="form-label">Systolique (Haut)</label>
                                <input type="number" id="bp_sys" class="form-control" placeholder="Ex: 120">
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="form-label">Diastolique (Bas)</label>
                                <input type="number" id="bp_dia" class="form-control" placeholder="Ex: 80">
                            </div>
                        </div>
                        <button class="btn-calculate" onclick="calcBP()">Évaluer la Pression</button>
                        <div id="bpResult" class="result-value-big mt-4" style="font-size:2rem;">--</div>
                    </div>
                </div>

                <!-- 7. Human Water Requirement -->
                <div class="tab-pane fade" id="tab-water-req" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Human Water Requirement</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Poids (kg)</label>
                            <input type="number" id="water_w" class="form-control" placeholder="Ex: 75">
                        </div>
                        <button class="btn-calculate" onclick="calcWaterReq()">Calculer les Besoins</button>
                        <div id="waterReqResult" class="result-value-big mt-4">--</div>
                        <p id="waterReqLabel" class="text-center text-muted" style="display:none;">Litres / jour</p>
                    </div>
                </div>

                <!-- 8. Water Loss -->
                <div class="tab-pane fade" id="tab-water-loss" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Water Loss (Pertes hydriques à l'effort)</h3>
                        <div class="row mt-4">
                            <div class="col-md-4 form-group">
                                <label class="form-label">Poids AVANT (kg)</label>
                                <input type="number" id="wl_w1" class="form-control" placeholder="Ex: 75">
                            </div>
                            <div class="col-md-4 form-group">
                                <label class="form-label">Poids APRÈS (kg)</label>
                                <input type="number" id="wl_w2" class="form-control" placeholder="Ex: 74.2">
                            </div>
                            <div class="col-md-4 form-group">
                                <label class="form-label">Boissons consommées (L)</label>
                                <input type="number" id="wl_drink" class="form-control" placeholder="Ex: 0.5" step="0.1">
                            </div>
                        </div>
                        <button class="btn-calculate" onclick="calcWaterLoss()">Évaluer la Perte</button>
                        <div id="wlResult" class="result-value-big mt-4">--</div>
                        <p id="wlLabel" class="text-center text-muted" style="display:none;">Litres perdus (transpiration)</p>
                    </div>
                </div>

                <!-- 9. Full Body Analysis -->
                <div class="tab-pane fade" id="tab-full-body" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Full Body Analysis (Masse Grasse US Navy)</h3>
                        <div class="row mt-4">
                            <div class="col-md-6 form-group">
                                <label class="form-label">Sexe</label>
                                <select id="fb_sex" class="form-select">
                                    <option value="male">Homme</option>
                                    <option value="female">Femme</option>
                                </select>
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="form-label">Taille (cm)</label>
                                <input type="number" id="fb_h" class="form-control" placeholder="175">
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="form-label">Tour de Cou (cm)</label>
                                <input type="number" id="fb_neck" class="form-control" placeholder="38">
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="form-label">Tour de Taille/Nombril (cm)</label>
                                <input type="number" id="fb_waist" class="form-control" placeholder="85">
                            </div>
                            <div class="col-md-6 form-group" id="fb_hip_group" style="display:none;">
                                <label class="form-label">Tour de Hanches (Femme) (cm)</label>
                                <input type="number" id="fb_hip" class="form-control" placeholder="95">
                            </div>
                        </div>
                        <button class="btn-calculate" onclick="calcFullBody()">Analyser</button>
                        <div id="fbResult" class="result-value-big mt-4">--</div>
                        <p id="fbLabel" class="text-center text-muted" style="display:none;">% de Masse Grasse Estimée</p>
                    </div>
                </div>

                <!-- 10. Training Calculation -->
                <div class="tab-pane fade" id="tab-training-calc" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Training Calculation (Volume / Charge d'entraînement)</h3>
                        <p class="text-muted">Charge = RPE (Difficulté perçue de 1 à 10) x Durée (minutes).</p>
                        <div class="row mt-4">
                            <div class="col-md-6 form-group">
                                <label class="form-label">RPE (1 à 10)</label>
                                <input type="number" id="tc_rpe" class="form-control" placeholder="Ex: 8" min="1" max="10">
                            </div>
                            <div class="col-md-6 form-group">
                                <label class="form-label">Durée (minutes)</label>
                                <input type="number" id="tc_time" class="form-control" placeholder="Ex: 60">
                            </div>
                        </div>
                        <button class="btn-calculate" onclick="calcTrainingLoad()">Calculer Unités Arbitraires (UA)</button>
                        <div id="tcResult" class="result-value-big mt-4">--</div>
                        <p id="tcLabel" class="text-center text-muted" style="display:none;">Unités Arbitraires</p>
                    </div>
                </div>

                <!-- 11. Yo-Yo Test 1 -->
                <div class="tab-pane fade" id="tab-yoyo1" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Yo-Yo Intermittent Recovery Test Level 1</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Distance totale courue (mètres)</label>
                            <input type="number" id="yy1_d" class="form-control" placeholder="Ex: 1000">
                        </div>
                        <button class="btn-calculate" onclick="calcYoyo1()">Évaluer VO₂max (IR1)</button>
                        <div id="yy1Result" class="result-value-big mt-4">--</div>
                    </div>
                </div>

                <!-- 12. Yo-Yo Test 2 -->
                <div class="tab-pane fade" id="tab-yoyo2" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Yo-Yo Intermittent Recovery Test Level 2</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Distance totale courue (mètres)</label>
                            <input type="number" id="yy2_d" class="form-control" placeholder="Ex: 800">
                        </div>
                        <button class="btn-calculate" onclick="calcYoyo2()">Évaluer VO₂max (IR2)</button>
                        <div id="yy2Result" class="result-value-big mt-4">--</div>
                    </div>
                </div>

                <!-- 13. Yo-Yo Endurance -->
                <div class="tab-pane fade" id="tab-yoyo-end" role="tabpanel">
                    <div class="glass-panel">
                        <h3>Yo-Yo Endurance Test 1/2</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Niveau (Paliers)</label>
                            <input type="number" id="yye_level" class="form-control" placeholder="Ex: 15" step="0.5">
                        </div>
                        <button class="btn-calculate" onclick="calcYoyoEnd()">Score Estimatif</button>
                        <div id="yyeResult" class="result-value-big mt-4">--</div>
                        <p class="text-center text-muted" style="margin-top:10px;">Le test d'endurance se lit principalement avec des tables normatives (ex: VMA associée). L'estimation ici est simplifiée.</p>
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

    let hrChartInstance = null;


    // Show/Hide hips field for Navy body fat
    document.getElementById('fb_sex').addEventListener('change', function() {
        document.getElementById('fb_hip_group').style.display = this.value === 'female' ? 'block' : 'none';
    });

    // 1. Target HR
    function calcTargetHR() {
        const age = parseInt(document.getElementById('t_hr_age').value);
        const restHr = parseInt(document.getElementById('t_hr_rest').value);
        if(!age) return alert('Âge invalide.');
        const maxHr = 220 - age;
        
        let zones = [];
        if (restHr) {
            const hrr = maxHr - restHr;
            zones = [
                { l: 'Z1 (50-60%)', min: Math.round(hrr*0.5+restHr), max: Math.round(hrr*0.6+restHr) },
                { l: 'Z2 (60-70%)', min: Math.round(hrr*0.6+restHr), max: Math.round(hrr*0.7+restHr) },
                { l: 'Z3 (70-80%)', min: Math.round(hrr*0.7+restHr), max: Math.round(hrr*0.8+restHr) },
                { l: 'Z4 (80-90%)', min: Math.round(hrr*0.8+restHr), max: Math.round(hrr*0.9+restHr) },
                { l: 'Z5 (90-100%)', min: Math.round(hrr*0.9+restHr), max: maxHr }
            ];
        } else {
            zones = [
                { l: 'Z1', min: Math.round(maxHr*0.5), max: Math.round(maxHr*0.6) },
                { l: 'Z2', min: Math.round(maxHr*0.6), max: Math.round(maxHr*0.7) },
                { l: 'Z3', min: Math.round(maxHr*0.7), max: Math.round(maxHr*0.8) },
                { l: 'Z4', min: Math.round(maxHr*0.8), max: Math.round(maxHr*0.9) },
                { l: 'Z5', min: Math.round(maxHr*0.9), max: maxHr }
            ];
        }
        
        document.getElementById('hrChartContainer').style.display = 'block';
        const ctx = document.getElementById('hrChart').getContext('2d');
        if (hrChartInstance) hrChartInstance.destroy();
        hrChartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: zones.map(z=>z.l),
                datasets: [
                    { label: 'BPM Min', data: zones.map(z=>z.min), backgroundColor: 'rgba(255,255,255,0.2)' },
                    { label: 'BPM Max', data: zones.map(z=>z.max), backgroundColor: '#FFB800' }
                ]
            },
            options:{ responsive:true, maintainAspectRatio:false }
        });
    }

    // 2. VO2 Max
    function calcVO2() {
        const d = parseInt(document.getElementById('vo2_dist').value);
        if(!d) return alert('Distance invalide');
        const res = (d - 504.9) / 44.73;
        document.getElementById('vo2Result').style.display='block';
        document.getElementById('vo2Result').innerText = res.toFixed(1) + " ml/kg/min";
    }

    // 3. VMA
    function calcVMA() {
        const d = parseInt(document.getElementById('vma_dist').value);
        if(!d) return alert('Distance invalide');
        const vma = d / 100; // Demi-cooper (6 min = 1/10 d'heure) donc distance en km * 10
        document.getElementById('vmaResult').style.display='block';
        document.getElementById('vmaLabel').style.display='block';
        document.getElementById('vmaResult').innerText = vma.toFixed(1);
    }

    // 4. vVO2max
    function calcVVO2() {
        const v = parseFloat(document.getElementById('vvo2_val').value);
        if(!v) return alert('Valeur invalide');
        const vma = v / 3.5; // Approximation classique de Balke
        document.getElementById('vvo2Result').style.display='block';
        document.getElementById('vvo2Label').style.display='block';
        document.getElementById('vvo2Result').innerText = vma.toFixed(1);
    }

    // 5. Avg Resting HR
    function calcRestingHR() {
        const r1 = parseInt(document.getElementById('rhr1').value) || 0;
        const r2 = parseInt(document.getElementById('rhr2').value) || 0;
        const r3 = parseInt(document.getElementById('rhr3').value) || 0;
        let c = 0, sum = 0;
        if(r1){ sum+=r1; c++; }
        if(r2){ sum+=r2; c++; }
        if(r3){ sum+=r3; c++; }
        if(c===0) return alert('Veuillez entrer au moins 1 valeur');
        document.getElementById('rhrResult').style.display='block';
        document.getElementById('rhrLabel').style.display='block';
        document.getElementById('rhrResult').innerText = Math.round(sum/c);
    }

    // 6. Blood Pressure
    function calcBP() {
        const sys = parseInt(document.getElementById('bp_sys').value);
        const dia = parseInt(document.getElementById('bp_dia').value);
        if(!sys || !dia) return alert('Saisie invalide');
        let txt = "Normale";
        let color = "#10b981";
        if(sys >= 140 || dia >= 90){ txt = "Hypertension (Stade 2/+)"; color = "#ef4444"; }
        else if(sys >= 130 || dia >= 80){ txt = "Hypertension (Stade 1)"; color = "#f59e0b"; }
        else if(sys >= 120 && dia < 80){ txt = "Élevée"; color = "#eab308"; }
        
        const el = document.getElementById('bpResult');
        el.style.display='block';
        el.innerText = txt;
        el.style.color = color;
    }

    // 7. Water Req
    function calcWaterReq() {
        const w = parseFloat(document.getElementById('water_w').value);
        if(!w) return;
        const r = w * 35 / 1000; // 35ml par kilo
        document.getElementById('waterReqResult').style.display='block';
        document.getElementById('waterReqLabel').style.display='block';
        document.getElementById('waterReqResult').innerText = r.toFixed(2);
    }

    // 8. Water loss
    function calcWaterLoss() {
        const w1 = parseFloat(document.getElementById('wl_w1').value);
        const w2 = parseFloat(document.getElementById('wl_w2').value);
        const d = parseFloat(document.getElementById('wl_drink').value) || 0;
        if(!w1 || !w2) return;
        const loss = (w1 - w2) + d;
        document.getElementById('wlResult').style.display='block';
        document.getElementById('wlLabel').style.display='block';
        document.getElementById('wlResult').innerText = (loss > 0 ? loss : 0).toFixed(2);
    }

    // 9. Full Body
    function calcFullBody() {
        const sx = document.getElementById('fb_sex').value;
        const h = parseFloat(document.getElementById('fb_h').value);
        const nk = parseFloat(document.getElementById('fb_neck').value);
        const ws = parseFloat(document.getElementById('fb_waist').value);
        if(!h || !nk || !ws) return;
        let bf = 0;
        if (sx === 'male') {
            bf = 495 / (1.0324 - 0.19077 * Math.log10(ws - nk) + 0.15456 * Math.log10(h)) - 450;
        } else {
            const hp = parseFloat(document.getElementById('fb_hip').value);
            if(!hp) return alert('Le tour de hanches est requis pour les femmes');
            bf = 495 / (1.29579 - 0.35004 * Math.log10(ws + hp - nk) + 0.22100 * Math.log10(h)) - 450;
        }
        document.getElementById('fbResult').style.display='block';
        document.getElementById('fbLabel').style.display='block';
        document.getElementById('fbResult').innerText = (bf > 0 ? bf.toFixed(1) : "--") + "%";
    }

    // 10. Training calc
    function calcTrainingLoad() {
        const r = parseInt(document.getElementById('tc_rpe').value);
        const t = parseInt(document.getElementById('tc_time').value);
        if(!r || !t) return;
        document.getElementById('tcResult').style.display='block';
        document.getElementById('tcLabel').style.display='block';
        document.getElementById('tcResult').innerText = (r * t);
    }

    // 11. YoYo 1
    function calcYoyo1() {
        const d = parseInt(document.getElementById('yy1_d').value);
        if(!d) return;
        const vo2 = d * 0.0084 + 36.4;
        document.getElementById('yy1Result').style.display='block';
        document.getElementById('yy1Result').innerText = vo2.toFixed(1) + " ml/kg/min";
    }

    // 12. YoYo 2
    function calcYoyo2() {
        const d = parseInt(document.getElementById('yy2_d').value);
        if(!d) return;
        const vo2 = d * 0.0136 + 45.3;
        document.getElementById('yy2Result').style.display='block';
        document.getElementById('yy2Result').innerText = vo2.toFixed(1) + " ml/kg/min";
    }

    // 13. YoYo Endurance
    function calcYoyoEnd() {
        const l = parseFloat(document.getElementById('yye_level').value);
        if(!l) return;
        // Approximation générique, normalement c'est des tableaux.
        document.getElementById('yyeResult').style.display='block';
        document.getElementById('yyeResult').innerText = "VMA ≈ " + (10 + (l*0.5)).toFixed(1) + " km/h";
    }

</script>
@endsection
