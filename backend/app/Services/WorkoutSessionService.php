<?php

namespace App\Services;

use App\Models\User;
use App\Models\WorkoutSession;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Carbon;
use Illuminate\Validation\ValidationException;

class WorkoutSessionService
{
    public function paginate(User $user, ?string $status = null, int $perPage = 15): LengthAwarePaginator
    {
        return WorkoutSession::query()
            ->forUser($user->id)
            ->status($status)
            ->with('program')
            ->orderBy('scheduled_date')
            ->paginate($perPage);
    }

    public function find(User $user, int $id): WorkoutSession
    {
        return WorkoutSession::forUser($user->id)
            ->with('program')
            ->findOrFail($id);
    }

    public function create(User $user, array $data): WorkoutSession
    {
        return WorkoutSession::create([
            'user_id' => $user->id,
            'program_id' => $data['program_id'] ?? null,
            'scheduled_date' => $data['scheduled_date'],
            'scheduled_time' => $data['scheduled_time'] ?? null,
            'status' => $data['status'] ?? WorkoutSession::STATUS_PLANNED,
        ])->load('program');
    }

    public function update(WorkoutSession $workoutSession, array $data): WorkoutSession
    {
        if (isset($data['status']) && $data['status'] === WorkoutSession::STATUS_COMPLETED
            && ! isset($data['completed_at'])) {
            $data['completed_at'] = now();
        }

        if (isset($data['scheduled_date'])) {
            $newDate = Carbon::parse($data['scheduled_date']);

            if ($workoutSession->status === WorkoutSession::STATUS_PLANNED && $newDate->isPast() && ! $newDate->isToday()) {
                throw ValidationException::withMessages([
                    'scheduled_date' => 'Cannot reschedule a planned session to a past date.',
                ]);
            }
        }

        $workoutSession->update($data);

        return $workoutSession->fresh('program');
    }

    public function delete(WorkoutSession $workoutSession): void
    {
        $workoutSession->delete();
    }
}
