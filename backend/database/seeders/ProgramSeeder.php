<?php

namespace Database\Seeders;

use App\Models\Exercise;
use App\Models\Program;
use Illuminate\Database\Seeder;

class ProgramSeeder extends Seeder
{
    public function run(): void
    {
        $programs = [
            [
                'name' => 'Push Day A',
                'muscles' => ['Poitrine', 'Épaules', 'Triceps'],
                'difficulty' => 'Intermédiaire',
                'duration' => 45,
                'description' => 'Séance poussée : pectoraux, épaules et triceps.',
                'exercises' => [
                    ['name' => 'Développé couché', 'sets' => 4, 'reps' => 8],
                    ['name' => 'Développé militaire', 'sets' => 3, 'reps' => 10],
                    ['name' => 'Dips', 'sets' => 3, 'reps' => 12],
                ],
            ],
            [
                'name' => 'Pull Day A',
                'muscles' => ['Dos', 'Biceps'],
                'difficulty' => 'Intermédiaire',
                'duration' => 45,
                'description' => 'Séance tirage : dos et biceps.',
                'exercises' => [
                    ['name' => 'Tractions', 'sets' => 4, 'reps' => 8],
                    ['name' => 'Soulevé de terre', 'sets' => 3, 'reps' => 6],
                    ['name' => 'Curl biceps', 'sets' => 3, 'reps' => 12],
                ],
            ],
            [
                'name' => 'Leg Day A',
                'muscles' => ['Jambes', 'Fessiers'],
                'difficulty' => 'Avancé',
                'duration' => 50,
                'description' => 'Séance jambes complète : quadriceps, ischio-jambiers, fessiers.',
                'exercises' => [
                    ['name' => 'Squat', 'sets' => 4, 'reps' => 8],
                    ['name' => 'Fentes', 'sets' => 3, 'reps' => 10],
                ],
            ],
            [
                'name' => 'Full Body Débutant',
                'muscles' => ['Poitrine', 'Dos', 'Jambes', 'Abdominaux'],
                'difficulty' => 'Débutant',
                'duration' => 30,
                'description' => 'Séance complète adaptée aux débutants, tout le corps en une session.',
                'exercises' => [
                    ['name' => 'Pompes', 'sets' => 3, 'reps' => 10],
                    ['name' => 'Fentes', 'sets' => 3, 'reps' => 10],
                    ['name' => 'Gainage', 'sets' => 3, 'reps' => 1],
                ],
            ],
            [
                'name' => 'Upper Body',
                'muscles' => ['Poitrine', 'Dos', 'Épaules', 'Bras'],
                'difficulty' => 'Intermédiaire',
                'duration' => 40,
                'description' => 'Séance haut du corps combinant poussée et tirage.',
                'exercises' => [
                    ['name' => 'Développé couché', 'sets' => 3, 'reps' => 10],
                    ['name' => 'Tractions', 'sets' => 3, 'reps' => 8],
                    ['name' => 'Curl biceps', 'sets' => 3, 'reps' => 12],
                ],
            ],
        ];

        foreach ($programs as $programData) {
            $exercisesData = $programData['exercises'];
            unset($programData['exercises']);

            $program = Program::updateOrCreate(['name' => $programData['name']], $programData);

            $program->programExercises()->delete();

            foreach ($exercisesData as $index => $exerciseData) {
                $exercise = Exercise::where('name', $exerciseData['name'])->first();

                if (! $exercise) {
                    continue;
                }

                $program->programExercises()->create([
                    'exercise_id' => $exercise->id,
                    'sets' => $exerciseData['sets'],
                    'reps' => $exerciseData['reps'],
                    'order' => $index,
                ]);
            }
        }
    }
}
