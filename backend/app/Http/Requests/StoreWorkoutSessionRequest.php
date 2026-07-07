<?php

namespace App\Http\Requests;

use App\Models\WorkoutSession;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreWorkoutSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'program_id' => ['nullable', 'integer', 'exists:programs,id'],
            'scheduled_date' => ['required', 'date', 'after_or_equal:today'],
            'scheduled_time' => ['nullable', 'date_format:H:i:s,H:i'],
            'status' => ['nullable', 'string', Rule::in([
                WorkoutSession::STATUS_PLANNED,
                WorkoutSession::STATUS_COMPLETED,
                WorkoutSession::STATUS_CANCELLED,
            ])],
        ];
    }

    public function messages(): array
    {
        return [
            'scheduled_date.after_or_equal' => 'The scheduled date must be today or a future date.',
        ];
    }
}
