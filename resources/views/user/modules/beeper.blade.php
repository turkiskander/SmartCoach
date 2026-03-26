@extends('layouts.dashboard')

@section('dashboard-styles')
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    .module-container {
        max-width: 800px;
        margin: 0 auto;
        animation: fadeIn 0.5s ease-out;
    }

    .glass-panel {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 24px;
        padding: 40px;
        backdrop-filter: blur(12px);
        margin-bottom: 25px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.2);
        position: relative;
        overflow: hidden;
    }

    html[data-theme="light"] .glass-panel {
        background: rgba(255, 255, 255, 0.9);
        border-color: rgba(0, 0, 0, 0.08);
        box-shadow: 0 15px 35px rgba(0,0,0,0.05);
    }

    /* Timer Display */
    .timer-circle {
        width: 280px;
        height: 280px;
        border-radius: 50%;
        border: 10px solid rgba(255,184,0,0.2);
        margin: 0 auto 30px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        position: relative;
        box-shadow: 0 0 50px rgba(255,184,0,0.1) inset;
        transition: border-color 0.3s ease;
    }

    .timer-circle.active { border-color: var(--accent, #FFB800); box-shadow: 0 0 40px rgba(255,184,0,0.3); }
    .timer-circle.rest { border-color: #10b981; box-shadow: 0 0 40px rgba(16,185,129,0.3); }
    html[data-theme="light"] .timer-circle.active { border-color: var(--accent, #FFB800); box-shadow: 0 0 40px rgba(255,184,0,0.5); }
    html[data-theme="light"] .timer-circle.rest { border-color: #10b981; box-shadow: 0 0 40px rgba(16,185,129,0.5); }

    .time-display {
        font-family: var(--font-display);
        font-size: 5.5rem;
        font-weight: 900;
        letter-spacing: -2px;
        line-height: 1;
        color: var(--text);
    }

    .phase-label {
        font-size: 1.2rem;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 2px;
        color: var(--muted);
        margin-top: 10px;
    }

    .timer-circle.active .phase-label { color: var(--accent, #FFB800); }
    .timer-circle.rest .phase-label { color: #10b981; }

    /* Controls */
    .controls-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
        margin-bottom: 30px;
    }

    .control-item {
        background: rgba(0,0,0,0.2);
        padding: 15px;
        border-radius: 16px;
        text-align: center;
        border: 1px solid rgba(255,255,255,0.05);
    }

    html[data-theme="light"] .control-item { background: rgba(0,0,0,0.03); border-color: rgba(0,0,0,0.05); }

    .control-label { font-size: 0.85rem; font-weight: 700; color: var(--muted); text-transform: uppercase; margin-bottom: 10px; }
    
    .input-group {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 15px;
    }

    .btn-icon {
        background: rgba(255,255,255,0.1);
        border: none;
        color: var(--text);
        width: 36px;
        height: 36px;
        border-radius: 10px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s;
    }

    .btn-icon:hover { background: var(--accent, #FFB800); color: #000; }
    html[data-theme="light"] .btn-icon { background: rgba(0,0,0,0.1); color: #000; }
    html[data-theme="light"] .btn-icon:hover { background: var(--accent, #FFB800); color: #000; }

    .val-display { font-size: 1.5rem; font-weight: 800; min-width: 40px; }

    .action-buttons {
        display: flex;
        gap: 15px;
        justify-content: center;
    }

    .btn-start {
        background: var(--accent, #FFB800);
        color: #000;
        font-weight: 900;
        font-size: 1.2rem;
        padding: 18px 40px;
        border-radius: 99px;
        border: none;
        cursor: pointer;
        text-transform: uppercase;
        letter-spacing: 2px;
        box-shadow: 0 10px 25px rgba(255,184,0,0.3);
        transition: all 0.3s;
    }
    .btn-start:hover { transform: scale(1.05); }

    .btn-stop {
        background: rgba(239, 68, 68, 0.2);
        color: #ef4444;
        font-weight: 900;
        font-size: 1.2rem;
        padding: 18px 40px;
        border-radius: 99px;
        border: 1px solid #ef4444;
        cursor: pointer;
        text-transform: uppercase;
        letter-spacing: 2px;
        transition: all 0.3s;
        display: none;
    }
    .btn-stop:hover { background: #ef4444; color: white; }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
</style>
@endsection

@section('dashboard-content')
<div class="module-container">
    <div class="d-flex align-items-center mb-4" style="gap:15px;">
        <a href="{{ route('modules.index') }}" class="btn-ghost" style="padding: 10px 15px; color: white; text-decoration: none; display: flex; align-items: center; gap: 8px;">
            <i data-lucide="arrow-left" style="width: 20px; height: 20px;"></i> {{ __('Retour') }}
        </a>
        <h1 class="welcome-title mb-0" style="font-size: 2.5rem; font-weight: 900; color: white;">Beeper & Performance</h1>
    </div>

    <!-- Main Dashboard Grid -->
    <div id="module-dashboard">
        <p class="text-muted mb-4" style="font-size: 1.1rem;">Outils de chronométrage et tests de terrain intermittents.</p>
        
        <div class="row g-3">
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('timer-interval')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">⏱️</div>
                    <h5 style="font-weight: 800;">Interval Timer</h5>
                    <small class="text-muted">Travail / Repos</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('beep-test')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">📢</div>
                    <h5 style="font-weight: 800;">Beep Test</h5>
                    <small class="text-muted">Test de Léger (VMA)</small>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="glass-panel text-center p-4 h-100 tool-launcher" onclick="launchTool('stopwatch')" style="cursor:pointer; transition: 0.3s;">
                    <div style="font-size: 2.5rem; margin-bottom: 15px;">🏁</div>
                    <h5 style="font-weight: 800;">Chronomètre</h5>
                    <small class="text-muted">Simple / Tours</small>
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
                <div class="nav flex-column nav-pills nav-pills-custom" id="beeperTabs" role="tablist">
                    <button class="nav-link active" id="timer-tab" data-bs-toggle="pill" data-bs-target="#timer-interval">Intervals</button>
                    <button class="nav-link" id="beep-tab" data-bs-toggle="pill" data-bs-target="#beep-test">Beep Test</button>
                    <button class="nav-link" id="stop-tab" data-bs-toggle="pill" data-bs-target="#stopwatch">Chrono</button>
                </div>
            </div>
            <div class="col-md-9">
                <div class="d-md-none mb-3">
                   <button class="btn btn-outline-light btn-sm" onclick="backToDashboard()"><i class="fas fa-arrow-left"></i> Liste</button>
                </div>
                <div class="tab-content">

                <div class="tab-pane fade show active" id="timer-interval" role="tabpanel">
                    <div class="glass-panel text-center">
                        <div id="targetCircle" class="timer-circle">
                            <div id="timeDisplay" class="time-display">00:00</div>
                            <div id="phaseDisplay" class="phase-label">PRÊT</div>
                        </div>
                        <div id="settingsPanel">
                            <div class="controls-grid">
                                <div class="control-item">
                                    <div class="control-label">Travail (sec)</div>
                                    <div class="input-group">
                                        <button class="btn-icon" onclick="adj('work', -5)"><i class="fas fa-minus"></i></button>
                                        <div id="val_work" class="val-display">30</div>
                                        <button class="btn-icon" onclick="adj('work', 5)"><i class="fas fa-plus"></i></button>
                                    </div>
                                </div>
                                <div class="control-item">
                                    <div class="control-label">Repos (sec)</div>
                                    <div class="input-group">
                                        <button class="btn-icon" onclick="adj('rest', -5)"><i class="fas fa-minus"></i></button>
                                        <div id="val_rest" class="val-display">15</div>
                                        <button class="btn-icon" onclick="adj('rest', 5)"><i class="fas fa-plus"></i></button>
                                    </div>
                                </div>
                                <div class="control-item">
                                    <div class="control-label">Cycles</div>
                                    <div class="input-group">
                                        <button class="btn-icon" onclick="adj('cycles', -1)"><i class="fas fa-minus"></i></button>
                                        <div id="val_cycles" class="val-display">8</div>
                                        <button class="btn-icon" onclick="adj('cycles', 1)"><i class="fas fa-plus"></i></button>
                                    </div>
                                </div>
                                <div class="control-item">
                                    <div class="control-label">Préparation (sec)</div>
                                    <div class="input-group">
                                        <button class="btn-icon" onclick="adj('prep', -5)"><i class="fas fa-minus"></i></button>
                                        <div id="val_prep" class="val-display">10</div>
                                        <button class="btn-icon" onclick="adj('prep', 5)"><i class="fas fa-plus"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="workoutStats" style="display:none; margin-bottom: 30px;">
                            <h3 style="font-family: var(--font-display); font-weight:900;">Cycle: <span id="currentCycle" style="color:var(--accent);">1</span> / <span id="totalCycles">8</span></h3>
                        </div>
                        <div class="action-buttons">
                            <button id="btnStart" class="btn-start" onclick="startTimer()"><i class="fas fa-play"></i> Démarrer</button>
                            <button id="btnStop" class="btn-stop" onclick="stopTimer()"><i class="fas fa-stop"></i> Arrêter</button>
                        </div>
                    </div>
                </div>

                <!-- Beep Test -->
                <div class="tab-pane fade" id="beep-test" role="tabpanel">
                    <div class="glass-panel text-center">
                        <h3 style="font-weight: 800; color: white;">Beep Test (Léger-Boucher)</h3>
                        <div class="timer-circle active mt-4" style="width:200px; height:200px;">
                            <div id="beepLevel" class="time-display" style="font-size: 3rem;">L.1</div>
                            <div id="beepShuttle" class="phase-label">Aller</div>
                        </div>
                        <div id="beepStats" class="mt-4">
                            <h4 style="color:var(--accent);">Vitesse: <span id="beepSpeed">8.0</span> km/h</h4>
                        </div>
                        <button class="btn-calculate mt-4" onclick="startBeepTest()">Démarrer le Test</button>
                    </div>
                </div>

                <!-- Stopwatch -->
                <div class="tab-pane fade" id="stopwatch" role="tabpanel">
                    <div class="glass-panel text-center">
                        <div class="time-display" id="chronoDisplay" style="font-size: 6rem; margin-bottom: 30px;">00:00.00</div>
                        <div class="action-buttons">
                            <button class="btn-calculate" style="background:#10b981;" onclick="toggleChrono()">Start/Stop</button>
                            <button class="btn-calculate" style="background:#ef4444;" onclick="resetChrono()">Reset</button>
                        </div>
                    </div>
                </div>

                </div>
            </div>
        </div>
    </div>
</div>


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
        stopTimer();
        stopBeepTest();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // --- STOPWATCH ---
    let chronoTime = 0;
    let chronoInt = null;
    function toggleChrono() {
        if(chronoInt) { clearInterval(chronoInt); chronoInt = null; }
        else {
            chronoInt = setInterval(() => {
                chronoTime += 10;
                let ms = Math.floor((chronoTime % 1000) / 10).toString().padStart(2, '0');
                let s = Math.floor((chronoTime / 1000) % 60).toString().padStart(2, '0');
                let m = Math.floor(chronoTime / 60000).toString().padStart(2, '0');
                document.getElementById('chronoDisplay').innerText = `${m}:${s}.${ms}`;
            }, 10);
        }
    }
    function resetChrono() {
        clearInterval(chronoInt); chronoInt = null; chronoTime = 0;
        document.getElementById('chronoDisplay').innerText = "00:00.00";
    }

    // --- BEEP TEST (SIMPLIFIED) ---
    let beepInt = null;
    function startBeepTest() {
        if(audioCtx.state === 'suspended') audioCtx.resume();
        let level = 1;
        let speed = 8.0;
        let shuttle = 1;
        document.getElementById('beepLevel').innerText = "L.1";
        document.getElementById('beepSpeed').innerText = "8.0";
        beepLong();
        
        // This is a simplified interval for demo
        beepInt = setInterval(() => {
            shuttle++;
            if(shuttle > 8) { level++; speed += 0.5; shuttle = 1; }
            document.getElementById('beepLevel').innerText = "L." + level;
            document.getElementById('beepSpeed').innerText = speed.toFixed(1);
            document.getElementById('beepShuttle').innerText = (shuttle % 2 === 0 ? "Retour" : "Aller");
            beepShort();
        }, 9000); // Level 1 is approx 9s per 20m shuttle
    }
    function stopBeepTest() { clearInterval(beepInt); }

    const settings = { work: 30, rest: 15, cycles: 8, prep: 10 };

    let currentPhase = 'idle'; // idle, prep, work, rest
    let timeLeft = 0;
    let cycleCount = 1;
    let timerInt = null;

    // Audio Context Setup (Generated beep to avoid missing file errors)
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    
    function playBeep(freq, type, duration) {
        if(audioCtx.state === 'suspended') audioCtx.resume();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = type;
        osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
        gain.gain.setValueAtTime(1, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + duration);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + duration);
    }

    function beepShort() { playBeep(880, 'sine', 0.2); }
    function beepLong() { playBeep(1000, 'square', 0.6); }

    function adj(key, val) {
        let n = settings[key] + val;
        if (key === 'cycles' && n < 1) n = 1;
        if (key !== 'cycles' && n < 0) n = 0;
        settings[key] = n;
        document.getElementById(`val_${key}`).innerText = n;
    }

    function fmt(sec) {
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    }

    function updateUI() {
        document.getElementById('timeDisplay').innerText = fmt(timeLeft);

        const circle = document.getElementById('targetCircle');
        circle.className = 'timer-circle';
        if (currentPhase === 'work') circle.classList.add('active');
        if (currentPhase === 'rest' || currentPhase === 'prep') circle.classList.add('rest');

        let lbl = "PRÊT";
        if (currentPhase === 'prep') lbl = "PRÉPARATION";
        if (currentPhase === 'work') lbl = "TRAVAIL !";
        if (currentPhase === 'rest') lbl = "REPOS";
        document.getElementById('phaseDisplay').innerText = lbl;
        
        document.getElementById('currentCycle').innerText = cycleCount;
    }

    function startTimer() {
        if(audioCtx.state === 'suspended') audioCtx.resume();
        document.getElementById('settingsPanel').style.display = 'none';
        document.getElementById('workoutStats').style.display = 'block';
        document.getElementById('btnStart').style.display = 'none';
        document.getElementById('btnStop').style.display = 'inline-block';
        
        document.getElementById('totalCycles').innerText = settings.cycles;
        cycleCount = 1;
        
        if (settings.prep > 0) {
            currentPhase = 'prep';
            timeLeft = settings.prep;
        } else {
            currentPhase = 'work';
            timeLeft = settings.work;
            beepLong();
        }
        
        updateUI();

        timerInt = setInterval(() => {
            timeLeft--;
            
            // Beep sounds countdown
            if (timeLeft > 0 && timeLeft <= 3) {
                beepShort();
            }

            if (timeLeft <= 0) {
                if (currentPhase === 'prep') {
                    currentPhase = 'work';
                    timeLeft = settings.work;
                    beepLong();
                } else if (currentPhase === 'work') {
                    if (cycleCount >= settings.cycles) {
                        endTimer();
                        return;
                    }
                    currentPhase = 'rest';
                    timeLeft = settings.rest;
                    beepLong();
                } else if (currentPhase === 'rest') {
                    cycleCount++;
                    currentPhase = 'work';
                    timeLeft = settings.work;
                    beepLong();
                }
            }
            updateUI();
        }, 1000);
    }

    function stopTimer() {
        endTimer(true);
    }

    function endTimer(manual = false) {
        clearInterval(timerInt);
        currentPhase = 'idle';
        timeLeft = 0;
        updateUI();
        
        if (!manual) {
            document.getElementById('timeDisplay').innerText = "FINI";
            playBeep(440, 'triangle', 1.0); // Victory sound
        }

        document.getElementById('settingsPanel').style.display = 'block';
        document.getElementById('workoutStats').style.display = 'none';
        document.getElementById('btnStart').style.display = 'inline-block';
        document.getElementById('btnStop').style.display = 'none';
    }
</script>
@endsection
