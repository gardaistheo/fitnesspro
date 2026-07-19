<?php

namespace Database\Factories;

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Subscription>
 */
class SubscriptionFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'is_active' => true,
            'provider' => fake()->randomElement(['revenuecat']),
            'external_id' => fake()->uuid(),
            'started_at' => now(),
            'expires_at' => now()->addMonth(),
        ];
    }
}
