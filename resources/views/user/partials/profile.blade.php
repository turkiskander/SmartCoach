<div id="section-profil" class="dashboard-section-content" style="display: none;">
    <h2 class="welcome-title" style="text-align: left; font-size: 2rem;">{{ __('Mon Profil Personnel') }}</h2>
    
    @if(session('success'))
        <div style="background: rgba(0, 255, 0, 0.1); color: #00ff00; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(0, 255, 0, 0.2);">
            {{ session('success') }}
        </div>
    @endif

    @if($errors->any())
        <div style="background: rgba(255, 0, 0, 0.1); color: #ff3333; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(255, 0, 0, 0.2);">
            @foreach($errors->all() as $error)
                <p style="margin: 0;">{{ $error }}</p>
            @endforeach
        </div>
    @endif

    <div class="stat-card" style="margin-top: 20px;">
        <div style="display: flex; gap: 40px; align-items: start;">
            <div style="text-align: center;">
                <div class="profile-avatar-wrap" style="width: 150px; height: 150px; margin: 0 auto 15px;">
                    <img src="{{ Auth::user()->avatar ? asset('storage/' . Auth::user()->avatar) : asset('assets/img/avatar_placeholder.png') }}" class="profile-avatar" id="avatarPreview">
                </div>
                <form action="{{ route('profile.avatar.update') }}" method="POST" enctype="multipart/form-data" id="avatarForm">
                    @csrf
                    <label for="avatarInput" class="btn-primary" style="cursor: pointer; font-size: 0.9rem;">
                        <i data-lucide="camera" style="width: 20px; height: 20px;"></i> {{ __('Changer Photo') }}
                    </label>
                    <input type="file" name="avatar" id="avatarInput" style="display: none;" onchange="document.getElementById('avatarForm').submit();">
                </form>
            </div>
            <div style="flex-grow: 1; padding-top: 20px;">
                <h3 style="font-family: var(--font-display); font-size: 1.5rem;">{{ Auth::user()->name }}</h3>
                <p style="color: var(--muted); margin-bottom: 20px;">{{ Auth::user()->email }}</p>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                    <div><strong>{{ __('Taille') }} :</strong> {{ Auth::user()->height }} cm</div>
                    <div><strong>{{ __('Poids') }} :</strong> {{ Auth::user()->weight }} kg</div>
                    <div><strong>{{ __('Objectif') }} :</strong> {{ __(str_replace('_', ' ', Auth::user()->goal)) }}</div>
                    <div><strong>{{ __('Niveau') }} :</strong> {{ __(str_replace('_', ' ', Auth::user()->activity_level)) }}</div>
                </div>
            </div>
        </div>
    </div>
</div>
