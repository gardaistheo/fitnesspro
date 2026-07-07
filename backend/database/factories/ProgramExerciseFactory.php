<?php

namespace Database\Factories;

use App\Models\Exercise;
use App\Models\Program;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\ProgramExercise>
 */
class ProgramExerciseFactory extends Factory
{
    public function definition(): array
    {
        return [
            'program_id' => Program::factory(),
            'exercise_id' => Exercise::factory(),
            'sets' => fake()->numberBetween(2, 5),
            'reps' => fake()->numberBetween(6, 15),
            'order' => fake()->numberBetween(0, 10),
        ];
    }
}
