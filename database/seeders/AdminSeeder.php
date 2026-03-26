<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Admin;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Check if admin already exists
        if (!Admin::where('email', 'admin@smartcoach.tn')->exists()) {
            Admin::create([
                'name' => 'SmartCoach Admin',
                'email' => 'admin@smartcoach.tn',
                'password' => Hash::make('adminadmin'),
            ]);
        }
    }
}
