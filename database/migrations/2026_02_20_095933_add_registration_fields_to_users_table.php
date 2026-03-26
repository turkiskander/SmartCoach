<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->decimal('height', 5, 2)->nullable();
            $table->decimal('weight', 5, 2)->nullable();
            $table->date('date_of_birth')->nullable();
            $table->string('gender')->nullable();
            $table->decimal('ideal_weight', 5, 2)->nullable();
            $table->string('goal')->nullable();
            $table->string('activity_level')->nullable();
            $table->string('offer')->nullable();
            $table->string('verification_code', 6)->nullable();
            $table->boolean('is_approved')->default(false);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'height',
                'weight',
                'date_of_birth',
                'gender',
                'ideal_weight',
                'goal',
                'activity_level',
                'offer',
                'verification_code',
                'is_approved'
            ]);
        });
    }
};
