<?php

namespace Database\Factories;

use App\Models\Exercise;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Exercise>
 */
class ExerciseFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => ucfirst(fake()->unique()->words(2, true)),
            'category' => fake()->randomElement(['strength', 'cardio', 'mobility', 'flexibility']),
            'muscles' => fake()->randomElements(['chest', 'back', 'legs', 'shoulders', 'arms', 'core'], 2),
            'difficulty' => fake()->randomElement(['beginner', 'intermediate', 'advanced']),
            'description' => fake()->sentence(),
            'instructions' => [fake()->sentence(), fake()->sentence()],
            'youtube_url' => 'https://www.youtube.com/watch?v='.fake()->lexify('???????????'),
        ];
    }
}
