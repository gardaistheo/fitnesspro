<?php

use App\Models\User;
use App\Models\WorkoutSession;
use App\Services\WorkoutSessionService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->service = new WorkoutSessionService;
    $this->user = User::factory()->create();
});

it('creates a session defaulting status to planned', function () {
    $session = $this->service->create($this->user, [
        'scheduled_date' => now()->addDay()->toDateString(),
    ]);

    expect($session->status)->toBe(WorkoutSession::STATUS_PLANNED)
        ->and($session->user_id)->toBe($this->user->id);
});

it('stamps completed_at automatically when marking a session completed without an explicit timestamp', function () {
    $session = WorkoutSession::factory()->create([
        'user_id' => $this->user->id,
        'status' => WorkoutSession::STATUS_PLANNED,
        'completed_at' => null,
    ]);

    $updated = $this->service->update($session, ['status' => WorkoutSession::STATUS_COMPLETED]);

    expect($updated->completed_at)->not->toBeNull();
});

it('does not overwrite an explicit completed_at when provided', function () {
    $session = WorkoutSession::factory()->create([
        'user_id' => $this->user->id,
        'status' => WorkoutSession::STATUS_PLANNED,
    ]);
    $explicitTimestamp = now()->subHour();

    $updated = $this->service->update($session, [
        'status' => WorkoutSession::STATUS_COMPLETED,
        'completed_at' => $explicitTimestamp,
    ]);

    expect($updated->completed_at->timestamp)->toBe($explicitTimestamp->timestamp);
});

it('blocks rescheduling a planned session to a past date', function () {
    $session = WorkoutSession::factory()->create([
        'user_id' => $this->user->id,
        'status' => WorkoutSession::STATUS_PLANNED,
    ]);

    $this->service->update($session, ['scheduled_date' => now()->subWeek()->toDateString()]);
})->throws(ValidationException::class);

it('allows rescheduling a completed session to a past date', function () {
    $session = WorkoutSession::factory()->create([
        'user_id' => $this->user->id,
        'status' => WorkoutSession::STATUS_COMPLETED,
        'completed_at' => now(),
    ]);
    $pastDate = now()->subWeek()->toDateString();

    $updated = $this->service->update($session, ['scheduled_date' => $pastDate]);

    expect($updated->scheduled_date->toDateString())->toBe($pastDate);
});

it('allows rescheduling a planned session to today', function () {
    $session = WorkoutSession::factory()->create([
        'user_id' => $this->user->id,
        'status' => WorkoutSession::STATUS_PLANNED,
    ]);

    $updated = $this->service->update($session, ['scheduled_date' => now()->toDateString()]);

    expect($updated->scheduled_date->toDateString())->toBe(now()->toDateString());
});

it('paginates only sessions for the given user ordered by scheduled_date', function () {
    $otherUser = User::factory()->create();
    WorkoutSession::factory()->create(['user_id' => $this->user->id, 'scheduled_date' => now()->addDays(5)]);
    WorkoutSession::factory()->create(['user_id' => $this->user->id, 'scheduled_date' => now()->addDay()]);
    WorkoutSession::factory()->create(['user_id' => $otherUser->id]);

    $result = $this->service->paginate($this->user);

    expect($result->total())->toBe(2)
        ->and($result->items()[0]->scheduled_date->lessThanOrEqualTo($result->items()[1]->scheduled_date))->toBeTrue();
});

it('filters paginated sessions by status', function () {
    WorkoutSession::factory()->create(['user_id' => $this->user->id, 'status' => WorkoutSession::STATUS_PLANNED]);
    WorkoutSession::factory()->completed()->create(['user_id' => $this->user->id]);

    $result = $this->service->paginate($this->user, status: WorkoutSession::STATUS_COMPLETED);

    expect($result->total())->toBe(1);
});

it('finds a session scoped to the given user', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->user->id]);

    $found = $this->service->find($this->user, $session->id);

    expect($found->id)->toBe($session->id);
});

it('throws when finding a session belonging to another user', function () {
    $otherUser = User::factory()->create();
    $session = WorkoutSession::factory()->create(['user_id' => $otherUser->id]);

    $this->service->find($this->user, $session->id);
})->throws(ModelNotFoundException::class);

it('deletes a session', function () {
    $session = WorkoutSession::factory()->create(['user_id' => $this->user->id]);

    $this->service->delete($session);

    expect(WorkoutSession::find($session->id))->toBeNull();
});
