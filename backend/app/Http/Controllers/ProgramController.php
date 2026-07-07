<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProgramRequest;
use App\Http\Requests\UpdateProgramRequest;
use App\Http\Responses\ApiResponse;
use App\Models\Program;
use App\Services\ProgramService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProgramController extends Controller
{
    public function __construct(
        private readonly ProgramService $programService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $programs = $this->programService->paginate(
            difficulty: $request->query('difficulty'),
            perPage: (int) $request->query('per_page', 15),
        );

        return ApiResponse::success($programs, 'Programs retrieved successfully');
    }

    public function show(Program $program): JsonResponse
    {
        $program->load('exercises');

        return ApiResponse::success($program, 'Program retrieved successfully');
    }

    public function store(StoreProgramRequest $request): JsonResponse
    {
        $program = $this->programService->create($request->validated());

        return ApiResponse::success($program, 'Program created successfully', 201);
    }

    public function update(UpdateProgramRequest $request, Program $program): JsonResponse
    {
        $program = $this->programService->update($program, $request->validated());

        return ApiResponse::success($program, 'Program updated successfully');
    }

    public function destroy(Request $request, Program $program): JsonResponse
    {
        $this->authorize('delete', $program);

        $this->programService->delete($program);

        return ApiResponse::success(null, 'Program deleted successfully');
    }
}
