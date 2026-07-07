<?php

use App\Models\User;
use App\Models\WorkoutSession;
use App\Policies\WorkoutSessionPolicy;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->policy = new WorkoutSessionPolicy;
    $this->owner = User::factory()->create();
    $this->stranger = User::factory()->create();
    $this->session = WorkoutSession::factory()->create(['user_id' => $this->owner->id]);
});

it('allows any authenticated user to view the list and create sessions', function () {
    expect($this->policy->viewAny($this->stranger))->toBeTrue()
        ->and($this->policy->create($this->stranger))->toBeTrue();
});

it('only allows the owner to view, update, and delete a specific session', function () {
    expect($this->policy->view($this->owner, $this->session))->toBeTrue()
        ->and($this->policy->update($this->owner, $this->session))->toBeTrue()
        ->and($this->policy->delete($this->owner, $this->session))->toBeTrue()
        ->and($this->policy->view($this->stranger, $this->session))->toBeFalse()
        ->and($this->policy->update($this->stranger, $this->session))->toBeFalse()
        ->and($this->policy->delete($this->stranger, $this->session))->toBeFalse();
});
