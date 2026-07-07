<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreMealRequest;
use App\Http\Responses\ApiResponse;
use App\Services\MealService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MealController extends Controller
{
    public function __construct(
        private readonly MealService $mealService
    ) {}

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

    public function store(StoreMealRequest $request): JsonResponse
    {
        $meal = $this->mealService->create($request->user(), $request->validated());

        return ApiResponse::success($meal, 'Meal logged successfully', 201);
    }
}
