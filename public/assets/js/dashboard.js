(() => {
    'use strict';
    const $ = (sel, root = document) => root.querySelector(sel);
    const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

    function bindSectionNavigation() {
        const navItems = $$('[data-section]');
        const sections = $$('.dashboard-section-content');

        const showSection = (targetSection) => {
            const item = navItems.find(i => i.getAttribute('data-section') === targetSection);
            if (!item) return;

            navItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');

            sections.forEach(s => {
                s.style.display = 'none';
                s.classList.remove('is-active');
            });

            const activePanel = document.getElementById(`section-${targetSection}`);
            if (activePanel) {
                activePanel.style.display = 'block';
                activePanel.classList.add('is-active');
            }
        };

        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                const targetSection = item.getAttribute('data-section');
                if (!targetSection) return;

                const href = item.getAttribute('href');
                const isRealPage = href && !href.includes('?section=') && !href.startsWith('#') && !href.includes(window.location.pathname + '?');

                // Add active class immediately for visual feedback
                navItems.forEach(i => i.classList.remove('active'));
                item.classList.add('active');

                // If on same dashboard page and it's a section link, handle via JS
                if (window.location.pathname.endsWith('/dashboard') && !isRealPage) {
                    e.preventDefault();
                    showSection(targetSection);
                    // Update URL without reload
                    const newUrl = window.location.pathname + '?section=' + targetSection;
                    window.history.pushState({ section: targetSection }, '', newUrl);
                }
            });
        });

        // Handle initial section from URL
        const urlParams = new URLSearchParams(window.location.search);
        const sectionParam = urlParams.get('section');
        if (sectionParam) {
            showSection(sectionParam);
        } else if (window.location.pathname.includes('/dashboard')) {
            // Only force default section on the main dashboard page
            // and ONLY if there are sections to switch
            if ($$('[id^="section-"]').length > 0) {
                showSection('dashboard');
            }
        }

        // Handle back/forward buttons
        window.addEventListener('popstate', (e) => {
            if (e.state && e.state.section) {
                showSection(e.state.section);
            }
        });
    }

    window.SmartCoachDashboard = { 
        init: () => { 
            bindSectionNavigation(); 
            if (window.lucide) {
                window.lucide.createIcons();
            } 
        } 
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => window.SmartCoachDashboard.init());
    else window.SmartCoachDashboard.init();
})();
