<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProgramRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('update', $this->route('program')) ?? false;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'muscles' => ['nullable', 'array'],
            'muscles.*' => ['string'],
            'difficulty' => ['sometimes', 'required', 'string', 'in:beginner,intermediate,advanced'],
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
