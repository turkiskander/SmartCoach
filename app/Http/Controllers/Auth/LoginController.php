<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class LoginController extends Controller
{
    public function showLoginForm()
    {
        if (Auth::check() || session()->has('api_token')) {
            return redirect()->to('/dashboard');
        }
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials, $request->filled('remember'))) {
            $user = Auth::user();
            
            // Check if the user is approved by the admin
            if ($user->is_approved != true) {
                Auth::logout();
                return back()->withErrors([
                    'email' => 'Votre compte est en attente d\'approbation par l\'administrateur.',
                ])->onlyInput('email');
            }

            // Generate token for the user
            $token = $user->createToken('auth_token')->plainTextToken;
            
            // Store token in session for web requests (custom middleware will check it)
            session(['api_token' => $token]);

            $request->session()->regenerate();
            return redirect()->to('/dashboard');
        }

        return back()->withErrors([
            'email' => 'Les identifiants ne correspondent pas à nos enregistrements.',
        ])->onlyInput('email');
    }

    public function logout(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            // Revoke all user tokens
            $user->tokens()->delete();
        }

        Auth::logout();
        $request->session()->forget('api_token');
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }
}
