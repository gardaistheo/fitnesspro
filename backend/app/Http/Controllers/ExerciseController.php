<?php

namespace App\Http\Controllers;

use App\Http\Responses\ApiResponse;
use App\Models\Exercise;
use App\Services\ExerciseService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Exercises', description: 'Exercise catalogue with category/difficulty filters')]
class ExerciseController extends Controller
{
    public function __construct(
        private readonly ExerciseService $exerciseService
    ) {}

    #[OA\Get(
        path: '/exercises',
        tags: ['Exercises'],
        summary: 'List exercises (paginated, filterable)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'category', in: 'query', required: false, schema: new OA\Schema(type: 'string'), example: 'strength'),
            new OA\Parameter(name: 'difficulty', in: 'query', required: false, schema: new OA\Schema(type: 'string'), example: 'beginner'),
            new OA\Parameter(name: 'per_page', in: 'query', required: false, schema: new OA\Schema(type: 'integer'), example: 15),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Paginated exercise list', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function index(Request $request): JsonResponse
    {
        $exercises = $this->exerciseService->paginate(
            category: $request->query('category'),
            difficulty: $request->query('difficulty'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($exercises, 'Exercises retrieved successfully');
    }

    #[OA\Get(
        path: '/exercises/{exercise}',
        tags: ['Exercises'],
        summary: 'Get a single exercise',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'exercise', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Exercise detail', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 404, description: 'Not found', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function show(Exercise $exercise): JsonResponse
    {
        return ApiResponse::success($exercise, 'Exercise retrieved successfully');
    }
}
