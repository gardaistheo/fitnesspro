<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreMealRequest;
use App\Http\Responses\ApiResponse;
use App\Services\MealService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Meals', description: 'Meal logging (calories/macros), typically fed by the Passio.ai scan result on the mobile app')]
class MealController extends Controller
{
    public function __construct(
        private readonly MealService $mealService
    ) {}

    #[OA\Get(
        path: '/meals',
        tags: ['Meals'],
        summary: "List the authenticated user's logged meals",
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'from', in: 'query', required: false, schema: new OA\Schema(type: 'string', format: 'date'), example: '2026-07-01'),
            new OA\Parameter(name: 'to', in: 'query', required: false, schema: new OA\Schema(type: 'string', format: 'date'), example: '2026-07-07'),
            new OA\Parameter(name: 'per_page', in: 'query', required: false, schema: new OA\Schema(type: 'integer'), example: 15),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Paginated meal list', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function index(Request $request): JsonResponse
    {
        $meals = $this->mealService->paginate(
            user: $request->user(),
            from: $request->query('from'),
            to: $request->query('to'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($meals, 'Meals retrieved successfully');
    }

    #[OA\Post(
        path: '/meals',
        tags: ['Meals'],
        summary: 'Log a meal (calories/macros)',
        security: [['sanctum' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['name', 'calories'],
                properties: [
                    new OA\Property(property: 'name', type: 'string', example: 'Chicken and rice'),
                    new OA\Property(property: 'calories', type: 'integer', example: 650),
                    new OA\Property(property: 'proteins', type: 'integer', nullable: true, example: 45),
                    new OA\Property(property: 'carbs', type: 'integer', nullable: true, example: 70),
                    new OA\Property(property: 'fats', type: 'integer', nullable: true, example: 15),
                    new OA\Property(property: 'logged_at', type: 'string', format: 'date-time', nullable: true),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Meal logged', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 422, description: 'Validation error', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function store(StoreMealRequest $request): JsonResponse
    {
        $meal = $this->mealService->create($request->user(), $request->validated());

        return ApiResponse::success($meal, 'Meal logged successfully', 201);
    }
}
