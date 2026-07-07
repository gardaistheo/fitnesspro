<?php

namespace App\Http\Controllers;

use App\Http\Responses\ApiResponse;
use App\Models\Exercise;
use App\Services\ExerciseService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    public function __construct(
        private readonly ExerciseService $exerciseService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $exercises = $this->exerciseService->paginate(
            category: $request->query('category'),
            difficulty: $request->query('difficulty'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($exercises, 'Exercises retrieved successfully');
    }

    public function show(Exercise $exercise): JsonResponse
    {
        return ApiResponse::success($exercise, 'Exercise retrieved successfully');
    }
}
