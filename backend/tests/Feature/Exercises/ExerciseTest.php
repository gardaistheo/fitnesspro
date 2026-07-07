<?php

use App\Models\Exercise;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
});

it('lists exercises for an authenticated user', function () {
    Exercise::factory()->count(3)->create();

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/exercises');

    $response->assertStatus(200)
        ->assertJsonCount(3, 'data.data');
});

it('rejects listing exercises without authentication', function () {
    $response = $this->getJson('/api/exercises');

    $response->assertStatus(401);
});

it('filters exercises by category', function () {
    Exercise::factory()->create(['category' => 'cardio']);
    Exercise::factory()->create(['category' => 'strength']);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/exercises?category=cardio');

    $response->assertStatus(200)
        ->assertJsonCount(1, 'data.data')
        ->assertJsonPath('data.data.0.category', 'cardio');
});

it('filters exercises by difficulty', function () {
    Exercise::factory()->create(['difficulty' => 'beginner']);
    Exercise::factory()->create(['difficulty' => 'advanced']);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/exercises?difficulty=advanced');

    $response->assertStatus(200)
        ->assertJsonCount(1, 'data.data')
        ->assertJsonPath('data.data.0.difficulty', 'advanced');
});

it('shows a single exercise', function () {
    $exercise = Exercise::factory()->create();

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/exercises/{$exercise->id}");

    $response->assertStatus(200)
        ->assertJsonPath('data.id', $exercise->id);
});

it('returns 404 for a non-existent exercise', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/exercises/999999');

    $response->assertStatus(404);
});
