<?php

use App\Models\Meal;
use App\Models\User;
use App\Services\MealService;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->service = new MealService;
    $this->user = User::factory()->create();
});

it('orders meals by logged_at descending', function () {
    Meal::factory()->create(['user_id' => $this->user->id, 'name' => 'Older', 'logged_at' => now()->subDay()]);
    Meal::factory()->create(['user_id' => $this->user->id, 'name' => 'Newer', 'logged_at' => now()]);

    $result = $this->service->paginate($this->user);

    expect($result->items()[0]->name)->toBe('Newer');
});

it('filters by from and to date bounds together', function () {
    Meal::factory()->create(['user_id' => $this->user->id, 'logged_at' => now()->subDays(10)]);
    Meal::factory()->create(['user_id' => $this->user->id, 'logged_at' => now()->subDays(3)]);
    Meal::factory()->create(['user_id' => $this->user->id, 'logged_at' => now()]);

    $result = $this->service->paginate(
        $this->user,
        from: now()->subDays(5)->toDateString(),
        to: now()->subDay()->toDateString(),
    );

    expect($result->total())->toBe(1);
});

it('creates a meal defaulting logged_at to now when not provided', function () {
    $meal = $this->service->create($this->user, [
        'name' => 'Snack',
        'calories' => 200,
    ]);

    expect($meal->logged_at)->not->toBeNull()
        ->and($meal->logged_at->diffInSeconds(now()))->toBeLessThan(5);
});
