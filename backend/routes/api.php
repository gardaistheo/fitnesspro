<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ExerciseController;
use App\Http\Controllers\ProgramController;
use App\Http\Controllers\WorkoutSessionController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('exercises', [ExerciseController::class, 'index']);
    Route::get('exercises/{exercise}', [ExerciseController::class, 'show']);

    Route::get('programs', [ProgramController::class, 'index']);
    Route::get('programs/{program}', [ProgramController::class, 'show']);
    Route::post('programs', [ProgramController::class, 'store']);
    Route::put('programs/{program}', [ProgramController::class, 'update']);
    Route::delete('programs/{program}', [ProgramController::class, 'destroy']);

    Route::get('workout-sessions', [WorkoutSessionController::class, 'index']);
    Route::get('workout-sessions/{workoutSession}', [WorkoutSessionController::class, 'show']);
    Route::post('workout-sessions', [WorkoutSessionController::class, 'store']);
    Route::put('workout-sessions/{workoutSession}', [WorkoutSessionController::class, 'update']);
    Route::delete('workout-sessions/{workoutSession}', [WorkoutSessionController::class, 'destroy']);
});
