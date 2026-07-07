<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['user_id', 'name', 'calories', 'proteins', 'carbs', 'fats', 'logged_at'])]
class Meal extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'calories' => 'integer',
            'proteins' => 'integer',
            'carbs' => 'integer',
            'fats' => 'integer',
            'logged_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
