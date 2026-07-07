<?php

namespace App\Services;

use App\Models\Program;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class ProgramService
{
    public function paginate(?string $difficulty = null, int $perPage = 15): LengthAwarePaginator
    {
        return Program::query()
            ->when($difficulty, fn ($q) => $q->where('difficulty', $difficulty))
            ->with('exercises')
            ->orderBy('name')
            ->paginate($perPage);
    }

    public function find(int $id): Program
    {
        return Program::with('exercises')->findOrFail($id);
    }

    public function create(array $data): Program
    {
        return DB::transaction(function () use ($data) {
            $program = Program::create([
                'name' => $data['name'],
                'muscles' => $data['muscles'] ?? [],
                'difficulty' => $data['difficulty'],
                'duration' => $data['duration'] ?? null,
                'description' => $data['description'] ?? null,
            ]);

            $this->syncExercises($program, $data['exercises'] ?? []);

            return $program->fresh('exercises');
        });
    }

    public function update(Program $program, array $data): Program
    {
        return DB::transaction(function () use ($program, $data) {
            $program->update(array_filter([
                'name' => $data['name'] ?? null,
                'muscles' => $data['muscles'] ?? null,
                'difficulty' => $data['difficulty'] ?? null,
                'duration' => $data['duration'] ?? null,
                'description' => $data['description'] ?? null,
            ], fn ($value) => ! is_null($value)));

            if (array_key_exists('exercises', $data)) {
                $this->syncExercises($program, $data['exercises'] ?? []);
            }

            return $program->fresh('exercises');
        });
    }

    public function delete(Program $program): void
    {
        DB::transaction(function () use ($program) {
            $program->programExercises()->delete();
            $program->delete();
        });
    }

    private function syncExercises(Program $program, array $exercises): void
    {
        $program->programExercises()->delete();

        foreach ($exercises as $index => $exercise) {
            $program->programExercises()->create([
                'exercise_id' => $exercise['exercise_id'],
                'sets' => $exercise['sets'],
                'reps' => $exercise['reps'],
                'order' => $exercise['order'] ?? $index,
            ]);
        }
    }
}
