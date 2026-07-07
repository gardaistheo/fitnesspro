<?php

namespace App\Http\Requests;

use App\Models\Program;
use Illuminate\Foundation\Http\FormRequest;

class StoreProgramRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', Program::class) ?? false;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'muscles' => ['nullable', 'array'],
            'muscles.*' => ['string'],
            'difficulty' => ['required', 'string', 'in:beginner,intermediate,advanced'],
            'duration' => ['nullable', 'integer', 'min:1'],
            'description' => ['nullable', 'string'],
            'exercises' => ['nullable', 'array'],
            'exercises.*.exercise_id' => ['required_with:exercises', 'integer', 'exists:exercises,id'],
            'exercises.*.sets' => ['required_with:exercises', 'integer', 'min:1'],
            'exercises.*.reps' => ['required_with:exercises', 'integer', 'min:1'],
            'exercises.*.order' => ['nullable', 'integer', 'min:0'],
        ];
    }
}
