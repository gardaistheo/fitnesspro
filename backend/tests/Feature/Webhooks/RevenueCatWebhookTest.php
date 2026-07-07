<?php

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    config(['services.revenuecat.webhook_secret' => 'test-secret']);
});

it('activates a subscription on INITIAL_PURCHASE event', function () {
    $user = User::factory()->create();

    $response = $this->withHeader('Authorization', 'test-secret')
        ->postJson('/api/subscriptions/webhook', [
            'event' => [
                'type' => 'INITIAL_PURCHASE',
                'app_user_id' => (string) $user->id,
                'id' => 'ext-123',
                'purchased_at_ms' => now()->getTimestampMs(),
                'expiration_at_ms' => now()->addMonth()->getTimestampMs(),
            ],
        ]);

    $response->assertStatus(200);

    $this->assertDatabaseHas('subscriptions', [
        'user_id' => $user->id,
        'provider' => 'revenuecat',
        'is_active' => true,
        'external_id' => 'ext-123',
    ]);
});

it('deactivates a subscription on EXPIRATION event', function () {
    $user = User::factory()->create();
    Subscription::factory()->create([
        'user_id' => $user->id,
        'provider' => 'revenuecat',
        'is_active' => true,
    ]);

    $response = $this->withHeader('Authorization', 'test-secret')
        ->postJson('/api/subscriptions/webhook', [
            'event' => [
                'type' => 'EXPIRATION',
                'app_user_id' => (string) $user->id,
            ],
        ]);

    $response->assertStatus(200);

    $this->assertDatabaseHas('subscriptions', [
        'user_id' => $user->id,
        'provider' => 'revenuecat',
        'is_active' => false,
    ]);
});

it('deactivates a subscription on CANCELLATION event', function () {
    $user = User::factory()->create();
    Subscription::factory()->create([
        'user_id' => $user->id,
        'provider' => 'revenuecat',
        'is_active' => true,
    ]);

    $response = $this->withHeader('Authorization', 'test-secret')
        ->postJson('/api/subscriptions/webhook', [
            'event' => [
                'type' => 'CANCELLATION',
                'app_user_id' => (string) $user->id,
            ],
        ]);

    $response->assertStatus(200);

    $this->assertDatabaseHas('subscriptions', [
        'user_id' => $user->id,
        'provider' => 'revenuecat',
        'is_active' => false,
    ]);
});

it('rejects a webhook with an invalid signature', function () {
    $user = User::factory()->create();

    $response = $this->withHeader('Authorization', 'wrong-secret')
        ->postJson('/api/subscriptions/webhook', [
            'event' => [
                'type' => 'INITIAL_PURCHASE',
                'app_user_id' => (string) $user->id,
            ],
        ]);

    $response->assertStatus(401);

    $this->assertDatabaseCount('subscriptions', 0);
});

it('ignores events for an unknown user without erroring', function () {
    $response = $this->withHeader('Authorization', 'test-secret')
        ->postJson('/api/subscriptions/webhook', [
            'event' => [
                'type' => 'INITIAL_PURCHASE',
                'app_user_id' => '999999',
            ],
        ]);

    $response->assertStatus(200);
    $this->assertDatabaseCount('subscriptions', 0);
});

it('logs an unhandled event type without erroring', function () {
    $user = User::factory()->create();

    $response = $this->withHeader('Authorization', 'test-secret')
        ->postJson('/api/subscriptions/webhook', [
            'event' => [
                'type' => 'SOME_OTHER_EVENT',
                'app_user_id' => (string) $user->id,
            ],
        ]);

    $response->assertStatus(200);
    $this->assertDatabaseCount('subscriptions', 0);
});
