<?php

namespace App\Services;

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class SubscriptionService
{
    public function handleRevenueCatEvent(array $event): void
    {
        $type = $event['type'] ?? null;
        $appUserId = $event['app_user_id'] ?? null;

        if (! $type || ! $appUserId) {
            Log::warning('RevenueCat webhook missing type or app_user_id', $event);

            return;
        }

        $user = User::find($appUserId);

        if (! $user) {
            Log::warning('RevenueCat webhook for unknown user', ['app_user_id' => $appUserId]);

            return;
        }

        match ($type) {
            'INITIAL_PURCHASE', 'RENEWAL', 'UNCANCELLATION', 'PRODUCT_CHANGE' => $this->activate($user, $event),
            'EXPIRATION', 'CANCELLATION' => $this->deactivate($user, $event),
            default => Log::info('Unhandled RevenueCat event type', ['type' => $type]),
        };
    }

    private function activate(User $user, array $event): void
    {
        $externalId = $event['id'] ?? null;
        $expiresAtMs = $event['expiration_at_ms'] ?? null;
        $purchasedAtMs = $event['purchased_at_ms'] ?? null;

        Subscription::updateOrCreate(
            ['user_id' => $user->id, 'provider' => 'revenuecat'],
            [
                'is_active' => true,
                'external_id' => $externalId,
                'started_at' => $purchasedAtMs ? now()->createFromTimestampMs($purchasedAtMs) : now(),
                'expires_at' => $expiresAtMs ? now()->createFromTimestampMs($expiresAtMs) : null,
            ]
        );
    }

    private function deactivate(User $user, array $event): void
    {
        Subscription::where('user_id', $user->id)
            ->where('provider', 'revenuecat')
            ->update(['is_active' => false]);
    }
}
