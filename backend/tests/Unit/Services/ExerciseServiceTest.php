<?php

use App\Models\Exercise;
use App\Services\ExerciseService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->service = new ExerciseService;
});

it('orders exercises alphabetically by name', function () {
    Exercise::factory()->create(['name' => 'Zercise']);
    Exercise::factory()->create(['name' => 'Arm curl']);

    $result = $this->service->paginate(null, null);

    expect($result->items()[0]->name)->toBe('Arm curl');
});

it('combines category and difficulty filters', function () {
    Exercise::factory()->create(['category' => 'strength', 'difficulty' => 'beginner']);
    Exercise::factory()->create(['category' => 'strength', 'difficulty' => 'advanced']);
    Exercise::factory()->create(['category' => 'cardio', 'difficulty' => 'beginner']);

    $result = $this->service->paginate('strength', 'beginner');

    expect($result->total())->toBe(1);
});

it('throws when finding a non-existent exercise', function () {
    $this->service->find(999999);
})->throws(ModelNotFoundException::class);
