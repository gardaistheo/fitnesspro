<?php

namespace App\Http\Requests;

use App\Models\WorkoutSession;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateWorkoutSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('update', $this->route('workoutSession')) ?? false;
    }

    public function rules(): array
    {
        return [
            'program_id' => ['nullable', 'integer', 'exists:programs,id'],
            'scheduled_date' => ['sometimes', 'required', 'date'],
            'scheduled_time' => ['nullable', 'date_format:H:i:s,H:i'],
            'completed_at' => ['nullable', 'date'],
            'status' => ['sometimes', 'required', 'string', Rule::in([
                WorkoutSession::STATUS_PLANNED,
                WorkoutSession::STATUS_COMPLETED,
                WorkoutSession::STATUS_CANCELLED,
            ])],
        ];
    }
}
