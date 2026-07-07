<?php

use App\Models\Exercise;
use App\Models\Program;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->admin = User::factory()->admin()->create();
    $this->user = User::factory()->create();
});

it('lists programs for an authenticated user', function () {
    Program::factory()->count(2)->create();

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/programs');

    $response->assertStatus(200)
        ->assertJsonCount(2, 'data.data');
});

it('shows a single program with its exercises', function () {
    $program = Program::factory()->create();
    $exercise = Exercise::factory()->create();
    $program->programExercises()->create([
        'exercise_id' => $exercise->id,
        'sets' => 3,
        'reps' => 10,
        'order' => 0,
    ]);

    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/programs/{$program->id}");

    $response->assertStatus(200)
        ->assertJsonPath('data.id', $program->id)
        ->assertJsonCount(1, 'data.exercises');
});

it('allows an admin to create a program', function () {
    $exercise = Exercise::factory()->create();

    $response = $this->actingAs($this->admin, 'sanctum')
        ->postJson('/api/programs', [
            'name' => 'Full Body Blast',
            'muscles' => ['legs', 'chest'],
            'difficulty' => 'intermediate',
            'duration' => 45,
            'description' => 'A full body workout',
            'exercises' => [
                ['exercise_id' => $exercise->id, 'sets' => 3, 'reps' => 12, 'order' => 0],
            ],
        ]);

    $response->assertStatus(201)
        ->assertJsonPath('data.name', 'Full Body Blast')
        ->assertJsonCount(1, 'data.exercises');

    $this->assertDatabaseHas('programs', ['name' => 'Full Body Blast']);
});

it('forbids a non-admin user from creating a program', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/programs', [
            'name' => 'Full Body Blast',
            'difficulty' => 'intermediate',
        ]);

    $response->assertStatus(403);
});

it('validates required fields when creating a program', function () {
    $response = $this->actingAs($this->admin, 'sanctum')
        ->postJson('/api/programs', []);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['name', 'difficulty']);
});

it('allows an admin to update a program', function () {
    $program = Program::factory()->create(['name' => 'Old Name']);

    $response = $this->actingAs($this->admin, 'sanctum')
        ->putJson("/api/programs/{$program->id}", [
            'name' => 'New Name',
        ]);

    $response->assertStatus(200)
        ->assertJsonPath('data.name', 'New Name');
});

it('forbids a non-admin user from updating a program', function () {
    $program = Program::factory()->create();

    $response = $this->actingAs($this->user, 'sanctum')
        ->putJson("/api/programs/{$program->id}", [
            'name' => 'Hacked Name',
        ]);

    $response->assertStatus(403);
});

it('allows an admin to delete a program', function () {
    $program = Program::factory()->create();

    $response = $this->actingAs($this->admin, 'sanctum')
        ->deleteJson("/api/programs/{$program->id}");

    $response->assertStatus(200);
    $this->assertDatabaseMissing('programs', ['id' => $program->id]);
});

it('forbids a non-admin user from deleting a program', function () {
    $program = Program::factory()->create();

    $response = $this->actingAs($this->user, 'sanctum')
        ->deleteJson("/api/programs/{$program->id}");

    $response->assertStatus(403);
    $this->assertDatabaseHas('programs', ['id' => $program->id]);
});

it('rejects program listing without authentication', function () {
    $response = $this->getJson('/api/programs');

    $response->assertStatus(401);
});
