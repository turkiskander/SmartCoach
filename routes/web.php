<?php

use App\Http\Controllers\Auth\LoginController;

Route::get('/set-locale/{locale}', function ($locale) {
    if (in_array($locale, ['fr', 'en', 'ar'])) {
        session(['locale' => $locale]);
    }
    return redirect()->back();
})->name('set-locale');


Route::get('/', function () {
    if (Auth::check() || session()->has('api_token')) {
        return redirect()->to('/dashboard');
    }
    return view('welcome');
})->name('home');

use App\Http\Controllers\UserController;
Route::get('/dashboard', [UserController::class, 'index'])->middleware('token.auth')->name('dashboard');

Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login'])->name('login.post');
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

// Mobile Modules Integration
use App\Http\Controllers\ModuleController;
Route::middleware('token.auth')->group(function () {
    Route::get('/modules', [ModuleController::class, 'index'])->name('modules.index');
    Route::get('/modules/{module}', [ModuleController::class, 'show'])->name('modules.show');
});

// Registration Routes
use App\Http\Controllers\Auth\RegisterController;
Route::get('/register', [RegisterController::class, 'showRegistrationForm'])->name('register');
Route::post('/register', [RegisterController::class, 'register'])->name('register.post');
Route::get('/verify', [RegisterController::class, 'showVerificationForm'])->name('verify');
Route::post('/verify', [RegisterController::class, 'verify'])->name('verify.post');
Route::get('/pending-approval', [RegisterController::class, 'pendingApproval'])->name('pending-approval');
Route::get('/check-approval-status', [RegisterController::class, 'checkStatus'])->name('check-approval-status');


// Admin Routes
use App\Http\Controllers\AdminController;
use App\Http\Controllers\Admin\AuthController as AdminAuthController;

Route::prefix('admin')->name('admin.')->group(function () {
    // Admin Authentication Routes
    Route::get('/login', [AdminAuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.post');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');

    // Protected Admin Dashboard & Operations
    Route::middleware(['admin'])->group(function () {
        Route::get('/approvals', [AdminController::class, 'index'])->name('approvals');
        Route::post('/approve/{id}', [AdminController::class, 'approve'])->name('approve');
        Route::post('/refuse/{id}', [AdminController::class, 'refuse'])->name('refuse');
    });
});


// Profile Routes
use App\Http\Controllers\ProfileController;
Route::post('/profile/avatar', [ProfileController::class, 'updateAvatar'])->middleware('token.auth')->name('profile.avatar.update');
