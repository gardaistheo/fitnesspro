<?php

namespace App\Http\Controllers;

use App\Http\Responses\ApiResponse;
use App\Services\SubscriptionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Subscriptions', description: 'RevenueCat webhook for subscription status sync')]
class WebhookController extends Controller
{
    public function __construct(
        private readonly SubscriptionService $subscriptionService
    ) {}

    #[OA\Post(
        path: '/subscriptions/webhook',
        tags: ['Subscriptions'],
        summary: 'RevenueCat webhook endpoint',
        description: 'Called directly by RevenueCat (not by the mobile app). Authenticated via a shared secret in the Authorization header (REVENUECAT_WEBHOOK_SECRET), not Sanctum.',
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(
                        property: 'event',
                        type: 'object',
                        properties: [
                            new OA\Property(property: 'type', type: 'string', example: 'INITIAL_PURCHASE'),
                            new OA\Property(property: 'app_user_id', type: 'string', example: '42'),
                            new OA\Property(property: 'id', type: 'string', example: 'ext-123'),
                            new OA\Property(property: 'purchased_at_ms', type: 'integer', nullable: true),
                            new OA\Property(property: 'expiration_at_ms', type: 'integer', nullable: true),
                        ]
                    ),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: 'Webhook processed', content: new OA\JsonContent(ref: '#/components/schemas/ApiSuccessResponse')),
            new OA\Response(response: 401, description: 'Invalid webhook signature', content: new OA\JsonContent(ref: '#/components/schemas/ApiErrorResponse')),
        ]
    )]
    public function revenuecat(Request $request): JsonResponse
    {
        $expectedSecret = config('services.revenuecat.webhook_secret');
        $providedSecret = $request->header('Authorization');

        if ($expectedSecret && $providedSecret !== $expectedSecret) {
            return ApiResponse::error('Invalid webhook signature.', null, 401);
        }

        $event = $request->input('event', []);

        $this->subscriptionService->handleRevenueCatEvent($event);

        return ApiResponse::success(null, 'Webhook processed successfully');
    }
}
