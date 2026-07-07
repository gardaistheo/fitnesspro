<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreWorkoutSessionRequest;
use App\Http\Requests\UpdateWorkoutSessionRequest;
use App\Http\Responses\ApiResponse;
use App\Models\WorkoutSession;
use App\Services\WorkoutSessionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WorkoutSessionController extends Controller
{
    public function __construct(
        private readonly WorkoutSessionService $workoutSessionService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $sessions = $this->workoutSessionService->paginate(
            user: $request->user(),
            status: $request->query('status'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($sessions, 'Workout sessions retrieved successfully');
    }

    public function show(Request $request, WorkoutSession $workoutSession): JsonResponse
    {
        $this->authorize('view', $workoutSession);

        $workoutSession->load('program');

        return ApiResponse::success($workoutSession, 'Workout session retrieved successfully');
    }

    public function store(StoreWorkoutSessionRequest $request): JsonResponse
    {
        $session = $this->workoutSessionService->create($request->user(), $request->validated());

        return ApiResponse::success($session, 'Workout session created successfully', 201);
    }

    public function update(UpdateWorkoutSessionRequest $request, WorkoutSession $workoutSession): JsonResponse
    {
        $session = $this->workoutSessionService->update($workoutSession, $request->validated());

        return ApiResponse::success($session, 'Workout session updated successfully');
    }

    public function destroy(Request $request, WorkoutSession $workoutSession): JsonResponse
    {
        $this->authorize('delete', $workoutSession);

        $this->workoutSessionService->delete($workoutSession);

        return ApiResponse::success(null, 'Workout session deleted successfully');
    }
}
