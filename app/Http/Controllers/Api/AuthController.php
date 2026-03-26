<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use App\Mail\VerificationCodeMail;

class AuthController extends Controller
{
    use ApiResponse;

    /**
     * Register a new user, generate verification code, and send email.
     */
    public function register(Request $request)
    {
        // Adjust for Android requests if they pass different date format
        if ($request->has('date_of_birth')) {
            $date = $request->input('date_of_birth');
            if (preg_match('/^(\d{2})\/(\d{2})\/(\d{4})$/', $date, $matches)) {
                $request->merge(['date_of_birth' => "{$matches[3]}-{$matches[2]}-{$matches[1]}"]);
            }
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'height' => 'required|numeric',
            'weight' => 'required|numeric',
            'date_of_birth' => 'required|date',
            'gender' => 'required|string',
            'ideal_weight' => 'required|numeric',
            'goal' => 'required|string',
            'activity_level' => 'required|string',
            'offer' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Erreur de validation', 422, $validator->errors());
        }

        $verificationCode = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);

        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'height' => $request->height,
                'weight' => $request->weight,
                'date_of_birth' => $request->date_of_birth,
                'gender' => $request->gender,
                'ideal_weight' => $request->ideal_weight,
                'goal' => $request->goal,
                'activity_level' => $request->activity_level,
                'offer' => $request->offer,
                'verification_code' => $verificationCode,
                'is_approved' => false,
            ]);

            // Send real email
            Mail::to($user->email)->send(new VerificationCodeMail($verificationCode));

            return $this->successResponse(
                ['email' => $user->email], 
                'Utilisateur inscrit avec succès. Veuillez vérifier votre adresse e-mail avec le code envoyé.',
                201
            );
        } catch (\Exception $e) {
             return $this->errorResponse('Une erreur est survenue lors de l\'inscription.', 500, ['error' => $e->getMessage()]);
        }
    }

    /**
     * Verify the email with the 6-digit code.
     */
    public function verifyEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'code' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Erreur de validation', 422, $validator->errors());
        }

        $user = User::where('email', $request->email)->where('verification_code', $request->code)->first();

        if (!$user) {
            return $this->errorResponse('Code de vérification invalide ou utilisateur introuvable.', 400);
        }

        $user->verification_code = null;
        $user->save();

        return $this->successResponse(
            null,
            'Email vérifié avec succès. Votre compte est maintenant en attente d\'approbation par l\'administrateur.'
        );
    }

    /**
     * Authenticate a user and generate a Sanctum token.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Erreur de validation', 422, $validator->errors());
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->errorResponse('Les identifiants ne correspondent pas.', 401);
        }

        if ($user->verification_code !== null) {
            return $this->errorResponse('Veuillez vérifier votre adresse e-mail avant de vous connecter.', 403);
        }

        if ($user->is_approved != true) {
            return $this->errorResponse('Votre compte est toujours en attente d\'approbation par l\'administrateur.', 403);
        }

        $token = $user->createToken('android_app')->plainTextToken;

        return $this->successResponse([
            'user' => $user,
            'token' => $token
        ], 'Connexion réussie');
    }

    /**
     * Revoke the current user's token.
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Déconnecté avec succès');
    }
}
