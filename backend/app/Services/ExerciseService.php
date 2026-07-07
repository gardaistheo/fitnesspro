<?php

namespace App\Services;

use App\Models\Exercise;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ExerciseService
{
    public function paginate(?string $category, ?string $difficulty, int $perPage = 15): LengthAwarePaginator
    {
        return Exercise::query()
            ->category($category)
            ->difficulty($difficulty)
            ->orderBy('name')
            ->paginate($perPage);
    }

    public function find(int $id): Exercise
    {
        return Exercise::findOrFail($id);
    }
}
