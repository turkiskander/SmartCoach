<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function updateAvatar(Request $request)
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $user = Auth::user();

        if (!$user && session()->has('api_token')) {
            // Fallback for custom token session
            $user = \App\Models\User::whereHas('tokens', function($q) {
                $q->where('token', hash('sha256', explode('|', session('api_token'))[1] ?? ''));
            })->first();
        }

        if (!$user) {
            return redirect()->route('login')->withErrors(['error' => 'Utilisateur non trouvé.']);
        }

        if ($request->hasFile('avatar')) {
            // Delete old avatar if exists
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = $path;
            $user->save();

            return back()->with('success', __('Photo de profil mise à jour !'));
        }

        return back()->with('error', __('Une erreur est survenue.'));
    }
}
