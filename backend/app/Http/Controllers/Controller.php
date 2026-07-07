<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use OpenApi\Attributes as OA;

#[OA\Info(
    version: '1.0.0',
    title: 'FitnessPro API',
    description: 'REST API for the FitnessPro mobile app: authentication, exercise catalogue, workout programs, planning, meal logging, and subscription sync.'
)]
#[OA\Server(url: '/api', description: 'API server')]
#[OA\SecurityScheme(
    securityScheme: 'sanctum',
    type: 'http',
    scheme: 'bearer',
    bearerFormat: 'Sanctum personal access token'
)]
#[OA\Schema(
    schema: 'ApiSuccessResponse',
    properties: [
        new OA\Property(property: 'status', type: 'string', example: 'success'),
        new OA\Property(property: 'message', type: 'string', nullable: true, example: 'Operation successful'),
        new OA\Property(property: 'data', type: 'object', nullable: true),
        new OA\Property(property: 'errors', type: 'object', nullable: true, example: null),
    ]
)]
#[OA\Schema(
    schema: 'ApiErrorResponse',
    properties: [
        new OA\Property(property: 'status', type: 'string', example: 'error'),
        new OA\Property(property: 'message', type: 'string', example: 'Something went wrong.'),
        new OA\Property(property: 'data', type: 'object', nullable: true, example: null),
        new OA\Property(property: 'errors', type: 'object', nullable: true),
    ]
)]
abstract class Controller
{
    use AuthorizesRequests;
}
