<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['name', 'category', 'muscles', 'difficulty', 'description', 'instructions', 'youtube_url'])]
class Exercise extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'muscles' => 'array',
            'instructions' => 'array',
        ];
    }

    public function programExercises(): HasMany
    {
        return $this->hasMany(ProgramExercise::class);
    }

    public function programs(): BelongsToMany
    {
        return $this->belongsToMany(Program::class, 'program_exercises')
            ->withPivot(['sets', 'reps', 'order'])
            ->withTimestamps();
    }

    public function scopeCategory($query, ?string $category)
    {
        return $query->when($category, fn ($q) => $q->where('category', $category));
    }

    public function scopeDifficulty($query, ?string $difficulty)
    {
        return $query->when($difficulty, fn ($q) => $q->where('difficulty', $difficulty));
    }
}
