<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Inter', sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e1e1e1; border-radius: 10px; }
        .header { text-align: center; margin-bottom: 30px; }
        .content { margin-bottom: 30px; }
        .button { background-color: #006039; color: white !important; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block; }
        .footer { font-size: 0.8rem; color: #777; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="color: #006039;">SmartCoach</h1>
        </div>
        <div class="content">
            <h2>Félicitations {{ $user->name }} !</h2>
            <p>Nous avons le plaisir de vous informer que votre compte SmartCoach a été <strong>approuvé par l'administrateur</strong>.</p>
            <p>Vous pouvez maintenant vous connecter à votre tableau de bord et commencer votre transformation physique.</p>
            <div style="text-align: center; margin: 30px 0;">
                <a href="{{ route('login') }}" class="button">Se connecter maintenant</a>
            </div>
            <p>À très vite sur SmartCoach !</p>
        </div>
        <div class="footer">
            <p>&copy; {{ date('Y') }} SmartCoach - Tous droits réservés.</p>
        </div>
    </div>
</body>
</html>
