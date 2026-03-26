<div class="lang-switcher">
    <button class="lang-btn" id="langBtn" type="button" aria-haspopup="true" aria-expanded="false">
        <span class="lang-btn__flag-img">
            @if(app()->getLocale() == 'fr') 
                <img src="{{ asset('assets/img/FR.png') }}" alt="FR" class="flag-icon">
            @elseif(app()->getLocale() == 'ar') 
                <img src="{{ asset('assets/img/AR.jpg') }}" alt="AR" class="flag-icon">
            @else 
                <img src="{{ asset('assets/img/ENG.png') }}" alt="EN" class="flag-icon">
            @endif
        </span>
        <span class="lang-btn__text">{{ strtoupper(app()->getLocale()) }}</span>
        <span class="lang-btn__arrow">▼</span>
    </button>
    <ul class="lang-dropdown" id="langDropdown">
        <li>
            <a href="{{ route('set-locale', 'fr') }}" class="{{ app()->getLocale() == 'fr' ? 'active' : '' }}">
                <img src="{{ asset('assets/img/FR.png') }}" alt="FR" class="flag-icon-small"> FR (Français)
            </a>
        </li>
        <li>
            <a href="{{ route('set-locale', 'ar') }}" class="{{ app()->getLocale() == 'ar' ? 'active' : '' }}">
                <img src="{{ asset('assets/img/AR.jpg') }}" alt="AR" class="flag-icon-small"> AR (العربية)
            </a>
        </li>
        <li>
            <a href="{{ route('set-locale', 'en') }}" class="{{ app()->getLocale() == 'en' ? 'active' : '' }}">
                <img src="{{ asset('assets/img/ENG.png') }}" alt="EN" class="flag-icon-small"> EN (English)
            </a>
        </li>
    </ul>
</div>

<style>
    .lang-switcher {
        position: relative;
        display: inline-block;
        margin-right: 15px;
    }

    .lang-btn {
        background: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        color: white;
        padding: 6px 12px;
        border-radius: 4px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
        font-family: 'Inter', sans-serif;
        font-size: 14px;
        transition: background 0.3s;
    }

    .lang-btn:hover {
        background: rgba(255, 255, 255, 0.2);
    }

    .flag-icon {
        width: 20px;
        height: 14px;
        object-fit: cover;
        border-radius: 2px;
        display: block;
    }

    .flag-icon-small {
        width: 16px;
        height: 11px;
        object-fit: cover;
        border-radius: 1px;
        margin-right: 8px;
        vertical-align: middle;
    }

    [dir="rtl"] .flag-icon-small {
        margin-right: 0;
        margin-left: 8px;
    }

    .lang-dropdown {
        position: absolute;
        top: 100%;
        left: 0;
        background: #1a1a1a;
        border: 1px solid #333;
        border-radius: 4px;
        padding: 8px 0;
        list-style: none;
        margin: 5px 0 0 0;
        min-width: 120px;
        display: none;
        z-index: 1000;
        box-shadow: 0 4px 12px rgba(0,0,0,0.5);
    }

    .lang-dropdown.show {
        display: block;
    }

    .lang-dropdown li a {
        display: block;
        padding: 8px 16px;
        color: #ccc;
        text-decoration: none;
        font-size: 13px;
        transition: background 0.2s, color 0.2s;
    }

    .lang-dropdown li a:hover, .lang-dropdown li a.active {
        background: #006039;
        color: white;
    }

    /* RTL Support for dropdown */
    [dir="rtl"] .lang-switcher {
        margin-right: 0;
        margin-left: 15px;
    }
    
    [dir="rtl"] .lang-dropdown {
        left: auto;
        right: 0;
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const langBtn = document.getElementById('langBtn');
        const langDropdown = document.getElementById('langDropdown');

        if (langBtn && langDropdown) {
            langBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                langDropdown.classList.toggle('show');
                const expanded = langBtn.getAttribute('aria-expanded') === 'true';
                langBtn.setAttribute('aria-expanded', !expanded);
            });

            document.addEventListener('click', function() {
                langDropdown.classList.remove('show');
                langBtn.setAttribute('aria-expanded', 'false');
            });
        }
    });
</script>
