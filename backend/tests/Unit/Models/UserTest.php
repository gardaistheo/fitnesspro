<?php

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('returns null active subscription when the user has none', function () {
    $user = User::factory()->create();

    expect($user->activeSubscription())->toBeNull();
});

it('returns the most recently started active subscription', function () {
    $user = User::factory()->create();
    Subscription::factory()->create([
        'user_id' => $user->id,
        'is_active' => true,
        'started_at' => now()->subMonth(),
    ]);
    $latest = Subscription::factory()->create([
        'user_id' => $user->id,
        'is_active' => true,
        'started_at' => now(),
    ]);

    expect($user->activeSubscription()->id)->toBe($latest->id);
});

it('ignores inactive subscriptions when resolving the active one', function () {
    $user = User::factory()->create();
    Subscription::factory()->create([
        'user_id' => $user->id,
        'is_active' => false,
        'started_at' => now(),
    ]);

    expect($user->activeSubscription())->toBeNull();
});

it('reports isAdmin correctly for admin and non-admin users', function () {
    $admin = User::factory()->admin()->create();
    $user = User::factory()->create();

    expect($admin->isAdmin())->toBeTrue()
        ->and($user->isAdmin())->toBeFalse();
});
