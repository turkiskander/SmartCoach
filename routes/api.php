<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;



// Public routes for Android app
Route::post('/register', [AuthController::class, 'register']);
Route::post('/verify-email', [AuthController::class, 'verifyEmail']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (requires Sanctum token)
Route::middleware('auth:sanctum')->group(function () {
    // User Context
    Route::get('/user', [UserController::class, 'getProfile']);
    Route::put('/user', [UserController::class, 'updateProfile']);
    
    // Auth actions
    Route::post('/logout', [AuthController::class, 'logout']);
});
