<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background-color: #0f172a;
            color: #ffffff;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #1e293b;
            border-radius: 16px;
            padding: 40px;
            text-align: center;
            border: 1px solid #FFB800;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #FFB800;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .title {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .code {
            font-size: 48px;
            font-weight: bold;
            color: #FFB800;
            letter-spacing: 8px;
            margin: 30px 0;
            padding: 20px;
            background: rgba(255, 184, 0, 0.1);
            border-radius: 12px;
            display: inline-block;
        }
        .footer {
            margin-top: 40px;
            font-size: 14px;
            color: #94a3b8;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">SmartCoach</div>
        <h1 class="title">Vérifiez votre email</h1>
        <p>Merci de vous être inscrit sur SmartCoach ! Utilisez le code ci-dessous pour valider votre compte.</p>
        <div class="code">{{ $code }}</div>
        <p>Ce code expirera bientôt. Ne le partagez avec personne.</p>
        <div class="footer">
            &copy; {{ date('Y') }} SmartCoach. Tous droits réservés.
        </div>
    </div>
</body>
</html>
