<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('registers a new user successfully', function () {
    $response = $this->postJson('/api/auth/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
    ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'status',
            'message',
            'data' => [
                'user' => ['id', 'name', 'email'],
                'token',
            ],
            'errors',
        ]);

    $this->assertDatabaseHas('users', [
        'email' => 'john@example.com',
    ]);
});

it('fails registration with validation errors', function () {
    $response = $this->postJson('/api/auth/register', [
        'name' => '',
        'email' => 'not-an-email',
        'password' => 'short',
        'password_confirmation' => 'mismatch',
    ]);

    $response->assertStatus(422)
        ->assertJsonStructure([
            'status',
            'message',
            'data',
            'errors' => ['name', 'email', 'password'],
        ]);
});

it('fails registration when email already exists', function () {
    User::factory()->create(['email' => 'existing@example.com']);

    $response = $this->postJson('/api/auth/register', [
        'name' => 'Jane Doe',
        'email' => 'existing@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors('email');
});
