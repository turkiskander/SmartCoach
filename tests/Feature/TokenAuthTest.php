<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class TokenAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_home_page_is_accessible_to_guests(): void
    {
        $response = $this->get('/');
        $response->assertStatus(200);
        $response->assertViewIs('welcome');
    }

    public function test_home_page_redirects_authenticated_users(): void
    {
        $user = \App\Models\User::factory()->create();
        $response = $this->actingAs($user)
                         ->withSession(['api_token' => 'fake-token'])
                         ->get('/');
        $response->assertRedirect('/dashboard');
    }

    public function test_dashboard_requires_token(): void
    {
        $response = $this->get('/dashboard');
        $response->assertRedirect('/login');
        $response->assertSessionHasErrors(['auth_error']);
    }

    public function test_login_issues_token_and_grants_access(): void
    {
        $user = \App\Models\User::factory()->create([
            'password' => bcrypt('password'),
            'is_approved' => true,
        ]);

        $response = $this->post('/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $response->assertRedirect('/dashboard');
        $this->assertTrue(session()->has('api_token'));
        
        // Follow redirect and ensure access to dashboard
        $response = $this->get('/dashboard');
        $response->assertStatus(200);
    }

    public function test_authenticated_user_is_redirected_from_login(): void
    {
        $user = \App\Models\User::factory()->create();
        
        // Simulate login by setting session and acting as user
        $response = $this->actingAs($user)
                         ->withSession(['api_token' => 'fake-token'])
                         ->get('/login');

        $response->assertRedirect('/dashboard');
    }
}
