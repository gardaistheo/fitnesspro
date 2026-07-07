<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreWorkoutSessionRequest;
use App\Http\Requests\UpdateWorkoutSessionRequest;
use App\Http\Responses\ApiResponse;
use App\Models\WorkoutSession;
use App\Services\WorkoutSessionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'WorkoutSessions', description: 'User workout planning: scheduled and completed sessions')]
class WorkoutSessionController extends Controller
{
    public function __construct(
        private readonly WorkoutSessionService $workoutSessionService
    ) {}

    #[OA\Get(
        path: '/workout-sessions',
        tags: ['WorkoutSessions'],
        summary: "List the authenticated user's workout sessions",
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'status', in: 'query', required: false, schema: new OA\Schema(type: 'string', enum: ['planned', 'completed', 'cancelled'])),
            new OA\Parameter(name: 'per_page', in: 'query', required: false, schema: new OA\Schema(type: 'integer'), example: 15),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Paginated workout session list', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function index(Request $request): JsonResponse
    {
        $sessions = $this->workoutSessionService->paginate(
            user: $request->user(),
            status: $request->query('status'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($sessions, 'Workout sessions retrieved successfully');
    }

    #[OA\Get(
        path: '/workout-sessions/{workoutSession}',
        tags: ['WorkoutSessions'],
        summary: 'Get a single workout session (owner only)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'workoutSession', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Workout session detail', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 403, description: 'Forbidden (not the owner)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function show(Request $request, WorkoutSession $workoutSession): JsonResponse
    {
        $this->authorize('view', $workoutSession);

        $workoutSession->load('program');

        return ApiResponse::success($workoutSession, 'Workout session retrieved successfully');
    }

    #[OA\Post(
        path: '/workout-sessions',
        tags: ['WorkoutSessions'],
        summary: 'Schedule a new workout session',
        security: [['sanctum' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['scheduled_date'],
                properties: [
                    new OA\Property(property: 'program_id', type: 'integer', nullable: true, example: 1),
                    new OA\Property(property: 'scheduled_date', type: 'string', format: 'date', example: '2026-07-10'),
                    new OA\Property(property: 'scheduled_time', type: 'string', nullable: true, example: '10:00'),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Workout session created', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 422, description: 'Validation error (e.g. past date)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function store(StoreWorkoutSessionRequest $request): JsonResponse
    {
        $session = $this->workoutSessionService->create($request->user(), $request->validated());

        return ApiResponse::success($session, 'Workout session created successfully', 201);
    }

    #[OA\Put(
        path: '/workout-sessions/{workoutSession}',
        tags: ['WorkoutSessions'],
        summary: 'Update a workout session (owner only)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'workoutSession', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Workout session updated', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 403, description: 'Forbidden (not the owner)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function update(UpdateWorkoutSessionRequest $request, WorkoutSession $workoutSession): JsonResponse
    {
        $session = $this->workoutSessionService->update($workoutSession, $request->validated());

        return ApiResponse::success($session, 'Workout session updated successfully');
    }

    #[OA\Delete(
        path: '/workout-sessions/{workoutSession}',
        tags: ['WorkoutSessions'],
        summary: 'Delete a workout session (owner only)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'workoutSession', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Workout session deleted', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 403, description: 'Forbidden (not the owner)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function destroy(Request $request, WorkoutSession $workoutSession): JsonResponse
    {
        $this->authorize('delete', $workoutSession);

        $this->workoutSessionService->delete($workoutSession);

        return ApiResponse::success(null, 'Workout session deleted successfully');
    }
}
