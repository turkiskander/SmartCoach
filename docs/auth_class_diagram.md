# Diagramme de Classes FINAL — Authentification & Gestion des Comptes
## SmartCoach (Admin · Utilisateur · Visiteur · API)

```mermaid
classDiagram
    direction TB

    %% ──────────────────────────────────────────
    %% CLASSES DE BASE
    %% ──────────────────────────────────────────

    class Authenticatable {
        <<abstract>>
    }

    class Controller {
        <<abstract>>
    }

    %% ──────────────────────────────────────────
    %% MODÈLES
    %% ──────────────────────────────────────────

    class User {
        +casts() array
    }

    class Admin {
        +casts() array
    }

    %% ──────────────────────────────────────────
    %% CONTROLLERS WEB
    %% ──────────────────────────────────────────

    class RegisterController {
        +showRegistrationForm()
        +register(Request $request)
        +showVerificationForm()
        +verify(Request $request)
        +pendingApproval()
        +checkStatus(Request $request)
    }

    class LoginController {
        +showLoginForm()
        +login(Request $request)
        +logout(Request $request)
    }

    class AdminAuthController {
        +showLoginForm()
        +login(Request $request)
        +logout(Request $request)
    }

    class AdminController {
        +index()
        +approve($id)
        +refuse($id)
    }

    %% ──────────────────────────────────────────
    %% CONTROLLER API & TRAITS
    %% ──────────────────────────────────────────

    class ApiAuthController {
        +register(Request $request)
        +verifyEmail(Request $request)
        +login(Request $request)
        +logout(Request $request)
    }

    class ApiResponse {
        <<trait>>
        +successResponse()
        +errorResponse()
    }

    %% ──────────────────────────────────────────
    %% MIDDLEWARE & MAIL
    %% ──────────────────────────────────────────

    class EnsureTokenIsPresent {
        +handle(Request $request, Closure $next) Response
    }

    class IsAdmin {
        +handle(Request $request, Closure $next) Response
    }

    class VerificationCodeMail {
        +envelope() Envelope
        +content() Content
        +attachments() array
    }

    class AccountApprovedMail {
        +envelope() Envelope
        +content() Content
        +attachments() array
    }

    %% ──────────────────────────────────────────
    %% RELATIONS FINALES
    %% ──────────────────────────────────────────

    %% Héritage (Inheritance)
    RegisterController  --|> Controller
    LoginController     --|> Controller
    AdminAuthController --|> Controller
    AdminController     --|> Controller
    ApiAuthController   --|> Controller
    User                --|> Authenticatable
    Admin               --|> Authenticatable

    %% Association (Association -->)
    RegisterController  --> User : crée / trouve
    LoginController     --> User : authentifie
    ApiAuthController   --> User : crée / authentifie
    EnsureTokenIsPresent --> LoginController : redirige si non auth
    IsAdmin             --> AdminAuthController : redirige si non admin
    ApiAuthController   --> ApiResponse : <<trait>> utilise

    %% Composition (Composition *--)
    RegisterController  *-- VerificationCodeMail : envoie
    ApiAuthController   *-- VerificationCodeMail : envoie
    AdminController     *-- AccountApprovedMail  : envoie

    %% Agrégation (Aggregation o--)
    AdminController     o-- User : approuve / refuse
    AccountApprovedMail o-- User : reçoit
```

---

### Liste complète des classes utilisées

| Type | Classe(s) |
|---|---|
| **Structure** | `Authenticatable`, `Controller` |
| **Données (Modèles)** | `User`, `Admin` |
| **Logique (Web)** | `RegisterController`, `LoginController`, `AdminAuthController`, `AdminController` |
| **Logique (API)** | `ApiAuthController`, `ApiResponse` |
| **Sécurité (Middleware)** | `EnsureTokenIsPresent`, `IsAdmin` |
| **Communication (Mail)** | `VerificationCodeMail`, `AccountApprovedMail` |
