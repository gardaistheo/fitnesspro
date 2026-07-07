<?php

use App\Models\Subscription;
use App\Models\User;
use App\Services\SubscriptionService;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->service = new SubscriptionService;
});

it('does nothing when the event has no type', function () {
    $user = User::factory()->create();

    $this->service->handleRevenueCatEvent(['app_user_id' => (string) $user->id]);

    $this->assertDatabaseCount('subscriptions', 0);
});

it('does nothing when the event has no app_user_id', function () {
    $this->service->handleRevenueCatEvent(['type' => 'INITIAL_PURCHASE']);

    $this->assertDatabaseCount('subscriptions', 0);
});

it('updates an existing revenuecat subscription instead of creating a duplicate', function () {
    $user = User::factory()->create();
    $existing = Subscription::factory()->create([
        'user_id' => $user->id,
        'provider' => 'revenuecat',
        'is_active' => false,
        'external_id' => 'old-id',
    ]);

    $this->service->handleRevenueCatEvent([
        'type' => 'RENEWAL',
        'app_user_id' => (string) $user->id,
        'id' => 'new-id',
    ]);

    $this->assertDatabaseCount('subscriptions', 1);
    $this->assertDatabaseHas('subscriptions', [
        'id' => $existing->id,
        'is_active' => true,
        'external_id' => 'new-id',
    ]);
});

it('sets expires_at from expiration_at_ms when provided', function () {
    $user = User::factory()->create();
    $expiresAtMs = now()->addMonth()->getTimestampMs();

    $this->service->handleRevenueCatEvent([
        'type' => 'INITIAL_PURCHASE',
        'app_user_id' => (string) $user->id,
        'expiration_at_ms' => $expiresAtMs,
    ]);

    $subscription = Subscription::where('user_id', $user->id)->first();

    expect($subscription->expires_at->timestamp)->toBe(intdiv($expiresAtMs, 1000));
});

it('leaves expires_at null when expiration_at_ms is not provided', function () {
    $user = User::factory()->create();

    $this->service->handleRevenueCatEvent([
        'type' => 'INITIAL_PURCHASE',
        'app_user_id' => (string) $user->id,
    ]);

    $subscription = Subscription::where('user_id', $user->id)->first();

    expect($subscription->expires_at)->toBeNull();
});
