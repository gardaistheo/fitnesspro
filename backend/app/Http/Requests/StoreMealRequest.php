<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMealRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'calories' => ['required', 'integer', 'min:0'],
            'proteins' => ['nullable', 'integer', 'min:0'],
            'carbs' => ['nullable', 'integer', 'min:0'],
            'fats' => ['nullable', 'integer', 'min:0'],
            'logged_at' => ['nullable', 'date'],
        ];
    }
}
