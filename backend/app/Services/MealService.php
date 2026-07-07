<?php

namespace App\Services;

use App\Models\Meal;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class MealService
{
    public function paginate(User $user, ?string $from = null, ?string $to = null, int $perPage = 15): LengthAwarePaginator
    {
        return Meal::query()
            ->where('user_id', $user->id)
            ->when($from, fn ($q) => $q->whereDate('logged_at', '>=', $from))
            ->when($to, fn ($q) => $q->whereDate('logged_at', '<=', $to))
            ->orderByDesc('logged_at')
            ->paginate($perPage);
    }

    public function create(User $user, array $data): Meal
    {
        return Meal::create([
            'user_id' => $user->id,
            'name' => $data['name'],
            'calories' => $data['calories'],
            'proteins' => $data['proteins'] ?? 0,
            'carbs' => $data['carbs'] ?? 0,
            'fats' => $data['fats'] ?? 0,
            'logged_at' => $data['logged_at'] ?? now(),
        ]);
    }
}
