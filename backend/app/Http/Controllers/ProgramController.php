<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProgramRequest;
use App\Http\Requests\UpdateProgramRequest;
use App\Http\Responses\ApiResponse;
use App\Models\Program;
use App\Services\ProgramService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Programs', description: 'Workout program library (admin-managed catalogue)')]
class ProgramController extends Controller
{
    public function __construct(
        private readonly ProgramService $programService
    ) {}

    #[OA\Get(
        path: '/programs',
        tags: ['Programs'],
        summary: 'List programs (paginated, filterable by difficulty)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'difficulty', in: 'query', required: false, schema: new OA\Schema(type: 'string'), example: 'intermediate'),
            new OA\Parameter(name: 'per_page', in: 'query', required: false, schema: new OA\Schema(type: 'integer'), example: 15),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Paginated program list', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function index(Request $request): JsonResponse
    {
        $programs = $this->programService->paginate(
            difficulty: $request->query('difficulty'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($programs, 'Programs retrieved successfully');
    }

    #[OA\Get(
        path: '/programs/{program}',
        tags: ['Programs'],
        summary: 'Get a program with its exercises',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'program', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Program detail', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 404, description: 'Not found', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function show(Program $program): JsonResponse
    {
        $program->load('exercises');

        return ApiResponse::success($program, 'Program retrieved successfully');
    }

    #[OA\Post(
        path: '/programs',
        tags: ['Programs'],
        summary: 'Create a program (admin only)',
        security: [['sanctum' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['name', 'difficulty'],
                properties: [
                    new OA\Property(property: 'name', type: 'string', example: 'Full Body Blast'),
                    new OA\Property(property: 'muscles', type: 'array', items: new OA\Items(type: 'string'), example: ['legs', 'chest']),
                    new OA\Property(property: 'difficulty', type: 'string', enum: ['beginner', 'intermediate', 'advanced']),
                    new OA\Property(property: 'duration', type: 'integer', nullable: true, example: 45),
                    new OA\Property(property: 'description', type: 'string', nullable: true),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Program created', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 403, description: 'Forbidden (non-admin)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
            new OA\Response(response: 422, description: 'Validation error', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function store(StoreProgramRequest $request): JsonResponse
    {
        $program = $this->programService->create($request->validated());

        return ApiResponse::success($program, 'Program created successfully', 201);
    }

    #[OA\Put(
        path: '/programs/{program}',
        tags: ['Programs'],
        summary: 'Update a program (admin only)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'program', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Program updated', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 403, description: 'Forbidden (non-admin)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function update(UpdateProgramRequest $request, Program $program): JsonResponse
    {
        $program = $this->programService->update($program, $request->validated());

        return ApiResponse::success($program, 'Program updated successfully');
    }

    #[OA\Delete(
        path: '/programs/{program}',
        tags: ['Programs'],
        summary: 'Delete a program (admin only)',
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'program', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Program deleted', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 403, description: 'Forbidden (non-admin)', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function destroy(Request $request, Program $program): JsonResponse
    {
        $this->authorize('delete', $program);

        $this->programService->delete($program);

        return ApiResponse::success(null, 'Program deleted successfully');
    }
}
