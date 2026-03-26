<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

use Illuminate\Support\Facades\Mail;
use App\Mail\VerificationCodeMail;

class RegisterController extends Controller
{
    public function showRegistrationForm()
    {
        if (Auth::check() || session()->has('api_token')) {
            return redirect()->to('/dashboard');
        }
        return view('auth.register');
    }

    public function register(Request $request)
    {
        // Convert French date format (JJ/MM/AAAA) to standard format (AAAA-MM-JJ)
        if ($request->has('date_of_birth')) {
            $date = $request->input('date_of_birth');
            if (preg_match('/^(\d{2})\/(\d{2})\/(\d{4})$/', $date, $matches)) {
                $request->merge(['date_of_birth' => "{$matches[3]}-{$matches[2]}-{$matches[1]}"]);
            }
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'height' => 'required|numeric',
            'weight' => 'required|numeric',
            'date_of_birth' => 'required|date',
            'gender' => 'required|string',
            'ideal_weight' => 'required|numeric',
            'goal' => 'required|string',
            'activity_level' => 'required|string',
            'offer' => 'required|string',
        ]);

        $verificationCode = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);

        try {
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'height' => $validated['height'],
                'weight' => $validated['weight'],
                'date_of_birth' => $validated['date_of_birth'],
                'gender' => $validated['gender'],
                'ideal_weight' => $validated['ideal_weight'],
                'goal' => $validated['goal'],
                'activity_level' => $validated['activity_level'],
                'offer' => $validated['offer'],
                'verification_code' => $verificationCode,
                'is_approved' => false,
            ]);

            Log::info("User created: " . $user->email . " with code: " . $verificationCode);

            // Send real email
            Mail::to($user->email)->send(new VerificationCodeMail($verificationCode));
            Log::info("Email sent to: " . $user->email);

            // Store email in session to identify user during verification
            session(['verify_email' => $user->email]);

            return redirect()->route('verify');
        } catch (\Exception $e) {
            Log::error("Registration error: " . $e->getMessage());
            return back()->withErrors(['error' => 'Une erreur est survenue lors de l\'inscription. Veuillez réessayer.'])->withInput();
        }
    }

    public function showVerificationForm()
    {
        if (Auth::check() || session()->has('api_token')) {
            return redirect()->to('/dashboard');
        }
        if (!session('verify_email')) {
            return redirect()->route('register');
        }
        return view('auth.verify');
    }

    public function verify(Request $request)
    {
        $request->validate([
            'code' => 'required|string|size:6',
        ]);

        $email = session('verify_email');
        $user = User::where('email', $email)->where('verification_code', $request->code)->first();

        if (!$user) {
            return back()->withErrors(['code' => 'Code de vérification invalide.']);
        }

        $user->verification_code = null;
        $user->save();

        session()->forget('verify_email');
        session(['pending_user_id' => $user->id]);

        return redirect()->route('pending-approval');
    }

    public function pendingApproval()
    {
        if (Auth::check() || session()->has('api_token')) {
            return redirect()->to('/dashboard');
        }
        return view('auth.approval');
    }

    public function checkStatus(Request $request)
    {
        $userId = session('pending_user_id');
        
        if (!$userId) {
            return response()->json(['error' => 'No pending user found'], 404);
        }

        $user = User::find($userId);
        
        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        return response()->json([
            'is_approved' => (bool) $user->is_approved,
            'user' => [
                'name' => $user->name,
                'gender' => $user->gender,
                'goal' => str_replace('_', ' ', $user->goal),
            ]
        ]);
    }
}
