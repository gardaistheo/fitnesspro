<?php

namespace Database\Factories;

use App\Models\Program;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Program>
 */
class ProgramFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => ucfirst(fake()->unique()->words(3, true)),
            'muscles' => fake()->randomElements(['chest', 'back', 'legs', 'shoulders', 'arms', 'core'], 3),
            'difficulty' => fake()->randomElement(['beginner', 'intermediate', 'advanced']),
            'duration' => fake()->numberBetween(20, 90),
            'description' => fake()->paragraph(),
        ];
    }
}
