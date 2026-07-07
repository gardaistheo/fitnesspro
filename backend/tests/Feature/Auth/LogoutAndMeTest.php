<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('returns the authenticated user via me endpoint', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user, 'sanctum')
        ->getJson('/api/auth/me');

    $response->assertStatus(200)
        ->assertJsonPath('data.id', $user->id)
        ->assertJsonPath('data.email', $user->email);
});

it('rejects me endpoint without a valid token', function () {
    $response = $this->getJson('/api/auth/me');

    $response->assertStatus(401);
});

it('logs out the authenticated user and revokes the token', function () {
    $user = User::factory()->create();
    $token = $user->createToken('test-device')->plainTextToken;

    $response = $this->withHeader('Authorization', "Bearer {$token}")
        ->postJson('/api/auth/logout');

    $response->assertStatus(200)
        ->assertJson(['status' => 'success']);

    $this->assertDatabaseCount('personal_access_tokens', 0);
});

it('rejects requests with an invalid token', function () {
    $response = $this->withHeader('Authorization', 'Bearer invalid-token-value')
        ->getJson('/api/auth/me');

    $response->assertStatus(401);
});
