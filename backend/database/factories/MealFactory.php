<?php

namespace Database\Factories;

use App\Models\Meal;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Meal>
 */
class MealFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'name' => ucfirst(fake()->words(2, true)),
            'calories' => fake()->numberBetween(200, 900),
            'proteins' => fake()->numberBetween(5, 60),
            'carbs' => fake()->numberBetween(5, 100),
            'fats' => fake()->numberBetween(5, 40),
            'logged_at' => now(),
        ];
    }
}
