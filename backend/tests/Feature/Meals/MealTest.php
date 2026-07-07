<?php

use App\Models\Meal;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->otherUser = User::factory()->create();
});

it('logs a meal for the authenticated user', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/meals', [
            'name' => 'Chicken and rice',
            'calories' => 650,
            'proteins' => 45,
            'carbs' => 70,
            'fats' => 15,
        ]);

    $response->assertStatus(201)
        ->assertJsonPath('data.name', 'Chicken and rice')
        ->assertJsonPath('data.calories', 650);

    $this->assertDatabaseHas('meals', [
        'user_id' => $this->user->id,
        'name' => 'Chicken and rice',
    ]);
});

it('defaults macros to zero when not provided', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/meals', [
            'name' => 'Apple',
            'calories' => 95,
        ]);

    $response->assertStatus(201)
        ->assertJsonPath('data.proteins', 0)
        ->assertJsonPath('data.carbs', 0)
        ->assertJsonPath('data.fats', 0);
});

it('validates required fields when logging a meal', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/meals', []);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['name', 'calories']);
});

it('rejects logging a meal without authentication', function () {
    $response = $this->postJson('/api/meals', [
        'name' => 'Apple',
        'calories' => 95,
    ]);

    $response->assertStatus(401);
});

it('lists only the authenticated users meals', function () {
    Meal::factory()->count(2)->create(['user_id' => $this->user->id]);
    Meal::factory()->count(3)->create(['user_id' => $this->otherUser->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/meals');

    $response->assertStatus(200)
        ->assertJsonCount(2, 'data.data');
});

it('filters meals by date range', function () {
    Meal::factory()->create([
        'user_id' => $this->user->id,
        'logged_at' => now()->subDays(10),
    ]);
    Meal::factory()->create([
        'user_id' => $this->user->id,
        'logged_at' => now(),
    ]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/meals?from='.now()->subDay()->toDateString());

    $response->assertStatus(200)
        ->assertJsonCount(1, 'data.data');
});

it('rejects listing meals without authentication', function () {
    $response = $this->getJson('/api/meals');

    $response->assertStatus(401);
});
