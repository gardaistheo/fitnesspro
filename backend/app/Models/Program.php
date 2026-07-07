<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['name', 'muscles', 'difficulty', 'duration', 'description'])]
class Program extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'muscles' => 'array',
            'duration' => 'integer',
        ];
    }

    public function programExercises(): HasMany
    {
        return $this->hasMany(ProgramExercise::class)->orderBy('order');
    }

    public function exercises(): BelongsToMany
    {
        return $this->belongsToMany(Exercise::class, 'program_exercises')
            ->withPivot(['sets', 'reps', 'order'])
            ->withTimestamps()
            ->orderByPivot('order');
    }

    public function workoutSessions(): HasMany
    {
        return $this->hasMany(WorkoutSession::class);
    }
}
