(() => {
  'use strict';
  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  class FeedbackManager {
    constructor() {
      this.modal = $('#feedback-modal');
      this.openBtn = $('#open-feedback');
      this.closeBtn = $('#close-feedback');
      this.content = $('#feedback-content');
      this.progressBar = $('#feedback-progress-bar');

      this.currentIndex = 0;
      this.questions = [
        {
          id: 1,
          text: "Comment évaluez-vous l’apparence générale du site ?",
          type: "slider",
          min: 1,
          max: 5,
          labels: ["Très mauvaise", "Excellente"]
        },
        {
          id: 2,
          text: "Le design du site vous semble-t-il moderne et professionnel ?",
          type: "options",
          options: ["Pas du tout", "Un peu", "Moyen", "Oui", "Absolument"]
        },
        {
          id: 3,
          text: "Les couleurs représentent-elles bien une marque technologique et sportive ?",
          type: "options",
          options: ["Pas du tout", "Un peu", "Moyen", "Oui", "Absolument"]
        },
        {
          id: 4,
          text: "Est-il facile de comprendre le contenu du site ?",
          type: "options",
          options: ["Très difficile", "Difficile", "Moyen", "Facile", "Très facile"]
        },
        {
          id: 5,
          text: "Le bouton principal (Call To Action) est-il bien visible ?",
          type: "options",
          options: ["Pas du tout", "Un peu", "Moyen", "Oui", "Absolument"]
        },
        {
          id: 6,
          text: "Le site est-il confortable à consulter sur mobile ?",
          type: "options",
          options: ["Très mauvais", "Mauvais", "Moyen", "Bon", "Excellent"]
        }
      ];

      this.init();
    }

    init() {
      if (!this.openBtn) return;

      this.openBtn.addEventListener('click', () => this.open());
      this.closeBtn.addEventListener('click', () => this.close());

      // Close on outside click
      this.modal.addEventListener('click', (e) => {
        if (e.target === this.modal) this.close();
      });
    }

    open() {
      this.currentIndex = 0;
      this.modal.classList.add('is-visible');
      document.body.style.overflow = 'hidden';
      this.renderQuestion();
    }

    close() {
      this.modal.classList.remove('is-visible');
      document.body.style.overflow = '';
    }

    updateProgress() {
      const prog = ((this.currentIndex) / this.questions.length) * 100;
      this.progressBar.style.width = prog + '%';
    }

    renderQuestion() {
      this.updateProgress();

      if (this.currentIndex >= this.questions.length) {
        this.renderSuccess();
        return;
      }

      const q = this.questions[this.currentIndex];
      let html = `
        <div class="question-block" key="${this.currentIndex}">
          <h3 class="question-title">${q.text}</h3>
          <div class="answer-container">
      `;

      if (q.type === 'slider') {
        html += `
          <div class="slider-container">
            <div id="slider-value" class="slider-value-display">3</div>
            <input type="range" class="slider-input" min="${q.min}" max="${q.max}" value="3" id="q-slider">
            <div class="slider-labels">
              <span>${q.labels[0]}</span>
              <span>${q.labels[1]}</span>
            </div>
            <button class="btn btn--primary next-btn" id="next-q">Suivant</button>
          </div>
        `;
      } else {
        html += `<div class="answer-options">`;
        q.options.forEach(opt => {
          html += `<button class="option-btn">${opt}</button>`;
        });
        html += `</div>`;
      }

      html += `</div></div>`;
      this.content.innerHTML = html;

      // Bind events
      const slider = $('#q-slider', this.content);
      const valDisplay = $('#slider-value', this.content);
      if (slider && valDisplay) {
        slider.addEventListener('input', (e) => {
          valDisplay.textContent = e.target.value;
        });
      }

      const nextBtn = $('#next-q', this.content);
      if (nextBtn) {
        nextBtn.addEventListener('click', () => this.next());
      }

      const options = $$('.option-btn', this.content);
      options.forEach(opt => {
        opt.addEventListener('click', () => this.next());
      });
    }

    next() {
      this.currentIndex++;
      this.renderQuestion();
    }

    renderSuccess() {
      this.progressBar.style.width = '100%';
      this.content.innerHTML = `
        <div class="thank-you">
          <div class="thank-you-title">🎉</div>
          <h3 class="h3">Merci pour votre participation</h3>
          <p class="muted">Votre avis aide Smart Coach à évoluer intelligemment</p>
          <button class="btn btn--primary" style="margin-top: 20px;" id="finish-btn">Fermer</button>
        </div>
      `;
      $('#finish-btn').addEventListener('click', () => this.close());
    }
  }

  /* -----------------------
     Newsletter
     ----------------------- */
  function bindNewsletter() {
    const footerForm = document.querySelector('.footer-form');
    if (footerForm) {
      footerForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('footerEmail').value;
        alert(`Merci ! L'adresse ${email} a été ajoutée à la newsletter.`);
        footerForm.reset();
      });
    }
  }

  /* -----------------------
     Feature Detail Manager
     ----------------------- */
  class FeatureManager {
    constructor() {
      this.modal = $('#feature-modal');
      this.content = $('#feature-detail-content');
      this.closeBtn = $('#close-feature');
      this.cards = $$('.featureCard');

      this.features = [
        {
          title: "Suivi cardiaque avancé",
          icon: "❤️",
          description: `
            <p>Cette fonctionnalité mesure votre rythme cardiaque tout au long de la journée, que vous soyez au repos, en marche ou en entraînement. Elle vous aide à comprendre comment votre cœur réagit à l’effort et à la récupération.</p>
            <p>Vous pouvez voir des zones d’intensité (faible, moyenne, élevée) pour savoir si vous vous entraînez trop doucement ou trop fort. Après une séance, la montre indique si votre cœur revient rapidement à la normale, ce qui peut montrer une bonne forme ou, au contraire, un besoin de repos.</p>
            <p>Elle peut aussi envoyer des alertes si votre rythme est anormalement élevé ou bas lorsque vous ne faites aucun effort.</p>
            <p><strong>Objectif :</strong> vous guider pour mieux gérer l’intensité, éviter le surmenage et améliorer votre condition en sécurité.</p>
          `
        },
        {
          title: "SpO₂ (taux d’oxygène)",
          icon: "🩸",
          description: `
            <p>Le SpO₂ représente le taux d’oxygène dans le sang. Cette mesure est utile pour suivre votre respiration et votre forme générale. La montre peut effectuer des mesures ponctuelles ou sur certaines périodes (par exemple la nuit).</p>
            <p>Si votre SpO₂ baisse, cela peut indiquer une fatigue, un sommeil moins réparateur, ou une adaptation difficile à l’effort. Cette fonctionnalité vous aide surtout à repérer des tendances : est-ce stable ? Est-ce que ça chute après les entraînements ?</p>
            <p>Vous obtenez un affichage simple (valeur + statut) et parfois des conseils : mieux récupérer, respirer correctement, éviter un effort intense si votre corps semble déjà fatigué.</p>
            <p><strong>Objectif :</strong> mieux comprendre votre état respiratoire et prendre de meilleures décisions pour votre sport et votre récupération.</p>
          `
        },
        {
          title: "Suivi des activités sportives",
          icon: "🏃",
          description: `
            <p>Cette fonctionnalité enregistre vos entraînements : type d’activité, durée, distance (si applicable), calories estimées, rythme cardiaque pendant l’effort, et parfois cadence ou pas.</p>
            <p>Après chaque séance, vous recevez un résumé clair : ce que vous avez fait, l’intensité, et comment votre corps a réagi. Vous pouvez aussi suivre votre progression sur la semaine ou le mois : régularité, amélioration des performances, et évolution de la charge d’entraînement.</p>
            <p>Elle vous aide à rester motivé grâce aux objectifs (ex : nombre de séances par semaine, minutes d’activité, calories) et aux statistiques faciles à lire.</p>
            <p><strong>Objectif :</strong> garder un historique complet de votre sport et vous permettre de progresser de manière organisée, sans oublier vos séances.</p>
          `
        },
        {
          title: "GPS & déplacements",
          icon: "📍",
          description: `
            <p>Le GPS permet à la montre de tracer vos parcours lors des sorties (course, marche, vélo). Vous pouvez voir une carte du trajet et des données simples : distance, vitesse moyenne, temps total, parfois dénivelé.</p>
            <p>Cette fonctionnalité est utile pour analyser vos performances selon le parcours : est-ce que vous êtes plus rapide sur une route précise ? Est-ce que votre rythme baisse sur les montées ?</p>
            <p>Elle permet aussi d’avoir un suivi plus précis sans avoir besoin de votre téléphone, selon le modèle et les réglages.</p>
            <p>Pour la sécurité, elle peut aider à localiser une activité ou à enregistrer l’endroit d’une séance.</p>
            <p><strong>Objectif :</strong> mesurer vos sorties de manière fiable, comparer vos performances, et rendre votre entraînement extérieur plus précis et plus intelligent.</p>
          `
        },
        {
          title: "Analyse mentale intelligente",
          icon: "🧠",
          description: `
            <p>Cette fonctionnalité aide à estimer votre niveau de stress et votre fatigue mentale à partir de signaux comme le rythme cardiaque, la variabilité cardiaque (HRV) et l’activité quotidienne.</p>
            <p>Le résultat est présenté de façon simple : un état (calme, normal, stressé) et une tendance (ça s’améliore ou ça se dégrade). Elle peut vous proposer des actions faciles : respirations guidées, mini-pauses, sommeil plus tôt, ou entraînement plus léger si vous êtes trop tendu.</p>
            <p>Ce n’est pas un diagnostic médical : c’est un outil de guidance pour mieux gérer votre énergie mentale.</p>
            <p><strong>Objectif :</strong> vous aider à éviter l’épuisement, mieux planifier vos journées, et améliorer vos performances en gardant un bon équilibre entre effort, travail, repos et récupération.</p>
          `
        },
        {
          title: "Analyse physique avancée",
          icon: "🏋️",
          description: `
            <p>Cette fonctionnalité évalue votre état physique global : fatigue, récupération, et niveau de forme. Elle combine plusieurs données (activité, sommeil, rythme cardiaque, charge d’entraînement) pour produire des indicateurs simples.</p>
            <p>Par exemple, elle peut vous dire : “Aujourd’hui vous êtes prêt pour une séance intense” ou “Aujourd’hui, privilégiez la récupération”. Elle vous aide à éviter de vous entraîner trop fort quand votre corps n’est pas prêt.</p>
            <p>Vous pouvez suivre votre progression avec des tendances : amélioration de l’endurance, meilleure récupération, ou signes de surmenage si la fatigue augmente trop.</p>
            <p><strong>Objectif :</strong> adapter votre entraînement au bon moment, réduire les risques de blessure, et progresser plus vite en respectant votre corps.</p>
          `
        },
        {
          title: "Coaching sportif personnalisé (IA)",
          icon: "🤖",
          description: `
            <p>Le coaching IA crée un programme adapté à votre objectif : perdre du poids, améliorer l’endurance, gagner en force, préparer une compétition, ou simplement rester en forme.</p>
            <p>Vous répondez à quelques infos (niveau, temps disponible, objectif), puis la montre propose un plan clair : séances, jours, intensité, et temps de récupération.</p>
            <p>Le plus important : le plan s’ajuste automatiquement. Si vous avez raté une séance, si vous êtes fatigué, ou si vos performances progressent rapidement, le programme se modifie pour rester réaliste et efficace.</p>
            <p><strong>Objectif :</strong> vous guider comme un coach personnel, avec des recommandations simples, un suivi régulier, et des ajustements intelligents pour maintenir une progression continue sans vous épuiser.</p>
          `
        },
        {
          title: "Nutrition & hydratation",
          icon: "🥗",
          description: `
            <p>Cette fonctionnalité vous aide à mieux gérer votre alimentation et votre eau au quotidien. Elle peut proposer des rappels d’hydratation adaptés à votre activité et à votre chaleur corporelle (selon les données disponibles).</p>
            <p>Pour la nutrition, elle peut vous guider avec des conseils simples : équilibrer les repas, améliorer l’énergie avant une séance, récupérer après l’effort, ou éviter certaines erreurs (mauvais timing, manque d’eau).</p>
            <p>L’objectif n’est pas de compliquer : c’est de donner des petites actions faciles à suivre, avec un suivi clair (ex : “objectif eau atteint”, “bons choix aujourd’hui”).</p>
            <p><strong>Objectif :</strong> soutenir vos performances et votre santé grâce à de meilleures habitudes, sans régime strict, juste avec des recommandations pratiques et régulières.</p>
          `
        },
        {
          title: "Rapport médical intelligent",
          icon: "📋",
          description: `
            <p>Le rapport médical intelligent regroupe vos données de santé en une lecture simple : évolution du rythme cardiaque, sommeil, stress, SpO₂, activité, et récupération.</p>
            <p>Au lieu de vous laisser devant des chiffres, il produit une synthèse claire : ce qui est stable, ce qui s’améliore, et ce qui peut nécessiter plus de repos ou d’attention.</p>
            <p>Il peut aussi afficher des alertes simples (ex : “fatigue élevée plusieurs jours”, “sommeil en baisse”) pour vous pousser à corriger vos habitudes.</p>
            <p>Ce rapport n’est pas un diagnostic, mais un support utile pour comprendre votre corps. Il peut aider si vous souhaitez partager une tendance générale avec un coach ou un professionnel de santé.</p>
            <p><strong>Objectif :</strong> transformer vos données en décisions faciles pour améliorer votre santé et votre performance.</p>
          `
        }
      ];

      this.init();
    }

    init() {
      if (!this.modal || !this.content) return;

      this.cards.forEach(card => {
        card.style.cursor = 'pointer';
        card.addEventListener('click', () => {
          const index = card.getAttribute('data-feature');
          if (index !== null) {
            this.open(index);
          }
        });
      });

      if (this.closeBtn) {
        this.closeBtn.addEventListener('click', () => this.close());
      }

      this.modal.addEventListener('click', (e) => {
        if (e.target === this.modal) this.close();
      });

      window.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && !this.modal.hidden) this.close();
      });
    }

    open(index) {
      const feature = this.features[index];
      if (!feature) return;

      // Use translations if available
      let title = feature.title;
      let description = feature.description;
      let btnFermer = "Fermer";

      if (window.APP_TRANSLATIONS && window.APP_TRANSLATIONS.features && window.APP_TRANSLATIONS.features[index]) {
        title = window.APP_TRANSLATIONS.features[index].title || title;
        description = window.APP_TRANSLATIONS.features[index].desc || description;
      }
      if (window.APP_TRANSLATIONS && window.APP_TRANSLATIONS.btnFermer) {
        btnFermer = window.APP_TRANSLATIONS.btnFermer;
      }

      this.content.innerHTML = `
        <span class="feature-modal-icon">${feature.icon}</span>
        <h2 class="feature-modal-title">${title}</h2>
        <div class="feature-modal-body">
          ${description}
        </div>
        <div class="feature-modal-footer">
          <button class="btn btn--primary btn--lux" onclick="document.getElementById('close-feature').click()">
            ${btnFermer}
          </button>
        </div>
      `;

      this.modal.classList.add('is-visible');
      document.body.style.overflow = 'hidden';
    }

    close() {
      this.modal.classList.remove('is-visible');
      document.body.style.overflow = '';
    }
  }

  /* -----------------------
     Tabs switching logic
     ----------------------- */
  function bindTabs() {
    const btns = document.querySelectorAll('.tab-btn');
    const panes = document.querySelectorAll('.tab-pane');

    btns.forEach(btn => {
      btn.addEventListener('click', () => {
        const target = btn.getAttribute('data-tab');

        // Update buttons
        btns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        // Update panes
        panes.forEach(p => {
          p.classList.remove('active');
          if (p.id === target + '-zone') {
            p.classList.add('active');
          }
        });
      });
    });
  }

  window.SmartCoachQuiz = { init: () => { new FeedbackManager(); bindTabs(); bindNewsletter(); } };
})();