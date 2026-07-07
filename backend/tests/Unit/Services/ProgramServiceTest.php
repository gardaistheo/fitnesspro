<?php

use App\Models\Exercise;
use App\Models\Program;
use App\Services\ProgramService;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->service = new ProgramService;
});

it('creates a program with attached exercises in order', function () {
    $exerciseA = Exercise::factory()->create();
    $exerciseB = Exercise::factory()->create();

    $program = $this->service->create([
        'name' => 'Leg Day',
        'difficulty' => 'intermediate',
        'exercises' => [
            ['exercise_id' => $exerciseA->id, 'sets' => 3, 'reps' => 10],
            ['exercise_id' => $exerciseB->id, 'sets' => 4, 'reps' => 8],
        ],
    ]);

    expect($program->exercises)->toHaveCount(2)
        ->and($program->exercises->first()->id)->toBe($exerciseA->id)
        ->and($program->programExercises->first()->order)->toBe(0)
        ->and($program->programExercises->last()->order)->toBe(1);
});

it('defaults muscles to an empty array when not provided', function () {
    $program = $this->service->create([
        'name' => 'Bodyweight Basics',
        'difficulty' => 'beginner',
    ]);

    expect($program->muscles)->toBe([]);
});

it('replaces exercises entirely when updating with a new exercise list', function () {
    $exerciseA = Exercise::factory()->create();
    $exerciseB = Exercise::factory()->create();

    $program = $this->service->create([
        'name' => 'Push Day',
        'difficulty' => 'advanced',
        'exercises' => [
            ['exercise_id' => $exerciseA->id, 'sets' => 3, 'reps' => 10],
        ],
    ]);

    $updated = $this->service->update($program, [
        'exercises' => [
            ['exercise_id' => $exerciseB->id, 'sets' => 5, 'reps' => 5],
        ],
    ]);

    expect($updated->exercises)->toHaveCount(1)
        ->and($updated->exercises->first()->id)->toBe($exerciseB->id);
});

it('clears all exercises when updating with an empty exercise list', function () {
    $exercise = Exercise::factory()->create();

    $program = $this->service->create([
        'name' => 'Pull Day',
        'difficulty' => 'advanced',
        'exercises' => [
            ['exercise_id' => $exercise->id, 'sets' => 3, 'reps' => 10],
        ],
    ]);

    $updated = $this->service->update($program, ['exercises' => []]);

    expect($updated->exercises)->toHaveCount(0);
});

it('leaves existing exercises untouched when exercises key is absent from the update', function () {
    $exercise = Exercise::factory()->create();

    $program = $this->service->create([
        'name' => 'Core Day',
        'difficulty' => 'beginner',
        'exercises' => [
            ['exercise_id' => $exercise->id, 'sets' => 3, 'reps' => 10],
        ],
    ]);

    $updated = $this->service->update($program, ['name' => 'Core Day Renamed']);

    expect($updated->name)->toBe('Core Day Renamed')
        ->and($updated->exercises)->toHaveCount(1);
});

it('ignores null values in a partial update without touching them', function () {
    $program = Program::factory()->create(['name' => 'Original', 'duration' => 30]);

    $updated = $this->service->update($program, ['name' => 'Updated', 'duration' => null]);

    expect($updated->name)->toBe('Updated')
        ->and($updated->duration)->toBe(30);
});

it('deletes a program along with its program_exercises pivot rows', function () {
    $exercise = Exercise::factory()->create();
    $program = $this->service->create([
        'name' => 'To Delete',
        'difficulty' => 'beginner',
        'exercises' => [
            ['exercise_id' => $exercise->id, 'sets' => 3, 'reps' => 10],
        ],
    ]);
    $programId = $program->id;

    $this->service->delete($program);

    expect(Program::find($programId))->toBeNull();
    $this->assertDatabaseMissing('program_exercises', ['program_id' => $programId]);
});

it('filters paginated programs by difficulty', function () {
    Program::factory()->create(['difficulty' => 'beginner']);
    Program::factory()->create(['difficulty' => 'advanced']);

    $result = $this->service->paginate(difficulty: 'advanced');

    expect($result->total())->toBe(1);
});
