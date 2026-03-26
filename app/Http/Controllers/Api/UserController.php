<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    use ApiResponse;

    /**
     * Get the authenticated user's profile info.
     */
    public function getProfile(Request $request)
    {
        $user = $request->user();
        return $this->successResponse($user, 'User profile retrieved successfully');
    }

    /**
     * Update the authenticated user's profile info.
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'height' => 'nullable|numeric|min:0',
            'weight' => 'nullable|numeric|min:0',
            'date_of_birth' => 'nullable|date',
            'gender' => 'nullable|string|in:male,female,other',
            'ideal_weight' => 'nullable|numeric|min:0',
            'goal' => 'nullable|string',
            'activity_level' => 'nullable|string',
            // avatar handled separately usually, but can be added here
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation error', 422, $validator->errors());
        }

        $user->update($validator->validated());

        return $this->successResponse($user, 'User profile updated successfully');
    }
}
