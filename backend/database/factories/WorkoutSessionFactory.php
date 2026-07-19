<?php

namespace Database\Factories;

use App\Models\Program;
use App\Models\User;
use App\Models\WorkoutSession;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WorkoutSession>
 */
class WorkoutSessionFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'program_id' => Program::factory(),
            'scheduled_date' => fake()->dateTimeBetween('now', '+1 month')->format('Y-m-d'),
            'scheduled_time' => fake()->time('H:i:s'),
            'completed_at' => null,
            'status' => WorkoutSession::STATUS_PLANNED,
        ];
    }

    public function completed(): static
    {
        return $this->state(fn () => [
            'completed_at' => now(),
            'status' => WorkoutSession::STATUS_COMPLETED,
        ]);
    }
}
