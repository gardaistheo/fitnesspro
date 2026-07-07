<?php

namespace App\Http\Controllers;

use App\Http\Responses\ApiResponse;
use App\Services\SubscriptionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WebhookController extends Controller
{
    public function __construct(
        private readonly SubscriptionService $subscriptionService
    ) {}

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
