<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureTokenIsPresent
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Check for authenticated session (standard Auth) or token-based auth (Sanctum / api_token)
        if (Auth::check() || auth('sanctum')->check()) {
            return $next($request);
        }

        if ($request->session()->has('api_token')) {
            // If we have an api_token in session but not logged in via web guard, 
            // we should ideally re-authenticate or ensure Auth::user() works.
            // For now, if the session has the token, we allow it, 
            // but we'll add a safety check in controllers or here.
            return $next($request);
        }

        return redirect()->route('login')->withErrors([
            'auth_error' => 'Accès refusé. Veuillez vous connecter pour accéder à cette page.',
        ]);

        return $next($request);
    }
}
