<?php

use App\Models\Program;
use App\Models\User;
use App\Models\WorkoutSession;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->otherUser = User::factory()->create();
});

it('lists only the authenticated users workout sessions', function () {
    WorkoutSession::factory()->count(2)->create(['user_id' => $this->user->id]);
    WorkoutSession::factory()->count(3)->create(['user_id' => $this->otherUser->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/workout-sessions');

    $response->assertStatus(200)
        ->assertJsonCount(2, 'data.data');
});

it('creates a workout session for the authenticated user', function () {
    $program = Program::factory()->create();

    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/workout-sessions', [
            'program_id' => $program->id,
            'scheduled_date' => now()->addDay()->toDateString(),
            'scheduled_time' => '10:00',
        ]);

    $response->assertStatus(201)
        ->assertJsonPath('data.program_id', $program->id);

    $this->assertDatabaseHas('workout_sessions', [
        'user_id' => $this->user->id,
        'program_id' => $program->id,
    ]);
});

it('rejects creating a workout session with a past date', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/workout-sessions', [
            'scheduled_date' => now()->subDay()->toDateString(),
        ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors('scheduled_date');
});

it('shows a workout session owned by the user', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->user->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/workout-sessions/{$session->id}");

    $response->assertStatus(200)
        ->assertJsonPath('data.id', $session->id);
});

it('forbids viewing another users workout session', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->otherUser->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/workout-sessions/{$session->id}");

    $response->assertStatus(403);
});

it('updates the users own workout session', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->user->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->putJson("/api/workout-sessions/{$session->id}", [
            'status' => 'completed',
        ]);

    $response->assertStatus(200)
        ->assertJsonPath('data.status', 'completed')
        ->assertJsonPath('data.completed_at', fn ($value) => ! is_null($value));
});

it('forbids updating another users workout session', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->otherUser->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->putJson("/api/workout-sessions/{$session->id}", [
            'status' => 'completed',
        ]);

    $response->assertStatus(403);
});

it('deletes the users own workout session', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->user->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->deleteJson("/api/workout-sessions/{$session->id}");

    $response->assertStatus(200);
    $this->assertDatabaseMissing('workout_sessions', ['id' => $session->id]);
});

it('forbids deleting another users workout session', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->otherUser->id]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->deleteJson("/api/workout-sessions/{$session->id}");

    $response->assertStatus(403);
    $this->assertDatabaseHas('workout_sessions', ['id' => $session->id]);
});

it('rejects workout session listing without authentication', function () {
    $response = $this->getJson('/api/workout-sessions');

    $response->assertStatus(401);
});
