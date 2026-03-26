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
        background: rgba(255, 255, 255, 0.05);
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

    .nav-pills-custom {
        display: flex;
        flex-direction: column;
        gap: 8px;
        padding-right: 15px;
        border-right: 1px solid rgba(255,255,255,0.1);
        max-height: 80vh;
        overflow-y: auto;
    }

    html[data-theme="light"] .nav-pills-custom {
        border-right-color: rgba(0,0,0,0.1);
    }

    .nav-pills-custom .nav-link {
        color: var(--text);
        border-radius: 12px;
        padding: 15px 20px;
        font-weight: 600;
        font-size: 0.95rem;
        background: rgba(255,255,255,0.03);
        border: 1px solid rgba(255,255,255,0.05);
        transition: all 0.3s;
        text-align: left;
        margin-bottom: 5px;
    }

    html[data-theme="light"] .nav-pills-custom .nav-link {
        background: rgba(0,0,0,0.03);
        border-color: rgba(0,0,0,0.05);
    }

    .nav-pills-custom .nav-link.active {
        background: var(--accent, #FFB800) !important;
        color: #000 !important;
        font-weight: 800;
        box-shadow: 0 5px 15px rgba(255, 184, 0, 0.3);
    }

    .form-group { margin-bottom: 18px; }
    .form-label { display: block; font-weight: 700; margin-bottom: 8px; color: var(--text); font-size: 0.9rem; }
    
    .form-control, .form-select {
        width: 100%;
        padding: 12px 18px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        color: var(--text);
    }

    html[data-theme="light"] .form-control, html[data-theme="light"] .form-select {
        background: rgba(0, 0, 0, 0.03);
        border-color: rgba(0, 0, 0, 0.1);
        color: #000;
    }

    .btn-calculate {
        background: var(--accent, #FFB800);
        color: #000;
        font-weight: 800;
        text-transform: uppercase;
        padding: 14px 25px;
        border: none;
        border-radius: 12px;
        width: 100%;
        cursor: pointer;
        transition: 0.3s;
        margin-top: 10px;
    }


    .result-box {
        background: rgba(255, 184, 0, 0.1);
        border: 1px solid rgba(255, 184, 0, 0.2);
        border-radius: 16px;
        padding: 20px;
        margin-top: 20px;
        text-align: center;
        display: none;
    }

    .result-val {
        font-size: 2.5rem;
        font-weight: 900;
        color: var(--accent, #FFB800);
        display: block;
    }

    .category-title {
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 2px;
        color: var(--accent, #FFB800);
        margin: 20px 0 10px 15px;
        font-weight: 800;
        opacity: 0.8;
    }

    .text-muted { color: rgba(255,255,255,0.5) !important; }
    html[data-theme="light"] .text-muted { color: #888 !important; }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
</style>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
@endsection

@section('dashboard-content')
<div class="module-container">
    <div class="d-flex align-items-center mb-4" style="gap:15px;">
        <a href="{{ route('modules.index') }}" class="btn-ghost" style="padding: 10px 15px; color: white; text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <i data-lucide="arrow-left" style="width: 20px; height: 20px;"></i> {{ __('Retour') }}
        </a>
        <h1 class="welcome-title mb-0" style="font-size: 2.5rem; font-weight: 900; color: white;">Training Calculation</h1>
    </div>

    <!-- Main Dashboard Grid -->
    <div id="module-dashboard">
        <p class="text-muted mb-4" style="font-size: 1.1rem;">Sélectionnez l'un des 16 outils de performance pour commencer vos calculs.</p>
        
        <div class="category-title mt-0">Tests Cardio & Zones</div>
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t1')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🏃‍♂️</div>
                    <h5 style="font-weight: 800;">Half Cooper</h5>
                    <small class="text-muted">VMA (6 min)</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t2')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">❤️</div>
                    <h5 style="font-weight: 800;">HRmax</h5>
                    <small class="text-muted">FC Maximale</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t3')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🫀</div>
                    <h5 style="font-weight: 800;">Karvonen</h5>
                    <small class="text-muted">Zones d'effort</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t4')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⚡</div>
                    <h5 style="font-weight: 800;">Aerobic Speed</h5>
                    <small class="text-muted">Allures % VMA</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t5')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🏁</div>
                    <h5 style="font-weight: 800;">Cooper Test</h5>
                    <small class="text-muted">VO2max (12 min)</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t6')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">📏</div>
                    <h5 style="font-weight: 800;">CAT Test</h5>
                    <small class="text-muted">Allure Terrain</small>
                </div>
            </div>
        </div>

        <div class="category-title">Séances & Programmation</div>
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t7')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⏱️</div>
                    <h5 style="font-weight: 800;">Time Based</h5>
                    <small class="text-muted">Volume par temps</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t8')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">📐</div>
                    <h5 style="font-weight: 800;">Distance Based</h5>
                    <small class="text-muted">Prog. par distance</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t9')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🚀</div>
                    <h5 style="font-weight: 800;">Speed Based</h5>
                    <small class="text-muted">Calcul de vitesse</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t10')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🛣️</div>
                    <h5 style="font-weight: 800;">Km Based</h5>
                    <small class="text-muted">Allure/Km</small>
                </div>
            </div>
        </div>

        <div class="category-title">Forme & Indices</div>
        <div class="row g-3">
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t11')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🏋️</div>
                    <h5 style="font-weight: 800;">Strength (1RM)</h5>
                    <small class="text-muted">Force maximale</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t12')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🧪</div>
                    <h5 style="font-weight: 800;">Ruffier Test</h5>
                    <small class="text-muted">Indice cardiaque</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t13')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🪜</div>
                    <h5 style="font-weight: 800;">YMCA Step</h5>
                    <small class="text-muted">Endurance step</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t14')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⚖️</div>
                    <h5 style="font-weight: 800;">Weight/Height</h5>
                    <small class="text-muted">IMC & Morpho</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t15')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">📉</div>
                    <h5 style="font-weight: 800;">Training Load</h5>
                    <small class="text-muted">Charge UA</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('t16')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🔥</div>
                    <h5 style="font-weight: 800;">Calories MET</h5>
                    <small class="text-muted">Dépense (kcal)</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Tool Detail View -->
    <div id="tool-detail-view" style="display: none;">
        <div class="row">
            <!-- Mini-Nav for Tool Switching -->
            <div class="col-md-3 d-none d-md-block">
                <button class="btn btn-outline-light w-100 mb-3" onclick="backToDashboard()" style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                    <i data-lucide="layout-grid" style="width: 18px; height: 18px;"></i> Menu des tests
                </button>
                <div class="nav flex-column nav-pills nav-pills-custom" id="training-tabs" role="tablist">
                    <button class="nav-link active" data-bs-toggle="pill" data-bs-target="#t1">1. Half Cooper</button>
                    <button class="nav-link" data-bs-toggle="pill" data-bs-target="#t2">2. HRmax</button>
                    ...
                </div>
            </div>
            <div class="col-md-9">
                <div class="d-md-none mb-3">
                   <button class="btn btn-outline-light btn-sm" onclick="backToDashboard()"><i class="fas fa-arrow-left"></i> Liste des tests</button>
                </div>
                
                <!-- 1. Half Cooper -->
                <div class="tab-pane fade show active" id="t1">
                    <div class="glass-panel">
                        <h3>Half Cooper (6 min)</h3>
                        <p class="text-muted">Estime la VMA en courant la distance maximale possible en 6 minutes.</p>
                        <div class="form-group mt-4">
                            <label class="form-label">Distance (mètres)</label>
                            <input type="number" id="c1_d" class="form-control" placeholder="Ex: 1500">
                        </div>
                        <button class="btn-calculate" onclick="calcT1()">Calculer VMA</button>
                        <div id="r1" class="result-box"><span class="result-val" id="v1">0</span><span>km/h</span></div>
                    </div>
                </div>

                <!-- 2. HRmax -->
                <div class="tab-pane fade" id="t2">
                    <div class="glass-panel">
                        <h3>Frequence Cardiaque Maximale (HRmax)</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Âge</label>
                            <input type="number" id="c2_age" class="form-control" placeholder="30">
                        </div>
                        <button class="btn-calculate" onclick="calcT2()">Calculer HRmax</button>
                        <div id="r2" class="result-box"><span class="result-val" id="v2">0</span><span>BPM (Gellish)</span></div>
                    </div>
                </div>

                <!-- 3. Karvonen -->
                <div class="tab-pane fade" id="t3">
                    <div class="glass-panel">
                        <h3>Zones Karvonen</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">HRmax</label><input type="number" id="c3_max" class="form-control"></div>
                            <div class="col-6"><label class="form-label">HR-Repos</label><input type="number" id="c3_rest" class="form-control"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT3()">Calculer Intensité 75%</button>
                        <div id="r3" class="result-box">Cible (75%): <span class="result-val" id="v3">0</span><span>BPM</span></div>
                    </div>
                </div>

                <!-- 4. Aerobic Speed -->
                <div class="tab-pane fade" id="t4">
                    <div class="glass-panel">
                        <h3>Aerobic Speed</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">VMA (km/h)</label>
                            <input type="number" id="c4_vma" class="form-control" placeholder="15">
                        </div>
                        <button class="btn-calculate" onclick="calcT4()">Allure à 80%</button>
                        <div id="r4" class="result-box"><span class="result-val" id="v4">0</span><span>km/h</span></div>
                    </div>
                </div>

                <!-- 5. Cooper Test -->
                <div class="tab-pane fade" id="t5">
                    <div class="glass-panel">
                        <h3>Cooper Test (12 min)</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Distance (mètres)</label>
                            <input type="number" id="c5_d" class="form-control" placeholder="2400">
                        </div>
                        <button class="btn-calculate" onclick="calcT5()">Calculer VO₂max</button>
                        <div id="r5" class="result-box"><span class="result-val" id="v5">0</span><span>ml/kg/min</span></div>
                    </div>
                </div>

                <!-- 6. CAT Test -->
                <div class="tab-pane fade" id="t6">
                    <div class="glass-panel">
                        <h3>CAT (Calculateur Allure Terrain)</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">Distance (m)</label><input type="number" id="c6_d" class="form-control" value="1000"></div>
                            <div class="col-6"><label class="form-label">Temps VMA (s)</label><input type="number" id="c6_t" class="form-control" placeholder="240"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT6()">Temps à 90%</button>
                        <div id="r6" class="result-box"><span class="result-val" id="v6">0</span><span>secondes</span></div>
                    </div>
                </div>

                <!-- 7. Time Based -->
                <div class="tab-pane fade" id="t7">
                    <div class="glass-panel">
                        <h3>Time Based Session</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">Temps Total (min)</label><input type="number" id="c7_t" class="form-control" value="30"></div>
                            <div class="col-6"><label class="form-label">Vitesse (km/h)</label><input type="number" id="c7_v" class="form-control" value="10"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT7()">Distance Estimée</button>
                        <div id="r7" class="result-box"><span class="result-val" id="v7">0</span><span>km</span></div>
                    </div>
                </div>

                <!-- 8. Distance Based -->
                <div class="tab-pane fade" id="t8">
                    <div class="glass-panel">
                        <h3>Distance Based Session</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">Distance (km)</label><input type="number" id="c8_d" class="form-control" value="5"></div>
                            <div class="col-6"><label class="form-label">Vitesse (km/h)</label><input type="number" id="c8_v" class="form-control" value="12"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT8()">Temps Nécessaire</button>
                        <div id="r8" class="result-box"><span class="result-val" id="v8">0</span><span>minutes</span></div>
                    </div>
                </div>

                <!-- 9. Speed Based -->
                <div class="tab-pane fade" id="t9">
                    <div class="glass-panel">
                        <h3>Speed Calculation</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">Distance (m)</label><input type="number" id="c9_d" class="form-control" value="400"></div>
                            <div class="col-6"><label class="form-label">Temps (s)</label><input type="number" id="c9_t" class="form-control" value="80"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT9()">Vitesse</button>
                        <div id="r9" class="result-box"><span class="result-val" id="v9">0</span><span>km/h</span></div>
                    </div>
                </div>

                <!-- 10. Kilometer Based -->
                <div class="tab-pane fade" id="t10">
                    <div class="glass-panel">
                        <h3>Allure au Kilomètre</h3>
                        <div class="form-group mt-4">
                            <label class="form-label">Vitesse (km/h)</label>
                            <input type="number" id="c10_v" class="form-control" value="10">
                        </div>
                        <button class="btn-calculate" onclick="calcT10()">Calculer Allure</button>
                        <div id="r10" class="result-box"><span class="result-val" id="v10">0</span><span>min/km</span></div>
                    </div>
                </div>

                <!-- 11. Strength (1RM) -->
                <div class="tab-pane fade" id="t11">
                    <div class="glass-panel">
                        <h3>Force Maximale (1RM)</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">Poids (kg)</label><input type="number" id="c11_w" class="form-control" value="80"></div>
                            <div class="col-6"><label class="form-label">Reps</label><input type="number" id="c11_r" class="form-control" value="6"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT11()">Calculer 1RM</button>
                        <div id="r11" class="result-box"><span class="result-val" id="v11">0</span><span>kg (Brzycki)</span></div>
                    </div>
                </div>

                <!-- 12. Ruffier-Dickson -->
                <div class="tab-pane fade" id="t12">
                    <div class="glass-panel">
                        <h3>Test Ruffier-Dickson</h3>
                        <div class="row mt-4">
                            <div class="col-4"><label class="form-label">Repos (P0)</label><input type="number" id="c12_p0" class="form-control"></div>
                            <div class="col-4"><label class="form-label">Effort (P1)</label><input type="number" id="c12_p1" class="form-control"></div>
                            <div class="col-4"><label class="form-label">Recup (P2)</label><input type="number" id="c12_p2" class="form-control"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT12()">Calculer Indice</button>
                        <div id="r12" class="result-box">Indice Ruffier: <span class="result-val" id="v12">0</span></div>
                    </div>
                </div>

                <!-- 13. YMCA Step Test -->
                <div class="tab-pane fade" id="t13">
                    <div class="glass-panel">
                        <h3>YMCA Step Test</h3>
                        <p class="text-muted">3 minutes de step, puis mesurez votre pouls pendant 1 minute.</p>
                        <div class="form-group mt-4">
                            <label class="form-label">Pouls après 3 min (BPM)</label>
                            <input type="number" id="c13_p" class="form-control" placeholder="90">
                        </div>
                        <button class="btn-calculate" onclick="calcT13()">Score</button>
                        <div id="r13" class="result-box">Score: <span class="result-val" id="v13">--</span></div>
                    </div>
                </div>

                <!-- 14. Weight & Height -->
                <div class="tab-pane fade" id="t14">
                    <div class="glass-panel">
                        <h3>Indice de Masse Corporelle (IMC)</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">Poids (kg)</label><input type="number" id="c14_w" class="form-control" value="70"></div>
                            <div class="col-6"><label class="form-label">Taille (cm)</label><input type="number" id="c14_h" class="form-control" value="175"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT14()">Calculer IMC</button>
                        <div id="r14" class="result-box"><span class="result-val" id="v14">0</span></div>
                    </div>
                </div>

                <!-- 15. Training Load -->
                <div class="tab-pane fade" id="t15">
                    <div class="glass-panel">
                        <h3>Charge d'entraînement (UA)</h3>
                        <div class="row mt-4">
                            <div class="col-6"><label class="form-label">RPE (1-10)</label><input type="number" id="c15_rpe" class="form-control" value="7"></div>
                            <div class="col-6"><label class="form-label">Durée (min)</label><input type="number" id="c15_d" class="form-control" value="60"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT15()">Calculer UA</button>
                        <div id="r15" class="result-box"><span class="result-val" id="v15">0</span><span>UA</span></div>
                    </div>
                </div>

                <!-- 16. Calories MET -->
                <div class="tab-pane fade" id="t16">
                    <div class="glass-panel">
                        <h3>Energy Expenditure (Calories)</h3>
                        <div class="row mt-4">
                            <div class="col-4"><label class="form-label">Poids (kg)</label><input type="number" id="c16_w" class="form-control" value="70"></div>
                            <div class="col-4"><label class="form-label">MET (Ex: 8)</label><input type="number" id="c16_met" class="form-control" value="8"></div>
                            <div class="col-4"><label class="form-label">Durée (min)</label><input type="number" id="c16_d" class="form-control" value="60"></div>
                        </div>
                        <button class="btn-calculate mt-3" onclick="calcT16()">Estimer Calories</button>
                        <div id="r16" class="result-box"><span class="result-val" id="v16">0</span><span>kcal</span></div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
@endsection

@section('dashboard-scripts')
<script>
    function showR(id, val) {
        let el = document.getElementById(id);
        let box = el.parentElement;
        el.innerText = val;
        box.style.display = 'block';
    }

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


    function calcT1() {
        let d = document.getElementById('c1_d').value;
        showR('v1', (d/100).toFixed(1));
    }
    function calcT2() {
        let a = document.getElementById('c2_age').value;
        showR('v2', (191.5 - 0.007 * a * a).toFixed(0)); // Gellish
    }
    function calcT3() {
        let max = document.getElementById('c3_max').value;
        let rest = document.getElementById('c3_rest').value;
        let v = (max - rest) * 0.75 + parseInt(rest);
        showR('v3', v.toFixed(0));
    }
    function calcT4() {
        let vma = document.getElementById('c4_vma').value;
        showR('v4', (vma * 0.8).toFixed(1));
    }
    function calcT5() {
        let d = document.getElementById('c5_d').value;
        showR('v5', ((d - 504.9) / 44.73).toFixed(1));
    }
    function calcT6() {
        let t = document.getElementById('c6_t').value;
        showR('v6', (t / 0.9).toFixed(0));
    }
    function calcT7() {
        let t = document.getElementById('c7_t').value;
        let v = document.getElementById('c7_v').value;
        showR('v7', (v * (t/60)).toFixed(2));
    }
    function calcT8() {
        let d = document.getElementById('c8_d').value;
        let v = document.getElementById('c8_v').value;
        showR('v8', ((d/v)*60).toFixed(0));
    }
    function calcT9() {
        let d = document.getElementById('c9_d').value;
        let t = document.getElementById('c9_t').value;
        showR('v9', ((d/t)*3.6).toFixed(1));
    }
    function calcT10() {
        let v = document.getElementById('c10_v').value;
        let m = 60 / v;
        let mm = Math.floor(m);
        let ss = Math.round((m-mm)*60);
        showR('v10', mm + ":" + (ss<10?'0':'') + ss);
    }
    function calcT11() {
        let w = document.getElementById('c11_w').value;
        let r = document.getElementById('c11_r').value;
        showR('v11', (w * (36 / (37 - r))).toFixed(1)); // Brzycki
    }
    function calcT12() {
        let p0 = parseInt(document.getElementById('c12_p0').value);
        let p1 = parseInt(document.getElementById('c12_p1').value);
        let p2 = parseInt(document.getElementById('c12_p2').value);
        showR('v12', ((p0 + p1 + p2 - 200)/10).toFixed(1));
    }
    function calcT13() {
        let p = document.getElementById('c13_p').value;
        let score = "Excellent";
        if(p > 100) score = "Moyen";
        if(p > 120) score = "Faible";
        showR('v13', score);
    }
    function calcT14() {
        let w = document.getElementById('c14_w').value;
        let h = document.getElementById('c14_h').value / 100;
        showR('v14', (w / (h*h)).toFixed(1));
    }
    function calcT15() {
        let r = document.getElementById('c15_rpe').value;
        let d = document.getElementById('c15_d').value;
        showR('v15', r * d);
    }
    function calcT16() {
        let w = document.getElementById('c16_w').value;
        let met = document.getElementById('c16_met').value;
        let d = document.getElementById('c16_d').value;
        showR('v16', (met * 3.5 * w / 200 * d).toFixed(0));
    }
</script>
@endsection
